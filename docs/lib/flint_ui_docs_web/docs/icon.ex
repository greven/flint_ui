defmodule FlintUIDocsWeb.Docs.Icon do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :icon

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def controls do
    [
      %{key: :name, type: :string, default: "lucide-house", label: "Icon (lucide-…)"},
      %{key: :label, type: :string, default: "", label: "Label (accessible name)"},
      %{key: :size, type: :select, default: "md", label: "Size"}
    ]
  end

  @impl true
  def structure do
    """
    <FlintUI.icon name="lucide-house" class="size-4" />

    <FlintUI.icon name="lucide-x" class="size-5" />

    <FlintUI.icon name="lucide-circle-alert" label="Error" class="size-5 text-red-500" />
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :name,
        title: "Icon name",
        layer: :base,
        covers: [:name],
        body: """
        `name` is applied verbatim as a CSS class. FlintUI ships no icon assets,
        so the host provides them — the docs use a Tailwind plugin that exposes
        `lucide-*`.
        """,
        code: """
        <FlintUI.icon name="lucide-house" class="size-5" />
        """
      },
      %{
        id: :class,
        title: "Sizing and color",
        layer: :base,
        covers: [:class],
        body: """
        The base icon ships no size or color of its own. Size and color come
        from `class`, so the component works with any icon set and any styling
        approach.
        """,
        code: """
        <div class="flex items-center gap-6">
          <FlintUI.icon name="lucide-x" class="size-5" />
          <FlintUI.icon name="lucide-circle-alert" class="size-5 text-red-500" />
        </div>
        """
      },
      %{
        id: :label,
        title: "Accessible name",
        layer: :base,
        covers: [:label],
        body: """
        Icons are decorative and hidden from assistive technology by default.
        When an icon conveys meaning on its own, pass `label` to expose it as a
        labeled image.
        """,
        code: """
        <FlintUI.icon name="lucide-circle-alert" label="Error" class="size-5 text-red-500" />
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        covers: [:size],
        body: """
        The generated component adds a `size` attribute mapped onto the
        `data-size` hook the theme targets. The theme publishes the box as
        `--fl-icon-size`, which icon sets can follow.
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
        description: "Icons scale with a `size-*` utility."
      },
      %{
        id: :colors,
        title: "Colors",
        description: "Inherit a color from `class`."
      },
      %{
        id: :in_button,
        title: "In a button",
        description: "A button sizes and tints the icon it wraps."
      },
      %{
        id: :base_decorative,
        title: "Decorative icon",
        layer: :base,
        description:
          "A decorative icon sits next to a text label and is hidden from assistive technology.",
        code: """
        <p class="flex items-center gap-2">
          <FlintUI.icon name="lucide-circle-check" class="size-5 text-green-600" />
          Saved
        </p>
        """
      },
      %{
        id: :base_labeled,
        title: "Labeled status",
        layer: :base,
        description: "When the icon carries the meaning, give it a label.",
        code: """
        <FlintUI.icon name="lucide-circle-alert" label="Warning" class="size-5 text-amber-500" />
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The icon renders a single `<span>` with the icon class applied. It is
      decorative by default, or exposed as a labeled image when `label` is set.
      """,
      nodes: [
        %{
          tag: "span",
          selector: ~s([data-element="icon"][data-part="root"]),
          hooks: ["class"],
          attributes: ["aria-hidden", "role", "aria-label"],
          children: []
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The base icon renders a `<span>` whose `name` is a CSS class. Size and
      color come from `class` and `currentColor`; FlintUI does not ship the icon
      asset. The generated styled component's `data-size` contract is documented
      on the CSS tab.
      """,
      snippets: [
        %{
          title: "Size",
          code: """
          [data-element="icon"] {
            display: inline-block;
            width: 1rem;
            height: 1rem;
          }
          """
        },
        %{
          title: "Color",
          code: """
          [data-element="icon"] {
            color: currentColor;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_main(assigns) do
    ~H"""
    <.preview
      :let={props}
      id={@id}
      name={:icon}
      state={@state}
      controls={[:name, :label, :size]}
      code={&main_code/1}
    >
      <Components.icon name={props.name} label={blank_to_nil(props.label)} size={props.size} />
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.component(
      ".icon",
      [
        Snippet.attr("name", props.name),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("label", blank_to_nil(props.label))
      ]
    )
  end

  @impl true
  def render_section(%{kind: :usage, block: :size} = assigns) do
    ~H"""
    <.preview id={@id} name={:icon} state={@state} code={code(:size)}>
      <div class="flex items-center gap-6">
        <Components.icon :for={size <- ~w(sm md lg)} name="lucide-house" size={size} />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :sizes} = assigns) do
    ~H"""
    <.preview id={@id} name={:icon} state={@state} code={code(:sizes)}>
      <div class="flex items-end gap-6">
        <.icon name="lucide-house" class="size-4" />
        <.icon name="lucide-house" class="size-6" />
        <.icon name="lucide-house" class="size-8" />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :colors} = assigns) do
    ~H"""
    <.preview id={@id} name={:icon} state={@state} code={code(:colors)}>
      <div class="flex items-center gap-6">
        <.icon name="lucide-circle-check" class="size-6 text-green-600" />
        <.icon name="lucide-circle-alert" class="size-6 text-amber-500" />
        <.icon name="lucide-circle-x" class="size-6 text-red-600" />
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :in_button} = assigns) do
    ~H"""
    <.preview id={@id} name={:icon} state={@state} code={code(:in_button)}>
      <Components.button variant="solid">
        <Components.icon name="lucide-download" /> Download
      </Components.button>
    </.preview>
    """
  end

  defp code(:size) do
    ~S"""
    <div class="flex items-center gap-6">
      <.icon :for={size <- ~w(sm md lg)} name="lucide-house" size={size} />
    </div>
    """
  end

  defp code(:sizes) do
    ~S"""
    <div class="flex items-end gap-6">
      <.icon name="lucide-house" class="size-4" />
      <.icon name="lucide-house" class="size-6" />
      <.icon name="lucide-house" class="size-8" />
    </div>
    """
  end

  defp code(:colors) do
    ~S"""
    <div class="flex items-center gap-6">
      <.icon name="lucide-circle-check" class="size-6 text-green-600" />
      <.icon name="lucide-circle-alert" class="size-6 text-amber-500" />
      <.icon name="lucide-circle-x" class="size-6 text-red-600" />
    </div>
    """
  end

  defp code(:in_button) do
    ~S"""
    <.button variant="solid">
      <.icon name="lucide-download" /> Download
    </.button>
    """
  end

  @impl true
  def css do
    %{
      body: """
      The styled icon maps `size` to `data-size` and publishes the box as
      `--fl-icon-size`. The icon set itself comes from the host. The docs' Lucide
      plugin reads the variable, so generated buttons and toggles can size their
      icon children.
      """,
      snippets: [
        %{
          title: "Follow the control size",
          body: "An icon that reads `--fl-icon-size` follows the surrounding control.",
          code: """
          [data-element="icon"] {
            width: var(--fl-icon-size, 1.25rem);
            height: var(--fl-icon-size, 1.25rem);
          }
          """
        },
        %{
          title: "Recolor one icon",
          body: "Color is inherited, so set it on the instance or its parent.",
          code: """
          .status-icon {
            color: var(--fl-color-success-text);
          }
          """
        }
      ]
    }
  end

  defp blank_to_nil(nil), do: nil
  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value
end
