defmodule FlintUIDocsWeb.Docs.Button do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :button

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{tab: :styled, section: :usage, id: :basic_text},
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        controls: [%{key: :color, type: :select, default: "neutral", label: "Color"}]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the `inner_block` to set the content of the button." />
    <.preview {assigns} code="<.button>Unbound</.button>">
      <Components.button>Unbound</Components.button>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :basic_text} = assigns) do
    ~H"""
    <.prose content="If all you want is to render text you can also use the `text` attribute." />
    <.preview {assigns} code={~s(<.button text="Shortcut" />)}>
      <Components.button text="Shortcut" />
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color of the button. The `color` and `variant` attributes compose freely." />
    <.preview :let={props} {assigns} code={&color_code/1}>
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
