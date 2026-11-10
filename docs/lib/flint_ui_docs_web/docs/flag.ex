defmodule FlintUIDocsWeb.Docs.Flag do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :flag

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  # These codes have SVGs copied to priv/static/images/flags by
  # `mix flint.icons.copy_flags --only pt,us,br,jp,fr,de`.
  @codes ~w(eu gb us pt br jp fr de)
  @shapes ~w(regular square round)

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
          %{key: :code, type: :select, values: @codes, default: "gb", label: "ISO Code"},
          %{
            key: :shape,
            type: :select,
            values: @shapes,
            default: "regular",
            label: "Shape"
          },
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :radius, type: :select, default: "xs", label: "Radius"},
          %{key: :overlay, type: :select, default: "none", label: "Overlay"},
          %{key: :border, type: :boolean, default: false, label: "Border"},
          %{key: :shadow, type: :boolean, default: false, label: "Shadow"}
        ]
      },
      %{
        tab: :styled,
        section: :shapes,
        id: :shapes,
        title: "Shapes"
      },
      %{
        tab: :styled,
        section: :overlays,
        id: :overlays,
        title: "Overlays"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="`code` is the ISO 3166-1 alpha-2 code and `shape` selects the asset: `regular` is 4:3, `square` is 1:1, and `round` is the square asset with a full radius.
      The component loads the copied SVG from `/images/flags/<code>.svg` or `/images/flags/<code>-square.svg`, so `code` can be dynamic and works the same with Tailwind or plain CSS.
      See the [Flags guide](/guides/flags) to install the flag assets." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.flag
        code={props.code}
        shape={props.shape}
        size={props.size}
        radius={props.radius}
        overlay={props.overlay}
        border={props.border}
        shadow={props.shadow}
      />
    </.preview>
    """
  end

  def render_section(%{section: :shapes, id: :shapes} = assigns) do
    ~H"""
    <.prose content="`shape` chooses the asset rather than stretching it. `round` uses the square asset and sets the radius to `full`." />
    <.preview
      {assigns}
      code={
        ~s|<.flag code="jp" />\n<.flag code="eu" shape="square" />\n<.flag code="pt" shape="round" />|
      }
      canvas_class="gap-4"
    >
      <div class="flex items-center gap-4">
        <Components.flag code="jp" label="Japan" />
        <Components.flag code="eu" shape="square" label="European Union" />
        <Components.flag code="ch" shape="round" label="Switzerland" />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :overlays, id: :overlays} = assigns) do
    ~H"""
    <.prose content="`linear` adds a soft vertical sheen; `wave` adds a diagonal glossy band. Pair either with `border` and `shadow` on light or busy surfaces." />
    <.preview
      {assigns}
      code={
        ~s|<.flag code="es" overlay="linear" border shadow />\n<.flag code="jp" overlay="wave" border shadow />|
      }
      canvas_class="gap-4"
    >
      <div class="flex items-center gap-4">
        <Components.flag code="es" overlay="linear" border shadow label="Spain" />
        <Components.flag code="br" overlay="wave" border shadow label="Brasil" />
      </div>
    </.preview>
    """
  end

  defp main_code(props) do
    radius = if props.shape == "round", do: nil, else: props.radius

    Snippet.component(
      ".flag",
      [
        Snippet.attr("code", props.code),
        Snippet.attr("shape", props.shape, "regular"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("radius", radius, "xs"),
        Snippet.attr("overlay", props.overlay, "none"),
        Snippet.flag("border", props.border),
        Snippet.flag("shadow", props.shadow)
      ]
    )
  end
end
