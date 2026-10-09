defmodule FlintUI.Toggle do
  @moduledoc """
  Renders a two-state button that is either pressed or not pressed.

  Use it to switch a feature or setting on and off, such as bold text or a
  muted microphone.

  ## Examples

      <.toggle>Bold</.toggle>

      <.toggle pressed>
        <.icon name="lucide-bold" class="size-4" /> Bold
      </.toggle>

  The button always updates its own `aria-pressed` and `data-state` attributes
  when clicked, so the state is reflected immediately. Pass `on_click` to also
  run a `Phoenix.LiveView.JS` command or push a server event. The `pressed`
  attribute is the source of truth, and the client state reconciles with it on
  the next render.

      <.toggle on_click={JS.push("toggle-bold")}>Bold</.toggle>

  ## Accessibility

  Renders a native `<button>` with `aria-pressed`, which exposes the on/off
  state to assistive technology. Keep the button's text stable between states;
  change an icon instead. An icon-only toggle needs an accessible name, so pass
  `aria-label` or `aria-labelledby`.

  ## Keyboard

  - `Enter` - toggles the button.
  - `Space` - toggles the button.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :toggle,
      type: :element,
      since: "0.1.0",
      status: :draft
    }
  end

  @impl true
  def parts_attrs do
    %{
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
          description: "The pressed state, for styling."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when `disabled` is set."
        },
        %Meta.PartAttr{
          name: "aria-pressed",
          value: ~s("true" | "false"),
          description: "The pressed state, exposed to assistive technology."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("button" | "submit" | "reset"),
          description: "The button type."
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
            "Toggles `aria-pressed` and `data-state` client-side, then runs `on_click` when set."
        }
      ]
    }
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{keys: "Enter", description: "Toggles the button."},
      %Meta.Keyboard{keys: "Space", description: "Toggles the button."}
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "type" => assigns.type,
        "aria-pressed" => to_string(assigns.pressed),
        "data-element" => "toggle",
        "data-part" => "root",
        "data-state" => if(assigns.pressed, do: "on", else: "off"),
        "data-disabled" => assigns.disabled,
        "disabled" => assigns.disabled,
        "phx-click" => click(assigns.on_click)
      }
    }
  end

  @doc false

  attr(:flint_parts, :map, default: nil)

  attr(:pressed, :boolean,
    default: false,
    doc: "Whether the button is currently pressed. The server-side source of truth."
  )

  attr(:on_click, :any,
    default: nil,
    doc:
      "A `Phoenix.LiveView.JS` command or server event name to run when clicked. The client state updates regardless."
  )

  attr(:type, :string,
    default: "button",
    values: ~w(button submit reset),
    doc: "The button type, defaults to `button`."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Whether the button should ignore user interaction."
  )

  attr(:rest, :global, doc: "Additional HTML attributes.")

  slot(:inner_block, required: true, doc: "The content of the toggle button.")

  @impl true
  def render(assigns) do
    ~H"""
    <button {@flint_parts[:root]} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  defp click(on_click) do
    on_click
    |> to_js()
    |> JS.toggle_attribute({"aria-pressed", "true", "false"})
    |> JS.toggle_attribute({"data-state", "on", "off"})
  end

  defp to_js(nil), do: %JS{}
  defp to_js(%JS{} = js), do: js
  defp to_js(event) when is_binary(event), do: JS.push(event)
end
