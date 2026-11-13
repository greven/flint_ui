defmodule FlintUI.Base.Button do
  @moduledoc """
  Renders a button that performs an action, or a link styled as a button.

  ## Examples

      <.button>Save</.button>
      <.button type="submit">Save</.button>
      <.button phx-click="delete" disabled>Delete</.button>

  `loading` is a pending state, not a second disabled state. The control keeps
  `aria-busy`, `aria-disabled`, and `data-loading`, stays focusable unless
  `disabled` is also set, and keeps its accessible name, but activation is
  ignored while `flint.js` is loaded. FlintUI is unstyled, so add an indicator
  yourself when you want one:

      <.button loading={@saving}>
        <.icon :if={@saving} name="lucide-loader-circle" class="size-4 animate-spin" />
        Save
      </.button>

  Announce progress in a status region outside the control. `aria-busy` marks
  the control as updating and can defer announcements inside it, but it does not
  announce the change itself:

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

  Use the button form for actions and the link form for navigation. A link
  styled as a button keeps link semantics: `Enter` activates it and `Space`
  does not. If the control changes state, render a button instead.

  Action buttons render a native `<button>`, which browsers expose with an
  implicit `button` role and activate with both `Enter` and `Space`. Links
  render a native `<a>`, are exposed with an implicit `link` role, and are
  activated with `Enter` only.

  When `disabled` is set on a link, the `href`, `navigate`, or `patch`
  destination is removed, the link is marked with `aria-disabled="true"`, and it
  stays in the tab order so its state can be discovered. `flint.js` also blocks
  clicks on it. Without the bundle, keyboard activation still fires click
  handlers, so guard them server-side. An action button uses the native
  `disabled` attribute and leaves the tab order. A link has no native equivalent,
  so this difference is deliberate.

  `loading` is the pending state. It sets `aria-busy="true"`,
  `aria-disabled="true"`, and `data-loading`, but leaves the native `disabled`
  attribute off. The control stays focusable unless `disabled` is also set, and
  keeps its accessible name, so keyboard and screen-reader users do not lose
  their place.

  The bundled `flint.js` blocks clicks and form submits while the control is
  pending; always guard the handler too, because the server is the authority and
  requests can bypass the control. Without `flint.js`, pending is advisory: the
  control still activates, so the server guard is required.

  Do not pass `disabled={@loading}`: that removes the control from the focus
  order. Do not combine it with `phx-disable-with` either: LiveView renders the
  native `disabled` attribute and replaces the button's content for the request,
  so focus and the pending indicator are lost until the reply. LiveView also
  disables every button in a form during `phx-submit` while it waits for the
  reply, so a focused submit button loses focus for that window even without
  `phx-disable-with`. Use `phx-click` with a server guard when focus
  preservation matters.

  A pending link drops its `href`, `navigate`, or `patch` destination and stays
  in the tab order, like a disabled link. A pending submit button renders
  `type="button"`, so it does not submit the form, it returns to `type="submit"`
  when the operation finishes. The guard still blocks submits while the
  operation is pending.

  ## Keyboard

  - `Tab` - moves focus to the control. A disabled link stays in the tab order;
    a disabled action button does not.
  - `Enter` - activates an action button or a link. Ignored while pending.
  - `Space` - activates an action button. Does not activate a link; the browser
    scrolls the page. Ignored while pending.
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
    [
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
            "Present when `disabled` is set. Action buttons also render the native `disabled` attribute; links stay focusable."
        },
        %Meta.PartAttr{
          name: "[data-loading]",
          value: "boolean",
          description:
            "Present when `loading` is set. The control is pending: focusable unless also hard-disabled, and non-activatable while `flint.js` is loaded. Pair it with a status region,
            `aria-busy` alone does not announce."
        },
        %Meta.PartAttr{
          name: "[data-pending-submit]",
          value: "boolean",
          description:
            "Present on a pending `type=\"submit\"` button, which renders `type=\"button\"` and therefore does not submit the form. Used by `flint.js` to block implicit submission."
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
            "Set while the control is pending, and on a disabled link. A pending control stays focusable unless also disabled."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("link"),
          description:
            "Set on a disabled or pending link. A link with no destination has no implicit link role."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: ~s("0"),
          description:
            "Set on a disabled or pending link so it stays focusable. Not rendered on action buttons."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("button" | "submit" | "reset"),
          description:
            "The button type. A pending submit button renders `type=\"button\"` so it does not submit the form. Rendered only for an action button."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Disables the action button. Rendered only for an action button."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description:
          "Moves focus to the control. A disabled link stays in the tab order, a disabled action button does not."
      },
      %Meta.Keyboard{
        keys: "Enter",
        description: "Activates an action button or a link. Ignored while pending."
      },
      %Meta.Keyboard{
        keys: "Space",
        description:
          "Activates an action button. Does not activate a link; the browser scrolls the page. Ignored while pending."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "disabled",
        description: "The button is disabled.",
        selector: ~s([data-element="button"][data-disabled])
      },
      %Meta.State{
        name: "loading",
        description: "The button is loading and cannot be activated.",
        selector: ~s([data-element="button"][data-loading])
      },
      %Meta.State{
        name: "pending-submit",
        description:
          "Applied while a submit button is pending; implicit form submission is blocked.",
        selector: ~s([data-element="button"][data-pending-submit])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    disabled? = disabled?(assigns)
    link? = link?(assigns)
    pending? = assigns.loading
    fallback_link? = link? && (disabled? || pending?)
    pending_submit? = pending? && !link? && assigns.type == "submit"

    root = %{
      "data-element" => "button",
      "data-part" => "root",
      "data-disabled" => disabled?,
      "data-loading" => pending?,
      "aria-busy" => pending? && "true",
      "aria-disabled" => (pending? || (link? && disabled?)) && "true"
    }

    root =
      if fallback_link? do
        Map.merge(root, %{"role" => "link", "tabindex" => "0"})
      else
        root
      end

    root = if pending_submit?, do: Map.put(root, "data-pending-submit", true), else: root

    %{root: root}
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :type, :string,
    default: "button",
    values: ~w(button submit reset),
    doc:
      "The button type, defaults to `button`. A pending submit button renders `type=\"button\"` until loading clears. Rendered only for an action button."

  attr :disabled, :boolean,
    default: false,
    doc:
      "Whether the control is disabled. A button renders the native `disabled` attribute, a link loses its destination and stays focusable."

  attr :loading, :boolean,
    default: false,
    doc:
      "Whether the control is pending. Sets `aria-busy`, `aria-disabled`, and `data-loading` while keeping it focusable unless `disabled` is also set. `flint.js` blocks activation, always guard the server event."

  attr :rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy name value form formaction formenctype
                formmethod formnovalidate formtarget popovertarget autofocus
                command commandfor),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of a button. Use the link form for navigation and the button form for actions."

  slot :inner_block, required: true, doc: "The content of the button."

  @impl true
  def render(assigns) do
    cond do
      link?(assigns) && (disabled?(assigns) || assigns.loading) ->
        assigns = assign(assigns, :rest, drop_navigation(assigns.rest))

        ~H"""
        <a {@rest} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </a>
        """

      link?(assigns) ->
        ~H"""
        <.link {@rest} {@flint_parts[:root]}>{render_slot(@inner_block)}</.link>
        """

      true ->
        assigns = assign(assigns, :rest, drop_navigation(assigns.rest))

        ~H"""
        <button {@rest} type={button_type(assigns)} disabled={@disabled} {@flint_parts[:root]}>
          {render_slot(@inner_block)}
        </button>
        """
    end
  end

  defp button_type(%{loading: true, type: "submit"}), do: "button"
  defp button_type(assigns), do: assigns.type

  defp link?(assigns) do
    rest = Map.get(assigns, :rest, %{})
    Enum.any?([:href, :navigate, :patch], &present?(rest[&1]))
  end

  defp present?(value), do: value not in [nil, false, ""]

  defp disabled?(assigns), do: assigns.disabled

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
