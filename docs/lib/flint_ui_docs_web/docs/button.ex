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
        controls: [%{key: :variant, type: :select, default: "subtle", label: "Variant"}]
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
      <Components.button>Button</Components.button>
    </.preview>
    <.prose content="If all you want is to render text you can also use the `text` attribute." />
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="Use the `variant` attr to change the visual style of the button. Default variant is outline." />
    <.preview :let={props} {assigns} code={&code_variant/1}>
      <Components.button variant={props.variant}>Button</Components.button>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color of the button." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.button variant="solid" color={props.color}>Button</Components.button>
    </.preview>

    <.prose content="Each `color` and `variant` compose freely: every variant is available in every role.
      Each row below is a color role, each column a variant." />

    <.preview id={"#{@id}-grid"}>
      <div class="overflow-x-auto py-1">
        <div class="grid grid-cols-8 items-center gap-x-3 gap-y-6">
          <div></div>
          <span
            :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
            class="text-center text-xs font-medium text-muted"
          >
            {variant}
          </span>
          <div
            :for={color <- ~w(neutral info success warning error)}
            class="contents"
          >
            <span class="text-xs font-medium text-muted">{color}</span>
            <Components.button
              :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
              variant={variant}
              color={color}
            >
              {String.capitalize(variant)}
            </Components.button>
          </div>
        </div>
      </div>
    </.preview>

    <.prose content="You can also override **Primary** and **Secondary** colors in your stylesheet." />

    <.preview id={"#{@id}-brand"}>
      <div class="overflow-x-auto py-1">
        <div class="grid grid-cols-8 items-center gap-x-3 gap-y-6">
          <div></div>
          <span
            :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
            class="text-center text-xs font-medium text-muted"
          >
            {variant}
          </span>
          <div
            :for={color <- ~w(primary secondary)}
            class="contents"
          >
            <span class="text-xs font-medium text-muted">{color}</span>
            <Components.button
              :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
              variant={variant}
              color={color}
            >
              {String.capitalize(variant)}
            </Components.button>
          </div>
        </div>
      </div>
    </.preview>

    <.prose content="You can customize the `color` of a button using raw CSS color for a one-off accent or a value that comes from data. The
            best available contrast is used, so a mid-tone fill can still fall below AA when neither black nor white clears it. Raw colors are
            an escape hatch: they do not follow `data-theme` presets or the semantic role contract. Prefer a role for app-wide
            theming, and pass `style` to override the derived values." />

    <.preview id={"#{@id}-raw"} code={&code_raw/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button color="#009966" icon="lucide-coins">Common</Components.button>
        <Components.button color="#165DFC" icon="lucide-pickaxe">Rare</Components.button>
        <Components.button color="#7007E7" icon="lucide-shield">Epic</Components.button>
        <Components.button color="#FE9A00" icon="lucide-swords">Legendary</Components.button>
      </div>
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

  defp code_raw(_props) do
    """
    <div class="flex flex-wrap items-center gap-3">
      <.button color="#009966" icon="lucide-coins">Common</.button>
      <.button color="#165DFC" icon="lucide-pickaxe">Rare</.button>
      <.button color="#7007E7" icon="lucide-shield">Epic</.button>
      <.button color="#FE9A00" icon="lucide-swords">Legendary</.button>
    </div>
    """
  end
end
