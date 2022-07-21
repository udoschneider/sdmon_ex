# SdMon

`SdMon` is a simple Elixir wrapper around https://github.com/Ognian/sdmon which provides health monitoring for some industrial grade SD Cards.
It's currently based on version [v0.4.1](https://github.com/Ognian/sdmon/tree/v0.4.1) of [sdmon.c](https://raw.githubusercontent.com/Ognian/sdmon/v0.4.1/src/sdmon.c).



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

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/sdmon_ex>.

