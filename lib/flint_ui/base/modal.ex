defmodule FlintUI.Base.Modal do
  @moduledoc """
  A modal dialog that interrupts the page for a focused task or confirmation.

  Use a modal for a task that needs the user's full attention: a form, a
  destructive confirmation, or a short flow that should not be interrupted. Use
  `FlintUI.popover` for a surface anchored to a trigger, and
  `FlintUI.dropdown` for a compact list of actions.

  The component renders a native `<dialog>` element and opens it with
  `showModal/1`. The browser owns modality: the dialog joins the top layer, the
  rest of the page becomes inert, focus is contained, and `Escape` is reported
  through the dialog's `cancel` event. That is why a modal must be opened from
  JavaScript. `mix flint.setup` installs the hook with the rest of the theme.

  ## Examples

  Open a modal from a control anywhere on the page with `open_modal/2`:

      <FlintUI.button phx-click={FlintUI.open_modal("invite")}>Invite</FlintUI.button>

      <FlintUI.modal id="invite">
        <:title>Invite teammate</:title>
        <:description>Send an invitation to join the workspace.</:description>

        <FlintUI.input name="email" type="email" label="Email" />

        <:footer>
          <FlintUI.button phx-click={FlintUI.close_modal("invite")}>Cancel</FlintUI.button>
        </:footer>
      </FlintUI.modal>

  The `:title` slot is the dialog's heading and its accessible name. The
  `:description` slot carries supporting text and is wired as the dialog's
  description. Both are optional, but give the dialog a name with a title or
  `aria_label`/`aria_labelledby`.

  A confirmation is the same component with `role="alertdialog"`, no backdrop
  dismissal, and explicit focus on the least destructive action:

      <FlintUI.modal
        id="archive"
        role="alertdialog"
        show_close={false}
        close_on_backdrop={false}
      >
        <:title>Archive project?</:title>
        <:description>You can restore it from the trash within 30 days.</:description>

        <:footer>
          <FlintUI.button autofocus phx-click={FlintUI.close_modal("archive")}>
            Cancel
          </FlintUI.button>
          <FlintUI.button color="danger">Archive</FlintUI.button>
        </:footer>
      </FlintUI.modal>

  ## Forms

  The dialog is rendered where you write it; it is not portalled. A modal
  rendered inside a form can therefore submit that form, including its fields.
  A modal with its own form should be rendered outside any enclosing form,
  because forms cannot nest. Use the `form` attribute on a footer control when
  the control sits outside the form it submits.

  The built-in close button is always `type="button"`, so it never submits an
  enclosing form.

  ## Controlled state

  `opened` is the initial open state and remains a server-driven input: changing
  it after mount opens or closes the modal. User opens and closes are
  client-side until the server renders a different value. Set `open_event`,
  `close_event`, or `toggle_event` to push the new state to the server. The
  payload is a map with the modal's `id` and `open` state.

  Server-driven changes do not push those events back to the server, so a
  delayed prompt opened from `handle_info/2` does not echo its own open. The
  `fl:modal:change` DOM event still fires on every state change.

  ## Accessibility

  The root is a native `<dialog>` opened with `showModal/1`:

    * the dialog is rendered in the top layer, so an `overflow: hidden`
      ancestor cannot clip it and a sibling's `z-index` cannot cover it;
    * every element outside the dialog is made inert by the browser;
    * focus is contained inside the dialog while it is open;
    * closing returns focus to the element that opened it.

  The root carries `aria-modal="true"`. Use `role="alertdialog"` for a
  confirmation that requires an explicit response. The title slot renders an
  `h2`; a dialog is a sectioning root, so its heading does not disturb the
  page's heading outline.

  While closed, the dialog is `display: none`, so it is neither exposed nor
  focusable. Give it an accessible name with `:title`, `aria_label`, or
  `aria_labelledby`, and an optional description with `:description` or
  `aria_describedby`.

  Opening focuses the first `[autofocus]` element, then the first focusable
  element, then the content container. Put `autofocus` on the element the user
  should interact with immediately, such as the first field or the Cancel button
  of a confirmation.

  A modal locks page scroll by default so the page behind it cannot move. Set
  `lock_scroll` to `false` when the dialog is embedded in a scrolling region
  that must keep scrolling.

  ## Keyboard

  - `Escape` - closes the modal and returns focus to the element that opened it,
    unless `close_on_esc` is `false`.
  - `Tab` / `Shift+Tab` - moves focus through the dialog. Focus wraps inside it
    while the dialog is modal.
  - `Enter` / `Space` - activates the focused control, including the built-in
    close button.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :modal,
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
          name: "id",
          value: "string",
          description: "The stable DOM id that opens and closes the modal by command."
        },
        %Meta.PartAttr{
          name: "phx-hook",
          value: "FlintUI.Modal",
          description: "The JS hook that opens the dialog, focuses it, and manages dismissal."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "modal",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the dialog element, which is also the modal surface."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state, managed by the hook."
        },
        %Meta.PartAttr{
          name: "[data-opened]",
          value: ~s("true" | "false"),
          description:
            "The server-driven open input. The hook applies it on mount and whenever the value changes."
        },
        %Meta.PartAttr{
          name: "[data-close-on-esc]",
          value: "boolean",
          description: "Present when `Escape` closes the modal."
        },
        %Meta.PartAttr{
          name: "[data-close-on-backdrop]",
          value: "boolean",
          description: "Present when a backdrop click closes the modal."
        },
        %Meta.PartAttr{
          name: "[data-lock-scroll]",
          value: "boolean",
          description: "Present when the hook locks page scroll while the modal is open."
        },
        %Meta.PartAttr{
          name: "[data-open-event]",
          value: "string",
          description: "Server event pushed when the modal opens."
        },
        %Meta.PartAttr{
          name: "[data-close-event]",
          value: "string",
          description: "Server event pushed when the modal closes."
        },
        %Meta.PartAttr{
          name: "[data-toggle-event]",
          value: "string",
          description: "Server event pushed on every open or close."
        },
        %Meta.PartAttr{
          name: "role",
          value: ~s("dialog" | "alertdialog"),
          description: "The dialog role. Use `alertdialog` for a confirmation."
        },
        %Meta.PartAttr{
          name: "aria-modal",
          value: "true",
          description: "Tells assistive technology that the dialog is modal."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description: "An explicit accessible name from the `aria_label` attribute."
        },
        %Meta.PartAttr{
          name: "aria-labelledby",
          value: "string",
          description:
            "An explicit name from `aria_labelledby`, or the generated title id when a title slot is present."
        },
        %Meta.PartAttr{
          name: "aria-describedby",
          value: "string",
          description:
            "An explicit description from `aria_describedby`, or the generated description id when a description slot is present."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description:
            "Identifies the focusable layout container inside the dialog. It carries the fallback focus target."
        },
        %Meta.PartAttr{
          name: "tabindex",
          value: "-1",
          description:
            "Lets the content receive focus when the dialog contains no focusable element."
        }
      ],
      header: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "header",
          description: "Identifies the header region wrapping the title and description."
        }
      ],
      title: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "title",
          description: "Identifies the dialog heading."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The heading id, used as the dialog's `aria-labelledby`."
        }
      ],
      description: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "description",
          description: "Identifies the supporting text under the title."
        },
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "The description id, used as the dialog's `aria-describedby`."
        }
      ],
      body: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "body",
          description: "Identifies the scrollable body region."
        }
      ],
      footer: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "footer",
          description: "Identifies the footer region that usually holds actions."
        }
      ],
      close: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "close",
          description: "Identifies the built-in close button."
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
          description: "Dispatches `fl:modal:close` to the closest modal."
        }
      ],
      close_icon: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "close-icon",
          description:
            "Identifies the fallback close glyph. The styled wrapper replaces it with an icon."
        },
        %Meta.PartAttr{
          name: "aria-hidden",
          value: "true",
          description: "The fallback glyph is decorative."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Escape",
        description:
          "Closes the modal and returns focus to the element that opened it, unless `close_on_esc` is `false`."
      },
      %Meta.Keyboard{
        keys: "Tab | Shift+Tab",
        description: "Moves focus through the dialog. Focus wraps inside a modal dialog."
      },
      %Meta.Keyboard{
        keys: "Enter / Space",
        description: "Activates the focused control, including the built-in close button."
      }
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:modal:open",
        source: :client,
        doc:
          "Client command event that opens the modal. Dispatch it with `open_modal/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:modal:close",
        source: :client,
        doc:
          "Client command event that closes the modal. Dispatch it with `close_modal/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:modal:toggle",
        source: :client,
        doc:
          "Client command event that toggles the modal. Dispatch it with `toggle_modal/2` or `Phoenix.LiveView.JS.dispatch/3`. Carries no payload."
      },
      %Meta.Event{
        name: "fl:modal:change",
        source: :client,
        doc:
          "Dispatched on the dialog whenever the open state changes. Bubbles up the DOM. The event `detail` is a map with a `state` key (`\"open\"` or `\"closed\"`)."
      }
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "open",
        description: "The modal is open.",
        selector: ~s([data-element="modal"][data-state="open"])
      },
      %Meta.State{
        name: "closed",
        description: "The modal is closed.",
        selector: ~s([data-element="modal"][data-state="closed"])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    id = assigns.id
    title_id = "#{id}-title"
    description_id = "#{id}-description"
    title? = slot_present?(assigns, :title)
    description? = slot_present?(assigns, :description)

    labelledby =
      assigns.aria_labelledby ||
        if(is_nil(assigns.aria_label) and title?, do: title_id, else: nil)

    describedby =
      assigns.aria_describedby || if(description?, do: description_id, else: nil)

    %{
      root: %{
        "id" => id,
        "phx-hook" => "FlintUI.Modal",
        "data-element" => "modal",
        "data-part" => "root",
        "data-state" => "closed",
        "data-opened" => to_string(assigns.opened),
        "data-close-on-esc" => assigns.close_on_esc,
        "data-close-on-backdrop" => assigns.close_on_backdrop,
        "data-lock-scroll" => assigns.lock_scroll,
        "data-open-event" => assigns.open_event,
        "data-close-event" => assigns.close_event,
        "data-toggle-event" => assigns.toggle_event,
        "role" => assigns.role,
        "aria-modal" => "true",
        "aria-label" => assigns.aria_label,
        "aria-labelledby" => labelledby,
        "aria-describedby" => describedby
      },
      content: %{
        "data-part" => "content",
        "tabindex" => "-1"
      },
      header: %{"data-part" => "header"},
      title: %{"data-part" => "title", "id" => title_id},
      description: %{"data-part" => "description", "id" => description_id},
      body: %{"data-part" => "body"},
      footer: %{"data-part" => "footer"},
      close: %{
        "type" => "button",
        "data-part" => "close",
        "aria-label" => assigns.close_label,
        "phx-click" => close_click()
      },
      close_icon: %{"data-part" => "close-icon", "aria-hidden" => "true"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string,
    required: true,
    doc:
      "The stable DOM id. A modal has no trigger to derive a handle from, so it is required for `open_modal/2`, `close_modal/2`, and the server events."

  attr :opened, :boolean,
    default: false,
    doc:
      "The initial open state. Changing it after mount opens or closes the modal, so the server can drive it too."

  attr :role, :string,
    default: "dialog",
    values: ~w(dialog alertdialog),
    doc:
      "The dialog role. Use `alertdialog` for a confirmation that requires an explicit response."

  attr :show_close, :boolean,
    default: true,
    doc:
      "Whether to render the built-in close button. Keep it unless the dialog provides its own dismissal controls."

  attr :close_label, :string,
    default: "Close",
    doc: "The accessible name for the built-in close button."

  attr :close_on_esc, :boolean,
    default: true,
    doc: "Whether pressing `Escape` closes the modal."

  attr :close_on_backdrop, :boolean,
    default: true,
    doc: "Whether clicking the backdrop outside the dialog closes the modal."

  attr :lock_scroll, :boolean,
    default: true,
    doc:
      "Whether to lock page scroll while the modal is open. Set it to `false` when the dialog lives in a scrolling region that must keep scrolling."

  attr :open_event, :string,
    default: nil,
    doc:
      "The server event pushed when the modal opens. The payload is a map with `id` and `open`."

  attr :close_event, :string,
    default: nil,
    doc:
      "The server event pushed when the modal closes. The payload is a map with `id` and `open`."

  attr :toggle_event, :string,
    default: nil,
    doc:
      "The server event pushed on every open or close. The payload is a map with `id` and `open`."

  attr :aria_label, :string,
    default: nil,
    doc:
      "An accessible name for the dialog, applied as `aria-label`. Use it when the title slot is not a good name. It suppresses the generated title reference."

  attr :aria_labelledby, :string,
    default: nil,
    doc:
      "The DOM id of an element that names the dialog, applied as `aria-labelledby`. Takes precedence over the generated title id."

  attr :aria_describedby, :string,
    default: nil,
    doc:
      "The DOM id of an element that describes the dialog, applied as `aria-describedby`. Takes precedence over the generated description id."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :title, doc: "The dialog heading. It renders as an `h2` and names the dialog."

  slot :description,
    doc: "Supporting text rendered under the title. It becomes the dialog's description."

  slot :inner_block, doc: "The dialog body."

  slot :footer, doc: "Content rendered at the end of the dialog, usually actions."

  slot :close,
    doc:
      "Content for the close button. The styled wrapper supplies a close icon; the unstyled base falls back to a multiplication glyph."

  @impl true
  def render(assigns) do
    ~H"""
    <% title = render_slot(@title) %>
    <% description = render_slot(@description) %>
    <% body = render_slot(@inner_block) %>
    <% footer = render_slot(@footer) %>
    <% close = render_slot(@close) %>
    <% title? = present?(title) %>
    <% description? = present?(description) %>
    <% body? = present?(body) %>
    <% footer? = present?(footer) %>
    <% close? = present?(close) %>
    <dialog {@rest} {@flint_parts[:root]}>
      <div {@flint_parts[:content]}>
        <header :if={title? or description? or @show_close} {@flint_parts[:header]}>
          <h2 :if={title?} {@flint_parts[:title]}>{title}</h2>
          <p :if={description?} {@flint_parts[:description]}>{description}</p>
        </header>
        <div :if={body?} {@flint_parts[:body]}>{body}</div>
        <footer :if={footer?} {@flint_parts[:footer]}>{footer}</footer>
        <button :if={@show_close} {@flint_parts[:close]}>
          <%= if close? do %>
            {close}
          <% else %>
            <span {@flint_parts[:close_icon]} aria-hidden="true">&times;</span>
          <% end %>
        </button>
      </div>
    </dialog>
    """
  end

  ## JS Helpers

  @doc """
  Opens the modal with the given DOM id from a `Phoenix.LiveView.JS` command.

  The command targets the modal root:

      <FlintUI.button phx-click={FlintUI.open_modal("invite")}>Invite</FlintUI.button>
  """
  def open_modal(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:modal:open", to: "##{id}")
  end

  @doc """
  Closes the modal with the given DOM id from a `Phoenix.LiveView.JS` command.

  The close button and any footer control can use it:

      <FlintUI.button phx-click={FlintUI.close_modal("invite")}>Cancel</FlintUI.button>
  """
  def close_modal(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:modal:close", to: "##{id}")
  end

  @doc """
  Toggles the modal with the given DOM id from a `Phoenix.LiveView.JS` command.
  """
  def toggle_modal(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:modal:toggle", to: "##{id}")
  end

  defp close_click do
    JS.dispatch(%JS{}, "fl:modal:close", to: {:closest, ~s([data-element="modal"])})
  end

  defp slot_present?(assigns, name) do
    case Map.get(assigns, name) do
      nil -> false
      [] -> false
      _ -> true
    end
  end

  defp present?(nil), do: false
  defp present?(value) when is_binary(value), do: String.trim(value) != ""

  defp present?(rendered) do
    rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary() |> String.trim() != ""
  end
end
