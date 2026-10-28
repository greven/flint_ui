defmodule FlintUI.Base.Group do
  @moduledoc """
  Lays out related controls as a single unit.

  A group is structural: it renders a root element and arranges its children, but
  it never changes their behavior and it does not care what they are.
  Buttons, toggles, inputs and selects can all be grouped together.

      <FlintUI.group>
        <FlintUI.button>Copy</FlintUI.button>
        <FlintUI.button>Paste</FlintUI.button>
      </FlintUI.group>

  The generated styled component adds the visual treatment through the `variant`
  hook: `attached` joins the children into one block (buttons that share a seam),
  while `framed` wraps them in a padded, bordered shell. Use `orientation` to
  stack them vertically.

  The group is a plain container and carries no implicit role. Pass `label` to
  expose it as a named `group`. A group that is only visual needs neither.

  ## Accessibility

  A group is a generic container, so it has no implicit role. Give it an
  accessible name with `label` when the grouping is meaningful; that exposes it
  as a `group` landmark. The `orientation` attribute is a styling hook: it sets
  `data-orientation`, but does not add arrow-key behavior. If you pass
  `role="toolbar"` yourself, also pass `aria-orientation` to match the layout
  and provide the keyboard interaction the role expects. Roving-focus support
  for toolbars is not implemented yet.

  ## Keyboard

  The group adds no keyboard interaction of its own. Keyboard behavior comes
  from the grouped controls.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :group,
      type: :action,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "group",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The layout direction, for styling."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("group"),
          description:
            "Set to `\"group\"` when `label` is given, unless a `role` is passed explicitly."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name, present when `label` is set."
        }
      ]
    }
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root:
        %{
          "data-element" => "group",
          "data-part" => "root",
          "data-orientation" => assigns.orientation
        }
        |> put_label(assigns)
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string, default: "div", doc: "The HTML element to render the group as."

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "The layout direction of the group."

  attr :label, :string,
    default: nil,
    doc: "An accessible name for the group. When set, the group is exposed with the `group` role."

  attr :rest, :global,
    doc:
      "Additional HTML attributes. If you pass `role=\"toolbar\"`, also pass `aria-orientation` and provide the expected keyboard interaction."

  slot :inner_block, required: true, doc: "The grouped children."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end

  defp put_label(attrs, %{label: nil}), do: attrs

  defp put_label(attrs, assigns) do
    attrs
    |> Map.put("aria-label", assigns.label)
    |> put_role(assigns)
  end

  # A role passed by the caller wins; otherwise a labelled group defaults to `group`.
  defp put_role(attrs, assigns) do
    if Map.has_key?(Map.get(assigns, :rest, %{}), :role) do
      attrs
    else
      Map.put(attrs, "role", "group")
    end
  end
end
