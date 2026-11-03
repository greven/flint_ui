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
      },
      %{
        tab: :styled,
        section: :usage,
        id: :variant,
        title: "Variant",
        controls: [%{key: :variant, type: :select, default: "outline", label: "Variant"}]
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
    <.preview {assigns} code={~s(<.button text="Shortcut" icon="lucide-square-slash" />)}>
      <Components.button text="Shortcut" icon="lucide-square-slash" />
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color of the button." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.button variant="solid" color={props.color}>Unbound</Components.button>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="Use the `variant` attr to change the visual style of the button. Default variant is outline." />
    <.preview :let={props} {assigns} code={&code_variant/1}>
      <Components.button variant={props.variant}>Unbound</Components.button>
    </.preview>
    """
  end

  defp code_color(props) do
    Snippet.tag(
      ".button",
      [Snippet.attr("color", props.color, "neutral"), Snippet.attr("variant", "solid")],
      "Unbound"
    )
  end

  defp code_variant(props) do
    Snippet.tag(
      ".button",
      [Snippet.attr("variant", props.variant, "outline")],
      "Unbound"
    )
  end
end
