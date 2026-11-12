defmodule FlintUIDocsWeb.Docs.AccordionItem do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :accordion_item

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
end
