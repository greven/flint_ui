defmodule FlintUIDocsWeb.Docs.DropdownHeading do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown_heading

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
    <.prose content="A heading labels a section of items. It is presentational and muted by default, so it adds no heading level to the page outline. Use `color` when the section needs a semantic accent." />
    <.preview {assigns} code={~s(<.dropdown_heading>Account</.dropdown_heading>)}>
      <div class="flex min-h-80 w-full items-start justify-center pt-4">
        <Components.dropdown label="Actions">
          <Components.dropdown_heading>Account</Components.dropdown_heading>
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
    <div class="flex min-h-52 w-full items-start justify-center py-6">
      <div class="flex w-64 flex-col gap-1">
        <div
          data-element="dropdown_heading"
          data-part="heading"
          data-dropdown_heading
          data-color="neutral"
          role="presentation"
        >
          Account
        </div>
        <div data-element="dropdown_item" data-part="item" data-dropdown_item data-intent="neutral">
          Settings
        </div>
      </div>
    </div>
    """
  end
end
