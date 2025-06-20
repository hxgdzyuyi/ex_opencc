defmodule ExOpencc.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_opencc,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      compilers: [:make] ++ Mix.compilers(),
      deps: deps(),
      package: package(),
      description: description(),

      # Docs
      name: "ex_opencc",
      source_url: "https://github.com/hxgdzyuyi/ex_opencc",
      docs: &docs/0
    ]
  end

  defp docs do
    [
      main: "readme", # The main page in the docs
      extras: ["README.md"]
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
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true},
    ]
  end

  defp package() do
    [
      name: "ex_opencc",
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* c_src),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/hxgdzyuyi/ex_opencc"}
    ]
  end

  defp description do
    """
    An Elixir wrapper for OpenCC, a library for converting between Traditional Chinese and Simplified Chinese.
    """
  end
end


defmodule Mix.Tasks.Compile.Make do
  def run(_args) do
    Mix.shell().cmd("make ex_opencc", quiet: false)
    :ok
  end
end
