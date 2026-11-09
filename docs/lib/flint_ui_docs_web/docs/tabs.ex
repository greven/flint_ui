defmodule FlintUIDocsWeb.Docs.Tabs do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :tabs

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
          %{key: :variant, type: :select, default: "outlined", label: "Variant"},
          %{key: :color, type: :select, default: "neutral", label: "Color"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
          %{key: :grow, type: :boolean, default: false, label: "Grow"},
          %{key: :justify, type: :select, default: "start", label: "Justify"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :custom_triggers,
        title: "Custom Triggers",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <div class="w-full max-w-md">
        <Components.tabs
          id={"#{@preview_id}-tabs"}
          value="overview"
          label="Workspace sections"
          variant={props.variant}
          color={props.color}
          size={props.size}
          grow={props.grow}
          justify={props.justify}
          disabled={props.disabled}
        >
          <:tab value="overview">Overview</:tab>
          <:tab value="activity">Activity</:tab>
          <:tab value="members">Members</:tab>
          <:panel value="overview">
            <p class="text-sm text-toned">
              Snapshot of the workspace with health, ownership, and recent updates.
            </p>
          </:panel>
          <:panel value="activity">
            <p class="text-sm text-toned">
              Timeline of edits, comments, and merges across the team.
            </p>
          </:panel>
          <:panel value="members">
            <p class="text-sm text-toned">
              Roster of teammates, roles, and pending invitations.
            </p>
          </:panel>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :custom_triggers} = assigns) do
    ~H"""
    <.prose content="Set `custom` on a tab to render the trigger yourself. Spread the attributes the slot provides through `:let` onto a focusable control; the hook finds the trigger through those attributes, so a composed button stays a button." />
    <.prose content="A custom trigger keeps its own component styles. The active trigger also carries `data-state=active` and `aria-selected=true`, updated in the browser when the selection changes, so add the selected treatment with those state hooks. The example uses Tailwind's `aria-selected` variant; plain CSS can target `[data-part=tab][data-state=active]`." />
    <.preview {assigns} code={&custom_triggers_code/1}>
      <div class="w-full max-w-md">
        <Components.tabs
          id={"#{@preview_id}-custom-tabs"}
          variant="minimal"
          value="overview"
          label="Workspace sections"
        >
          <:tab :let={attrs} value="overview" custom>
            <Components.button
              variant="subtle"
              {attrs}
              class="aria-selected:bg-inverted aria-selected:text-inverted aria-selected:border-inverted"
            >
              Overview
            </Components.button>
          </:tab>
          <:tab :let={attrs} value="activity" custom>
            <Components.button
              variant="subtle"
              {attrs}
              class="aria-selected:bg-inverted aria-selected:text-inverted aria-selected:border-inverted"
            >
              Activity
            </Components.button>
          </:tab>
          <:panel value="overview">
            <p class="text-sm text-toned">
              Snapshot of the workspace with health, ownership, and recent updates.
            </p>
          </:panel>
          <:panel value="activity">
            <p class="text-sm text-toned">
              Timeline of edits, comments, and merges across the team.
            </p>
          </:panel>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".tabs",
      [
        ~s(id="workspace"),
        ~s(value="overview"),
        ~s(label="Workspace sections"),
        Snippet.attr("variant", props.variant, "outlined"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.flag("grow", props.grow),
        Snippet.attr("justify", props.justify, "start"),
        Snippet.flag("disabled", props.disabled)
      ],
      """
      <:tab value="overview">Overview</:tab>
      <:tab value="activity">Activity</:tab>
      <:tab value="members">Members</:tab>

      <:panel value="overview">Overview content</:panel>
      <:panel value="activity">Activity content</:panel>
      <:panel value="members">Members content</:panel>
      """
    )
  end

  defp custom_triggers_code(_) do
    """
    <.tabs id="workspace" variant="minimal" value="overview" label="Workspace sections">
      <:tab value="overview" custom :let={attrs}>
        <.button
          variant="subtle"
          {attrs}
          class="aria-selected:bg-inverted aria-selected:text-inverted aria-selected:border-inverted"
        >
          Overview
        </.button>
      </:tab>
      <:tab value="activity" custom :let={attrs}>
        <.button
          variant="subtle"
          {attrs}
          class="aria-selected:bg-inverted aria-selected:text-inverted aria-selected:border-inverted"
        >
          Activity
        </.button>
      </:tab>

      <:panel value="overview">Overview content</:panel>
      <:panel value="activity">Activity content</:panel>
    </.tabs>
    """
    |> String.trim()
  end
end
