defmodule FlintUIDocs.ThemeWatcher do
  @moduledoc """
  Dev-only watcher that refreshes the docs' theme copy when the library's theme
  templates change.

  The library lives in a sibling project, so its `priv/templates` and utility
  source are outside the docs' asset pipeline. Watching them here and rewriting
  the docs' copies lets the Tailwind watcher rebuild the stylesheet without a
  server restart.
  """

  use GenServer

  @templates Path.expand("../../../priv/templates", __DIR__)
  @utilities_source Path.expand("../../../lib/flint_ui/utilities.ex", __DIR__)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, watcher} =
      FileSystem.start_link(dirs: [@templates, Path.dirname(@utilities_source)])

    FileSystem.subscribe(watcher)
    {:ok, %{watcher: watcher}}
  end

  @impl true
  def handle_info({:file_event, watcher, {path, _events}}, %{watcher: watcher} = state) do
    path = to_string(path)

    if String.starts_with?(path, @templates) or path == @utilities_source do
      FlintUIDocs.Theme.write_all!()
    end

    {:noreply, state}
  end

  def handle_info({:file_event, watcher, :stop}, %{watcher: watcher} = state) do
    FileSystem.subscribe(watcher)
    {:noreply, state}
  end

  def handle_info(_message, state), do: {:noreply, state}
end
