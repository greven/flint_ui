defmodule FlintUIDocsWeb.Examples.Toggle do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example

  @impl true
  def controls do
    [
      %{key: :pressed, type: :boolean, default: false, label: "Pressed"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"}
    ]
  end

  @impl true
  def variants do
    base = defaults()

    [
      {"Off", base},
      {"On", %{base | pressed: true}},
      {"Disabled", %{base | disabled: true}},
      {"Pressed + disabled", %{base | pressed: true, disabled: true}}
    ]
  end

  @impl true
  def structure do
    """
    <.toggle>Bold</.toggle>

    <.toggle pressed>
      <.icon name="lucide-bold" class="size-4" /> Bold
    </.toggle>

    <.toggle on_click={JS.push("toggle-italic")}>
      <.icon name="lucide-italic" class="size-4" /> Italic
    </.toggle>
    """
    |> String.trim()
  end

  @impl true
  def render_example(assigns) do
    ~H"""
    <.toggle
      pressed={@props.pressed}
      disabled={@props.disabled}
      class={[
        "inline-flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors",
        "text-zinc-600 hover:bg-zinc-100",
        "data-[state=on]:bg-zinc-900 data-[state=on]:text-white",
        "dark:text-zinc-400 dark:hover:bg-zinc-800",
        "dark:data-[state=on]:bg-white dark:data-[state=on]:text-zinc-900",
        "disabled:pointer-events-none disabled:opacity-50"
      ]}
    >
      <.icon name="lucide-bold" class="size-4" /> Bold
    </.toggle>
    """
  end
end
