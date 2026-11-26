defmodule FlintUIDocsWeb.Docs.DropdownHeader do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown_header

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
    <.prose content="A header labels a section of items. It is presentational and muted by default: the native `<header>` carries a presentational role, so it adds neither a heading level nor a banner landmark to the page outline. Use `color` when the section needs a semantic accent." />
    <.preview {assigns} code={~s(<.dropdown_header>Account</.dropdown_header>)}>
      <div class="flex min-h-40 fl-w-full items-center justify-center">
        <Components.dropdown label="Actions">
          <Components.dropdown_header>Account</Components.dropdown_header>
          <Components.dropdown_item icon="lucide-settings">Settings</Components.dropdown_item>
          <Components.dropdown_item icon="lucide-user">Profile</Components.dropdown_item>
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
        <header
          data-element="dropdown_header"
          data-part="header"
          data-dropdown_header
          role="presentation"
        >
          Account
        </header>
        <div data-element="dropdown_item" data-part="item" data-dropdown_item data-intent="neutral">
          Settings
        </div>
      </div>
    </div>
    """
  end
end
