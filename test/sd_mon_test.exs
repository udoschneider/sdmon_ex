defmodule SdMonTest do
  use ExUnit.Case, async: true

  @moduletag :tmp_dir

  test "sdmon binary is built" do
    assert File.exists?(SdMon.sdmon_path())
  end

  test "returns an error for a device that does not exist" do
    device = "/dev/sdmon-ex-does-not-exist"

    assert {:error, %{"device" => ^device, "error" => "device open failed" <> _} = data} =
             SdMon.run(device)

    assert data["version"] =~ ~r/^\d+\.\d+\.\d+/
    assert data["method"] == "auto"
  end

  test "returns an error for a device that does not support CMD56" do
    assert {:error, %{"device" => "/dev/null", "error2" => _}} = SdMon.run("/dev/null")
  end

  test "passes method and add_time options" do
    assert {:error, %{"method" => "2step", "addTime" => true}} =
             SdMon.run("/dev/null", method: :"2step", add_time: true)
  end

  test "rejects invalid options" do
    assert_raise ArgumentError, ~r/invalid :method/, fn ->
      SdMon.run("/dev/null", method: :nope)
    end

    assert_raise ArgumentError, fn -> SdMon.run("/dev/null", unknown: 1) end
  end

  # Mocked CMD56 responses (via `sdmon -i`): each vendor branch must produce
  # valid JSON, including when the card returns arbitrary bytes.
  @vendors [
    {"sandisk", <<0x44, 0x53>>, "SanDisk"},
    {"sandisk", <<0x70, 0x58>>, "Longsys"},
    {"innodisk", <<0x4C, 0x58>>, "Innodisk"},
    {"adata", <<0x09, 0x41>>, "Adata"},
    {"transcend", <<0x54, 0x72>>, "Transcend"},
    {"micron", <<0x4D, 0x45>>, "Micron"},
    {"swissbit", <<0x53, 0x77>>, "Swissbit"}
  ]

  for {method, signature, key} <- @vendors do
    test "mocked #{key} response decodes to valid JSON", %{tmp_dir: tmp_dir} do
      for _ <- 1..20 do
        block = unquote(signature) <> :crypto.strong_rand_bytes(510)
        assert {%{"success" => true} = data, 0} = mock(tmp_dir, unquote(method), block)
        assert data[unquote(key)] == true
      end
    end
  end

  test "mocked 2step response decodes to valid JSON", %{tmp_dir: tmp_dir} do
    block = :crypto.strong_rand_bytes(512)
    assert {%{"success" => true, "flashId" => [_ | _]}, 0} = mock(tmp_dir, "2step", block)
  end

  test "decode_output escapes control and non-UTF-8 bytes" do
    assert {:ok, %{"s" => "a\u0001b\u00ffc€"}} =
             SdMon.decode_output(~s({\n  "s": "a\x01b\xffc€"\n}))

    assert {:error, {:invalid_json, "nope"}} = SdMon.decode_output("nope")
  end

  defp mock(tmp_dir, method, block) do
    file = Path.join(tmp_dir, "cmd56.bin")
    File.write!(file, block)

    {output, status} =
      System.cmd(SdMon.sdmon_path(), ["-q", "-m", method, "-i", file, "/dev/null"])

    assert {:ok, data} = SdMon.decode_output(output)
    {data, status}
  end
end
