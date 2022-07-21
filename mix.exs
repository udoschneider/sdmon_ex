defmodule SdMon.MixProject do
  use Mix.Project

  def project do
    [
      app: :sdmon_ex,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: package(),
      make_targets: ["all"],
      make_clean: ["clean"],
      compilers: [:elixir_make | Mix.compilers()],
      deps: deps()
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
      {:elixir_make, "~> 0.6.3"},
      {:jason, "~> 1.3"},
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "c_src/*.[ch]", "Makefile", "LICENSE", "CHANGELOG"],
    ]
  end

end
