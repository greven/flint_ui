defmodule FlintUI.Base.DropdownSeparator do
  @moduledoc """
  Separates groups of items inside a dropdown menu.

  The separator renders `role="separator"` and is not focusable:

      <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
      <FlintUI.dropdown_separator />
      <FlintUI.dropdown_item intent="error">Log out</FlintUI.dropdown_item>

  Use a separator for a visual break between unrelated actions. Use a
  `FlintUI.dropdown_group/1` when the items share an accessible name.

  ## Accessibility

  The separator is a structural divider. It is not in the tab sequence and adds
  no keyboard behavior. It does not label the items around it; name a group
  instead when the relationship needs to be announced.

  ## Keyboard

  The separator is not interactive and adds no keyboard behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :dropdown_separator,
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
          value: "dropdown_separator",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "separator",
          description: "Identifies the separator element."
        },
        %Meta.PartAttr{
          name: "role",
          value: "separator",
          description: "Exposes the static separator role."
        }
      ]
    ]
  end

  @impl true
  def build_attrs(_assigns) do
    %{
      root: %{
        "data-element" => "dropdown_separator",
        "data-part" => "separator",
        "role" => "separator"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :rest, :global, doc: "Additional HTML attributes."

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}></div>
    """
  end
end
