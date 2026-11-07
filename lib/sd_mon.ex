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

  @doc """
  Runs `sdmon` against `device` (e.g. `"/dev/mmcblk0"`) and returns the
  decoded health data.

  Returns `{:ok, data}` if `sdmon` exits successfully, otherwise
  `{:error, reason}` (see `t:reason/0`).

  ## Examples

      SdMon.run("/dev/mmcblk0")
      #=> {:ok, %{"success" => true, "healthStatusPercentUsed" => 1, ...}}

      SdMon.run("/dev/does-not-exist")
      #=> {:error, %{"error" => "device open failed", ...}}
  """
  @spec run(Path.t()) :: {:ok, data()} | {:error, reason()}
  def run(device) when is_binary(device) do
    with {:ok, {output, status}} <- exec(device),
         {:ok, data} <- decode(output) do
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

  defp exec(device) do
    {:ok, System.cmd(sdmon_path(), [device])}
  rescue
    e in ErlangError -> {:error, {:exec_failed, e.original}}
  end

  defp decode(output) do
    case Jason.decode(output) do
      {:ok, data} -> {:ok, data}
      {:error, _} -> {:error, {:invalid_json, output}}
    end
  end
end
