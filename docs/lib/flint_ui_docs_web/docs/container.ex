defmodule FlintUIDocsWeb.Docs.Container do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :container

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
          %{
            key: :as,
            type: :select,
            default: "div",
            label: "Element",
            values: ~w(div section article aside header footer nav form)
          },
          %{key: :size, type: :select, default: "6xl", label: "Size"}
        ]
      },
      %{tab: :styled, section: :usage, id: :responsive, title: "Responsive max-width"},
      %{
        tab: :styled,
        section: :examples,
        id: :page,
        title: "Page shell",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :fluid, title: "Fluid and arbitrary"},
      %{tab: :css, section: :layout_inputs, id: :inputs, title: "Layout inputs"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={
      ~s|A container centers its content and caps its inline size. `size` accepts a container token from `xs` to `7xl`, `fluid`, a number of pixels, or an arbitrary CSS length; `as` chooses the semantic element. The default is `size="6xl"` with inline padding from `--fl-spacing-lg`.|
    } />

    <.preview :let={props} {assigns} code={&basic_code/1}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.container
          as={props.as}
          size={props.size}
          class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-md"
        >
          <p class="fl-text-highlighted fl-font-medium">Container content</p>
          <p class="fl-text-toned fl-text-sm">Centered and capped by the size prop.</p>
        </Components.container>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :responsive} = assigns) do
    ~H"""
    <.prose content={
      ~s|Pass a map to `size` to change the cap at breakpoints. The base value applies first; each key overrides the previous step from that viewport width up. Keys are `base`, `sm`, `md`, `lg`, `xl`, and `2xl`; `2xl` is a string key in Elixir. A map without `base` starts from the default `6xl`.|
    } />

    <.preview {assigns} code={responsive_code()} code_only />
    """
  end

  def render_section(%{section: :examples, id: :page} = assigns) do
    ~H"""
    <.prose content={
      ~s|Use `as` for structure and `size` for the measure. The container centers the page content; a stack handles the rhythm inside it. Use `as="main"` once per document, or `as="section"` with a heading when the container is one region of a larger page.|
    } />

    <.preview {assigns} code={page_code()}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.container
          as="section"
          size="md"
          aria-labelledby="container-page-title"
          class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-lg"
        >
          <Components.stack gap="sm">
            <Components.heading as="h2" size="lg" id="container-page-title">
              Release notes
            </Components.heading>
            <p class="fl-text-toned">Tokens, components, and utilities in one release.</p>
            <Components.button size="sm">Read the notes</Components.button>
          </Components.stack>
        </Components.container>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :fluid} = assigns) do
    ~H"""
    <.prose content={
      ~s|`size="fluid"` removes the cap for full-width content such as a table or media band. A number is pixels converted to rem (`384` becomes `24rem`); any other CSS length is used as written, so `clamp(20rem, 80vw, 60rem)` is also valid.|
    } />

    <.preview {assigns} code={fluid_code()}>
      <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
        <Components.stack gap="sm">
          <Components.container
            size="fluid"
            class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-md"
          >
            <p class="fl-text-highlighted fl-font-medium">Fluid content</p>
            <p class="fl-text-toned fl-text-sm">
              The container fills the available inline size.
            </p>
          </Components.container>
          <Components.container
            size={384}
            class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-md"
          >
            <p class="fl-text-highlighted fl-font-medium">24rem content</p>
            <p class="fl-text-toned fl-text-sm">A numeric size caps the measure.</p>
          </Components.container>
        </Components.stack>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :layout_inputs, id: :inputs} = assigns) do
    ~H"""
    <.prose content={
      ~s|The styled layer sets `--fl-container-size` and `--fl-container-padding`; the responsive map writes `--fl-container-size-{sm,md,lg,xl,2xl}` overrides. Set an input on one container with `style` when the scale is not enough, and keep `size` for the common case.|
    } />

    <.preview {assigns} code={layout_inputs_code()} code_only />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full fl-rounded-lg fl-bg-subtle fl-p-md">
      <Components.container
        size="sm"
        class="fl-rounded-lg fl-border fl-border-default fl-bg-surface fl-p-md"
      >
        <p class="fl-text-highlighted fl-font-medium">Centered content</p>
        <p class="fl-text-toned fl-text-sm">The container root is the only part.</p>
      </Components.container>
    </div>
    """
  end

  defp basic_code(props) do
    Snippet.tag(
      ".container",
      [
        Snippet.attr("as", props.as, "div"),
        Snippet.attr("size", props.size, "6xl")
      ],
      """
      <div class="fl-rounded-lg fl-border fl-p-md">
        <p>Content</p>
      </div>
      """
    )
  end

  defp responsive_code do
    """
    <.container size={%{"2xl" => "7xl", base: "md", md: "xl"}}>
      <p>Content</p>
    </.container>
    """
    |> String.trim()
  end

  defp page_code do
    """
    <.container as="section" size="md" aria-labelledby="release-title">
      <.stack gap="sm">
        <.heading as="h2" size="lg" id="release-title">Release notes</.heading>
        <p>Tokens, components, and utilities in one release.</p>
        <.button size="sm">Read the notes</.button>
      </.stack>
    </.container>
    """
    |> String.trim()
  end

  defp fluid_code do
    """
    <.stack gap="sm">
      <.container size="fluid">
        <p>Full-width content</p>
      </.container>

      <.container size={384}>
        <p>24rem cap</p>
      </.container>
    </.stack>
    """
    |> String.trim()
  end

  defp layout_inputs_code do
    """
    <.container size="5xl" style="--fl-container-padding: var(--fl-spacing-xl)">
      <p>Content</p>
    </.container>
    """
    |> String.trim()
  end
end
