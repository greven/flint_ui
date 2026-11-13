defmodule FlintUIDocsWeb.Docs.Collapsible do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :collapsible

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet
  alias FlintUIDocsWeb.DocsComponents

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
          %{key: :open, type: :boolean, default: false, label: "Open"},
          %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
          %{key: :hidden_until_found, type: :boolean, default: false, label: "Hidden until found"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <div class="w-full max-w-74 self-start">
        <Components.collapsible
          id={"#{@preview_id}-styled"}
          class="flex flex-col gap-2"
          open={props.open}
          disabled={props.disabled}
          hidden_until_found={props.hidden_until_found}
        >
          <:trigger :let={attrs}>
            <Components.button {attrs} variant="surface" wide justify="between" class="group">
              Open
              <Components.icon
                name="lucide-chevron-down"
                class="size-4 transition-transform group-aria-expanded:rotate-180"
              />
            </Components.button>
          </:trigger>
          <:content :let={attrs}>
            <div {attrs}>
              <DocsComponents.content_placeholder class="h-40" />
            </div>
          </:content>
        </Components.collapsible>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.collapsible
      id={"#{@parts_id}-collapsible"}
      open
      class="flex w-full max-w-md flex-col gap-2"
    >
      <:trigger :let={attrs}>
        <Components.button {attrs} variant="surface" wide justify="between" class="group">
          Details
          <Components.icon
            name="lucide-chevron-down"
            class="size-4 transition-transform group-aria-expanded:rotate-180"
          />
        </Components.button>
      </:trigger>
      <:content :let={attrs}>
        <div {attrs} class="p-3 text-sm text-toned">
          The content part animates open and closed.
        </div>
      </:content>
    </Components.collapsible>
    """
  end

  defp main_code(props) do
    Snippet.tag(".collapsible", code_attrs(props), styled_code_body())
  end

  defp code_attrs(props) do
    [
      ~s(id="repos"),
      ~s(class="flex flex-col gap-2"),
      Snippet.flag("open", props.open),
      Snippet.flag("disabled", props.disabled),
      Snippet.flag("hidden_until_found", props.hidden_until_found)
    ]
  end

  defp styled_code_body do
    """
    <:trigger :let={attrs}>
      <.button {attrs} variant="surface" wide justify="between" class="group">
        Open
        <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
      </.button>
    </:trigger>
    <:content :let={attrs}>
      <div {attrs}>
        <p>Content</p>
      </div>
    </:content>
    """
    |> String.trim()
  end
end
