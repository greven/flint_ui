defmodule FlintUI.Collapsible do
  @moduledoc """
  An interactive component that can show or hide content sections when triggered.

  ## Examples

    <FlintUI.collapsible id="example-collapsible" open>
      <:trigger :let={attrs}>
        <button {attrs} class="my-custom-class">Toggle</button>
      </:trigger>
      <:content :let={attrs}>
        <div {attrs} class="my-content-class">
          <p>Hidden content</p>
        </div>
      </:content>
    </FlintUI.collapsible>
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :collapsible,
      type: :misc,
      since: "0.1.0",
      status: :experimental
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
          value: "Collapsible",
          description: "The JS hook that powers the component."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "collapsible",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "true | false",
          description: "Whether interactions are suppressed."
        },
        %Meta.PartAttr{
          name: "[data-open-event]",
          value: "string",
          description: "Server event pushed on open."
        },
        %Meta.PartAttr{
          name: "[data-close-event]",
          value: "string",
          description: "Server event pushed on close."
        },
        %Meta.PartAttr{
          name: "[data-toggle-event]",
          value: "string",
          description: "Server event pushed on toggle."
        }
      ],
      trigger: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "collapsible",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "trigger",
          description: "Identifies the trigger element."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "true | false",
          description: "Whether trigger interactions are suppressed."
        },
        %Meta.PartAttr{
          name: "aria-controls",
          value: "string",
          description: "The ID of the controlled content element."
        },
        %Meta.PartAttr{
          name: "aria-expanded",
          value: "true | false",
          description: "Whether the content is expanded."
        },
        %Meta.PartAttr{
          name: "aria-disabled",
          value: "true | false",
          description: "Whether the trigger is disabled."
        }
      ],
      content: [
        %Meta.PartAttr{
          name: "id",
          value: "string",
          description: "Content element ID (derived from root id)."
        },
        %Meta.PartAttr{
          name: "hidden",
          value: ~s(true | "until-found"),
          description:
            "Whether the content is hidden. `until-found` when `hidden_until_found` is set."
        },
        %Meta.PartAttr{
          name: "[data-element]",
          value: "collapsible",
          description: "Identifies the component type."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "content",
          description: "Identifies the content element."
        },
        %Meta.PartAttr{
          name: "[data-state]",
          value: ~s("open" | "closed"),
          description: "Current open/closed state."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "true | false",
          description: "Whether interactions are suppressed."
        }
      ]
    }
  end

  @impl true
  def css_vars do
    [
      %Meta.CSSVar{
        name: "--fl-collapsible-height",
        description:
          "Natural scroll height of the content in pixels. Dynamically set on the content element by the Collapsible Hook."
      },
      %Meta.CSSVar{
        name: "--fl-collapsible-width",
        description:
          "Natural scroll width of the content in pixels. Dynamically set on the content element by the Collapsible Hook."
      }
    ]
  end

  @impl true
  def events do
    [
      %Meta.Event{
        name: "fl:collapsible:open",
        source: :client,
        doc:
          "Event triggered when the collapsible is opened. The event payload includes the collapsible's id and state."
      },
      %Meta.Event{
        name: "fl:collapsible:close",
        source: :client,
        doc:
          "Event triggered when the collapsible is closed. The event payload includes the collapsible's id and state."
      },
      %Meta.Event{
        name: "fl:collapsible:toggle",
        source: :client,
        doc:
          "Event triggered when the collapsible is toggled. The event payload includes the collapsible's id and state."
      },
      %Meta.Event{
        name: "fl:collapsible:change",
        source: :client,
        doc:
          "Event dispatched when the collapsible state changes. Bubbles up the DOM. The event payload includes the collapsible's current state."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    state = if(assigns.open, do: "open", else: "closed")

    %{
      root: %{
        "id" => assigns.id,
        "phx-hook" => "Collapsible",
        "data-element" => "collapsible",
        "data-part" => "root",
        "data-disabled" => assigns.disabled,
        "data-state" => state,
        "data-open-event" => assigns.open_event,
        "data-close-event" => assigns.close_event,
        "data-toggle-event" => assigns.toggle_event
      },
      trigger: %{
        "data-element" => "collapsible",
        "data-part" => "trigger",
        "data-disabled" => assigns.disabled,
        "data-state" => state,
        "aria-controls" => "#{assigns.id}-content",
        "aria-expanded" => assigns.open,
        "aria-disabled" => assigns.disabled
      },
      content: %{
        "id" => "#{assigns.id}-content",
        "hidden" =>
          if(assigns.open,
            do: nil,
            else: if(assigns.hidden_until_found, do: "until-found", else: true)
          ),
        "data-element" => "collapsible",
        "data-part" => "content",
        "data-disabled" => assigns.disabled,
        "data-state" => state
      }
    }
  end

  @doc false

  attr(:id, :string, required: true, doc: "Unique component DOM id.")

  attr(:as, :string,
    default: "div",
    doc: "The HTML element to render the collapsible root as."
  )

  attr(:open, :boolean, default: false, doc: "Initial open state.")

  attr(:disabled, :boolean,
    default: false,
    doc: "Whether the trigger interactions are suppressed."
  )

  attr(:hidden_until_found, :boolean,
    default: false,
    doc:
      ~S(Whether the content is hidden until it is found by the browser. When true, the content will be marked with `hidden=\"until-found\"`
    when collapsed, allowing browsers to find and automatically expand the content when a search is performed.)
  )

  attr(:open_event, :string,
    default: nil,
    doc: "The event pushed to the server when the collapsible is opened.
      The event will receive the collapsible's id and state as the payload."
  )

  attr(:close_event, :string,
    default: nil,
    doc: "The event pushed to the server when the collapsible is closed.
      The event will receive the collapsible's id and state as the payload."
  )

  attr(:toggle_event, :string,
    default: nil,
    doc: "The event pushed to the server when the collapsible is toggled.
      The event will receive the collapsible's id and state as the payload."
  )

  attr(:rest, :global, doc: "Additional HTML attributes.")

  slot(:trigger, required: true, doc: "The trigger element for the collapsible.")
  slot(:content, required: true, doc: "The content to show or hide.")

  @impl true
  def render(assigns) do
    ~H"""
    <.dynamic_tag tag_name={@as} {attrs(:root)} {@rest}>
      {render_slot(@trigger, attrs(:trigger))}
      {render_slot(@content, attrs(:content))}
    </.dynamic_tag>
    """
  end

  ## JS Helpers

  def open_collapsible(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:open", to: "##{id}")
  end

  def close_collapsible(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:close", to: "##{id}")
  end

  def toggle_collapsible(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:toggle", to: "##{id}")
  end
end
