# SdMon

`SdMon` is a simple Elixir wrapper around https://github.com/Ognian/sdmon which provides health monitoring for some industrial grade SD Cards.
It's currently based on version [v0.4.1](https://github.com/Ognian/sdmon/tree/v0.4.1) of [sdmon.c](https://raw.githubusercontent.com/Ognian/sdmon/v0.4.1/src/sdmon.c).


## Requirements

* Linux (the tool uses the `MMC_IOC_CMD` ioctl)
* A C compiler and `make`. The binary is linked statically (`-static`), so a
  static libc (e.g. `glibc-static` / `libc6-dev`) must be available
* Read/write access to the SD card block device (usually root)

## Installation

The package is not available on Hex. So you need to add the `sdmon_ex` GitHub Repo
in your `mix.exs`:

```elixir
def deps do
  [
    {:sdmon_ex, git: "https://github.com/udoschneider/sdmon_ex.git", tag: "v0.1.0"}
  ]
end
```

## Usage

```elixir
iex> SdMon.run("/dev/mmcblk0")
{:ok,
 %{
   "device" => "/dev/mmcblk0",
   "healthStatusPercentUsed" => 1,
   "success" => true,
   ...
 }}
```

`SdMon.run/1` returns:

* `{:ok, data}` - `sdmon` succeeded; `data` is its decoded JSON output
* `{:error, data}` - `sdmon` ran but reported an error (e.g. the device could
  not be opened or does not support `CMD56`); `data` contains the error fields
* `{:error, {:invalid_json, output}}` - `sdmon` output could not be decoded
* `{:error, {:exec_failed, reason}}` - the `sdmon` binary could not be executed

The fields returned depend on the card vendor; see the
[sdmon documentation](https://github.com/Ognian/sdmon) for details.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sdmon_ex>.
