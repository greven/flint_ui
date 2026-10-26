defmodule FlintUIDocsWeb.Docs.Group do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :group

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

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
    <FlintUI.group>
      <FlintUI.button>Copy</FlintUI.button>
      <FlintUI.button>Paste</FlintUI.button>
    </FlintUI.group>

    <FlintUI.group label="Text formatting">
      <FlintUI.toggle aria-label="Bold">Bold</FlintUI.toggle>
      <FlintUI.toggle aria-label="Italic">Italic</FlintUI.toggle>
    </FlintUI.group>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :as,
        title: "Root element",
        layer: :base,
        covers: [:as],
        body: """
        Choose the root element with `as`. The default is a plain `div`; use a
        semantic element when the grouping is part of the page structure.
        """,
        code: """
        <FlintUI.group as="section" label="Text formatting">
          <FlintUI.toggle aria-label="Bold">Bold</FlintUI.toggle>
          <FlintUI.toggle aria-label="Italic">Italic</FlintUI.toggle>
        </FlintUI.group>
        """
      },
      %{
        id: :orientation,
        title: "Orientation",
        layer: :base,
        covers: [:orientation],
        body: """
        `orientation` lays the children out in a row or a column and sets the
        `data-orientation` styling hook. It does not add arrow-key behavior; if
        you pass a role that expects orientation, such as `toolbar`, set
        `aria-orientation` yourself.
        """,
        code: """
        <div class="flex flex-wrap items-start gap-4">
          <FlintUI.group orientation="horizontal">
            <FlintUI.button>Copy</FlintUI.button>
            <FlintUI.button>Paste</FlintUI.button>
          </FlintUI.group>
          <FlintUI.group orientation="vertical">
            <FlintUI.button>Copy</FlintUI.button>
            <FlintUI.button>Paste</FlintUI.button>
          </FlintUI.group>
        </div>
        """
      },
      %{
        id: :label,
        title: "Accessible name",
        layer: :base,
        covers: [:label],
        body: """
        A group has no implicit role. Pass `label` to expose it as a named
        `group`. If you pass `role="toolbar"` yourself, also pass
        `aria-orientation` and provide the arrow-key interaction the role
        expects; roving focus is not implemented yet.
        """,
        code: """
        <FlintUI.group label="Text formatting">
          <FlintUI.toggle aria-label="Bold">Bold</FlintUI.toggle>
          <FlintUI.toggle aria-label="Italic">Italic</FlintUI.toggle>
        </FlintUI.group>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        covers: [:variant],
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets. `attached` collapses the children
        into one block; `framed` wraps them in a padded, bordered shell. The
        theme is child-agnostic, so the same variant works for any controls and
        each child keeps its own button variant.
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        covers: [:size],
        body: """
        `size` sets the group spacing and cascades onto the child controls, so
        the whole unit stays aligned from one attribute.
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :toolbar,
        title: "Formatting group",
        description: "A framed group of icon toggles."
      },
      %{
        id: :with_icons,
        title: "With icons",
        description: "Pair an icon with a label in each control."
      },
      %{
        id: :icon_only,
        title: "Icon only",
        description: "Give each icon-only control an accessible name with `aria-label`."
      },
      %{
        id: :button_group,
        title: "Button group",
        description: "Buttons attached into a single control."
      },
      %{
        id: :segmented,
        title: "Segmented control",
        description:
          "Toggles attached into a single-select control; the selection is yours to own."
      },
      %{
        id: :base_list,
        title: "Grouped controls",
        layer: :base,
        description: "A structural group with a named, accessible container.",
        code: """
        <FlintUI.group label="Clipboard actions">
          <FlintUI.button>Copy</FlintUI.button>
          <FlintUI.button>Paste</FlintUI.button>
        </FlintUI.group>
        """
      },
      %{
        id: :base_vertical,
        title: "Vertical group",
        layer: :base,
        description:
          "Orientation is a layout hook; the grouped controls keep their own semantics.",
        code: """
        <FlintUI.group orientation="vertical" label="View options">
          <FlintUI.button>Details</FlintUI.button>
          <FlintUI.button>History</FlintUI.button>
        </FlintUI.group>
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
      The base group renders a single container with `data-orientation`. It does
      not style its children. The generated styled layer's attached/framed
      geometry and public group variables are documented on the CSS tab.

      Attached children overlap by 1px. Every bordered control paints an
      opaque control surface, so the later child's fill covers the previous
      border at the seam and only one line shows; hover is an in-border overlay,
      keeping that border stable while the fill tints.
      """,
      snippets: [
        %{
          title: "Layout",
          code: """
          [data-element="group"] {
            display: inline-flex;
            gap: 0.5rem;
          }

          [data-element="group"][data-orientation="vertical"] {
            flex-direction: column;
          }
          """
        },
        %{
          title: "Join direct children",
          code: """
          [data-element="group"] > * + * {
            margin-inline-start: -1px;
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
      name={:group}
      state={@state}
      controls={[:orientation, :variant, :size]}
      code={&main_code/1}
    >
      <Components.group
        orientation={props.orientation}
        variant={props.variant}
        size={props.size}
      >
        <Components.button variant="outline">Copy</Components.button>
        <Components.button variant="outline">Paste</Components.button>
      </Components.group>
    </.preview>
    """
  end

  defp main_code(props) do
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

  @impl true
  def render_section(%{kind: :usage, block: :variant} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:variant)}>
      <div class="flex flex-col items-start gap-4">
        <Components.group variant="attached">
          <Components.button variant="outline">Left</Components.button>
          <Components.button variant="outline">Center</Components.button>
          <Components.button variant="outline">Right</Components.button>
        </Components.group>
        <Components.group variant="attached">
          <Components.button variant="dashed">Left</Components.button>
          <Components.button variant="dashed">Center</Components.button>
          <Components.button variant="dashed">Right</Components.button>
        </Components.group>
        <Components.group variant="attached">
          <Components.button variant="ghost">Left</Components.button>
          <Components.button variant="ghost">Center</Components.button>
          <Components.button variant="ghost">Right</Components.button>
        </Components.group>
        <Components.group variant="framed">
          <Components.toggle>Day</Components.toggle>
          <Components.toggle>Week</Components.toggle>
          <Components.toggle>Month</Components.toggle>
        </Components.group>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :size} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:size)}>
      <div class="flex flex-col items-start gap-4">
        <Components.group :for={size <- ~w(xs sm md lg xl)} size={size} variant="framed">
          <Components.toggle>Details</Components.toggle>
          <Components.toggle>History</Components.toggle>
        </Components.group>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :toolbar} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:toolbar)}>
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
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :with_icons} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:with_icons)}>
      <Components.group variant="attached">
        <Components.button variant="outline">
          <Components.icon name="lucide-copy" /> Copy
        </Components.button>
        <Components.button variant="outline">
          <Components.icon name="lucide-scissors" /> Cut
        </Components.button>
        <Components.button variant="outline">
          <Components.icon name="lucide-clipboard-paste" /> Paste
        </Components.button>
      </Components.group>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :icon_only} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:icon_only)}>
      <Components.group variant="attached">
        <Components.button variant="outline" aria-label="Copy">
          <Components.icon name="lucide-copy" />
        </Components.button>
        <Components.button variant="outline" aria-label="Cut">
          <Components.icon name="lucide-scissors" />
        </Components.button>
        <Components.button variant="outline" aria-label="Paste">
          <Components.icon name="lucide-clipboard-paste" />
        </Components.button>
      </Components.group>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :button_group} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:button_group)}>
      <Components.group variant="attached">
        <Components.button variant="outline">Left</Components.button>
        <Components.button variant="outline">Center</Components.button>
        <Components.button variant="outline">Right</Components.button>
      </Components.group>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :segmented} = assigns) do
    ~H"""
    <.preview id={@id} name={:group} state={@state} code={code(:segmented)}>
      <Components.group variant="attached">
        <Components.toggle variant="subtle" pressed aria-label="Day">Day</Components.toggle>
        <Components.toggle variant="subtle" aria-label="Week">Week</Components.toggle>
        <Components.toggle variant="subtle" aria-label="Month">Month</Components.toggle>
      </Components.group>
    </.preview>
    """
  end

  defp code(:variant) do
    ~S"""
    <div class="flex flex-col items-start gap-4">
      <.group variant="attached">
        <.button variant="outline">Left</.button>
        <.button variant="outline">Center</.button>
        <.button variant="outline">Right</.button>
      </.group>
      <.group variant="framed">
        <.toggle>Day</.toggle>
        <.toggle>Week</.toggle>
      </.group>
    </div>
    """
  end

  defp code(:size) do
    ~S"""
    <div class="flex flex-col items-start gap-4">
      <.group :for={size <- ~w(xs sm md lg xl)} size={size} variant="framed">
        <.toggle>Details</.toggle>
        <.toggle>History</.toggle>
      </.group>
    </div>
    """
  end

  defp code(:toolbar) do
    ~S"""
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
  end

  defp code(:with_icons) do
    ~S"""
    <.group variant="attached">
      <.button variant="outline">
        <.icon name="lucide-copy" /> Copy
      </.button>
      <.button variant="outline">
        <.icon name="lucide-scissors" /> Cut
      </.button>
      <.button variant="outline">
        <.icon name="lucide-clipboard-paste" /> Paste
      </.button>
    </.group>
    """
  end

  defp code(:icon_only) do
    ~S"""
    <.group variant="attached">
      <.button variant="outline" aria-label="Copy">
        <.icon name="lucide-copy" />
      </.button>
      <.button variant="outline" aria-label="Cut">
        <.icon name="lucide-scissors" />
      </.button>
      <.button variant="outline" aria-label="Paste">
        <.icon name="lucide-clipboard-paste" />
      </.button>
    </.group>
    """
  end

  defp code(:button_group) do
    ~S"""
    <.group variant="attached">
      <.button variant="outline">Left</.button>
      <.button variant="outline">Center</.button>
      <.button variant="outline">Right</.button>
    </.group>
    """
  end

  defp code(:segmented) do
    ~S"""
    <.group variant="attached">
      <.toggle variant="subtle" pressed aria-label="Day">Day</.toggle>
      <.toggle variant="subtle" aria-label="Week">Week</.toggle>
      <.toggle variant="subtle" aria-label="Month">Month</.toggle>
    </.group>
    """
  end

  @impl true
  def css do
    %{
      body: """
      The styled group adds layout and joining geometry, not control styling.
      It targets direct children with `> *`, so buttons, toggles, and future
      controls can be mixed. `size` cascades onto known controls.
      """,
      snippets: [
        %{
          title: "Loosen an attached group",
          body: "Give a specific group a small gap without changing its variant.",
          code: """
          .spaced-group {
            --fl-group-gap: 0.5rem;
          }
          """
        },
        %{
          title: "Pad a framed group",
          body: "Override the shell padding on one instance.",
          code: """
          .roomy-group {
            --fl-group-padding: 0.75rem;
          }
          """
        }
      ]
    }
  end
end
