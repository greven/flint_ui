defmodule FlintUI.Base.Tabs do
  @moduledoc """
  Switches between panels of content with a tab list.

  Tabs are a selection control: exactly one tab is active and the matching
  `tabpanel` is visible. Use the `:tab` and `:panel` slots, matched by `value`.

      <.tabs id="account" value="profile" label="Account sections">
        <:tab value="profile">Profile</:tab>
        <:tab value="billing">Billing</:tab>

        <:panel value="profile">Profile content</:panel>
        <:panel value="billing">Billing content</:panel>
      </.tabs>

  The active tab is rendered on the server, so the panels are correct without
  JavaScript. The hook then updates the state optimistically on user
  interaction. Set `change_event` to push the new value to the server:

      <.tabs id="account" value={@tab} change_event="account_tab_changed">
        <:tab value="profile">Profile</:tab>
        <:tab value="billing">Billing</:tab>

        <:panel value="profile">Profile content</:panel>
        <:panel value="billing">Billing content</:panel>
      </.tabs>

  The event payload is `%{"id" => id, "value" => value}`.

  ## Custom triggers

  Set `custom` on a tab to render the trigger yourself. The slot receives the
  trigger attributes through `:let`, which must be spread onto a focusable
  element, usually a button or a link:

      <.tabs id="billing" value="monthly">
        <:tab value="monthly" custom :let={attrs}>
          <.button {attrs} variant="ghost">Monthly</.button>
        </:tab>
        <:tab value="yearly" custom :let={attrs}>
          <.button {attrs} variant="ghost">Yearly</.button>
        </:tab>
      </.tabs>

  Every trigger carries `data-tabs-trigger`, the ARIA wiring, and the state
  attributes; the hook finds triggers through that marker rather than the part
  hook. A composed component keeps its own `data-element` (a `<.button>` stays a
  button) and the trigger keeps `data-part="tab"`, so the behavior does not
  depend on the element type.

  Default triggers are also marked with `data-tabs-tab`; the styled layer scopes
  its trigger visuals to that marker, so a composed button keeps its own variant
  styles. A raw custom `<button>` should set `type="button"` itself; a composed
  button component usually sets it already.

  ## Link triggers

  A custom trigger may be a link. This is useful when the active tab belongs in
  the URL and the server should render it:

      <.tabs id="settings" value={@tab} label="Settings sections">
        <:tab value="profile" custom :let={attrs}>
          <.link {attrs} patch={~p"/settings?tab=profile"}>Profile</.link>
        </:tab>
        <:tab value="billing" custom :let={attrs}>
          <.link {attrs} patch={~p"/settings?tab=billing"}>Billing</.link>
        </:tab>
      </.tabs>

  The hook treats a link trigger as navigation-owned: it does not change the
  local state or push `change_event`. The link patch or navigation updates the
  server. Link triggers are also manual: arrow keys move focus and `Enter`
  follows the link.

  ## Guarding a change

  The hook dispatches a cancelable `fl:tabs:before-change` event on the trigger
  before a button tab changes. Calling `preventDefault()` aborts the local
  change, the `fl:tabs:change` event, and the `change_event` push:

      window.addEventListener("fl:tabs:before-change", (event) => {
        if (hasUnsavedChanges() && !confirm("Discard changes?")) {
          event.preventDefault()
        }
      })

  After an asynchronous confirmation, cancel the change now and continue with
  `FlintUI.select_tab/3` (or a `fl:tabs:select` dispatch). The select command
  bypasses the guard. With a guard, use `activation_mode="manual"` so moving
  focus with the arrow keys does not ask again.

  Link triggers use LiveView's `phx:before-navigate` event instead. It is
  cancelable and fires before `<.link navigate>` and `<.link patch>`
  navigations, but not for server-side pushes, redirects, regular links, form
  submits, or page unloads.

  ## Overflow

  Set `scrollable` when the tab list can be wider than its container. The hook
  keeps the active tab in view and the styled layer makes the list scroll
  horizontally instead of overflowing.

  Set `fadable` to add a fade at the edge that still has hidden tabs. It also
  makes the list scrollable, so the fade has a scroll container. `scrollable`
  alone scrolls without the fade cue.

  ## Find in page

  Set `findable` to mark inactive panels with `hidden="until-found"`. Browsers
  that support it can find text in a hidden panel, reveal it, and the hook then
  selects the matching tab. Browsers without support treat the panel as hidden
  and skip it in find-in-page. The automatic selection bypasses
  `fl:tabs:before-change`.

  ## Accessibility

  The tab list is a `tablist` with an `aria-orientation`. Each trigger is a
  `tab` with `aria-selected` and `aria-controls`; each panel is a
  `tabpanel` labelled by its tab. The active tab has `tabindex="0"` and the
  others `tabindex="-1"`, so the tab list is one tab stop and the arrow keys
  move between tabs.

  Give the tab list an accessible name with `label` whenever the page has more
  than one tab list. A disabled tab is skipped by the arrow keys. Do not make a
  disabled tab the active one; if it is, the hook keeps the first enabled tab
  focusable.

  A tab that navigates to a different page is a navigation link, not a tab. Keep
  `role="tab"` only when the trigger controls a `tabpanel` on the same page.

  ## Keyboard

  - `ArrowRight` / `ArrowLeft` - move to the next or previous tab in a
    horizontal list.
  - `ArrowDown` / `ArrowUp` - move to the next or previous tab in a vertical
    list.
  - `Home` / `End` - move to the first or last enabled tab.
  - `Enter` / `Space` - activate the focused button tab. A link trigger follows
    the link with `Enter`; `Space` does not activate a link.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :tabs,
      type: :navigation,
      since: "0.1",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Unique component DOM id."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: "FlintUI.Tabs",
          description: "The JS hook that powers the component."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "tabs",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-value]",
          value: "string",
          description: "The server-rendered active tab value."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The tab list orientation."
        },
        %Meta.PartAttr{
          name: "[data-activation]",
          value: ~s("automatic" | "manual"),
          description: "How arrow-key focus activates a tab."
        },
        %Meta.PartAttr{
          name: "[data-loop]",
          value: ~s("true" | "false"),
          description: "Whether arrow-key navigation wraps."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the whole tab list is disabled."
        },
        %Meta.PartAttr{
          name: "[data-change-event]",
          value: "string",
          description: "The server event pushed on a user change."
        },
        %Meta.PartAttr{
          name: "[data-findable]",
          value: "boolean",
          description: "Present when inactive panels use `hidden=\"until-found\"`."
        },
        %Meta.PartAttr{
          name: "[data-scrollable]",
          value: "boolean",
          description: "Present when the tab list scrolls horizontally."
        },
        %Meta.PartAttr{
          name: "[data-fadable]",
          value: "boolean",
          description: "Present when edge fading is enabled."
        }
      ],
      tablist: [
        %Meta.PartAttr{
          name: "role",
          value: ~s("tablist"),
          description: "The tab list role."
        },
        %Meta.PartAttr{
          name: "aria-orientation",
          value: ~s("horizontal" | "vertical"),
          description: "The orientation of the tab list."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name, present when `label` is set."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "tablist",
          description: "Identifies the tab list."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("horizontal" | "vertical"),
          description: "The orientation, for styling."
        },
        %Meta.PartAttr{
          name: "[data-fade-start]",
          value: "boolean",
          description:
            "Set by the hook when `fadable` and the tab list can scroll toward the start."
        },
        %Meta.PartAttr{
          name: "[data-fade-end]",
          value: "boolean",
          description:
            "Set by the hook when `fadable` and the tab list can scroll toward the end."
        }
      ],
      tab: [
        %Meta.PartAttr{
          name: "role",
          value: ~s("tab"),
          description: "The tab role."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description:
            "Present on default triggers. Set it on a raw custom button too, so it cannot submit an enclosing form."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the root id and the tab value."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "tab",
          description:
            "Identifies the trigger part. A composed component keeps this part hook and its own `data-element`."
        },
        %Meta.PartAttr{
          name: "[data-tabs-trigger]",
          value: "boolean",
          description:
            "Present on every trigger. The hook uses it to find triggers, so a composed component still works after it takes over `data-part`."
        },
        %Meta.PartAttr{
          name: "[data-tabs-tab]",
          value: "boolean",
          description:
            "Present on default triggers only. The styled layer scopes its trigger visuals to this marker, so a custom trigger keeps its own component styles."
        },
        %Meta.PartAttr{
          name: "[data-value]",
          value: "string",
          description: "The tab value."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("active" | "inactive"),
          description: "The selection state, for styling."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when the tab is disabled."
        },
        %Meta.PartAttr{
          name: "aria-selected",
          value: ~s("true" | "false"),
          description: "Whether the tab is selected."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The id of the matching panel, when one exists."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "An optional accessible name, present when `aria_label` is set."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: ~s("0" | "-1"),
          description: "Roving tab stop: `0` for the selected tab, `-1` for the rest."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Disables a default trigger."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: ~s("true"),
          description: "Present when the trigger is disabled."
        }
      ],
      panel: [
        %Meta.PartAttr{
          name: "role",
          value: ~s("tabpanel"),
          description: "The tab panel role."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Derived from the root id and the panel value."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "panel",
          description: "Identifies the panel."
        },
        %Meta.PartAttr{
          name: "[data-value]",
          value: "string",
          description: "The value matching the panel's tab."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("active" | "inactive"),
          description: "The visibility state, for styling."
        },
        %Meta.PartAttr{
          name: "aria-labelledby",
          value: "string",
          description: "The id of the matching tab."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: ~s("0"),
          description: "Present when the panel is focusable."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: ~s(true | "until-found"),
          description:
            "Present while the panel is inactive. `until-found` when `findable` is set."
        }
      ]
    }
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "ArrowRight / ArrowLeft",
        description: "Moves to the next or previous tab in a horizontal list."
      },
      %Meta.Keyboard{
        keys: "ArrowDown / ArrowUp",
        description: "Moves to the next or previous tab in a vertical list."
      },
      %Meta.Keyboard{keys: "Home / End", description: "Moves to the first or last enabled tab."},
      %Meta.Keyboard{
        keys: "Enter / Space",
        description:
          "Activates the focused button tab. A link trigger follows the link with `Enter`; `Space` does not activate a link."
      }
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:tabs:before-change",
        source: :client,
        doc:
          "Cancelable event dispatched on the trigger before a button tab changes. Call `preventDefault()` to abort the local change and the server push. Continue with `select_tab/3`. Find-in-page selection bypasses this event."
      },
      %Meta.Event{
        name: "fl:tabs:change",
        source: :client,
        doc:
          "Dispatched on the root after the active tab changes, including find-in-page selection. The event detail is a map with `id`, `value`, and `previous`."
      },
      %Meta.Event{
        name: "fl:tabs:select",
        source: :client,
        doc:
          "Client command event that selects a tab. Dispatch it with `select_tab/3` or `Phoenix.LiveView.JS.dispatch/3`. Carries a `value` detail and bypasses `fl:tabs:before-change`."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    tabs = Map.get(assigns, :tab, []) || []
    panels = Map.get(assigns, :panel, []) || []
    active = resolve_active(tabs, Map.get(assigns, :value))
    panel_values = MapSet.new(panels, &to_string(&1.value))

    %{
      root: %{
        "id" => assigns.id,
        "phx-hook" => "FlintUI.Tabs",
        "data-element" => "tabs",
        "data-part" => "root",
        "data-value" => active,
        "data-orientation" => assigns.orientation,
        "data-activation" => assigns.activation_mode,
        "data-loop" => to_string(assigns.loop),
        "data-disabled" => assigns.disabled,
        "data-change-event" => assigns.change_event,
        "data-findable" => assigns.findable,
        "data-scrollable" => assigns.scrollable,
        "data-fadable" => assigns.fadable
      },
      tablist: %{
        "role" => "tablist",
        "data-part" => "tablist",
        "data-orientation" => assigns.orientation,
        "aria-orientation" => assigns.orientation,
        "aria-label" => assigns.label
      },
      tab:
        Map.new(tabs, fn tab ->
          {to_string(tab.value), tab_attrs(assigns, tab, active, panel_values)}
        end),
      panel:
        Map.new(panels, fn panel ->
          {to_string(panel.value), panel_attrs(assigns, panel, active)}
        end)
    }
  end

  defp tab_attrs(assigns, tab, active, panel_values) do
    value = to_string(tab.value)
    selected = value == active
    disabled = assigns.disabled or Map.get(tab, :disabled, false)

    %{
      "role" => "tab",
      "id" => "#{assigns.id}-tab-#{value}",
      "data-part" => "tab",
      "data-tabs-trigger" => "",
      "data-value" => value,
      "data-state" => if(selected, do: "active", else: "inactive"),
      "data-disabled" => disabled,
      "aria-selected" => to_string(selected),
      "aria-controls" => aria_controls(assigns, value, panel_values),
      "aria-label" => Map.get(tab, :aria_label),
      "aria-disabled" => disabled && "true",
      "tabindex" => if(selected and not disabled, do: "0", else: "-1"),
      "disabled" => disabled
    }
    |> put_trigger_class(tab)
  end

  defp panel_attrs(assigns, panel, active) do
    value = to_string(panel.value)
    selected = value == active

    %{
      "role" => "tabpanel",
      "id" => "#{assigns.id}-panel-#{value}",
      "data-part" => "panel",
      "data-value" => value,
      "data-state" => if(selected, do: "active", else: "inactive"),
      "aria-labelledby" => "#{assigns.id}-tab-#{value}",
      "tabindex" => if(Map.get(panel, :focusable, true), do: "0"),
      "hidden" => hidden_value(assigns, selected)
    }
    |> put_panel_class(panel)
  end

  # The class is applied to default triggers only. A custom trigger is styled by
  # the element the caller renders.
  defp put_trigger_class(attrs, tab) do
    case {Map.get(tab, :custom, false), Map.get(tab, :class)} do
      {false, class} when not is_nil(class) -> Map.put(attrs, "class", class)
      _ -> attrs
    end
  end

  defp put_panel_class(attrs, panel) do
    case Map.get(panel, :class) do
      nil -> attrs
      class -> Map.put(attrs, "class", class)
    end
  end

  defp aria_controls(assigns, value, panel_values) do
    if MapSet.member?(panel_values, value), do: "#{assigns.id}-panel-#{value}"
  end

  defp hidden_value(_assigns, true), do: nil

  defp hidden_value(assigns, false) do
    if assigns.findable, do: "until-found", else: true
  end

  defp resolve_active([], _value), do: nil

  defp resolve_active(tabs, value) do
    value = value && to_string(value)

    if value not in [nil, ""] and Enum.any?(tabs, &(to_string(&1.value) == value)) do
      value
    else
      first_enabled_value(tabs)
    end
  end

  defp first_enabled_value(tabs) do
    tab = Enum.find(tabs, &(not Map.get(&1, :disabled, false))) || List.first(tabs)
    tab && to_string(tab.value)
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string, required: true, doc: "Unique component DOM id."

  attr :label, :string,
    default: nil,
    doc: "An accessible name for the tab list, applied as `aria-label`."

  attr :value, :string,
    default: nil,
    doc:
      "The active tab value. Defaults to the first enabled tab when it is missing or does not match a tab."

  attr :orientation, :string,
    default: "horizontal",
    values: ~w(horizontal vertical),
    doc: "The orientation of the tab list and the arrow-key axis."

  attr :activation_mode, :string,
    default: "automatic",
    values: ~w(automatic manual),
    doc:
      "Whether arrow-key focus selects the tab (`automatic`) or only moves focus (`manual`). Use `manual` when guarding changes."

  attr :loop, :boolean,
    default: true,
    doc: "Whether arrow-key navigation wraps at the ends."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the whole tab list is disabled."

  attr :findable, :boolean,
    default: false,
    doc:
      "Whether inactive panels use `hidden=\"until-found\"`, so browser find-in-page can reveal them and select the matching tab."

  attr :scrollable, :boolean,
    default: false,
    doc:
      "Whether the tab list scrolls horizontally when its tabs overflow. Horizontal orientation only."

  attr :fadable, :boolean,
    default: false,
    doc:
      "Whether to fade the tab list edge that has more tabs. It also makes the list scrollable, so use it with a bounded width. Horizontal orientation only."

  attr :change_event, :string,
    default: nil,
    doc:
      "The server event pushed when a button tab changes. The event receives a map with the component's `id` and the new `value`. Link tabs rely on navigation instead."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :tab,
    required: true,
    doc:
      "One tab. Render the label as the slot content, or set `custom` and render the trigger yourself with the provided attributes." do
    attr :value, :string,
      required: true,
      doc: "The tab value. Used in the tab and panel ids, so use a slug."

    attr :disabled, :boolean, doc: "Whether the tab is disabled. Defaults to `false`."

    attr :custom, :boolean,
      doc:
        "Whether the slot renders the trigger. The slot receives the trigger attributes through `:let`. Defaults to `false`. A raw custom button should set `type=\"button\"`."

    attr :aria_label, :string,
      doc:
        "An accessible name for the trigger, applied as `aria-label`. Useful for icon-only tabs."

    attr :class, :any,
      doc:
        "Additional classes for a default trigger. A custom trigger is styled by the element you render."
  end

  slot :panel, doc: "A panel. Match its value to a tab value." do
    attr :value, :string, required: true, doc: "The value of the tab this panel belongs to."

    attr :focusable, :boolean,
      doc: "Whether the panel receives `tabindex=\"0\"`. Defaults to `true`."

    attr :class, :any, doc: "Additional classes for the panel."
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}>
      <div {@flint_parts[:tablist]}>
        <%= for tab <- @tab do %>
          <%= if Map.get(tab, :custom, false) do %>
            {render_slot(tab, @flint_parts[:tab][to_string(tab.value)])}
          <% else %>
            <button
              {@flint_parts[:tab][to_string(tab.value)]}
              data-tabs-tab
              type="button"
            >
              {render_slot(tab)}
            </button>
          <% end %>
        <% end %>
      </div>
      <%= for panel <- @panel do %>
        <div {@flint_parts[:panel][to_string(panel.value)]}>
          {render_slot(panel)}
        </div>
      <% end %>
    </div>
    """
  end

  ## JS Helpers

  @doc """
  Selects a tab from a `Phoenix.LiveView.JS` command.

  The command dispatches `fl:tabs:select` and bypasses
  `fl:tabs:before-change`, so it is the explicit way to continue after a
  cancelled change:

      <button phx-click={FlintUI.select_tab("account", "billing")}>Continue</button>
  """
  def select_tab(js \\ %JS{}, id, value) do
    JS.dispatch(js, "fl:tabs:select", to: "##{id}", detail: %{value: value})
  end
end
