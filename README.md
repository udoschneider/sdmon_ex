# SdMon

`SdMon` is a simple Elixir wrapper around https://github.com/Ognian/sdmon which provides health monitoring for some industrial grade SD Cards.
It's currently based on upstream master commit
[`8a70aed`](https://github.com/Ognian/sdmon/tree/8a70aed673f4b319972b3a2cfac043e3b171653a)
(2026-07-21), which is newer than the latest release v0.9.0. This version
supports SanDisk, Longsys, Innodisk, ADATA, Transcend, Micron and Swissbit
cards, plus a generic "2step" method, and emits proper JSON for all of them.

The bundled sources in `c_src/` are unmodified upstream files except for one
patch to `sdmon.c`, marked `sdmon_ex patch`: it fixes `is_data_valid()`
rejecting valid responses that contain no `0x00` byte.


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

By default all query methods are tried in turn. A specific one can be chosen
with the `:method` option (`:auto`, `:sandisk`, `:adata`, `:transcend`,
`:micron`, `:swissbit`, `:"2step"`, `:innodisk`). `add_time: true` adds a delay
between the two calls of the `:"2step"` method, which helps with some cards:

```elixir
SdMon.run("/dev/mmcblk0", method: :"2step", add_time: true)
```

The fields returned depend on the card vendor; see the
[sdmon documentation](https://github.com/Ognian/sdmon) for details.

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sdmon_ex>.

## License

The Elixir wrapper is released under the MIT license (see `LICENSE`).

The bundled [sdmon](https://github.com/Ognian/sdmon) sources in `c_src/` keep
their own licenses: `sdmon.c` is (c) OGI-IT, Ognian Tschakalov and
contributors under the GNU GPL v2 (see `c_src/LICENSE.sdmon`), and
`json.[ch]` / `json-builder.[ch]` are from
[json-parser](https://github.com/json-parser/json-parser) under the
BSD-2-Clause license (see their file headers). The compiled `sdmon` binary is
therefore distributed under the GPL v2.
