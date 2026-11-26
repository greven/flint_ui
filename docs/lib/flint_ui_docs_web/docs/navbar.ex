defmodule FlintUIDocsWeb.Docs.Navbar do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :navbar

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
          %{key: :variant, type: :select, default: "segmented", label: "Variant"},
          %{key: :color, type: :select, default: "neutral", label: "Color"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :gap, type: :select, default: "xs", label: "Gap"},
          %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
          %{key: :grow, type: :boolean, default: false, label: "Grow"},
          %{key: :justify, type: :select, default: "start", label: "Justify"},
          %{
            key: :position,
            type: :select,
            default: "center",
            values: ~w(start center end),
            label: "Menu position"
          },
          %{key: :open_on_hover, type: :boolean, default: false, label: "Open menu on hover"}
        ]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :outlined,
        title: "Outlined and Disabled",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A navbar is a horizontal navigation landmark. Use `navbar_item` for direct links and `navbar_menu` for an item that reveals a menu of links. Mark the current page with `active`." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <div class="fl-w-full">
        <Components.navbar
          variant={props.variant}
          color={props.color}
          size={props.size}
          gap={props.gap}
          grow={props.grow}
          justify={props.justify}
          disabled={props.disabled}
        >
          <Components.navbar_item navigate="/">Home</Components.navbar_item>
          <Components.navbar_item navigate="/components" active>
            Components
          </Components.navbar_item>
          <Components.navbar_menu
            label="Resources"
            icon="lucide-book-open"
            open_on_hover={props.open_on_hover}
            position={props.position}
          >
            <Components.navbar_menu_item navigate="/getting-started/introduction">
              Getting started
            </Components.navbar_menu_item>
            <Components.navbar_menu_item navigate="/guides/theming">
              Theming
            </Components.navbar_menu_item>
            <Components.navbar_menu_item navigate="/guides/icons">Icons</Components.navbar_menu_item>
          </Components.navbar_menu>
        </Components.navbar>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :outlined} = assigns) do
    ~H"""
    <.prose content={
      ~S|Set `variant="outlined"` for the minimal treatment plus the tabs-style rail: a shared rule under the list and a bottom indicator on the active item or open menu trigger. `color` builds the indicator and tints the active fill. The variant adds no height, so it is the minimal navbar with the rail on top. The outlined variant stays on one row; pair it with `scrollable` or `fadable` when the items can overflow.|
    } />
    <.prose content="Set `disabled` on an item to render it as non-focusable text, even when it has a destination. Set `disabled` on the navbar to make the whole landmark inert." />
    <.preview {assigns} code={outlined_code()}>
      <div class="fl-w-full">
        <Components.navbar variant="outlined" color="primary">
          <Components.navbar_item navigate="/">Home</Components.navbar_item>
          <Components.navbar_item navigate="/components" active>Components</Components.navbar_item>
          <Components.navbar_item navigate="/changelog" disabled>Changelog</Components.navbar_item>
          <Components.navbar_menu label="Resources" icon="lucide-book-open">
            <Components.navbar_menu_item navigate="/guides/theming">
              Theming
            </Components.navbar_menu_item>
            <Components.navbar_menu_item navigate="/guides/icons">Icons</Components.navbar_menu_item>
            <Components.navbar_menu_item disabled>API reference</Components.navbar_menu_item>
          </Components.navbar_menu>
        </Components.navbar>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full">
      <Components.navbar>
        <Components.navbar_item navigate="/">Home</Components.navbar_item>
        <Components.navbar_item navigate="/components" active>Components</Components.navbar_item>
        <Components.navbar_menu
          id={"#{@parts_id}-menu"}
          label="Resources"
          icon="lucide-book-open"
          open
        >
          <Components.navbar_menu_item navigate="/guides/theming" active>
            Theming
          </Components.navbar_menu_item>
          <Components.navbar_menu_item navigate="/guides/icons">Icons</Components.navbar_menu_item>
        </Components.navbar_menu>
      </Components.navbar>
    </div>
    """
  end

  defp main_code(props) do
    menu_attrs =
      [
        ~s(label="Resources"),
        ~s(icon="lucide-book-open"),
        Snippet.attr("position", props.position, "center"),
        Snippet.flag("open_on_hover", props.open_on_hover)
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    Snippet.tag(
      ".navbar",
      [
        Snippet.attr("variant", props.variant, "minimal"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("gap", props.gap, "xs"),
        Snippet.flag("grow", props.grow),
        Snippet.attr("justify", props.justify, "start"),
        Snippet.flag("disabled", props.disabled)
      ],
      """
      <.navbar_item navigate="/">Home</.navbar_item>
      <.navbar_item navigate="/components" active>Components</.navbar_item>
      <.navbar_menu #{menu_attrs}>
        <.navbar_menu_item navigate="/getting-started/introduction">Getting started</.navbar_menu_item>
        <.navbar_menu_item navigate="/guides/theming">Theming</.navbar_menu_item>
        <.navbar_menu_item navigate="/guides/icons">Icons</.navbar_menu_item>
      </.navbar_menu>
      """
    )
  end

  defp outlined_code do
    """
    <.navbar variant="outlined" color="primary">
      <.navbar_item navigate="/">Home</.navbar_item>
      <.navbar_item navigate="/components" active>Components</.navbar_item>
      <.navbar_item navigate="/changelog" disabled>Changelog</.navbar_item>
      <.navbar_menu label="Resources" icon="lucide-book-open">
        <.navbar_menu_item navigate="/guides/theming">Theming</.navbar_menu_item>
        <.navbar_menu_item navigate="/guides/icons">Icons</.navbar_menu_item>
        <.navbar_menu_item disabled>API reference</.navbar_menu_item>
      </.navbar_menu>
    </.navbar>
    """
    |> String.trim()
  end
end
