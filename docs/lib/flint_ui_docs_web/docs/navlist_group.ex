defmodule FlintUIDocsWeb.Docs.NavlistGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navlist_group

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
      ~S|This component is used inside `<.navlist>` and contains `<.navlist_item>` links. Please see the [Navlist docs](/components/navlist) for the static and collapsible group patterns and more examples.|
    } />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full fl-max-w-xs">
      <Components.navlist label="Documentation" rail>
        <Components.navlist_group label="Overview" collapsible={false}>
          <Components.navlist_item navigate="/docs">Introduction</Components.navlist_item>
        </Components.navlist_group>

        <Components.navlist_group id={"#{@parts_id}-group"} label="Guides" icon="lucide-palette" open>
          <Components.navlist_item navigate="/guides/theming">Theming</Components.navlist_item>
          <Components.navlist_item navigate="/guides/icons">Icons</Components.navlist_item>
        </Components.navlist_group>
      </Components.navlist>
    </div>
    """
  end
end
