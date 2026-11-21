defmodule FlintUI.Base.DropdownGroup do
  @moduledoc """
  Groups related items inside a dropdown menu.

  The group renders `role="group"` and takes an accessible name from `label` or
  a caller-supplied `aria-label`:

      <FlintUI.dropdown_group aria-label="Session">
        <FlintUI.dropdown_item>Switch user</FlintUI.dropdown_item>
        <FlintUI.dropdown_item intent="danger">Log out</FlintUI.dropdown_item>
      </FlintUI.dropdown_group>

  Use a group when the items share a name that helps a screen-reader user
  understand the collection. For a purely visual split, use a
  `FlintUI.dropdown_separator/1` instead.

  ## Accessibility

  A group is a collection role, not a control. Its items stay in the dropdown's
  roving focus sequence, and the group adds no keyboard behavior of its own.
  Name every group with `label` or `aria-label`; an unnamed group is exposed but
  gives the user no context.

  ## Keyboard

  The dropdown owns navigation. A group adds no keyboard behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :dropdown_group,
      type: :overlay,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    [
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "dropdown_group",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "group",
          description: "Identifies the group element."
        },
        %Meta.PartAttr{
          name: "role",
          value: "group",
          description: "Exposes the collection role."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description:
            "The group's accessible name, from `label` or a caller-supplied `aria-label`."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "dropdown_group",
        "data-part" => "group",
        "role" => "group",
        "aria-label" => assigns.label
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :label, :string,
    default: nil,
    doc:
      "The group's accessible name, applied as `aria-label`. A caller-supplied `aria-label` wins."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The items in the group."

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
