defmodule FlintUIDocsWeb.Docs.Text do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :text

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
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :color, type: :select, default: "default", label: "Color"},
          %{key: :weight, type: :select, default: "normal", label: "Weight"},
          %{key: :align, type: :select, default: "start", label: "Align"}
        ]
      },
      %{tab: :styled, section: :usage, id: :inline, title: "Inline Text"},
      %{tab: :styled, section: :usage, id: :links, title: "Links"},
      %{tab: :styled, section: :usage, id: :external, title: "External Links"},
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
        id: :article_lede,
        title: "Article Lede",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="`Text` renders a paragraph by default. `size` selects the type scale, `color` selects an ink tier or a semantic role, and `weight` and `align` adjust the block without changing the element. Use `as` when the content needs a different element." />
    <.preview :let={props} {assigns} code={&basic_code/1}>
      <Components.text
        size={props.size}
        color={props.color}
        weight={props.weight}
        align={props.align}
        class="max-w-prose"
      >
        FlintUI separates behavior from appearance. The headless component owns the
        semantics, and the generated wrapper maps design props onto the theme.
      </Components.text>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :inline} = assigns) do
    ~H"""
    <.prose content={"Use `as=\"span\"` for a run of text inside a larger block. The root stays inline, so the surrounding paragraph controls the line box. Inline links inside a text block keep their underline and follow the block's ink; a link in the default tier uses the primary ink."} />
    <.preview {assigns} code={inline_code()}>
      <Components.text as="p" class="max-w-prose">
        Read the
        <Components.text as="span" color="primary">installation guide</Components.text>
        before generating your first component. The guide covers the theme file, the
        wrapper target, and the assets pipeline.
      </Components.text>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :links} = assigns) do
    ~H"""
    <.prose content="Pass `href`, `navigate`, or `patch` to render a native link with the text styling and an underline. A link in the default tier uses the primary ink; pass a role color to match a surrounding accent. The underline takes the link's ink at reduced opacity and becomes solid on hover and keyboard focus." />
    <.preview {assigns} code={links_code()}>
      <div class="flex flex-col gap-3">
        <Components.text href="/components/heading">Read the heading guide</Components.text>
        <Components.text navigate="/components/button" color="success">
          Go to the button component
        </Components.text>
        <Components.text as="span" color="muted">
          A span can be a link too:
          <Components.text as="a" href="/guides/theming" color="primary">
            open the theming guide
          </Components.text>
        </Components.text>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :external} = assigns) do
    ~H"""
    <.prose content="Set `external` on a link to append a trailing arrow. The arrow is decorative and comes from `external_icon`, which defaults to `lucide-arrow-up-right`; pass another icon class to match your set, or an empty string to keep the hook without an arrow. `external` does not change where the link opens, so set `target` and `rel` when it should open in a new tab." />
    <.preview {assigns} code={external_code()}>
      <div class="flex flex-col gap-3">
        <Components.text href="https://hexdocs.pm/phoenix" external>
          Phoenix documentation
        </Components.text>
        <Components.text
          href="https://hexdocs.pm/phoenix"
          external
          target="_blank"
          rel="noopener noreferrer"
        >
          Phoenix documentation in a new tab
        </Components.text>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :truncation} = assigns) do
    ~H"""
    <.prose content="`truncate` keeps the text on one line. `line_clamp` limits a paragraph to a fixed number of lines. Both turn the root into a block or line-clamp box; `line_clamp` wins when both are set." />
    <.preview :let={props} {assigns} code={&truncation_code/1}>
      <div class="w-full max-w-xs space-y-6">
        <Components.text truncate>
          A long line of supporting copy that stays on one line
        </Components.text>
        <Components.text line_clamp={props.line_clamp}>
          A longer paragraph that wraps over a controlled number of lines and then stops,
          keeping card and list layouts aligned while the full text remains in the DOM.
        </Components.text>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :article_lede} = assigns) do
    ~H"""
    <.prose content="Combine `Heading` for the document title with `Text` for the lede. The heading owns the display scale; the lede uses a toned ink and a comfortable measure." />
    <.preview {assigns} code={article_lede_code()}>
      <div class="max-w-2xl">
        <Components.heading as="h1" size="4xl">
          <:kicker>Engineering</:kicker>
          Designing a component layer without global styles
          <:subtitle>
            How FlintUI keeps semantics, theme tokens, and generated wrappers in one system.
          </:subtitle>
        </Components.heading>
        <Components.text size="lg" color="toned" class="mt-6">
          A component library usually starts with a reset and a pile of utility classes.
          FlintUI starts with the native element, then builds the visual layer outward from
          tokens that a consumer can replace.
        </Components.text>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="max-w-prose space-y-3">
      <Components.text>
        A paragraph with the default ink and the shared type scale.
      </Components.text>
      <Components.text as="span" color="primary">An inline link or accent text.</Components.text>
    </div>
    """
  end

  defp basic_code(props) do
    attrs = [
      Snippet.attr("size", props.size, "md"),
      Snippet.attr("color", props.color, "default"),
      Snippet.attr("weight", props.weight, "normal"),
      Snippet.attr("align", props.align, "start")
    ]

    Snippet.tag(".text", attrs, """
    FlintUI separates behavior from appearance. The headless component owns the
    semantics, and the generated wrapper maps design props onto the theme.
    """)
  end

  defp inline_code do
    """
    <.text as="p">
      Read the <.text as="span" color="primary">installation guide</.text>
      before generating your first component.
    </.text>
    """
    |> String.trim()
  end

  defp links_code do
    """
    <.text href="/components/heading">Read the heading guide</.text>
    <.text navigate="/components/button" color="success">Go to the button component</.text>
    <.text as="span" color="muted">
      A span can be a link too:
      <.text as="a" href="/guides/theming" color="primary">open the theming guide</.text>
    </.text>
    """
    |> String.trim()
  end

  defp external_code do
    """
    <.text href="https://hexdocs.pm/phoenix" external>
      Phoenix documentation
    </.text>

    <.text
      href="https://hexdocs.pm/phoenix"
      external
      target="_blank"
      rel="noopener noreferrer"
    >
      Phoenix documentation in a new tab
    </.text>
    """
    |> String.trim()
  end

  defp truncation_code(props) do
    """
    <div class="max-w-xs space-y-6">
      <.text truncate>A long line of supporting copy that stays on one line</.text>
      <.text line_clamp={#{props.line_clamp}}>
        A longer paragraph that wraps over a controlled number of lines and then stops,
        keeping card and list layouts aligned while the full text remains in the DOM.
      </.text>
    </div>
    """
    |> String.trim()
  end

  defp article_lede_code do
    """
    <div class="max-w-2xl">
      <.heading as="h1" size="4xl">
        <:kicker>Engineering</:kicker>
        Designing a component layer without global styles
        <:subtitle>
          How FlintUI keeps semantics, theme tokens, and generated wrappers in one system.
        </:subtitle>
      </.heading>
      <.text size="lg" color="toned" class="mt-6">
        A component library usually starts with a reset and a pile of utility classes.
        FlintUI starts with the native element, then builds the visual layer outward from
        tokens that a consumer can replace.
      </.text>
    </div>
    """
    |> String.trim()
  end
end
