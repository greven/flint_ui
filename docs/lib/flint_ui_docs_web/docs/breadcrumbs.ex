defmodule FlintUIDocsWeb.Docs.Breadcrumbs do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :breadcrumbs

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @separators ~w(chevron slash arrow dot none)

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
          %{
            key: :separator,
            type: :select,
            default: "chevron",
            label: "Separator",
            values: @separators
          }
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :current,
        title: "Current Page"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :icons,
        title: "Icons",
        group_title: "Examples"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :overflow,
        title: "Collapsed Trail"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Wrap a trail of `breadcrumbs_item` components in `breadcrumbs`. Each item with a
      destination renders a link; the item for the page being viewed omits the destination and
      sets `current`. `label` names the navigation landmark and defaults to `Breadcrumb`." />
    <.prose content="The first crumb never shows a separator. Use the `separator` prop to choose
      between the default chevron and `slash`, `arrow`, `dot`, or `none`." />

    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.breadcrumbs>
        <Components.breadcrumbs_item navigate="/">Home</Components.breadcrumbs_item>
        <Components.breadcrumbs_item navigate="/blog" separator={props.separator}>
          Blog
        </Components.breadcrumbs_item>
        <Components.breadcrumbs_item current separator={props.separator}>
          Post
        </Components.breadcrumbs_item>
      </Components.breadcrumbs>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :current} = assigns) do
    ~H"""
    <.prose content={
      ~S|Set `current` on exactly one item. It sets `aria-current="page"` on the crumb's content and gives that crumb the default ink, so it stands out from the linked crumbs above it. A current crumb may still carry a destination, but a plain-text crumb is the more common form.|
    } />

    <.preview {assigns} code={&current_code/1}>
      <Components.breadcrumbs>
        <Components.breadcrumbs_item navigate="/">Home</Components.breadcrumbs_item>
        <Components.breadcrumbs_item navigate="/projects">Projects</Components.breadcrumbs_item>
        <Components.breadcrumbs_item current>FlintUI</Components.breadcrumbs_item>
      </Components.breadcrumbs>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :icons} = assigns) do
    ~H"""
    <.prose content="An item accepts an `icon` content shortcut. When the icon is the only visible
      content, pass `aria-label` so the link keeps an accessible name." />

    <.preview {assigns} code={&icons_code/1}>
      <Components.breadcrumbs>
        <Components.breadcrumbs_item
          navigate="/"
          icon="lucide-house"
          aria-label="Home"
        />
        <Components.breadcrumbs_item navigate="/blog">Blog</Components.breadcrumbs_item>
        <Components.breadcrumbs_item current>Post</Components.breadcrumbs_item>
      </Components.breadcrumbs>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :overflow} = assigns) do
    ~H"""
    <.prose content="A crumb can hold a small control instead of a link. Use this to collapse a long
      trail into a menu without losing the path's landmarks. Keep the menu short; the breadcrumb
      trail is a shortcut, not the primary navigation." />

    <.preview {assigns} code={&overflow_code/1}>
      <Components.breadcrumbs>
        <Components.breadcrumbs_item
          navigate="/"
          icon="lucide-house"
          aria-label="Home"
        />
        <Components.breadcrumbs_item>
          <Components.dropdown>
            <:trigger :let={attrs}>
              <Components.button
                icon="lucide-ellipsis"
                variant="ghost"
                size="sm"
                square
                aria-label="More pages"
                {attrs}
              />
            </:trigger>
            <Components.dropdown_item icon="lucide-circle-dollar-sign">
              Client
            </Components.dropdown_item>
            <Components.dropdown_item icon="lucide-users">
              Team
            </Components.dropdown_item>
            <Components.dropdown_item icon="lucide-user">
              User
            </Components.dropdown_item>
          </Components.dropdown>
        </Components.breadcrumbs_item>
        <Components.breadcrumbs_item current>Post</Components.breadcrumbs_item>
      </Components.breadcrumbs>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.breadcrumbs>
      <Components.breadcrumbs_item navigate="/" icon="lucide-house" aria-label="Home" />
      <Components.breadcrumbs_item navigate="/blog">Blog</Components.breadcrumbs_item>
      <Components.breadcrumbs_item current>Post</Components.breadcrumbs_item>
    </Components.breadcrumbs>
    """
  end

  defp main_code(props) do
    items =
      [
        Snippet.tag(".breadcrumbs_item", [~s(navigate="/")], "Home"),
        Snippet.tag(
          ".breadcrumbs_item",
          [~s(navigate="/blog"), separator_attr(props)],
          "Blog"
        ),
        Snippet.tag(
          ".breadcrumbs_item",
          [Snippet.flag("current", true), separator_attr(props)],
          "Post"
        )
      ]
      |> Enum.join("\n")

    Snippet.tag(".breadcrumbs", [], items)
  end

  defp current_code(_props) do
    items =
      [
        Snippet.tag(".breadcrumbs_item", [~s(navigate="/")], "Home"),
        Snippet.tag(".breadcrumbs_item", [~s(navigate="/projects")], "Projects"),
        Snippet.tag(".breadcrumbs_item", [Snippet.flag("current", true)], "FlintUI")
      ]
      |> Enum.join("\n")

    Snippet.tag(".breadcrumbs", [], items)
  end

  defp icons_code(_props) do
    """
    <.breadcrumbs>
      <.breadcrumbs_item navigate="/" icon="lucide-house" aria-label="Home" />
      <.breadcrumbs_item navigate="/blog">Blog</.breadcrumbs_item>
      <.breadcrumbs_item current>Post</.breadcrumbs_item>
    </.breadcrumbs>
    """
  end

  defp overflow_code(_props) do
    """
    <.breadcrumbs>
      <.breadcrumbs_item navigate="/" icon="lucide-house" aria-label="Home" />
      <.breadcrumbs_item>
        <.dropdown>
          <:trigger :let={attrs}>
            <.button
              icon="lucide-ellipsis"
              variant="ghost"
              size="sm"
              square
              aria-label="More pages"
              {attrs}
            />
          </:trigger>
          <.dropdown_item>Client</.dropdown_item>
          <.dropdown_item icon="lucide-arrow-turn-down-right">Team</.dropdown_item>
          <.dropdown_item icon="lucide-arrow-turn-down-right">User</.dropdown_item>
        </.dropdown>
      </.breadcrumbs_item>
      <.breadcrumbs_item current>Post</.breadcrumbs_item>
    </.breadcrumbs>
    """
  end

  defp separator_attr(props), do: Snippet.attr("separator", props.separator, "chevron")
end
