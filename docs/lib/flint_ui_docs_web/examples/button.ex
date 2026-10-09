defmodule FlintUIDocsWeb.Examples.Button do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example

  @impl true
  def controls do
    [
      %{key: :type, type: :string, default: "button", label: "Type (button/submit/reset)"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :loading, type: :boolean, default: false, label: "Loading"},
      %{key: :href, type: :string, default: "", label: "Href"},
      %{key: :navigate, type: :string, default: "", label: "Navigate"},
      %{key: :patch, type: :string, default: "", label: "Patch"}
    ]
  end

  @impl true
  def variants do
    base = defaults()
    url = "https://hexdocs.pm/phoenix_live_view"

    [
      {"Default", base},
      {"Submit", %{base | type: "submit"}},
      {"Disabled", %{base | disabled: true}},
      {"Loading", %{base | loading: true}},
      {"Link", %{base | href: url}},
      {"Disabled link", %{base | href: url, disabled: true}},
      {"Navigate", %{base | navigate: "/"}}
    ]
  end

  @impl true
  def structure do
    """
    <.button>Save changes</.button>

    <.button type="submit" loading>
      <.loading class="hidden size-4 [[data-loading]_&]:inline-block" />
      Save changes
    </.button>

    <.button navigate={~p"/settings"}>Settings</.button>

    <.button href="https://example.com" target="_blank" rel="noopener">
      Visit
    </.button>
    """
    |> String.trim()
  end

  @impl true
  def render_example(assigns) do
    ~H"""
    <.button
      type={type_or_default(@props.type)}
      disabled={@props.disabled}
      loading={@props.loading}
      href={blank_to_nil(@props.href)}
      navigate={blank_to_nil(@props.navigate)}
      patch={blank_to_nil(@props.patch)}
      class={[
        "inline-flex items-center justify-center gap-2 rounded-md bg-zinc-900 px-4 py-2 text-sm font-medium text-white transition-colors",
        "hover:bg-zinc-700",
        "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-zinc-900 disabled:cursor-not-allowed disabled:opacity-50",
        "dark:bg-white dark:text-zinc-900 dark:hover:bg-zinc-200 dark:focus-visible:outline-white"
      ]}
    >
      <.loading class="hidden size-4 [[data-loading]_&]:inline-block" /> Button
    </.button>
    """
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

  defp type_or_default(type) when type in ~w(button submit reset), do: type
  defp type_or_default(_), do: "button"
end
