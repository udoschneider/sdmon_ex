defmodule SdMon do
  @moduledoc """
  Elixir wrapper around [sdmon](https://github.com/Ognian/sdmon), a tool that
  reads health data from some industrial grade SD cards via the SD `CMD56`
  command.

  The bundled `sdmon` C source is compiled into the application's `priv`
  directory at build time and executed by `run/1`.

  Note that `sdmon` opens the device read/write and issues ioctls, so the
  calling process usually needs root privileges (or write access to the
  block device).
  """

  @typedoc "Decoded JSON output of `sdmon`."
  @type data :: %{optional(String.t()) => term()}

  @typedoc """
  Reason for a failure.

    * `data()` - `sdmon` ran but reported an error (non-zero exit status);
      the map contains the error fields (e.g. `"error"`, `"error2"`)
    * `{:invalid_json, output}` - `sdmon` produced output that could not be decoded
    * `{:exec_failed, reason}` - the `sdmon` binary could not be executed
  """
  @type reason ::
          data()
          | {:invalid_json, String.t()}
          | {:exec_failed, term()}

  @methods ~w(auto sandisk adata transcend micron swissbit 2step innodisk)a

  @typedoc """
  Query method passed to `sdmon -m`. `:auto` tries all vendor-specific methods
  in turn.
  """
  @type method ::
          :auto | :sandisk | :adata | :transcend | :micron | :swissbit | :"2step" | :innodisk

  @typedoc """
  Options for `run/2`.

    * `:method` - query method to use, see `t:method/0` (default: `:auto`)
    * `:add_time` - for the `:"2step"` method, add a delay between the two
      `CMD56` calls; this helps with some cards (default: `false`)
  """
  @type option :: {:method, method()} | {:add_time, boolean()}

  @doc """
  Runs `sdmon` against `device` (e.g. `"/dev/mmcblk0"`) and returns the
  decoded health data.

  Returns `{:ok, data}` if `sdmon` exits successfully, otherwise
  `{:error, reason}` (see `t:reason/0`). See `t:option/0` for options.

  Raises `ArgumentError` for unknown options or methods.

  ## Examples

      SdMon.run("/dev/mmcblk0")
      #=> {:ok, %{"success" => true, "SanDisk" => true, "healthStatusPercentUsed" => 1, ...}}

      SdMon.run("/dev/mmcblk0", method: :swissbit)
      #=> {:ok, %{"success" => true, "Swissbit" => true, ...}}

      SdMon.run("/dev/does-not-exist")
      #=> {:error, %{"error" => "device open failed (No such file or directory)", ...}}
  """
  @spec run(Path.t(), [option()]) :: {:ok, data()} | {:error, reason()}
  def run(device, opts \\ []) when is_binary(device) and is_list(opts) do
    args = build_args(device, opts)

    with {:ok, {output, status}} <- exec(args),
         {:ok, data} <- decode_output(output) do
      case status do
        0 -> {:ok, data}
        _ -> {:error, data}
      end
    end
  end

  @doc """
  Returns the path to the compiled `sdmon` binary.
  """
  @spec sdmon_path() :: Path.t()
  def sdmon_path do
    :sdmon_ex
    |> Application.app_dir("priv")
    |> Path.join("sdmon")
  end

  defp build_args(device, opts) do
    opts = Keyword.validate!(opts, method: :auto, add_time: false)
    method = Keyword.fetch!(opts, :method)

    unless method in @methods do
      raise ArgumentError,
            "invalid :method #{inspect(method)}, expected one of #{inspect(@methods)}"
    end

    # -q silences sdmon's progress messages on stderr; errors are still printed.
    ["-q", "-m", Atom.to_string(method)] ++
      if(Keyword.fetch!(opts, :add_time), do: ["-a"], else: []) ++
      ["--", device]
  end

  defp exec(args) do
    {:ok, System.cmd(sdmon_path(), args)}
  rescue
    e in ErlangError -> {:error, {:exec_failed, e.original}}
  end

  @doc false
  # Public for testing with mocked sdmon output.
  @spec decode_output(binary()) :: {:ok, data()} | {:error, {:invalid_json, binary()}}
  def decode_output(output) do
    case output |> sanitize() |> JSON.decode() do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:error, {:invalid_json, output}}
    end
  end

  # sdmon's JSON serializer copies raw card bytes into strings without escaping
  # control characters or validating UTF-8 (e.g. 0xFF padding in product
  # strings). Outside of strings its output is plain ASCII, so escape every
  # control byte (except the newlines used for formatting) and every byte that
  # is not part of valid UTF-8 as \u00XX (i.e. interpret it as Latin-1).
  defp sanitize(output), do: sanitize(output, [])

  defp sanitize(<<>>, acc), do: acc |> Enum.reverse() |> IO.iodata_to_binary()
  defp sanitize(<<?\n, rest::binary>>, acc), do: sanitize(rest, [?\n | acc])

  defp sanitize(<<c, rest::binary>>, acc) when c < 0x20 or c == 0x7F,
    do: sanitize(rest, [escape(c) | acc])

  defp sanitize(<<c::utf8, rest::binary>>, acc), do: sanitize(rest, [<<c::utf8>> | acc])
  defp sanitize(<<c, rest::binary>>, acc), do: sanitize(rest, [escape(c) | acc])

  defp escape(c), do: "\\u00" <> Base.encode16(<<c>>)
end
