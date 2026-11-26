defmodule FlintUIDocsWeb.Docs.DropdownSub do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown_sub

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage",
        controls: [
          %{key: :open_on_hover, type: :boolean, default: true, label: "Open on hover"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Declare the submenu content in a `:submenu` slot with an `id`, then point a `dropdown_sub` at it with `menu`. The submenu opens to the right, flips when it does not fit, and closes back to its trigger with `ArrowLeft` or `Escape`. It opens on hover by default, after the dropdown's `open_delay`; set `open_on_hover={false}` to require a click. Hover opening never moves focus. The hook tracks the path between the trigger and the submenu, so a diagonal move toward it — even across another row — stays open." />
    <.preview :let={props} {assigns} code={&sub_code/1}>
      <div class="flex min-h-40 fl-w-full items-center justify-center">
        <Components.dropdown label="Actions">
          <Components.dropdown_item>Settings</Components.dropdown_item>
          <:submenu id="more">
            <Components.dropdown_item icon="lucide-book-open">Documentation</Components.dropdown_item>
            <Components.dropdown_item icon="lucide-git-branch">Changelog</Components.dropdown_item>
          </:submenu>
          <Components.dropdown_sub menu="more" open_on_hover={props.open_on_hover}>
            More
          </Components.dropdown_sub>
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
        <div
          data-element="dropdown_sub"
          data-part="submenu-trigger"
          data-dropdown_sub
          data-menu="more"
          role="menuitem"
          aria-haspopup="menu"
          aria-expanded="false"
        >
          More
          <span data-part="submenu-indicator" aria-hidden="true">
            <Components.icon name="lucide-chevron-right" class="size-4" />
          </span>
        </div>
      </div>
    </div>
    """
  end

  defp sub_code(props) do
    Snippet.tag(
      ".dropdown",
      [~s(label="Actions")],
      """
      <.dropdown_item>Settings</.dropdown_item>
      <:submenu id="more">
        <.dropdown_item>Documentation</.dropdown_item>
      </:submenu>
      #{Snippet.tag(".dropdown_sub", [~s(menu="more"), Snippet.attr("open_on_hover", props.open_on_hover, true)], "More")}
      </.dropdown>
      """
      |> String.trim()
    )
  end
end
