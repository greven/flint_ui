defmodule FlintUIDocsWeb.Docs.Navbar do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navbar

  alias FlintUIDocsWeb.Components

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [%{tab: :styled, section: :usage, id: :basic, title: "Usage"}]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A navbar is a horizontal navigation landmark. Use `navbar_item` for direct links and `navbar_menu` for an item that reveals a menu of links. Mark the current page with `active`." />
    <.preview {assigns} code={usage_code()}>
      <Components.navbar>
        <Components.navbar_item navigate="/">Home</Components.navbar_item>
        <Components.navbar_item navigate="/components" active>
          Components
        </Components.navbar_item>
        <Components.navbar_menu label="Resources" icon="lucide-book-open">
          <Components.navbar_menu_item navigate="/getting-started/introduction">
            Getting started
          </Components.navbar_menu_item>
          <Components.navbar_menu_item navigate="/guides/theming">
            Theming
          </Components.navbar_menu_item>
          <Components.navbar_menu_item navigate="/guides/icons">Icons</Components.navbar_menu_item>
        </Components.navbar_menu>
      </Components.navbar>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.navbar>
      <Components.navbar_item navigate="/">Home</Components.navbar_item>
      <Components.navbar_item navigate="/components" active>Components</Components.navbar_item>
      <Components.navbar_menu id={"#{@parts_id}-menu"} label="Resources" icon="lucide-book-open" open>
        <Components.navbar_menu_item navigate="/guides/theming" active>
          Theming
        </Components.navbar_menu_item>
        <Components.navbar_menu_item navigate="/guides/icons">Icons</Components.navbar_menu_item>
      </Components.navbar_menu>
    </Components.navbar>
    """
  end

  defp usage_code do
    """
    <.navbar>
      <.navbar_item navigate="/">Home</.navbar_item>
      <.navbar_item navigate="/components" active>Components</.navbar_item>
      <.navbar_menu label="Resources" icon="lucide-book-open">
        <.navbar_menu_item navigate="/getting-started/introduction">Getting started</.navbar_menu_item>
        <.navbar_menu_item navigate="/guides/theming">Theming</.navbar_menu_item>
        <.navbar_menu_item navigate="/guides/icons">Icons</.navbar_menu_item>
      </.navbar_menu>
    </.navbar>
    """
  end
end
