defmodule FlintUIDocsWeb.Examples.Icon do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example

  @impl true
  def controls do
    [
      %{key: :name, type: :string, default: "lucide-house", label: "Icon (lucide-…)"},
      %{key: :label, type: :string, default: "", label: "Label (accessible name)"}
    ]
  end

  @impl true
  def variants do
    base = defaults()

    [
      {"Decorative", base},
      {"Settings", %{base | name: "lucide-settings"}},
      {"Success", %{base | name: "lucide-circle-check"}},
      {"Labeled", %{base | name: "lucide-circle-alert", label: "Error"}}
    ]
  end

  @impl true
  def structure do
    """
    <.icon name="lucide-house" />

    <.icon name="lucide-x" class="size-5" />

    <.icon name="lucide-circle-alert" label="Error" class="size-5 text-red-500" />
    """
    |> String.trim()
  end

  @impl true
  def render_example(assigns) do
    ~H"""
    <.icon
      name={@props.name}
      label={blank_to_nil(@props.label)}
      class="size-6 text-zinc-900 dark:text-zinc-100"
    />
    """
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
