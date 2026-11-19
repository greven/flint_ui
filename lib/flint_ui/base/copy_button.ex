defmodule FlintUI.Base.CopyButton do
  @moduledoc """
  Renders a button that copies text to the clipboard.

  Use it for short, repeatable actions: copy a code snippet, an API key, a share
  link, or an install command. The button briefly confirms the result, then
  returns to its default state.

      <.copy_button value="mix flint.add copy_button" />

      <.copy_button from="install-command" label="Copy install command">
        Copy install command
      </.copy_button>

  Copying is a client-side action. It needs the bundled `flint.js` and, for the
  Clipboard API, a secure context (HTTPS or `localhost`). When the Clipboard API
  is unavailable, the bundled fallback uses `document.execCommand("copy")`.
  Without the bundle the button is inert; there is no server equivalent.

  ## Sources

  `value` copies a literal string. `from` names the id of an element in the same
  document and takes precedence over `value`; by default it copies that
  element's text content. Set `attribute` to copy one of its attributes instead,
  or `property` to copy a JavaScript property such as an input's `value`.
  `property` wins when both are set. An empty source is an error, not a silent
  no-op.

      <.copy_button from="profile-link" attribute="href" />
      <.copy_button from="email-input" property="value" />

  `label` is the button's accessible name and stays stable across states; the
  outcome is announced separately by a live region. When the button also shows
  visible text, keep `label` equal to that text so the name matches what the
  user sees. The styled wrapper uses `text` as the name when `label` is omitted.

  ## Feedback

  The bundled copy behavior sets `data-state` to `success` or `error` and clears it after
  `feedback_duration` milliseconds. A server render can clear that client state;
  the feedback is best-effort and never changes the source of truth. The
  styled layer swaps the icon for each state. Non-solid variants tint it with
  the success or error text role; solid variants keep the button's label color.
  Announcements are made through one shared, visually-hidden `role="status"`
  region, so the button's name never changes.

  The styled wrapper can also recolor the whole control while the success state
  is visible (`success_color`) and show the same labels in a tooltip
  (`tooltip`) on hover and focus, which is useful for an icon-only button. The
  tooltip follows the copy state without touching `data-state`.

  ## Variants and styling

  The styled wrapper opts into the shared control primitive, so a copy button
  supports the same `variant`, `dashed`, `color`, `size`, `radius`, `pill`,
  `square`, `wide`, `justify`, `depth`, and `inset` props as a button. The
  default is the quiet `ghost` treatment; pass the surrounding variant when the
  copy button joins a group. The shared inputs are `--fl-control-color`,
  `-color-content`, `-text`, `-soft`, and `-soft-border`. See the Button docs
  for the full variant and color contract.

  The base stays unstyled. The styled wrapper adds `data-control`; the copy
  anatomy layers the state stack on top of the shared control.

  ## Accessibility

  Renders a native `<button>` with `type="button"`, so it never submits an
  enclosing form. The button always carries `aria-label`, which keeps the
  accessible name stable while the icon or state content changes. The success
  and error content is decorative and hidden from assistive technology; the
  live region announces the result.

  Do not rely on the icon swap alone to communicate success or failure. The
  default labels are "Copied" and "Copy failed"; customize them with
  `success_label` and `error_label`.

  A disabled button uses the native `disabled` attribute, leaves the tab order,
  and ignores the copy behavior.

  ## Keyboard

  - `Tab` - moves focus to the control. A disabled button leaves the tab order.
  - `Enter` - copies the source.
  - `Space` - copies the source.
  """

  use FlintUI.Component

  alias FlintUI.Field

  @impl true
  def meta do
    %Meta{
      name: :copy_button,
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
          value: "copy_button",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-copy]",
          value: "boolean",
          description:
            "Marks the element as a copy trigger. The bundled `flint.js` delegates the copy behavior to it."
        },
        %Meta.PartAttr{
          name: "[data-copy-value]",
          value: "string",
          description: "The literal text to copy, when `value` is set."
        },
        %Meta.PartAttr{
          name: "[data-copy-from]",
          value: "string",
          description: "The id of the source element, when `from` is set."
        },
        %Meta.PartAttr{
          name: "[data-copy-attribute]",
          value: "string",
          description: "The source attribute to copy, when `attribute` is set."
        },
        %Meta.PartAttr{
          name: "[data-copy-property]",
          value: "string",
          description: "The source JavaScript property to copy, when `property` is set."
        },
        %Meta.PartAttr{
          name: "[data-copy-duration]",
          value: "number",
          description: "How long the success or error state stays visible, in milliseconds."
        },
        %Meta.PartAttr{
          name: "[data-copy-success-label]",
          value: "string",
          description: "The message the live region announces after a successful copy."
        },
        %Meta.PartAttr{
          name: "[data-copy-error-label]",
          value: "string",
          description: "The message the live region announces after a failed copy."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("success" | "error"),
          description:
            "Set by `flint.js` while feedback is visible, then removed. Absence is the idle state."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when `disabled` is set."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("button"),
          description: "Always renders `button`, so the control never submits a form."
        },
        %Meta.PartAttr{
          name: "aria-label",
          value: "string",
          description:
            "The accessible name from `label`. Kept stable while the state content changes."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Disables the button."
        }
      ],
      states: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "states",
          description:
            "The three-state stack. It keeps the button width stable while the idle, success, and error content swap."
        }
      ],
      copy_state: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "copy_state",
          description: "The default content, visible while the button is idle."
        }
      ],
      success_state: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "success_state",
          description:
            "The content shown after a successful copy. It is decorative and `aria-hidden`; the live region announces the result."
        }
      ],
      error_state: [
        %Meta.PartAttr{
          name: "[data-part]",
          value: "error_state",
          description:
            "The content shown after a failed copy. It is decorative and `aria-hidden`; the live region announces the result."
        }
      ]
    ]
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab",
        description: "Moves focus to the control. A disabled button leaves the tab order."
      },
      %Meta.Keyboard{keys: "Enter", description: "Copies the source."},
      %Meta.Keyboard{keys: "Space", description: "Copies the source."}
    ]
  end

  @impl true
  def states do
    [
      %Meta.State{
        name: "success",
        description: "Applied briefly after a successful copy.",
        selector: ~s([data-element="copy_button"][data-state="success"])
      },
      %Meta.State{
        name: "error",
        description: "Applied briefly after a failed copy.",
        selector: ~s([data-element="copy_button"][data-state="error"])
      },
      %Meta.State{
        name: "disabled",
        description: "The button is disabled.",
        selector: ~s([data-element="copy_button"][data-disabled])
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    root =
      %{
        "data-element" => "copy_button",
        "data-part" => "root",
        "aria-label" => assigns.label,
        "data-copy" => true,
        "data-disabled" => assigns.disabled,
        "data-copy-duration" => assigns.feedback_duration,
        "data-copy-success-label" => assigns.success_label,
        "data-copy-error-label" => assigns.error_label
      }
      |> Field.put_present("data-copy-value", assigns.value)
      |> Field.put_present("data-copy-from", assigns.from)
      |> Field.put_present("data-copy-attribute", assigns.attribute)
      |> Field.put_present("data-copy-property", assigns.property)

    %{
      root: root,
      states: %{"data-part" => "states"},
      copy_state: %{"data-part" => "copy_state"},
      success_state: %{"data-part" => "success_state"},
      error_state: %{"data-part" => "error_state"}
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :value, :string,
    default: nil,
    doc: "The literal text to copy. Ignored when `from` is set."

  attr :from, :string,
    default: nil,
    doc:
      "The id of an element to copy from. Takes precedence over `value`. By default the element's text content is copied."

  attr :attribute, :string,
    default: nil,
    doc:
      "An attribute name to copy from the `from` element instead of its text content, such as `href` or `value`."

  attr :property, :string,
    default: nil,
    doc:
      "A JavaScript property to copy from the `from` element, such as an input's `value`. Takes precedence over `attribute`."

  attr :label, :string,
    default: "Copy",
    doc:
      "The accessible name, rendered as `aria-label`. Keep it stable across states; the live region announces the result. When the button shows visible text, keep `label` equal to that text. The styled wrapper derives the name from `text` when `label` is omitted."

  attr :success_label, :string,
    default: "Copied",
    doc: "The message announced after a successful copy."

  attr :error_label, :string,
    default: "Copy failed",
    doc: "The message announced after a failed copy."

  attr :feedback_duration, :integer,
    default: 2000,
    doc: "How long the success or error state stays visible, in milliseconds."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether the button should ignore user interaction."

  attr :rest, :global,
    include: ~w(autofocus form tabindex),
    doc: "Additional HTML attributes. A caller-supplied `aria-label` overrides `label`."

  slot :inner_block, required: true, doc: "The default content, shown while the button is idle."

  slot :success,
    doc:
      "Decorative content shown after a successful copy. Hidden from assistive technology; the live region announces the result."

  slot :error,
    doc:
      "Decorative content shown after a failed copy. Hidden from assistive technology; the live region announces the result."

  @impl true
  def render(assigns) do
    ~H"""
    <button
      {@rest}
      type="button"
      disabled={@disabled}
      {@flint_parts[:root]}
    >
      <span {@flint_parts[:states]}>
        <span {@flint_parts[:copy_state]}>{render_slot(@inner_block)}</span>
        <span :if={@success != []} {@flint_parts[:success_state]} aria-hidden="true">
          {render_slot(@success)}
        </span>
        <span :if={@error != []} {@flint_parts[:error_state]} aria-hidden="true">
          {render_slot(@error)}
        </span>
      </span>
    </button>
    """
  end
end
