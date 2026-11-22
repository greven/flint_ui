defmodule FlintUIDocsWeb.Docs.Dropdown do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown

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
          %{key: :placement, type: :select, default: "bottom", label: "Placement"},
          %{key: :align, type: :select, default: "start", label: "Align"},
          %{key: :open_on_hover, type: :boolean, default: false, label: "Open on hover"},
          %{key: :arrow, type: :boolean, default: false, label: "Arrow"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="`label` renders the default trigger and the default slot is the menu content. Use `dropdown_header` for a
      muted section label, `dropdown_item` for actions and links, `dropdown_separator` for a visual break, and `dropdown_group` to name a related set
      of items.The menu opens on click, `Enter`, `Space`, or `ArrowDown`; set `open_on_hover` to open it on hover. Submenus take their own
      `open_on_hover`, so a menu can open on click while its submenu opens on hover. `placement`, `align`, and `offset` position it,
      and `max_height` caps its height so long menus scroll." />
    <.preview :let={props} {assigns} code={&usage_code/1}>
      <div class="flex min-h-40 fl-w-full items-center justify-center">
        <Components.dropdown
          label="Actions"
          placement={props.placement}
          open_on_hover={props.open_on_hover}
          align={props.align}
          arrow={props.arrow}
        >
          <Components.dropdown_header>Account</Components.dropdown_header>
          <Components.dropdown_item icon="lucide-settings">Settings</Components.dropdown_item>
          <Components.dropdown_item icon="lucide-user">Profile</Components.dropdown_item>
          <Components.dropdown_item navigate="/account">Account</Components.dropdown_item>
          <Components.dropdown_item href="https://example.com">Billing</Components.dropdown_item>
          <Components.dropdown_item disabled>Referrals</Components.dropdown_item>
          <Components.dropdown_sub menu="more">More</Components.dropdown_sub>

          <Components.dropdown_separator />

          <Components.dropdown_group aria-label="Session">
            <Components.dropdown_item icon="lucide-arrow-left-right">
              Switch user
            </Components.dropdown_item>
            <Components.dropdown_item icon="lucide-log-out" intent="danger">
              Log out
            </Components.dropdown_item>
          </Components.dropdown_group>

          <:submenu id="more">
            <Components.dropdown_item icon="lucide-book-open">Documentation</Components.dropdown_item>
            <Components.dropdown_item icon="lucide-git-branch">Changelog</Components.dropdown_item>
          </:submenu>
        </Components.dropdown>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex min-h-64 fl-w-full items-start justify-center py-6">
      <div class={["relative fl-stack fl-items-start fl-gap-sm"]}>
        <div data-element="dropdown" data-part="root" data-dropdown data-state="open">
          <button
            data-part="trigger"
            data-dropdown-trigger
            data-state="open"
            type="button"
            class="inline-flex items-center gap-2 rounded-md border border-default bg-surface px-3 py-1.5 text-sm font-medium text-default shadow-sm"
          >
            Actions
            <span data-part="indicator" aria-hidden="true">
              <Components.icon name="lucide-chevron-down" class="size-4 text-muted" />
            </span>
          </button>
          <div
            data-part="content"
            data-dropdown-content
            data-state="open"
            data-side="bottom"
            data-align="start"
            class="relative mt-2 w-64"
          >
            <div data-part="list">
              <header data-element="dropdown_header" data-part="header" data-dropdown_header>
                Account
              </header>
              <div
                data-element="dropdown_item"
                data-part="item"
                data-dropdown_item
                data-intent="neutral"
              >
                <Components.icon name="lucide-settings" class="size-4" /> Settings
              </div>
              <div data-element="dropdown_separator" data-part="separator" data-dropdown_separator>
              </div>
              <div
                data-element="dropdown_group"
                data-part="group"
                data-dropdown_group
                role="group"
                aria-label="Session"
              >
                <div data-element="dropdown_sub" data-part="submenu-trigger" data-dropdown_sub>
                  More <Components.icon name="lucide-chevron-right" class="size-4" />
                </div>
              </div>
            </div>
          </div>
          <div
            data-part="submenu"
            data-dropdown-submenu
            data-state="open"
            role="menu"
            class="absolute top-0 left-68 w-56"
          >
            <div data-part="list">
              <div
                data-element="dropdown_item"
                data-part="item"
                data-dropdown_item
                data-intent="neutral"
              >
                Documentation
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp usage_code(props) do
    Snippet.tag(
      ".dropdown",
      [
        ~s(label="Actions"),
        Snippet.attr("placement", props.placement, "bottom"),
        Snippet.attr("align", props.align, "start"),
        Snippet.flag("arrow", props.arrow),
        Snippet.flag("open_on_hover", props.open_on_hover)
      ],
      usage_body()
    )
  end

  defp usage_body do
    """
    <.dropdown_header>Account</.dropdown_header>
    <.dropdown_item icon="lucide-settings">Settings</.dropdown_item>
    <.dropdown_item icon="lucide-user">Profile</.dropdown_item>
    <.dropdown_item navigate="/account">Account</.dropdown_item>
    <.dropdown_item href="https://example.com">Billing</.dropdown_item>
    <.dropdown_item disabled>Referrals</.dropdown_item>
    <.dropdown_sub menu="more">More</.dropdown_sub>

    <.dropdown_separator />

    <.dropdown_group aria-label="Session">
      <.dropdown_item icon="lucide-arrow-left-right">
        Switch user
      </.dropdown_item>
      <.dropdown_item icon="lucide-log-out" intent="danger">
        Log out
      </.dropdown_item>
    </.dropdown_group>

    <:submenu id="more">
      <.dropdown_item icon="lucide-book-open">Documentation</.dropdown_item>
      <.dropdown_item icon="lucide-git-branch">Changelog</.dropdown_item>
    </:submenu>
    </.dropdown>
    """
    |> String.trim()
  end
end
