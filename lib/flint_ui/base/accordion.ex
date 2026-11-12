defmodule FlintUI.Base.Accordion do
  @moduledoc """
  A vertical stack of collapsible sections that reveal one or more panels.

  The accordion coordinates its items; each item owns its expanded state. Use a
  required `id` for each item and bind `expanded` to your state:

      <FlintUI.accordion id="faq">
        <FlintUI.accordion_item id="faq-shipping" label="Shipping" expanded>
          <:panel>Orders leave the warehouse in one business day.</:panel>
        </FlintUI.accordion_item>
        <FlintUI.accordion_item id="faq-returns" label="Returns">
          <:panel>Return any item within 30 days.</:panel>
        </FlintUI.accordion_item>
      </FlintUI.accordion>

  By default only one item is open at a time. Set `multiple` to keep several
  open, or `require_open` to prevent closing the last open item.

  ## Server-driven state

  `expanded` is re-read on every LiveView patch, so binding it to an assign makes
  the server the source of truth. The browser updates the clicked item
  optimistically; after the patch, the server-rendered state wins.

  Use the header slot to push an event with the header click:

      <FlintUI.accordion id="onboarding">
        <FlintUI.accordion_item
          :for={step <- @steps}
          id={"onboarding-\#{step.id}"}
          expanded={@current_step == step.id}
        >
          <:header phx-click={JS.push("focus_step", value: %{id: step.id})}>
            {step.title}
          </:header>
          <:panel>{step.body}</:panel>
        </FlintUI.accordion_item>
      </FlintUI.accordion>

  Render at most one `expanded` item when `multiple` is false. Single mode
  enforces exclusivity on interaction; it does not rewrite server-rendered
  state.

  ## Accessibility

  Every item header is a native `<button>` inside an `h2`–`h6` by default, so
  screen readers can navigate the accordion by heading. Each button carries
  `aria-expanded` and `aria-controls`; each panel is a `region` labelled by its
  header.

  All enabled headers stay in the page's normal tab sequence. Disabled items are
  skipped by the arrow keys and cannot be activated. Set `heading="none"` on an
  item only when the surrounding content already provides the heading
  structure.

  ## Keyboard

  - `Tab` / `Shift+Tab` - move through the page; every enabled header is
    focusable.
  - `ArrowDown` / `ArrowUp` - move focus to the next or previous enabled header,
    wrapping at the ends.
  - `Home` / `End` - move focus to the first or last enabled header.
  - `Enter` / `Space` - toggle the focused header.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :accordion,
      type: :action,
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
          value: "FlintUI.Accordion",
          description: "The JS hook that coordinates single mode, guarding, and keyboard focus."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "accordion",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-multiple]",
          value: "boolean",
          description: "Present when several items may be open at once."
        },
        %Meta.PartAttr{
          name: "[data-require-open]",
          value: "boolean",
          description: "Present when closing the last open item is prevented."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description: "Present when interactions are suppressed."
        }
      ]
    }
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{
        keys: "Tab / Shift+Tab",
        description: "Moves through the page; every enabled header is focusable."
      },
      %Meta.Keyboard{
        keys: "ArrowDown / ArrowUp",
        description: "Moves focus to the next or previous enabled header, wrapping at the ends."
      },
      %Meta.Keyboard{
        keys: "Home / End",
        description: "Moves focus to the first or last enabled header."
      },
      %Meta.Keyboard{
        keys: "Enter / Space",
        description: "Toggles the focused header."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "id" => assigns.id,
        "phx-hook" => "FlintUI.Accordion",
        "data-element" => "accordion",
        "data-part" => "root",
        "data-multiple" => assigns.multiple,
        "data-require-open" => assigns.require_open,
        "data-disabled" => assigns.disabled
      }
    }
  end

  @doc false

  attr :flint_parts, :map, default: nil, doc: false

  attr :id, :string, required: true, doc: "Unique component DOM id."

  attr :multiple, :boolean,
    default: false,
    doc: "Whether several items may be open at the same time."

  attr :require_open, :boolean,
    default: false,
    doc:
      "Whether at least one item must stay open. Closing the last open item is prevented. Render at least one item with `expanded`; server-driven state changes are not blocked."

  attr :disabled, :boolean,
    default: false,
    doc: "Whether user interaction with every item is suppressed."

  attr :rest, :global, doc: "Additional HTML attributes."

  slot :inner_block, required: true, doc: "The accordion items."

  @impl true
  def render(assigns) do
    ~H"""
    <div {@rest} {@flint_parts[:root]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  ## JS Helpers

  @doc """
  Opens an accordion item from a `Phoenix.LiveView.JS` command.

  The command targets the item root, so it works from any element:

      <button phx-click={FlintUI.open_accordion_item("faq-shipping")}>Open</button>
  """
  def open_accordion_item(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:open", to: "##{id}")
  end

  @doc """
  Closes an accordion item from a `Phoenix.LiveView.JS` command.

  Closing the last open item is prevented when the accordion sets
  `require_open`.
  """
  def close_accordion_item(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:close", to: "##{id}")
  end

  @doc """
  Toggles an accordion item from a `Phoenix.LiveView.JS` command.

  Closing the last open item is prevented when the accordion sets
  `require_open`.
  """
  def toggle_accordion_item(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:toggle", to: "##{id}")
  end
end
