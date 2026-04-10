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
    %FlintUI.Meta{
      name: :collapsible,
      type: :misc,
      since: "0.1.0"
    }
  end

  @impl true
  def attrs(assigns) do
    %{
      root: %{
        "id" => assigns.id,
        "data-part" => "root",
        "data-element" => "collapsible",
        "data-disabled" => assigns.disabled,
        "data-state" => if(assigns.open, do: "open", else: "closed"),
        "phx-hook" => "Collapsible"
      },
      trigger: %{
        "data-part" => "trigger",
        "data-element" => "collapsible",
        "data-disabled" => assigns.disabled,
        "data-state" => if(assigns.open, do: "open", else: "closed"),
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
        "data-part" => "content",
        "data-element" => "collapsible",
        "data-disabled" => assigns.disabled,
        "data-state" => if(assigns.open, do: "open", else: "closed")
      }
    }
  end

  @doc false

  attr(:id, :string, required: true, doc: "Unique component DOM id.")

  attr(:as, :string,
    default: "div",
    doc: "The HTML element to render the collapsible root as. Defaults to 'div'."
  )

  attr(:open, :boolean, default: false, doc: "Initial open state. Defaults to false.")

  attr(:disabled, :boolean,
    default: false,
    doc: "Whether the trigger interactions are suppressed. Defaults to false."
  )

  attr(:hidden_until_found, :boolean,
    default: false,
    doc:
      "Whether the content is hidden until it is found by the browser. When true, the content will be marked with `hidden=\"until-found\"`
      when collapsed, allowing browsers to find and automatically expand the content when a search is performed. Defaults to false."
  )

  attr(:rest, :global, doc: "Additional HTML attributes.")

  slot(:trigger, required: true, doc: "The trigger element for the collapsible.")
  slot(:content, required: true, doc: "The content to show or hide.")

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :attrs, attrs(assigns))

    ~H"""
    <.dynamic_tag tag_name={@as} {@attrs[:root]} {@rest}>
      {render_slot(@trigger, @attrs[:trigger])}
      {render_slot(@content, @attrs[:content])}
    </.dynamic_tag>
    """
  end
end
