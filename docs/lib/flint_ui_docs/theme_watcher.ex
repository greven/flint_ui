defmodule FlintUIDocs.ThemeWatcher do
  @moduledoc """
  Dev-only watcher that refreshes the docs' theme copy when the library's theme
  templates change.

  The library lives in a sibling project, so its `priv/templates` are outside the
  docs' asset pipeline. Watching them here and rewriting `docs/assets/css/flint.css`
  lets the Tailwind watcher rebuild the stylesheet without a server restart.
  """

  use GenServer

  @templates Path.expand("../../../priv/templates", __DIR__)

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, watcher} = FileSystem.start_link(dirs: [@templates])
    FileSystem.subscribe(watcher)
    {:ok, %{watcher: watcher}}
  end

  @impl true
  def handle_info({:file_event, watcher, {_path, _events}}, %{watcher: watcher} = state) do
    FlintUIDocs.Theme.write!()
    {:noreply, state}
  end

  def handle_info({:file_event, watcher, :stop}, %{watcher: watcher} = state) do
    FileSystem.subscribe(watcher)
    {:noreply, state}
  end

  def handle_info(_message, state), do: {:noreply, state}
end
