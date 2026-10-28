defmodule FlintUI.Base.Button do
  @moduledoc """
  Renders a button that performs an action, or a link styled as a button.

  ## Examples

      <.button>Save</.button>
      <.button type="submit">Save</.button>
      <.button phx-click="delete" disabled>Delete</.button>

  `loading` is a pending state, not a second disabled state. The control keeps
  `aria-busy`, `aria-disabled`, and `data-loading`, stays focusable, and keeps
  its accessible name, but activation is ignored. FlintUI is unstyled, so add
  an indicator yourself when you want one:

      <.button loading={@saving}>
        <.icon :if={@saving} name="lucide-loader-circle" class="size-4 animate-spin" />
        Save
      </.button>

  Announce progress in a status region outside the control; `aria-busy` can defer
  announcements inside it:

      <.button loading={@saving} phx-click="save">Save</.button>
      <span role="status">{if @saving, do: "Saving…", else: ""}</span>

  Pass `href`, `navigate`, or `patch` to render a link instead of a button:

      <.button navigate={~p"/settings"}>Settings</.button>
      <.button patch={~p"/settings?tab=profile"}>Profile</.button>
      <.button href="https://example.com" target="_blank" rel="noopener">
        Visit
      </.button>

  ## Accessibility

  Always provide an accessible name. The content is the name in most cases, so
  prefix an icon-only button with `aria-label` or `aria-labelledby`.

  Action buttons render a native `<button>`, which browsers expose with an
  implicit `button` role and activate with both `Enter` and `Space`. Links
  render a native `<a>`, are exposed with an implicit `link` role, and are
  activated with `Enter` only.

  When `disabled` is set on a link, the `href`, `navigate`, or `patch`
  destination is removed, the link is marked with `aria-disabled="true"`, and it
  stays in the tab order so its state can be discovered. It cannot be activated.

  `loading` is the pending state. It sets `aria-busy="true"`,
  `aria-disabled="true"`, and `data-loading`, but leaves the native `disabled`
  attribute off. The control stays focusable and keeps its accessible name, so
  keyboard and screen-reader users do not lose their place. The bundled
  `flint.js` ignores activation while pending; guard the handler as well, because
  requests can bypass the button. The bundled `flint.js` swallows
  clicks and form submits while the control is pending; always guard the handler
  too, because the server is the authority. Do not pass `disabled={@loading}`:
  that removes the control from the focus order. Do not combine it with
  `phx-disable-with` either: LiveView renders the native `disabled` attribute
  and replaces the button's content for the request, so focus and the pending
  indicator are lost until the reply.

  Announce progress in a status region outside the control. `aria-busy` tells
  assistive technology to defer updates inside it, so text inside the button may
  not be announced. A persistent `role="status"` region whose text changes is
  the reliable pattern; reserve `aria-live="assertive"` for errors or urgent
  messages, not routine progress. Keep the button's accessible name stable
  rather than replacing it with `"Loading"`.

  A pending link drops its `href`, `navigate`, or `patch` destination and stays
  in the tab order, like a disabled link, while being announced as busy.

  ## Keyboard

  - `Enter` - activates a button or a link. Ignored while pending.
  - `Space` - activates a button. Has no effect on a link. Ignored while pending.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :button,
      type: :action,
      since: "0.1",
      status: :stable
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "button",
          description: "Identifies the component type. Shared by the button and link forms."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description:
            "Present when the button cannot be interacted with because `disabled` is set."
        },
        %Meta.PartAttr{
          name: "[data-loading]",
          value: "boolean",
          description:
            "Present when `loading` is set. The control is pending: focusable, non-activatable, and announced."
        },
        %Meta.PartAttr{
          name: "aria-busy",
          value: ~s("true"),
          description: "Set to `\"true\"` while `loading` is set."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: ~s("true"),
          description:
            "Set while the control is pending, and on a disabled link. A pending control stays focusable."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("button" | "submit" | "reset"),
          description: "The button type. Rendered only for an action button."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Disables the action button. Rendered only for an action button."
        }
      ]
    }
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Enter",
        description: "Activates an action button or a link. Ignored while pending."
      },
      %Meta.Keyboard{
        keys: "Space",
        description: "Activates an action button. Has no effect on a link. Ignored while pending."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    disabled? = disabled?(assigns)
    link? = link?(assigns)
    pending? = assigns.loading

    %{
      root: %{
        "data-element" => "button",
        "data-part" => "root",
        "data-disabled" => disabled?,
        "data-loading" => pending?,
        "aria-busy" => pending? && "true",
        "aria-disabled" => (pending? || (link? && disabled?)) && "true"
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :type, :string,
    default: "button",
    values: ~w(button submit reset),
    doc: "The button type, defaults to `button`. Rendered only for an action button."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the button should ignore user interaction."

  attr :loading, :boolean,
    default: false,
    doc:
      "Whether the control is pending. Sets `aria-busy`, `aria-disabled`, and `data-loading` while keeping it focusable; activation is ignored."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy name value form formaction formenctype
                formmethod formnovalidate formtarget popovertarget autofocus
                command commandfor),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of a button."

  slot :inner_block, required: true, doc: "The content of the button."

  @impl true
  def render(assigns) do
    cond do
      link?(assigns) && (disabled?(assigns) || assigns.loading) ->
        assigns = assign(assigns, :rest, drop_navigation(assigns.rest))

        ~H"""
        <a {@rest} role="link" tabindex="0" {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </a>
        """

      link?(assigns) ->
        ~H"""
        <.link {@rest} {@flint_parts[:root]}>{render_slot(@inner_block)}</.link>
        """

      true ->
        ~H"""
        <button {@rest} type={@type} disabled={@disabled} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </button>
        """
    end
  end

  defp link?(assigns) do
    rest = Map.get(assigns, :rest, %{})
    rest[:href] || rest[:navigate] || rest[:patch]
  end

  defp disabled?(assigns), do: assigns.disabled

  defp drop_navigation(rest) do
    Map.drop(rest, [:href, :navigate, :patch, :replace, :method, :csrf_token])
  end
end
