defmodule FlintUIDocsWeb.Docs.AccordionItem do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :accordion_item

  alias FlintUIDocsWeb.Components

  @impl true
  def base_docs, do: [:api]

  @impl true
  def api_only?, do: true

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={
      ~S|This component must be used as a child of `<.accordion>`. Please see the [Accordion docs](/components/accordion) to see more examples of this component in action.|
    } />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.accordion id={"#{@parts_id}-accordion"} variant="contained" class="w-full max-w-md">
      <Components.accordion_item id={"#{@parts_id}-shipping"} label="Shipping" expanded>
        <:panel>Orders leave the warehouse in one business day.</:panel>
      </Components.accordion_item>
      <Components.accordion_item id={"#{@parts_id}-returns"} label="Returns">
        <:panel>Return any item within 30 days.</:panel>
      </Components.accordion_item>
    </Components.accordion>
    """
  end
end
