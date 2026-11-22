defmodule FlintUIDocsWeb.Docs.DropdownSeparator do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown_separator

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
    <.prose content={"A separator divides unrelated actions. It is a static `role=\"separator\"`, not focusable, and adds no keyboard behavior. Use a group instead when the items need a shared accessible name."} />
    <.preview {assigns} code="<.dropdown_separator />">
      <div class="flex min-h-40 fl-w-full items-center justify-center">
        <Components.dropdown label="Actions">
          <Components.dropdown_item>Settings</Components.dropdown_item>
          <Components.dropdown_separator />
          <Components.dropdown_item intent="danger">Log out</Components.dropdown_item>
        </Components.dropdown>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex min-h-52 fl-w-full items-start justify-center py-6">
      <div class="fl-stack fl-gap-xs w-64">
        <div data-element="dropdown_item" data-part="item" data-dropdown_item data-intent="neutral">
          Settings
        </div>
        <div data-element="dropdown_separator" data-part="separator" data-dropdown_separator></div>
        <div data-element="dropdown_item" data-part="item" data-dropdown_item data-intent="danger">
          Log out
        </div>
      </div>
    </div>
    """
  end
end
