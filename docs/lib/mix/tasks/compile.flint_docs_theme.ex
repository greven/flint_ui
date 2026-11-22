defmodule Mix.Tasks.Compile.FlintDocsTheme do
  @moduledoc false
  use Mix.Task.Compiler

  @impl true
  def run(_args) do
    case FlintUIDocs.Theme.write_all!() do
      :ok -> {:ok, []}
      :noop -> {:noop, []}
    end
  end
end
