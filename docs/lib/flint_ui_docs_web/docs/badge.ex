defmodule FlintUIDocsWeb.Docs.Badge do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :badge

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
      },
      %{tab: :styled, section: :usage, id: :icon, title: "Icon"},
      %{tab: :styled, section: :usage, id: :size, title: "Size"},
      %{
        tab: :styled,
        section: :usage,
        id: :radius,
        title: "Radius",
        controls: [%{key: :radius, type: :select, default: "md", label: "Radius"}]
      },
      %{tab: :styled, section: :usage, id: :wide, title: "Wide"},
      %{tab: :styled, section: :usage, id: :inset, title: "Inset"},
      %{tab: :styled, section: :usage, id: :uppercase, title: "Uppercase"},
      %{
        tab: :styled,
        section: :examples,
        id: :as_link,
        title: "As a Link",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :status_dot, title: "Status Dot"},
      %{
        tab: :styled,
        section: :examples,
        id: :custom_color,
        title: "Custom Color"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the `inner_block` to set the content of the badge." />
    <.preview {assigns} code="<.badge>Badge</.badge>">
      <div class="flex items-center flex-wrap gap-3">
        <Components.badge>Some</Components.badge>
        <Components.badge color="info">Things</Components.badge>
        <Components.badge color="success">Come</Components.badge>
        <Components.badge color="warning">In Small</Components.badge>
        <Components.badge color="error">Packages</Components.badge>
      </div>
    </.preview>
    <.prose content="If all you want is to render text you can also use the `text` attribute." />
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="Use the `variant` attr to change the visual emphasis of the badge. The default variant is `subtle`." />
    <.preview :let={props} {assigns} code={&code_variant/1}>
      <Components.badge variant={props.variant}>Badge</Components.badge>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color the variant is built from. The default color is `neutral`." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.badge variant="solid" color={props.color}>Badge</Components.badge>
    </.preview>

    <.prose content="Each `color` and `variant` compose freely: every variant is available in every role.
      Each row below is a color role, each column a variant. You can use any of the semantic theme colors, `primary`, `secondary`,
      `info`, `success`, etc." />

    <.preview id={"#{@id}-grid"}>
      <div class="space-y-3">
        <div
          :for={color <- ~w(neutral info success warning error)}
          class="flex flex-wrap gap-3 justify-center"
        >
          <Components.badge
            :for={variant <- ~w(solid soft subtle outline dashed ghost)}
            variant={variant}
            color={color}
          >
            {String.capitalize(variant)}
          </Components.badge>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :icon} = assigns) do
    ~H"""
    <.prose content="Use the `icon` attr to render a decorative icon before the label. The icon scales with the badge size." />
    <.prose content="You can also use the `:leading` and `:trailing` slots to place an icon or other content before and after the label." />
    <.prose content="Icons are decorative. Keep the badge's text meaningful on its own instead of relying on the icon to carry the state." />
    <.preview id={@id} code={&code_icon/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge icon="lucide-sparkles">New</Components.badge>
        <Components.badge variant="solid" color="success" icon="lucide-check">
          Passed
        </Components.badge>
        <Components.badge variant="outline" color="info">
          <:leading>
            <Components.icon name="lucide-clock" />
          </:leading>
          In progress
        </Components.badge>
        <Components.badge variant="subtle" color="primary">
          Synced
          <:trailing>
            <Components.icon name="lucide-cloud" />
          </:trailing>
        </Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="Use the `size` attr to change the badge size, from `xs` to `xl`. The default size is `md`." />
    <.preview id={@id} code={&code_size/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge :for={{label, size} <- sizes()} size={size}>{label}</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :radius} = assigns) do
    ~H"""
    <.prose content="Use the `radius` attr to change the corner radius, from `none` to `xl`, or `full` for a pill shape. The default radius is `md`." />
    <.preview :let={props} id={@id} {assigns} code={&code_radius/1}>
      <Components.badge radius={props.radius}>Badge</Components.badge>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :wide} = assigns) do
    ~H"""
    <.prose content="Set `wide` to fill the width of the surrounding container. The content stays centered." />
    <.preview id={@id} code={&code_wide/1}>
      <div class="w-full max-w-lg">
        <Components.badge variant="solid" color="info" wide>Full width</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :inset} = assigns) do
    ~H"""
    <.prose content="Set `inset` to pull the badge over the padding it keeps for its box, so its label lines up with surrounding content. The hit area is unchanged." />
    <.prose content="It is most useful when a badge starts a row or sits inline with text and would otherwise look indented." />
    <.preview id={@id} code={&code_inset/1}>
      <div class="w-full max-w-lg space-y-4 text-sm">
        <div class="flex items-baseline gap-3">
          <span class="w-24 shrink-0 text-xs font-medium text-muted">Default</span>
          <Components.badge variant="subtle" color="success">Passed</Components.badge>
          <span class="text-toned">Build finished</span>
        </div>
        <div class="flex items-baseline gap-3">
          <span class="w-24 shrink-0 text-xs font-medium text-muted">Inset</span>
          <Components.badge variant="subtle" color="success" inset>Passed</Components.badge>
          <span class="text-toned">Build finished</span>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :uppercase} = assigns) do
    ~H"""
    <.prose content="Set `uppercase` to render the label in uppercase. A little letter spacing is added so short labels stay legible." />
    <.preview id={@id} code={&code_uppercase/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge variant="solid" color="info" uppercase>New</Components.badge>
        <Components.badge variant="subtle" color="success" uppercase>Stable</Components.badge>
        <Components.badge variant="outline" color="warning" uppercase>Beta</Components.badge>
        <Components.badge variant="dot" color="error" uppercase>Offline</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :as_link} = assigns) do
    ~H"""
    <.prose content="Pass `href`, `navigate`, or `patch` to render the badge as a link. The badge keeps its styling and gains native link semantics: `Enter` activates it,
      and assistive technology announces it as a link." />
    <.prose content="Use the link form for navigation. Keep a plain badge for labels and statuses that only describe something." />
    <.preview {assigns} code={&code_as_link/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge href="/components">Browse components</Components.badge>
        <Components.badge variant="solid" color="info" navigate="/components/badge">
          Badge docs
        </Components.badge>
        <Components.badge
          variant="outline"
          color="success"
          patch="/components/badge#usage-color"
        >
          Color options
        </Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :status_dot} = assigns) do
    ~H"""
    <.prose content="Use the `dot` variant for a status badge. The `color` fills the dot, while the border and text stay neutral. The dot is decorative, so keep
      the label meaningful and do not rely on color alone." />
    <.preview {assigns} code={dot_code()}>
      <div class="flex flex-wrap items-center gap-2">
        <Components.badge variant="dot" color="success" radius="xl">Online</Components.badge>
        <Components.badge variant="dot" color="warning" radius="xl">Pending</Components.badge>
        <Components.badge variant="dot" color="error" radius="xl">Offline</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :custom_color} = assigns) do
    ~H"""
    <.prose content="You can customize the `color` of a badge using raw CSS color for a one-off accent or a value that comes from data." />
    <.prose content="The best available contrast is used, so a mid-tone fill can still fall below AA when neither black nor white clears it.
      Raw colors are an escape hatch: they do not follow `data-theme` presets or the semantic role contract. Prefer a role for app-wide theming,
      and pass `style` to override the derived values." />
    <.prose content="You can also override the exposed CSS variables directly, either in your stylesheet or with inline styles." />

    <.preview {assigns} code={&code_raw/1} collapsed>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge variant="solid" color="#165DFC">J'aime le Bleu</Components.badge>

        <Components.badge
          variant="solid"
          radius="full"
          style="--fl-badge-color: var(--color-violet-700);  --fl-badge-color-content: white;
            background: linear-gradient(0.25turn, var(--color-violet-500), var(--color-fuchsia-500));"
        >
          Fancy Badge
        </Components.badge>
      </div>
    </.preview>
    """
  end

  defp code_variant(props) do
    Snippet.tag(".badge", [Snippet.attr("variant", props.variant, "subtle")], "Badge")
  end

  defp code_color(props) do
    Snippet.tag(
      ".badge",
      [Snippet.attr("color", props.color, "neutral"), Snippet.attr("variant", "solid")],
      "Badge"
    )
  end

  defp code_radius(props) do
    Snippet.tag(".badge", [Snippet.attr("radius", props.radius, "md")], "Badge")
  end

  defp code_icon(_) do
    """
    <.badge icon="lucide-sparkles">New</.badge>
    <.badge variant="solid" color="success" icon="lucide-check">Passed</.badge>
    <.badge variant="outline" color="info">
      <:leading>
        <.icon name="lucide-clock" />
      </:leading>
      In progress
    </.badge>
    <.badge variant="subtle" color="primary">
      Synced
      <:trailing>
        <.icon name="lucide-cloud" />
      </:trailing>
    </.badge>
    """
    |> String.trim()
  end

  defp code_size(_) do
    """
    <.badge size="xs">Extra Small</.badge>
    <.badge size="sm">Small</.badge>
    <.badge size="md">Medium</.badge>
    <.badge size="lg">Large</.badge>
    <.badge size="xl">Extra Large</.badge>
    """
    |> String.trim()
  end

  defp code_wide(_) do
    """
    <div class="w-full">
      <.badge variant="solid" color="info" wide>Full width</.badge>
    </div>
    """
    |> String.trim()
  end

  defp code_inset(_) do
    """
    <div class="flex items-baseline gap-3">
      <.badge variant="subtle" color="success">Passed</.badge>
      <span>Build finished</span>
    </div>

    <div class="flex items-baseline gap-3">
      <.badge variant="subtle" color="success" inset>Passed</.badge>
      <span>Build finished</span>
    </div>
    """
    |> String.trim()
  end

  defp code_uppercase(_) do
    """
    <.badge variant="solid" color="info" uppercase>New</.badge>
    <.badge variant="subtle" color="success" uppercase>Stable</.badge>
    <.badge variant="outline" color="warning" uppercase>Beta</.badge>
    <.badge variant="dot" color="error" uppercase>Offline</.badge>
    """
    |> String.trim()
  end

  defp code_as_link(_) do
    """
    <.badge href="/components">Browse components</.badge>
    <.badge variant="solid" color="info" navigate="/components/badge">Badge docs</.badge>
    <.badge variant="outline" color="success" patch="/components/badge#usage-color">Color options</.badge>
    """
    |> String.trim()
  end

  defp code_raw(_) do
    """
    <.badge variant="solid" color="#165DFC">J'aime le Bleu</.badge>
    <.badge variant="solid" radius="full"
      style="--fl-badge-color: var(--color-violet-700);  --fl-badge-color-content: white;
      background: linear-gradient(0.25turn, var(--color-violet-500), var(--color-fuchsia-500));"
    >Fancy Badge</.badge>
    """
    |> String.trim()
  end

  defp dot_code do
    """
    <.badge variant="dot" color="success" radius="xl">Online</.badge>
    <.badge variant="dot" color="warning" radius="xl">Pending</.badge>
    <.badge variant="dot" color="error" radius="xl">Offline</.badge>
    """
    |> String.trim()
  end

  defp sizes,
    do: [
      {"Extra Small", "xs"},
      {"Small", "sm"},
      {"Medium", "md"},
      {"Large", "lg"},
      {"Extra Large", "xl"}
    ]
end
