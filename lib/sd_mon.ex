defmodule SdMon do
  @moduledoc """
  Documentation for `SdMon`.
  """

  def run(device) do
    with {json, return} <- System.cmd(sdmon_path(), [device]),
         {:ok, data} <- Jason.decode(json) do
      case return do
        0 -> {:ok, data}
        _ -> {:error, data}
      end
    else
      _ -> :error
    end
  end

  defp sdmon_path() do
    :sdmon_ex
    |> Application.app_dir()
    |> Path.join("priv")
    |> Path.join("sdmon")
  end
end
