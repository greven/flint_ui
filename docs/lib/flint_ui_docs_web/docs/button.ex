defmodule FlintUIDocsWeb.Docs.Button do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :button

  alias FlintUIDocsWeb.Components
  # alias FlintUIDocsWeb.DocsComponents
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
        body: "Use the `inner_block` to set the content of the button.",
        code: """
        <.button>Unbound</.button>
        """
      },
      %{
        tab: :styled,
        section: :usage,
        id: :basic_text,
        body: "If all you want is to render text you can also use the `text` attribute.",
        code: """
        <.button text="Shortcut" />
        """
      },
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        body: """
        Use the `color` attr to change the color of the button.
        The `color` and `variant` attributes compose freely.
        """,
        controls: [%{key: :color, type: :select, default: "neutral", label: "Color"}],
        code: &color_code/1
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview {assigns}>
      <Components.button>Unbound</Components.button>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.preview :let={props} {assigns}>
      <Components.button variant="solid" color={props.color}>Unbound</Components.button>
    </.preview>
    """
  end

  defp color_code(props) do
    Snippet.tag(
      ".button",
      [Snippet.attr("color", props.color, "neutral"), Snippet.attr("variant", "solid")],
      "Unbound"
    )
  end
end
