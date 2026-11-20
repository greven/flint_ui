defmodule FlintUIDocsWeb.Docs.BreadcrumbsItem do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :breadcrumbs_item

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
      ~S|This component must be used as a child of `<.breadcrumbs>`. Please see the [Breadcrumbs docs](/components/breadcrumbs) to see more examples of this component in action.|
    } />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.breadcrumbs>
      <Components.breadcrumbs_item navigate="/" icon="lucide-house" aria-label="Home" />
      <Components.breadcrumbs_item navigate="/blog">Blog</Components.breadcrumbs_item>
      <Components.breadcrumbs_item current>Post</Components.breadcrumbs_item>
    </Components.breadcrumbs>
    """
  end
end
