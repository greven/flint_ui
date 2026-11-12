defmodule FlintUI.Base.AvatarGroup do
  @moduledoc """
  Lays out several avatars as one overlapping unit.

  An avatar group is structural: it renders a root element and arranges its
  children, but it does not inspect or change them. Pass avatars directly as
  children:

      <FlintUI.avatar_group label="Project members">
        <FlintUI.avatar src={@ana.avatar_url} alt={@ana.name} />
        <FlintUI.avatar src={@bo.avatar_url} alt={@bo.name} />
      </FlintUI.avatar_group>

  The generated styled component adds the overlap, size cascade, and optional
  surface ring. Overflow is caller-controlled: render an extra avatar with
  fixed text, such as `text="+3"` and an `alt` such as `"3 more members"`, when
  there are more people than fit.

  ## Accessibility

  A group is a generic container. Give it an accessible name with `label` when
  the grouping is meaningful; that exposes it as a `group` landmark. The avatars
  keep their own accessible names and behavior.

  ## Keyboard

  The group adds no keyboard interaction. Avatars are not interactive.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :avatar_group,
      type: :element,
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
          value: "avatar_group",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
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
          "data-element" => "avatar_group",
          "data-part" => "root"
        }
        |> put_label(assigns)
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string, default: "span", doc: "The HTML element to render the group as."

  attr :label, :string,
    default: nil,
    doc: "An accessible name for the group. When set, the group is exposed with the `group` role."

  attr :rest, :global,
    doc:
      "Additional HTML attributes. If you pass `role=\"group\"` yourself, the accessible name still comes from `label`."

  slot :inner_block, required: true, doc: "The avatars to arrange."

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

  defp put_role(attrs, assigns) do
    if Map.has_key?(Map.get(assigns, :rest, %{}), :role) do
      attrs
    else
      Map.put(attrs, "role", "group")
    end
  end
end
