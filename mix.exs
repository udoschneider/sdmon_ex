defmodule SdMon.MixProject do
  use Mix.Project

  def project do
    [
      app: :sdmon_ex,
      version: "0.1.0",
      description: "Elixir wrapper around sdmon, a health monitor for industrial grade SD cards",
      source_url: "https://github.com/udoschneider/sdmon_ex",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      package: package(),
      make_targets: ["all"],
      make_clean: ["clean"],
      compilers: [:elixir_make | Mix.compilers()],
      deps: deps(),
      docs: [main: "readme", extras: ["README.md", "CHANGELOG.md"]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:elixir_make, "~> 0.10"},
      {:jason, "~> 1.3"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      files: [
        "lib",
        "mix.exs",
        "README.md",
        "c_src/*.[ch]",
        "c_src/LICENSE.sdmon",
        "Makefile",
        "LICENSE",
        "CHANGELOG.md"
      ],
      licenses: ["MIT", "GPL-2.0-only", "BSD-2-Clause"],
      links: %{
        "GitHub" => "https://github.com/udoschneider/sdmon_ex",
        "sdmon" => "https://github.com/Ognian/sdmon"
      }
    ]
  end
end
