defmodule FlintUIDocsWeb.Docs.Navlist do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navlist

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
    <.prose content="A navlist stacks links vertically. Add `rail` for a vertical indicator line, use `navlist_group` to label a section, and mark the current page with `active` on the item." />
    <.preview {assigns} code={usage_code()}>
      <Components.navlist label="Documentation" rail>
        <Components.navlist_group label="Overview" icon="lucide-book-open" collapsible={false}>
          <Components.navlist_item navigate="/getting-started/introduction" active>
            Introduction
          </Components.navlist_item>
          <Components.navlist_item navigate="/getting-started/installation">
            Installation
          </Components.navlist_item>
        </Components.navlist_group>

        <Components.navlist_group label="Guides" icon="lucide-palette" open>
          <Components.navlist_item navigate="/guides/theming">Theming</Components.navlist_item>
          <Components.navlist_item navigate="/guides/icons">Icons</Components.navlist_item>
        </Components.navlist_group>
      </Components.navlist>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full fl-max-w-xs">
      <Components.navlist label="Documentation" rail>
        <Components.navlist_group label="Overview" icon="lucide-book-open" collapsible={false}>
          <Components.navlist_item navigate="/getting-started/introduction" active>
            Introduction
          </Components.navlist_item>
          <Components.navlist_item navigate="/getting-started/installation">
            Installation
          </Components.navlist_item>
        </Components.navlist_group>

        <Components.navlist_group id={"#{@parts_id}-group"} label="Guides" icon="lucide-palette" open>
          <Components.navlist_item navigate="/guides/theming">Theming</Components.navlist_item>
          <Components.navlist_item navigate="/guides/icons">Icons</Components.navlist_item>
        </Components.navlist_group>
      </Components.navlist>
    </div>
    """
  end

  defp usage_code do
    """
    <.navlist label="Documentation" rail>
      <.navlist_group label="Overview" icon="lucide-book-open" collapsible={false}>
        <.navlist_item navigate="/getting-started/introduction" active>
          Introduction
        </.navlist_item>
        <.navlist_item navigate="/getting-started/installation">Installation</.navlist_item>
      </.navlist_group>

      <.navlist_group label="Guides" icon="lucide-palette" open>
        <.navlist_item navigate="/guides/theming">Theming</.navlist_item>
        <.navlist_item navigate="/guides/icons">Icons</.navlist_item>
      </.navlist_group>
    </.navlist>
    """
  end
end
