defmodule FlintUIDocsWeb.Docs.NavbarItem do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navbar_item

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
      ~S|This component is used inside `<.navbar>`. Please see the [Navbar docs](/components/navbar) for the navigation pattern and more examples.|
    } />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.navbar>
      <Components.navbar_item navigate="/" icon="lucide-house" aria-label="Home" />
      <Components.navbar_item navigate="/components" active icon="lucide-box">
        Components
      </Components.navbar_item>
      <Components.navbar_item navigate="/changelog" disabled>Changelog</Components.navbar_item>
      <Components.navbar_item text="Coming soon" />
    </Components.navbar>
    """
  end
end
