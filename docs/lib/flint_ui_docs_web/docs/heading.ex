defmodule FlintUIDocsWeb.Docs.Heading do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :heading

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
          %{key: :size, type: :select, default: "auto", label: "Size"},
          %{key: :color, type: :select, default: "highlighted", label: "Color"},
          %{key: :weight, type: :select, default: "semibold", label: "Weight"},
          %{key: :align, type: :select, default: "start", label: "Align"}
        ]
      },
      %{tab: :styled, section: :usage, id: :levels, title: "Levels and Visual Size"},
      %{tab: :styled, section: :usage, id: :kicker_subtitle, title: "Kicker and Subtitle"},
      %{
        tab: :styled,
        section: :usage,
        id: :truncation,
        title: "Truncation",
        controls: [%{key: :line_clamp, type: :number, default: 2, label: "Lines"}]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :page_header,
        title: "Page Header",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={"`Heading` renders a real `h1`–`h6` and keeps the visual size separate from the document outline. `size=\"auto\"` follows `as`: an `h2` starts at `4xl`, while `as=\"h1\"` starts at `5xl`. Pass a scale step to change only the visual size. The caller `class` and `style` land on the container, so you can set a measure or spacing once; `id`, `aria-*`, and events land on the native heading."} />
    <.preview :let={props} {assigns} code={&basic_code/1}>
      <Components.heading
        size={props.size}
        color={props.color}
        weight={props.weight}
        align={props.align}
      >
        A heading that scales with the page
      </Components.heading>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :levels} = assigns) do
    ~H"""
    <.prose content="Use `as` for the document structure and leave `size` on `auto` when the default ramp fits. Do not choose a lower heading level to make the text smaller; keep the outline correct and let `size` carry the visual hierarchy." />
    <.preview {assigns} code={levels_code()}>
      <div class="fl-stack fl-w-full fl-gap-lg">
        <div :for={level <- ~w(h1 h2 h3 h4 h5 h6)} class="flex items-baseline gap-4">
          <span class="w-6 shrink-0 font-mono text-xs text-muted">{level}</span>
          <Components.heading as={level}>Section title</Components.heading>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :kicker_subtitle} = assigns) do
    ~H"""
    <.prose content="A kicker labels the heading from above and a subtitle supports it from below. Both sit outside the `h1`–`h6` element, so they do not join the heading's accessible name. The default kicker treatment is small, uppercase, and tracked; the subtitle uses the toned ink and scales from the heading. Keep both short and let the heading carry the main idea." />
    <.preview {assigns} code={kicker_subtitle_code()}>
      <div class="max-w-2xl">
        <Components.heading as="h1" size="4xl">
          <:kicker>Release notes</:kicker>
          Build faster with FlintUI
          <:subtitle>
            A headless component layer and a generated theme, designed to ship together.
          </:subtitle>
        </Components.heading>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :truncation} = assigns) do
    ~H"""
    <.prose content="Use `truncate` for a single line and `line_clamp` for a fixed number of lines. Both target the heading title, so the kicker and subtitle stay visible. `line_clamp` wins when both are set." />
    <.preview :let={props} {assigns} code={&truncation_code/1}>
      <div class="fl-w-full max-w-xs fl-stack fl-gap-xl">
        <Components.heading truncate>
          A long heading that stays on one line
        </Components.heading>
        <Components.heading line_clamp={props.line_clamp}>
          A long heading that wraps over a controlled number of lines and then stops
        </Components.heading>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :page_header} = assigns) do
    ~H"""
    <.prose content="A page header combines the semantic `h1`, a kicker, a subtitle, and body copy. The heading block owns the vertical rhythm, while the surrounding layout owns its width and spacing." />
    <.preview {assigns} code={page_header_code()}>
      <div class="max-w-2xl">
        <Components.heading as="h1" size="5xl" color="highlighted">
          <:kicker>FlintUI 0.1</:kicker>
          Build interfaces that feel inevitable
          <:subtitle>
            Accessible parts, a theme you own, and no utility-class dependency.
          </:subtitle>
        </Components.heading>
        <Components.text color="toned" class="mt-6">
          Start with the headless components, generate the wrappers you use, and shape the
          theme with tokens. The same markup works with or without Tailwind.
        </Components.text>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <Components.heading as="h2" size="3xl">
      <:kicker>Release notes</:kicker>
      Everything new in this version
      <:subtitle>A small release with a few useful additions.</:subtitle>
    </Components.heading>
    """
  end

  defp basic_code(props) do
    attrs = [
      Snippet.attr("size", props.size, "auto"),
      Snippet.attr("color", props.color, "highlighted"),
      Snippet.attr("weight", props.weight, "semibold"),
      Snippet.attr("align", props.align, "start")
    ]

    Snippet.tag(".heading", attrs, "A heading that scales with the page")
  end

  defp levels_code do
    """
    <.heading as="h1">Section title</.heading>
    <.heading as="h2">Section title</.heading>
    <.heading as="h3">Section title</.heading>
    <.heading as="h4">Section title</.heading>
    <.heading as="h5">Section title</.heading>
    <.heading as="h6">Section title</.heading>
    """
    |> String.trim()
  end

  defp kicker_subtitle_code do
    """
    <.heading as="h1" size="4xl">
      <:kicker>Release notes</:kicker>
      Build faster with FlintUI
      <:subtitle>
        A headless component layer and a generated theme, designed to ship together.
      </:subtitle>
    </.heading>
    """
    |> String.trim()
  end

  defp truncation_code(props) do
    """
    <div class="max-w-xs fl-stack fl-gap-xl">
      <.heading truncate>A long heading that stays on one line</.heading>
      <.heading line_clamp={#{props.line_clamp}}>
        A long heading that wraps over a controlled number of lines and then stops
      </.heading>
    </div>
    """
    |> String.trim()
  end

  defp page_header_code do
    """
    <div class="max-w-2xl">
      <.heading as="h1" size="5xl" color="highlighted">
        <:kicker>FlintUI 0.1</:kicker>
        Build interfaces that feel inevitable
        <:subtitle>
          Accessible parts, a theme you own, and no utility-class dependency.
        </:subtitle>
      </.heading>
      <.text color="toned" class="mt-6">
        Start with the headless components, generate the wrappers you use, and shape the
        theme with tokens. The same markup works with or without Tailwind.
      </.text>
    </div>
    """
    |> String.trim()
  end
end
