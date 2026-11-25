defmodule FlintUIDocsWeb.Docs.NavbarMenu do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navbar_menu

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
      ~S|This component is used inside `<.navbar>` and contains `<.navbar_menu_item>` links. Please see the [Navbar docs](/components/navbar) for the disclosure pattern and more examples.|
    } />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.navbar>
      <Components.navbar_menu
        id={"#{@parts_id}-menu"}
        label="Resources"
        icon="lucide-book-open"
        open
      >
        <Components.navbar_menu_item navigate="/guides/theming" icon="lucide-palette">
          Theming
        </Components.navbar_menu_item>
        <Components.navbar_menu_item navigate="/guides/icons" icon="lucide-shapes">
          Icons
        </Components.navbar_menu_item>
      </Components.navbar_menu>
    </Components.navbar>
    """
  end
end
