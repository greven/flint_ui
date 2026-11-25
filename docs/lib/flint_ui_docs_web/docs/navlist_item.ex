defmodule FlintUIDocsWeb.Docs.NavlistItem do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navlist_item

  alias FlintUIDocsWeb.Components

  @impl true
  def base_docs, do: [:api]

  @impl true
  def api_only?, do: true

  @impl true
  def sections do
    [%{tab: :styled, section: :usage, id: :basic, title: "Usage"}]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={
      ~S|This component is used inside `<.navlist>` and `<.navlist_group>`. Please see the [Navlist docs](/components/navlist) for the rail and group patterns and more examples.|
    } />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full fl-max-w-xs">
      <Components.navlist label="Documentation" rail>
        <Components.navlist_item navigate="/" icon="lucide-house" aria-label="Home" />
        <Components.navlist_item navigate="/docs" icon="lucide-book-open" active>
          Documentation
        </Components.navlist_item>
        <Components.navlist_item text="Coming soon" />
      </Components.navlist>
    </div>
    """
  end
end
