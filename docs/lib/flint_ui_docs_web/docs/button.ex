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
      %{
        tab: :styled,
        section: :usage,
        id: :variant,
        title: "Variant",
        controls: [%{key: :variant, type: :select, default: "outline", label: "Variant"}]
      },
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
    <.prose content="If all you want is to render text you can also use the `text` attribute." />
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color of the button." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.button variant="solid" color={props.color}>Unbound</Components.button>
    </.preview>

    <.prose content="Each `color` and `variant` compose freely: every variant is available in every role.
      Each row below is a color role, each column a variant.." />

    <.preview id={@id} name={:button} state={@state} preview_only>
      <div class="overflow-x-auto py-1">
        <div class="grid grid-cols-8 items-center gap-x-3 gap-y-6">
          <div></div>
          <span
            :for={variant <- ~w(solid soft subtle outline dashed ghost link)}
            class="text-center text-xs font-medium text-muted"
          >
            {variant}
          </span>
          <div
            :for={color <- ~w(primary secondary neutral info success warning error)}
            class="contents"
          >
            <span class="text-xs font-medium text-muted">{color}</span>
            <Components.button
              :for={variant <- ~w(solid soft subtle outline dashed ghost link)}
              variant={variant}
              color={color}
            >
              {String.capitalize(variant)}
            </Components.button>
          </div>
        </div>
      </div>
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
