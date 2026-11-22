defmodule FlintUIDocsWeb.Docs.DropdownItem do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :dropdown_item

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @roles ~w(neutral info success warning danger primary secondary)

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
          %{key: :intent, type: :select, default: "neutral", label: "Intent", values: @roles},
          %{key: :disabled, type: :boolean, default: false, label: "Disabled"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="An item is a native button by default. Pass `href`, `navigate`, or `patch` to render a link, `intent` to tint it with a semantic color, and `disabled` to skip it in the menu's arrow navigation. Use the `icon` shortcut before the label, or set `custom` for a non-interactive content block." />
    <.preview :let={props} {assigns} code={&usage_code/1}>
      <div class="flex min-h-40 fl-w-full items-center justify-center">
        <Components.dropdown label="Actions">
          <Components.dropdown_item
            icon="lucide-settings"
            intent={props.intent}
            disabled={props.disabled}
          >
            Settings
          </Components.dropdown_item>
          <Components.dropdown_item icon="lucide-user">Profile</Components.dropdown_item>
          <Components.dropdown_item navigate="/account">Account</Components.dropdown_item>
        </Components.dropdown>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex min-h-64 fl-w-full items-start justify-center py-6">
      <div class="fl-stack fl-items-start fl-gap-sm">
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
            <div
              data-element="dropdown_item"
              data-part="item"
              data-dropdown_item
              data-intent="neutral"
            >
              <Components.icon name="lucide-settings" class="size-4" /> Settings
            </div>
            <div
              data-element="dropdown_item"
              data-part="item"
              data-dropdown_item
              data-intent="danger"
            >
              <Components.icon name="lucide-log-out" class="size-4" /> Log out
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp usage_code(props) do
    Snippet.tag(
      ".dropdown_item",
      [
        Snippet.attr("icon", "lucide-settings"),
        Snippet.attr("intent", props.intent, "neutral"),
        Snippet.flag("disabled", props.disabled)
      ],
      "Settings"
    )
  end
end
