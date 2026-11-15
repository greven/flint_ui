defmodule FlintUIDocsWeb.Docs.DropdownGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown_group

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
    <.prose content={"A group names a related set of items. Use `label` or a caller-supplied `aria-label`; the group is exposed with `role=\"group\"` and its items stay in the menu's roving focus."} />
    <.preview
      {assigns}
      code={
        ~s(<.dropdown_group aria-label="Session">\n  <.dropdown_item>Switch user</.dropdown_item>\n  <.dropdown_item intent="error">Log out</.dropdown_item>\n</.dropdown_group>)
      }
    >
      <div class="flex min-h-80 w-full items-start justify-center pt-4">
        <Components.dropdown label="Actions">
          <Components.dropdown_item>Settings</Components.dropdown_item>
          <Components.dropdown_group aria-label="Session">
            <Components.dropdown_item icon="lucide-arrow-left-right">
              Switch user
            </Components.dropdown_item>
            <Components.dropdown_item icon="lucide-log-out" intent="error">
              Log out
            </Components.dropdown_item>
          </Components.dropdown_group>
        </Components.dropdown>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex min-h-64 w-full items-start justify-center py-6">
      <div class="flex w-64 flex-col gap-1">
        <div
          data-element="dropdown_group"
          data-part="group"
          data-dropdown_group
          role="group"
          aria-label="Session"
        >
          <div data-element="dropdown_item" data-part="item" data-dropdown_item data-intent="neutral">
            Switch user
          </div>
          <div data-element="dropdown_item" data-part="item" data-dropdown_item data-intent="error">
            Log out
          </div>
        </div>
      </div>
    </div>
    """
  end
end
