defmodule FlintUI.Base.Header do
  @moduledoc """
  A page-level header bar with brand, navigation, action, and secondary regions.

  A header is a layout shell, not a navigation component. It provides the
  page's banner bar and a responsive mobile disclosure; the navigation landmark,
  its links, and its keyboard behavior come from the component you place in the
  `:nav` slot, usually `FlintUI.navbar`:

      <FlintUI.header id="site-header">
        <:brand>
          <.link navigate="/">Acme</.link>
        </:brand>
        <:nav>
          <FlintUI.navbar label="Primary">
            <FlintUI.navbar_item navigate="/">Home</FlintUI.navbar_item>
            <FlintUI.navbar_item navigate="/pricing">Pricing</FlintUI.navbar_item>
          </FlintUI.navbar>
        </:nav>
        <:actions>
          <FlintUI.button>Sign in</FlintUI.button>
        </:actions>
      </FlintUI.header>

  The root is the element chosen by `as`, a `header` by default. A top-level
  `header` maps to the `banner` landmark; a header nested in `main`, `section`,
  or `article` does not. The component adds no role of its own.

  ## Mobile navigation

  Below the styled layer's breakpoint, the header shows a toggle and expands the
  navigation into a full-width panel under the bar. The panel is part of the
  header flow rather than a detached overlay, so it pushes the page content down
  instead of being clipped by a scrolling ancestor. The toggle is a native
  button with `aria-expanded` and `aria-controls`, and the panel is the `:nav`
  region.

  `toggle_position` places the toggle before the brand (`start`) or after the
  actions (`end`, the default). The panel always renders under the bar. When the
  toggle sits after the inline navigation, opening the panel moves focus into it
  so the keyboard path follows the reading order.

  Pass a `:mobile` slot to replace the panel content on small screens. The
  `:nav` region then stays inline on larger screens while the `:mobile` slot
  fills the panel. This is the place for a vertical `FlintUI.navlist`, repeated
  actions, or a custom menu, and it keeps the panel after the toggle in the DOM.

  Set `open` to render the panel open server-side. The toggle, `Escape`,
  outside clicks, following a link, live navigation, and crossing back above
  the breakpoint all close it.

  The default toggle is a hamburger mark that morphs into a close mark while the
  panel is open. Add `data-toggle-icon="closed"` and `data-toggle-icon="open"`
  to custom `:toggle` content to opt into the same state swap.

  ## Accessibility

  The root is the chosen native element. A top-level `header` is exposed as the
  page's `banner` landmark; the header does not add a role, so `as="div"` is a
  plain container.

  The mobile toggle is a native `button`. It carries `aria-expanded` and
  `aria-controls`, and its accessible name comes from `toggle_label`; the icon
  is decorative. The navigation landmark itself comes from the `Navbar` (or
  another labelled `nav`) inside `:nav`.

  Keep the visual order the same as the reading order: brand, navigation,
  actions, and the toggle at the chosen edge, then the panel and the secondary
  row.

  ## Keyboard

  - `Tab` / `Shift+Tab` - moves through the brand, navigation, actions, and the
    toggle in DOM order.
  - `Enter` / `Space` - toggles the mobile navigation panel when the toggle is
    visible. Opening moves focus to the first focusable item in the panel when
    the panel precedes the toggle (the default `end` position with the inline
    `:nav`).
  - `Escape` - closes the mobile panel and returns focus to the toggle.

  The navigation links keep their own keyboard behavior from the navigation
  component inside the `:nav` slot.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :header,
      type: :layout,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    [
      root: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Unique component DOM id. Generated when `id` is omitted."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: "FlintUI.Header",
          description:
            "The header hook that toggles the mobile panel, swaps the toggle icon, closes it on dismiss, and syncs ARIA."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "header",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the header landmark or container."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "The mobile panel state."
        },
        %Meta.PartAttr{
          name: "[data-mobile]",
          value: "boolean",
          description: "Present when a custom `:mobile` panel is supplied."
        },
        %Meta.PartAttr{
          name: "[data-toggle-position]",
          value: ~s("start" | "end"),
          description: "Which side of the bar the mobile toggle sits on."
        }
      ],
      bar: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "bar",
          description:
            "The grid row that holds the brand, toggle, navigation, and actions. The mobile panel flows as an extra row under it."
        }
      ],
      brand: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "brand",
          description: "The start region, usually a logo link with the product name."
        }
      ],
      nav: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "Derived from the root id; the toggle controls it when no `:mobile` slot is set."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "nav",
          description:
            "The navigation region, inline on larger screens and the panel on smaller ones."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "The mobile panel state."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description: "Lets the panel receive focus when it has no focusable content."
        }
      ],
      actions: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "actions",
          description: "The end region for account controls, theme toggles, and primary actions."
        }
      ],
      toggle: [
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the toggle from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "toggle",
          description: "Identifies the mobile navigation toggle."
        },
        %Meta.PartAttr{
          name: "[data-toggle-icon]",
          value: ~s("closed" | "open"),
          description:
            "Marks custom state-specific icons inside the toggle; the hook toggles their `hidden` attribute. The built-in mark uses `data-part=\"toggle-icon\"` instead."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The id of the navigation or custom mobile panel."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the mobile panel is open."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name of the toggle; the icon is decorative."
        }
      ],
      toggle_icon: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "toggle-icon",
          description:
            "The built-in hamburger mark. The styled layer morphs it into a close mark from the root `data-state`."
        },
        %Meta.PartAttr{
          name: "[data-default]",
          value: "boolean",
          description: "Present on the built-in mark."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The mark is decorative."
        }
      ],
      mobile: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the root id; the toggle controls it."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "mobile",
          description: "The custom mobile panel rendered from the `:mobile` slot."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "The mobile panel state."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description: "Lets the panel receive focus when it has no focusable content."
        }
      ],
      secondary: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "secondary",
          description: "An optional full-width row below the bar."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab / Shift+Tab",
        description: "Moves through the brand, navigation, actions, and the toggle in DOM order."
      },
      %Meta.Keyboard{
        keys: "Enter / Space",
        description:
          "Toggles the mobile panel when the toggle is visible. Opening moves focus into the panel when it precedes the toggle."
      },
      %Meta.Keyboard{
        keys: "Escape",
        description: "Closes the mobile panel and returns focus to the toggle."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The mobile panel is expanded.",
        selector: ~s([data-element="header"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The mobile panel is collapsed.",
        selector: ~s([data-element="header"][data-state="closed"])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id || FlintUI.API.use_id("fl-header")
    mobile? = assigns.mobile != []
    toggle? = mobile? or assigns.nav != []
    panel_id = if mobile?, do: "#{id}-mobile", else: "#{id}-nav"
    state = if assigns.open, do: "open", else: "closed"

    %{
      root: %{
        "id" => id,
        "phx-hook" => toggle? && "FlintUI.Header",
        "data-element" => "header",
        "data-part" => "root",
        "data-state" => state,
        "data-mobile" => mobile?,
        "data-toggle-position" => assigns.toggle_position
      },
      bar: %{"data-part" => "bar"},
      brand: %{"data-part" => "brand"},
      toggle: %{
        "type" => "button",
        "data-part" => "toggle",
        "aria-controls" => panel_id,
        "aria-expanded" => to_string(assigns.open),
        "aria-label" => assigns.toggle_label
      },
      toggle_icon: %{
        "data-part" => "toggle-icon",
        "data-default" => "",
        "aria-hidden" => "true"
      },
      nav: %{
        "id" => "#{id}-nav",
        "data-part" => "nav",
        "data-state" => state,
        "tabindex" => "-1"
      },
      actions: %{"data-part" => "actions"},
      mobile: %{
        "id" => "#{id}-mobile",
        "data-part" => "mobile",
        "data-state" => state,
        "tabindex" => "-1"
      },
      secondary: %{"data-part" => "secondary"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string,
    default: "header",
    doc:
      "The HTML element to render the header as. A top-level `header` is the page's `banner` landmark; `div` renders a plain container."

  attr :id, :string,
    default: nil,
    doc: "Unique component DOM id. Generated when omitted."

  attr :open, :boolean,
    default: false,
    doc:
      "Whether the mobile panel is rendered open. Bind it to an assign to make the server the source of truth."

  attr :toggle_label, :string,
    default: "Menu",
    doc:
      "The accessible name of the mobile toggle. The toggle icon is decorative, so keep this meaningful."

  attr :toggle_position, :string,
    values: ~w(start end),
    default: "end",
    doc:
      "Which side of the bar the mobile toggle sits on. `end` places it after the actions, `start` before the brand. The panel always flows under the bar."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :brand,
    doc: "The start region, usually a logo link with the product name."

  slot :nav,
    doc:
      "The desktop navigation region, normally a `FlintUI.navbar`. It becomes the mobile panel when `:mobile` is not set."

  slot :actions,
    doc: "The end region for account controls, theme toggles, and primary actions."

  slot :mobile,
    doc:
      "Content for the mobile panel. When set, `:nav` stays inline on larger screens and this slot fills the panel on smaller ones."

  slot :secondary,
    doc: "A full-width row below the bar, such as a section nav, filters, or an announcement."

  slot :toggle,
    validate_attrs: false,
    doc:
      "Custom content for the mobile toggle. The default is a hamburger mark that morphs into a close mark; the button's accessible name still comes from `toggle_label`. Add `data-toggle-icon=\"closed\"` and `data-toggle-icon=\"open\"` to opt into the state swap with your own icons."

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      <div {@flint_parts[:bar]}>
        <.toggle_button
          :if={@toggle_position == "start"}
          show={@nav != [] or @mobile != []}
          attrs={@flint_parts[:toggle]}
          icon_attrs={@flint_parts[:toggle_icon]}
          content={@toggle}
        />
        <div {@flint_parts[:brand]}>{render_slot(@brand)}</div>
        <div {@flint_parts[:nav]}>{render_slot(@nav)}</div>
        <div {@flint_parts[:actions]}>{render_slot(@actions)}</div>
        <.toggle_button
          :if={@toggle_position == "end"}
          show={@nav != [] or @mobile != []}
          attrs={@flint_parts[:toggle]}
          icon_attrs={@flint_parts[:toggle_icon]}
          content={@toggle}
        />
        <div :if={@mobile != []} {@flint_parts[:mobile]}>{render_slot(@mobile)}</div>
      </div>
      <div :if={@secondary != []} {@flint_parts[:secondary]}>{render_slot(@secondary)}</div>
    </.dynamic_tag>
    """
  end

  defp toggle_button(assigns) do
    ~H"""
    <button :if={@show} {@attrs}>
      {render_slot(@content)}
      <span :if={@content == []} {@icon_attrs} />
    </button>
    """
  end
end
