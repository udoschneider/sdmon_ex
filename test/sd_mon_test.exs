defmodule SdMonTest do
  use ExUnit.Case, async: true

  test "sdmon binary is built" do
    assert File.exists?(SdMon.sdmon_path())
  end

  test "returns an error for a device that does not exist" do
    device = "/dev/sdmon-ex-does-not-exist"

    assert {:error, %{"device" => ^device, "error" => "device open failed"} = data} =
             SdMon.run(device)

    assert data["version"] != ""
  end

  test "returns an error for a device that does not support CMD56" do
    assert {:error, %{"device" => "/dev/null", "error2" => _}} = SdMon.run("/dev/null")
  end
end
