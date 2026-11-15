defmodule FlintUI.Base.DropdownItem do
  @moduledoc """
  A single action or link inside a dropdown menu.

  The item renders a native `<button>` by default. Pass `href`, `navigate`, or
  `patch` to render a link instead:

      <FlintUI.dropdown_item>Settings</FlintUI.dropdown_item>
      <FlintUI.dropdown_item navigate="/account">Account</FlintUI.dropdown_item>
      <FlintUI.dropdown_item href="https://example.com">Billing</FlintUI.dropdown_item>
      <FlintUI.dropdown_item disabled>Referrals</FlintUI.dropdown_item>

  `intent` tints the item with a semantic color. Use it sparingly for a
  destructive action or a state the item confirms:

      <FlintUI.dropdown_item intent="error">Delete project</FlintUI.dropdown_item>

  ## Custom content

  Set `custom` to render a non-interactive content block instead of a menu item.
  It carries no `menuitem` role, no tab stop, and no item layout or hover
  treatment, so it can hold a footer, an account summary, or other arbitrary
  content:

      <FlintUI.dropdown_item custom>
        <p>Signed in as ada@example.com</p>
      </FlintUI.dropdown_item>

  Do not put a `custom` item in the arrow-key sequence; its children keep their
  own semantics and are reached through normal page navigation.

  ## Accessibility

  A normal item carries `role="menuitem"` and is managed by the dropdown's
  roving focus. A disabled action item renders the native `disabled` attribute;
  a disabled link loses its destination and carries `aria-disabled="true"`.
  Disabled items are skipped by the dropdown's arrow keys.

  Use the button form for actions and the link form for navigation. A link
  keeps link semantics: `Enter` follows it and `Space` does not.

  ## Keyboard

  The dropdown owns navigation. `Enter` and `Space` activate a focused button;
  `Enter` follows a focused link. The item itself adds no shortcut.
  """

  use FlintUI.Component

  @intents ~w(neutral info success warning error primary secondary)

  @impl true
  def meta do
    %Meta{
      name: :dropdown_item,
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
          value: "dropdown_item",
          description:
            "Identifies the component type. Shared by the button, link, and custom forms."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "item",
          description: "Identifies the item root."
        },
        %Meta.PartAttr{
          name: "role",
          value: "menuitem",
          description: "Exposes the item role. Absent on a `custom` item."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description:
            "Set by the server and managed by the hook, which keeps the active item at `0` and the rest at `-1`. Absent on a `custom` item."
        },
        %Meta.PartAttr{
          name: "[data-intent]",
          value:
            ~s("neutral" | "info" | "success" | "warning" | "error" | "primary" | "secondary"),
          description: "The semantic color of the item."
        },
        %Meta.PartAttr{
          name: "[data-custom]",
          value: "boolean",
          description:
            "Present when the item is a non-interactive content block. It has no menu role, tab stop, or item layout."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the item is disabled."
        },
        %Meta.PartAttr{
          name: "[data-active]",
          value: "boolean",
          description: "Present on the item the roving focus currently owns."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: "true",
          description: "Present on a disabled item that has no native `disabled` state."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "The native disabled state, rendered only on the button form."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Enter",
        description: "Activates a focused button or follows a focused link."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Activates a focused button. Does not activate a link."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The item is disabled and skipped by menu navigation.",
        selector: ~s([data-element="dropdown_item"][data-disabled])
      },
      %Meta.State{
        name: "active",
        description: "The item currently owns the roving focus.",
        selector: ~s([data-element="dropdown_item"][data-active])
      },
      %Meta.State{
        name: "custom",
        description: "The item is a non-interactive content block.",
        selector: ~s([data-element="dropdown_item"][data-custom])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root:
        %{
          "data-element" => "dropdown_item",
          "data-part" => "item",
          "data-intent" => assigns.intent,
          "data-custom" => assigns.custom,
          "data-disabled" => assigns.disabled
        }
        |> Map.merge(item_attrs(assigns))
    }
  end

  defp item_attrs(%{custom: true}), do: %{}

  defp item_attrs(assigns) do
    %{
      "role" => "menuitem",
      "tabindex" => "-1",
      "aria-disabled" => assigns.disabled && "true"
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "button",
    values: ~w(button a div),
    doc:
      "The element used for the interactive item. A link destination (`href`, `navigate`, or `patch`) always renders a link."

  attr :intent, :string,
    default: "neutral",
    values: @intents,
    doc: "The semantic color of the item."

  attr :custom, :boolean,
    default: false,
    doc:
      "Whether the item is a non-interactive content block. It renders a `div` with no menu role, tab stop, or item layout."

  attr :disabled, :boolean,
    default: false,
    doc:
      "Whether the item is disabled. A button renders the native `disabled` attribute; a link loses its destination and stays discoverable."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of a button."

  slot :inner_block, required: true, doc: "The item content."

  @impl true
  def render(assigns) do
    cond do
      assigns.custom ->
        assigns = assign(assigns, :rest, drop_navigation(assigns.rest))

        ~H"""
        <div {@rest} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </div>
        """

      navigation?(assigns) && navigable?(assigns) ->
        ~H"""
        <.link {@rest} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </.link>
        """

      navigation?(assigns) ->
        assigns = assign(assigns, :rest, drop_navigation(assigns.rest))

        ~H"""
        <a {@rest} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </a>
        """

      assigns.as == "a" ->
        ~H"""
        <a {@rest} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </a>
        """

      assigns.as == "div" ->
        ~H"""
        <div {@rest} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </div>
        """

      true ->
        ~H"""
        <button {@rest} type="button" disabled={@disabled} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </button>
        """
    end
  end

  defp navigation?(assigns) do
    Enum.any?([:href, :navigate, :patch], &present?(Map.get(assigns.rest, &1)))
  end

  # A disabled item must not navigate, so the link form drops its destination.
  # The hook also blocks activation on a disabled item.
  defp navigable?(assigns), do: not assigns.disabled

  defp present?(value), do: value not in [nil, false, ""]

  defp drop_navigation(rest) do
    Map.drop(rest, [
      :href,
      :navigate,
      :patch,
      :replace,
      :method,
      :csrf_token,
      :target,
      :rel,
      :download,
      :hreflang,
      :referrerpolicy
    ])
  end
end
