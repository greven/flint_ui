defmodule FlintUI.Base.Toggle do
  @moduledoc """
  Renders a two-state button that is either toggled on or off.

  Use it to switch a feature or setting on and off, such as bold text or a
  muted microphone.

  ## Examples

      <.toggle>Toggled</.toggle>

      <.toggle toggled>
        <.icon name="lucide-letter-b" class="size-4" /> Bold
      </.toggle>

  The button always updates its own `aria-pressed` and `data-state` attributes
  when clicked, so the state is reflected immediately. That update is part of
  the component's `phx-click`: pass your own `phx-click`, a
  `Phoenix.LiveView.JS` command or a server event name, and the toggle adds the
  update to it. The update runs first, so a handler that reads `data-state`
  sees the new state. The `toggled` attribute is the source of truth, and the
  client state reconciles with it on the next render.

      <.toggle phx-click={JS.push("toggle-bold")}>Bold</.toggle>
      <.toggle phx-click="toggle-bold">Bold</.toggle>

  A toggle only ever renders a button. Unlike `<.button>`, it has no link form:
  a control that changes state must not navigate.

  ## Content per state

  The headless toggle has one content slot; the styled wrapper adds `:on` and
  `:off` slots, which it renders in the DOM and reveals with `data-state`. A
  headless consumer writes their own state content inside the button and hides
  the inactive one with `data-state`:

      <.toggle toggled={@muted}>
        <span class="on">Muted</span>
        <span class="off">Sound on</span>
      </.toggle>

      [data-element="toggle"][data-state="on"] .off,
      [data-element="toggle"][data-state="off"] .on { display: none; }

  ## Accessibility

  Renders a native `<button>` with `aria-pressed`, which exposes the on/off
  state to assistive technology. Keep the accessible name stable between
  states: an `aria-pressed` toggle already announces its state, so a label that
  also changes ("Mute" to "Unmute") makes the announcement ambiguous. Change a
  decorative icon or a state-specific visual instead. An icon-only toggle needs
  an accessible name, so pass `aria-label` or `aria-labelledby`.

  `loading` is a pending state, not a second disabled state. It sets
  `aria-busy="true"`, `aria-disabled="true"`, and `data-loading`, keeps the
  control focusable unless `disabled` is also set, and keeps its accessible
  name, but activation is ignored while `flint.js` is loaded. Announce progress
  in a status region outside the control and guard the server event too. A
  pending submit toggle renders `type="button"`, so it does not submit the
  form, and carries `data-pending-submit` for the browser guard.

  ## Keyboard

  - `Tab` - moves focus to the control. A disabled toggle leaves the tab order.
  - `Enter` - toggles the button. Ignored while pending.
  - `Space` - toggles the button. Ignored while pending.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :toggle,
      type: :action,
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
          value: "toggle",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("on" | "off"),
          description: "The toggled state, for styling."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when `disabled` is set."
        },
        %Meta.PartAttr{
          name: "[data-loading]",
          value: "boolean",
          description:
            "Present when `loading` is set. The control is pending: focusable unless also hard-disabled, and non-activatable while `flint.js` is loaded."
        },
        %Meta.PartAttr{
          name: "[data-pending-submit]",
          value: "boolean",
          description:
            "Present on a pending `type=\"submit\"` toggle, which renders `type=\"button\"` and therefore does not submit the form."
        },
        %Meta.PartAttr{
          name: "aria-pressed",
          value: ~s("true" | "false"),
          description: "The toggled state, exposed to assistive technology."
        },
        %Meta.PartAttr{
          name: "aria-busy",
          value: ~s("true"),
          description:
            "Set to `\"true\"` while `loading` is set. Marks the control as updating; use a status region for the announcement."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: ~s("true"),
          description:
            "Set while the control is pending. A pending control stays focusable unless also disabled."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("button" | "submit" | "reset"),
          description:
            "The button type. A pending submit toggle renders `type=\"button\"` so it does not submit the form."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Disables the button."
        },
        %Meta.PartAttr{
          name: "phx-click",
          value: "Phoenix.LiveView.JS",
          description:
            "Toggles `aria-pressed` and `data-state` client-side, then runs the caller's command or event when set."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves focus to the control. A disabled toggle leaves the tab order."
      },
      %Meta.Keyboard{keys: "Enter", description: "Toggles the button. Ignored while pending."},
      %Meta.Keyboard{keys: "Space", description: "Toggles the button. Ignored while pending."}
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "on",
        description: "The toggle is pressed.",
        selector: ~s([data-element="toggle"][data-state="on"])
      },
      %Meta.State{
        name: "off",
        description: "The toggle is not pressed.",
        selector: ~s([data-element="toggle"][data-state="off"])
      },
      %Meta.State{
        name: "disabled",
        description: "The toggle is disabled.",
        selector: ~s([data-element="toggle"][data-disabled])
      },
      %Meta.State{
        name: "loading",
        description: "The toggle is loading and cannot be activated.",
        selector: ~s([data-element="toggle"][data-loading])
      },
      %Meta.State{
        name: "pending-submit",
        description:
          "Applied while a submit toggle is pending; implicit form submission is blocked.",
        selector: ~s([data-element="toggle"][data-pending-submit])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    pending? = assigns.loading
    pending_submit? = pending? && assigns.type == "submit"

    root = %{
      "data-element" => "toggle",
      "data-part" => "root",
      "data-state" => if(assigns.toggled, do: "on", else: "off"),
      "data-disabled" => assigns.disabled,
      "data-loading" => pending?,
      "aria-pressed" => to_string(assigns.toggled),
      "aria-busy" => pending? && "true",
      "aria-disabled" => pending? && "true"
    }

    root = if pending_submit?, do: Map.put(root, "data-pending-submit", true), else: root

    %{root: root}
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :toggled, :boolean,
    default: false,
    doc: "Whether the button is currently pressed (toggled on). The server-side source of truth."

  attr :type, :string,
    default: "button",
    values: ~w(button submit reset),
    doc:
      "The button type, defaults to `button`. A pending submit toggle renders `type=\"button\"` until loading clears."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the button should ignore user interaction."

  attr :loading, :boolean,
    default: false,
    doc:
      "Whether the control is pending. Sets `aria-busy`, `aria-disabled`, and `data-loading` while keeping it focusable unless `disabled` is also set. `flint.js` blocks activation, always guard the server event."

  attr :rest, :global,
    include: ~w(name value form formaction formenctype formmethod formnovalidate
                formtarget autofocus command commandfor popovertarget),
    doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The content of the toggle button."

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:rest, drop_click(assigns.rest))
      |> assign(:click, click(assigns.rest))

    ~H"""
    <button
      {@rest}
      type={toggle_type(assigns)}
      disabled={@disabled}
      phx-click={@click}
      {@flint_parts[:root]}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp toggle_type(%{loading: true, type: "submit"}), do: "button"
  defp toggle_type(assigns), do: assigns.type

  # The caller's `phx-click` is composed into the toggle's own command, so it
  # must not also be forwarded as the element's attribute.
  defp drop_click(rest) when is_map(rest) do
    Map.drop(rest, ["phx-click", :"phx-click"])
  end

  defp drop_click(rest), do: rest

  defp click(rest) do
    user = rest |> user_click() |> to_js()

    %JS{}
    |> JS.toggle_attribute({"aria-pressed", "true", "false"})
    |> JS.toggle_attribute({"data-state", "on", "off"})
    |> JS.concat(user)
  end

  defp user_click(rest) when is_map(rest) do
    Map.get(rest, "phx-click") || Map.get(rest, :"phx-click")
  end

  defp user_click(_rest), do: nil

  defp to_js(nil), do: %JS{}
  defp to_js(%JS{} = js), do: js
  defp to_js(event) when is_binary(event), do: JS.push(event)
end
