defmodule Mix.Tasks.Compile.FlintTheme do
  @moduledoc false
  use Mix.Task.Compiler

  @impl true
  def run(_args) do
    case FlintUI.Generator.write_aggregate!() do
      :ok -> {:ok, []}
      :noop -> {:noop, []}
    end
  end
end
