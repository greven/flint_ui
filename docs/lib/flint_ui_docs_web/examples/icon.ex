defmodule FlintUIDocsWeb.Examples.Icon do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example, component: :icon

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Examples.Snippet

  @impl true
  def controls do
    [
      %{key: :name, type: :string, default: "lucide-house", label: "Icon (lucide-…)"},
      %{key: :label, type: :string, default: "", label: "Label (accessible name)"}
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
  def usage do
    [
      %{
        id: :size,
        title: "Sizing and color",
        body: """
        The `name` is applied verbatim as a CSS class. FlintUI ships no icon
        assets, so the host provides them — the docs use a Tailwind plugin that
        exposes `lucide-*`. Size and color come from `class`.
        """,
        code: """
        <.icon name="lucide-x" class="size-5" />
        <.icon name="lucide-circle-alert" class="size-5 text-red-500" />
        """
      },
      %{
        id: :label,
        title: "Accessible name",
        body: """
        Icons are decorative and hidden from assistive technology by default.
        When an icon conveys meaning on its own, pass `label` to expose it as a
        labeled image.
        """,
        code: """
        <.icon name="lucide-circle-alert" label="Error" />
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :sizes,
        title: "Sizes",
        description: "Icons scale with a `size-*` utility.",
        code: """
        <div class="flex items-end gap-6">
          <.icon name="lucide-house" class="size-4" />
          <.icon name="lucide-house" class="size-6" />
          <.icon name="lucide-house" class="size-8" />
        </div>
        """
      },
      %{
        id: :colors,
        title: "Colors",
        description: "Inherit a color from `class`.",
        code: """
        <div class="flex items-center gap-6">
          <.icon name="lucide-circle-check" class="size-6 text-green-600" />
          <.icon name="lucide-circle-alert" class="size-6 text-amber-500" />
          <.icon name="lucide-circle-x" class="size-6 text-red-600" />
        </div>
        """
      },
      %{
        id: :in_button,
        title: "In a button",
        description: "Pair an icon with a label.",
        code: """
        <.button class="inline-flex items-center gap-2 rounded-md bg-zinc-900 px-4 py-2 text-sm font-medium text-white">
          <.icon name="lucide-download" class="size-4" /> Download
        </.button>
        """
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      Icons are styled entirely through `class`. The icon asset comes from your
      icon set; FlintUI only sets the size and lets the color inherit.
      """,
      snippets: [
        %{
          title: "Size",
          code: """
          [data-element="icon"][data-size="md"] {
            width: 1.25rem;
            height: 1.25rem;
          }
          """
        },
        %{
          title: "Color",
          code: """
          [data-element="icon"] {
            color: var(--fl-color-foreground);
          }
          """
        }
      ]
    }
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

  @impl true
  def render_code(%{props: props}) do
    Snippet.component(
      ".icon",
      [
        Snippet.attr("name", props.name),
        Snippet.attr("label", blank_to_nil(props.label))
      ]
    )
  end

  @impl true
  def render_block(%{block: :sizes} = assigns) do
    ~H"""
    <div class="flex items-end gap-6 text-zinc-900 dark:text-zinc-100">
      <.icon name="lucide-house" class="size-4" />
      <.icon name="lucide-house" class="size-6" />
      <.icon name="lucide-house" class="size-8" />
    </div>
    """
  end

  def render_block(%{block: :colors} = assigns) do
    ~H"""
    <div class="flex items-center gap-6">
      <.icon name="lucide-circle-check" class="size-6 text-green-600" />
      <.icon name="lucide-circle-alert" class="size-6 text-amber-500" />
      <.icon name="lucide-circle-x" class="size-6 text-red-600" />
    </div>
    """
  end

  def render_block(%{block: :in_button} = assigns) do
    ~H"""
    <.button class="inline-flex items-center gap-2 rounded-md bg-zinc-900 px-4 py-2 text-sm font-medium text-white dark:bg-white dark:text-zinc-900">
      <.icon name="lucide-download" class="size-4" /> Download
    </.button>
    """
  end

  @impl true
  def styled do
    %{
      description:
        "The generated wrapper adds a `size` prop mapped onto the `data-size` hook; the icon asset itself still comes from your icon set.",
      code: """
      <.icon name="lucide-house" size="md" />
      <.icon name="lucide-settings" size="lg" />
      """
    }
  end

  @impl true
  def render_styled(assigns) do
    ~H"""
    <div class="flex items-center gap-6 text-zinc-900 dark:text-zinc-100">
      <Components.icon name="lucide-house" size="sm" />
      <Components.icon name="lucide-settings" size="md" />
      <Components.icon name="lucide-bell" size="lg" />
    </div>
    """
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
