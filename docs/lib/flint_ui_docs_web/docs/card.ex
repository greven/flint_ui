defmodule FlintUIDocsWeb.Docs.Card do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :card

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
          %{key: :variant, type: :select, default: "solid", label: "Variant"},
          %{key: :body, type: :select, default: "seamless", label: "Body"},
          %{key: :orientation, type: :select, default: "vertical", label: "Orientation"},
          %{key: :spacing, type: :select, default: "md", label: "Spacing"},
          %{key: :outline, type: :boolean, default: true, label: "Outline"},
          %{key: :shadow, type: :boolean, default: true, label: "Shadow"},
          %{key: :inverted, type: :boolean, default: false, label: "Inverted"}
        ]
      },
      %{tab: :styled, section: :usage, id: :link, title: "Link"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.card
        variant={props.variant}
        body={props.body}
        orientation={props.orientation}
        spacing={props.spacing}
        outline={props.outline}
        shadow={props.shadow}
        inverted={props.inverted}
      >
        <:title>Starred repositories</:title>
        <:description>Updated just now</:description>
        <:header_actions>
          <Components.button variant="ghost" size="sm">Edit</Components.button>
        </:header_actions>
        <p>Reorder or remove the repositories you follow.</p>
        <:footer>3 repositories</:footer>
        <:footer_actions>
          <Components.button variant="outline" size="sm">View logs</Components.button>
        </:footer_actions>
      </Components.card>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :link} = assigns) do
    ~H"""
    <.prose content="Pass `href`, `navigate`, or `patch` to render the card root as a link. A linked card is one anchor, so keep buttons and links out of it. Set `title_id` so the root can use the title as its accessible name." />
    <.preview {assigns} code={link_code()}>
      <Components.card href="/components" title_id="card-link-title" class="max-w-sm">
        <:title>Browse components</:title>
        <:description>See every FlintUI component</:description>
        <p>Open the component index.</p>
      </Components.card>
    </.preview>
    """
  end

  defp link_code do
    """
    <.card href="/components" title_id="card-link-title">
      <:title>Browse components</:title>
      <:description>See every FlintUI component</:description>
      <p>Open the component index.</p>
    </.card>
    """
    |> String.trim()
  end

  defp main_code(props) do
    Snippet.tag(
      ".card",
      [
        Snippet.attr("variant", props.variant, "solid"),
        Snippet.attr("body", props.body, "seamless"),
        Snippet.attr("orientation", props.orientation, "vertical"),
        Snippet.attr("spacing", props.spacing, "md"),
        Snippet.attr("outline", props.outline, true),
        Snippet.attr("shadow", props.shadow, true),
        Snippet.flag("inverted", props.inverted)
      ],
      body_code()
    )
  end

  defp body_code do
    """
    <:title>Starred repositories</:title>
    <:description>Updated just now</:description>
    <:header_actions>
      <.button variant="ghost" size="sm">Edit</.button>
    </:header_actions>
    <p>Reorder or remove the repositories you follow.</p>
    <:footer>3 repositories</:footer>
    <:footer_actions>
      <.button variant="outline" size="sm">View logs</.button>
    </:footer_actions>
    """
    |> String.trim()
  end
end
