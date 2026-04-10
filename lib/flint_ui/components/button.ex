defmodule FlintUI.Button do
  @moduledoc """
  A button component that can be rendered as different HTML elements.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %FlintUI.Meta{
      name: :button,
      type: :button,
      since: "0.1.0"
    }
  end

  @impl true
  def attrs(assigns) do
    %{
      root: %{
        "data-part" => "root",
        "data-element" => "button",
        "data-disabled" => assigns.disabled,
        "type" => if(assigns.as == "button", do: assigns.type, else: nil)
      }
    }
  end

  @doc false

  attr(:as, :string, default: "button", doc: "The HTML element to render the button as.")

  attr(:type, :string,
    default: "button",
    values: ~w(button submit reset),
    doc: "The button type, defaults to button"
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Whether the button should ignore user interaction."
  )

  attr(:rest, :global,
    include: ~w(href navigate patch method disabled name value popovertarget),
    doc: "Additional HTML attributes."
  )

  slot(:inner_block, required: true, doc: "The content of the button.")

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:attrs, attrs(assigns))

    ~H"""
    <.dynamic_tag tag_name={@as} tabindex="0" {@attrs[:root]} {@rest}>
      {render_slot(@inner_block)}
    </.dynamic_tag>
    """
  end
end
