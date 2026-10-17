defmodule FlintUIDocsWeb.ComponentDocs.Group do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :group

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet

  @impl true
  def controls do
    [
      %{key: :orientation, type: :select, default: "horizontal", label: "Orientation"},
      %{key: :variant, type: :select, default: "attached", label: "Variant"},
      %{key: :size, type: :select, default: "md", label: "Size"}
    ]
  end

  @impl true
  def structure do
    """
    <.group>
      <.button>Copy</.button>
      <.button>Paste</.button>
    </.group>

    <.group variant="framed">
      <.toggle aria-label="Bold">Bold</.toggle>
      <.toggle aria-label="Italic">Italic</.toggle>
    </.group>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :orientation,
        title: "Orientation",
        layer: :base,
        body: """
        `orientation` lays the children out in a row or a column. It also
        reports itself to assistive technology, so a group exposed with a role
        announces the right arrow-key expectation.
        """,
        code: """
        <div class="flex flex-wrap items-start gap-4">
          <.group orientation="horizontal">
            <.button>Copy</.button>
            <.button>Paste</.button>
          </.group>
          <.group orientation="vertical">
            <.button>Copy</.button>
            <.button>Paste</.button>
          </.group>
        </div>
        """
      },
      %{
        id: :label,
        title: "Accessible name",
        layer: :base,
        body: """
        A group has no implicit role. Pass `label` to expose it as a named
        `group`, or set `role="toolbar"` yourself when the children form a
        toolbar.
        """,
        code: """
        <.group label="Text formatting">
          <.toggle aria-label="Bold">Bold</.toggle>
          <.toggle aria-label="Italic">Italic</.toggle>
        </.group>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets. `attached` collapses the children
        into one block; `framed` wraps them in a padded, bordered shell. The
        theme is child-agnostic, so the same variant works for any controls.
        """,
        code: """
        <div class="flex flex-col items-start gap-4">
          <.group variant="attached">
            <.button variant="outline">Left</.button>
            <.button variant="outline">Center</.button>
            <.button variant="outline">Right</.button>
          </.group>
          <.group variant="framed">
            <.toggle>Day</.toggle>
            <.toggle>Week</.toggle>
            <.toggle>Month</.toggle>
          </.group>
        </div>
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        body: """
        `size` sets the group spacing and cascades onto the child controls, so
        the whole unit stays aligned from one attribute.
        """,
        code: """
        <div class="flex flex-col items-start gap-4">
          <.group :for={size <- ~w(xs sm md lg xl)} size={size} variant="framed">
            <.toggle>Details</.toggle>
            <.toggle>History</.toggle>
          </.group>
        </div>
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :toolbar,
        title: "Formatting toolbar",
        description: "A framed group of icon toggles.",
        code: """
        <.group variant="framed">
          <.toggle variant="solid" aria-label="Bold" pressed>
            <.icon name="lucide-bold" />
          </.toggle>
          <.toggle variant="solid" aria-label="Italic">
            <.icon name="lucide-italic" />
          </.toggle>
          <.toggle variant="solid" aria-label="Underline">
            <.icon name="lucide-underline" />
          </.toggle>
        </.group>
        """
      },
      %{
        id: :button_group,
        title: "Button group",
        description: "Buttons attached into a single control.",
        code: """
        <.group variant="attached">
          <.button variant="outline">Left</.button>
          <.button variant="outline">Center</.button>
          <.button variant="outline">Right</.button>
        </.group>
        """
      },
      %{
        id: :segmented,
        title: "Segmented control",
        description:
          "Toggles attached into a single-select control; the selection is yours to own.",
        code: """
        <.group variant="attached">
          <.toggle variant="subtle" pressed aria-label="Day">Day</.toggle>
          <.toggle variant="subtle" aria-label="Week">Week</.toggle>
          <.toggle variant="subtle" aria-label="Month">Month</.toggle>
        </.group>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The group renders a single root container and lays out whatever children
      you give it. It has no inner parts of its own; the joining geometry is
      applied to its direct children by the theme.
      """,
      nodes: [
        %{
          tag: "div",
          selector: ~s([data-element="group"][data-part="root"]),
          hooks: ["data-variant", "data-size", "data-orientation"],
          attributes: ["class", "as", "role", "aria-label"],
          children: []
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The group ships layout, not appearance. The headless base renders a single
      container; the styled layer keys on `data-variant` to join or frame the
      children, and on `data-orientation` to flip the axis. Grouped controls also
      suppress the button press nudge, so a row of buttons does not jitter when
      clicked.
      """,
      snippets: [
        %{
          title: "Attached",
          code: """
          [data-element="group"][data-variant="attached"] > * + * {
            border-inline-start-width: 0;
          }

          [data-element="group"][data-variant="attached"]
            > :first-child:not(:last-child) {
            border-start-end-radius: 0;
            border-end-end-radius: 0;
          }
          """
        },
        %{
          title: "Framed",
          code: """
          [data-element="group"][data-size="md"] {
            --fl-group-gap: calc(var(--fl-spacing) * 0.75);
            --fl-group-padding: calc(var(--fl-spacing) * 0.75);
          }

          [data-element="group"][data-variant="framed"] {
            padding: var(--fl-group-padding);
            border: 1px solid var(--fl-color-border);
            border-radius: var(--fl-radius-lg);
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.group
      orientation={@props.orientation}
      variant={@props.variant}
      size={@props.size}
    >
      <Components.button variant="outline">Copy</Components.button>
      <Components.button variant="outline">Paste</Components.button>
    </Components.group>
    """
  end

  def render_playground(assigns) do
    ~H"""
    <.group orientation={@props.orientation}>
      <.button>Copy</.button>
      <.button>Paste</.button>
    </.group>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(
      ".group",
      [
        Snippet.attr("orientation", props.orientation, "horizontal"),
        Snippet.attr("variant", props.variant, "attached"),
        Snippet.attr("size", props.size, "md")
      ],
      """
      <.button variant="outline">Copy</.button>
      <.button variant="outline">Paste</.button>
      """
      |> String.trim()
    )
  end

  def render_code(%{props: props}) do
    Snippet.tag(
      ".group",
      [Snippet.attr("orientation", props.orientation, "horizontal")],
      """
      <.button>Copy</.button>
      <.button>Paste</.button>
      """
      |> String.trim()
    )
  end

  @impl true
  def render_usage(%{block: :orientation} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-start gap-4">
      <.group orientation="horizontal">
        <.button>Copy</.button>
        <.button>Paste</.button>
      </.group>
      <.group orientation="vertical">
        <.button>Copy</.button>
        <.button>Paste</.button>
      </.group>
    </div>
    """
  end

  def render_usage(%{block: :label} = assigns) do
    ~H"""
    <.group label="Text formatting">
      <.toggle aria-label="Bold">Bold</.toggle>
      <.toggle aria-label="Italic">Italic</.toggle>
    </.group>
    """
  end

  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <Components.group variant="attached">
        <Components.button variant="outline">Left</Components.button>
        <Components.button variant="outline">Center</Components.button>
        <Components.button variant="outline">Right</Components.button>
      </Components.group>
      <Components.group variant="framed">
        <Components.toggle>Day</Components.toggle>
        <Components.toggle>Week</Components.toggle>
        <Components.toggle>Month</Components.toggle>
      </Components.group>
    </div>
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-4">
      <Components.group :for={size <- ~w(xs sm md lg xl)} size={size} variant="framed">
        <Components.toggle>Details</Components.toggle>
        <Components.toggle>History</Components.toggle>
      </Components.group>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :toolbar} = assigns) do
    ~H"""
    <Components.group variant="framed">
      <Components.toggle variant="solid" aria-label="Bold" pressed>
        <Components.icon name="lucide-bold" />
      </Components.toggle>
      <Components.toggle variant="solid" aria-label="Italic">
        <Components.icon name="lucide-italic" />
      </Components.toggle>
      <Components.toggle variant="solid" aria-label="Underline">
        <Components.icon name="lucide-underline" />
      </Components.toggle>
    </Components.group>
    """
  end

  def render_block(%{block: :button_group} = assigns) do
    ~H"""
    <Components.group variant="attached">
      <Components.button variant="outline">Left</Components.button>
      <Components.button variant="outline">Center</Components.button>
      <Components.button variant="outline">Right</Components.button>
    </Components.group>
    """
  end

  def render_block(%{block: :segmented} = assigns) do
    ~H"""
    <Components.group variant="attached">
      <Components.toggle variant="subtle" pressed aria-label="Day">Day</Components.toggle>
      <Components.toggle variant="subtle" aria-label="Week">Week</Components.toggle>
      <Components.toggle variant="subtle" aria-label="Month">Month</Components.toggle>
    </Components.group>
    """
  end
end
