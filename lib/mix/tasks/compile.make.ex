defmodule Mix.Tasks.Compile.Make do
  use Mix.Task.Compiler

  @moduledoc false
  @recursive true
  @shortdoc "Compile NIF with make"

  def run(_args) do
    Mix.shell().cmd("make ex_opencc", quiet: false)
    :ok
  end

  def clean(_args) do
    Mix.shell().cmd("make clean", quiet: false)
    :ok
  end
end
