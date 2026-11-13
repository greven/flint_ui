defmodule FlintUI.Base.Alert do
  @moduledoc """
  A prominent message that communicates a status, warning, or error.

  ## Examples

      <FlintUI.alert intent="success" title="Saved">
        Your changes are now live.
      </FlintUI.alert>

      <FlintUI.alert intent="warning" title="Storage almost full">
        You have used 90% of your plan.
        <:actions>
          <FlintUI.button size="sm" variant="subtle" color="warning">Upgrade</FlintUI.button>
        </:actions>
      </FlintUI.alert>

  The `title` names the message and the default slot is its body. Both render
  when both are set. Actions render below the body, or beside it when
  `orientation="horizontal"`.

  `intent` selects the theme color and a default icon. Pass `show_icon={false}`
  on the styled wrapper to keep the intent color without the icon, or supply a
  `:icon` slot to replace the default. An explicit icon always renders.

  The alert root is a plain region. `show_close` adds only the close button; the
  rest of the alert keeps its content semantics.

  ## Accessibility

  The root is a live region. `warning` and `error` intents default to
  `role="alert"` (assertive); the other intents default to `role="status"`
  (polite). Pass `role` yourself to choose another role or to make a purely
  static callout `role="none"`.

  The intent icon is decorative because the text carries the meaning. If you
  replace it with a labeled icon, the label becomes part of the alert's content.

  Keep the title and body meaningful without the icon or color. When the alert is
  inserted or updated dynamically, the live region announces the change; a
  static callout still reads correctly without an announcement.

  `show_close` renders a native close button named by `close_label`. Dismissing
  hides the alert in the browser and removes it from the accessibility tree. If
  the alert is rendered from server state, set `close_event` so your handler can
  remove it and show the next state; hiding alone returns on the next render.

  ## Closing

  The close button dispatches the client command `fl:alert:close` and hides the
  nearest alert. When `close_event` is set, it also pushes that server event with
  `%{"id" => id}` so the server can remove the alert from its assigns.

      <FlintUI.alert id="billing-alert" show_close close_event="dismiss_alert">
        Your trial ends in three days.
      </FlintUI.alert>

      def handle_event("dismiss_alert", %{"id" => id}, socket) do
        {:noreply, update(socket, :alerts, &Enum.reject(&1, fn alert -> alert.id == id end))}
      end

  To close an alert from a server-rendered control, use `close_alert/2` with the
  alert's `id`. It dispatches `fl:alert:close` and hides the alert:

      <FlintUI.button phx-click={FlintUI.close_alert("billing-alert")}>
        Hide notice
      </FlintUI.button>

  The helper targets an id, so give the alert one when you use it. Without
  `close_event`, the alert stays hidden until the server re-renders it.

  ## Keyboard

  The alert adds no keyboard interaction. Its close button and any controls in
  the actions slot keep their native button behavior.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :alert,
      type: :feedback,
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
          value: "alert",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the alert root element."
        },
        %Meta.PartAttr{
          name: "[data-intent]",
          value: ~s("neutral" | "info" | "success" | "warning" | "error"),
          description: "The semantic intent, when set. It selects the default icon and color."
        },
        %Meta.PartAttr{
          name: "[data-orientation]",
          value: ~s("vertical" | "horizontal"),
          description: "Where the actions sit relative to the content."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description:
            "The optional DOM id. Required when closing the alert with `close_alert/2`."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("alert" | "status" | "none"),
          description:
            "The live-region role. `warning`/`error` default to `alert`, the other intents default to `status`. A caller-supplied role wins."
        }
      ],
      icon: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "icon",
          description: "Identifies the icon region. Rendered only when an icon is present."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the region wrapping the title, body, and actions."
        }
      ],
      title: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "title",
          description: "Identifies the title line."
        }
      ],
      body: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "body",
          description: "Identifies the default-slot body."
        }
      ],
      actions: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "actions",
          description: "Identifies the actions region."
        }
      ],
      close: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "close",
          description: "Identifies the close button."
        },
        %Meta.PartAttr{
          name: "type",
          value: "button",
          description: "Prevents the close button from submitting an enclosing form."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "The accessible name of the close button, from `close_label`."
        },
        %Meta.PartAttr{
          name: "phx-click",
          value: "Phoenix.LiveView.JS",
          description:
            "Dispatches `fl:alert:close`, hides the nearest alert, and pushes `close_event` when set."
        }
      ],
      close_icon: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "close-icon",
          description:
            "Identifies the fallback close glyph. The styled wrapper replaces it with an icon."
        }
      ]
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:alert:close",
        source: :client,
        doc:
          "Client command event that hides the alert. The close button and `close_alert/2` dispatch it; consumers can listen for it on the alert. Carries no payload."
      }
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves focus to the close button and any controls in the actions slot."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Activates the focused close button or action control."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Activates the focused close button or action control."
      }
    ]
  end

  @intents ~w(neutral info success warning error)

  @impl true
  def build_attrs(%{intent: intent} = assigns) when is_nil(intent) or intent in @intents do
    %{
      root: %{
        "data-element" => "alert",
        "data-part" => "root",
        "id" => assigns.id,
        "data-intent" => assigns.intent,
        "data-orientation" => assigns.orientation,
        "role" => assigns.role || alert_role(assigns)
      },
      icon: %{"data-part" => "icon"},
      content: %{"data-part" => "content"},
      title: %{"data-part" => "title"},
      body: %{"data-part" => "body"},
      actions: %{"data-part" => "actions"},
      close: %{
        "type" => "button",
        "data-part" => "close",
        "aria-label" => assigns.close_label,
        "phx-click" => close_click(assigns)
      },
      close_icon: %{"data-part" => "close-icon"}
    }
  end

  def build_attrs(%{intent: intent}) do
    raise ArgumentError,
          "invalid alert intent #{inspect(intent)}; expected one of #{Enum.join(@intents, ", ")}"
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :as, :string, default: "div", doc: "The HTML element to render the alert root as."

  attr :intent, :string,
    default: nil,
    doc:
      "The semantic meaning of the message: `neutral`, `info`, `success`, `warning`, or `error`. It selects the default icon and is the fallback color when `color` is not set."

  attr :title, :string,
    default: nil,
    doc: "A title line rendered above the body. The default slot is the body."

  attr :show_close, :boolean,
    default: false,
    doc:
      "Whether to render a close button. It hides the alert in the browser and pushes `close_event` when set."

  attr :close_label, :string,
    default: "Dismiss",
    doc: "The accessible name for the close button."

  attr :close_event, :string,
    default: nil,
    doc:
      "The server event pushed when the close button is clicked. The payload includes the alert `id`."

  attr :orientation, :string,
    values: ~w(vertical horizontal),
    default: "vertical",
    doc: "Where the actions sit relative to the content."

  attr :id, :string,
    default: nil,
    doc: "The optional DOM id. Required when closing the alert with `close_alert/2`."

  attr :role, :string,
    default: nil,
    doc:
      "The live-region role. Defaults to `alert` for warning and error intents, and `status` otherwise."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, doc: "The body of the alert."

  slot :icon,
    doc:
      "An icon rendered before the content. It replaces the default intent icon; the styled wrapper supplies one from the intent when this slot is absent."

  slot :actions,
    doc:
      "Actions rendered below the body, or beside it with `orientation=\"horizontal\"`. May be repeated."

  slot :close,
    doc:
      "Content for the close button. The styled wrapper supplies a close icon; the unstyled base falls back to a multiplication glyph."

  @impl true
  def render(assigns) do
    ~H"""
    <% icon = render_slot(@icon) %>
    <% body = render_slot(@inner_block) %>
    <% actions = render_slot(@actions) %>
    <% close = render_slot(@close) %>
    <.dynamic_tag tag_name={@as} {@rest} {@flint_parts[:root]}>
      <div :if={present?(icon)} {@flint_parts[:icon]}>{icon}</div>
      <div {@flint_parts[:content]}>
        <div :if={present?(@title)} {@flint_parts[:title]}>{@title}</div>
        <div :if={present?(body)} {@flint_parts[:body]}>{body}</div>
        <div :if={present?(actions)} {@flint_parts[:actions]}>{actions}</div>
      </div>
      <button :if={@show_close} {@flint_parts[:close]}>
        <%= if present?(close) do %>
          {close}
        <% else %>
          <span {@flint_parts[:close_icon]} aria-hidden="true">&times;</span>
        <% end %>
      </button>
    </.dynamic_tag>
    """
  end

  ## Helpers

  @doc """
  Returns the default Lucide icon class for an alert intent, or `nil`.
  """
  def intent_icon("neutral"), do: "lucide-info"
  def intent_icon("info"), do: "lucide-info"
  def intent_icon("success"), do: "lucide-circle-check"
  def intent_icon("warning"), do: "lucide-circle-exclamation-point"
  def intent_icon("error"), do: "lucide-circle-x"
  def intent_icon(_intent), do: nil

  @doc """
  Closes the alert with the given DOM id from the client.

  Dispatches `fl:alert:close` and hides the alert. Use it in a `phx-click` on a
  server-rendered control:

      <FlintUI.button phx-click={FlintUI.close_alert("billing-alert")}>
        Hide notice
      </FlintUI.button>
  """
  def close_alert(js \\ %JS{}, id) do
    js
    |> JS.dispatch("fl:alert:close", to: "##{id}")
    |> JS.hide(to: "##{id}")
  end

  defp close_click(assigns) do
    %JS{}
    |> maybe_push_close(assigns)
    |> JS.dispatch("fl:alert:close", to: closest_alert())
    |> JS.hide(to: closest_alert())
  end

  defp maybe_push_close(js, %{close_event: event} = assigns)
       when is_binary(event) and event != "" do
    JS.push(js, event, value: %{id: assigns.id})
  end

  defp maybe_push_close(js, _assigns), do: js

  defp closest_alert, do: {:closest, ~s([data-element="alert"])}

  defp present?(nil), do: false
  defp present?(value) when is_binary(value), do: String.trim(value) != ""

  defp present?(rendered) do
    rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary() |> String.trim() != ""
  end

  defp alert_role(%{intent: intent}) when intent in ["warning", "error"], do: "alert"
  defp alert_role(_assigns), do: "status"
end
