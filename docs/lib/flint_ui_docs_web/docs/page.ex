defmodule FlintUIDocsWeb.Docs.Page do
  @moduledoc """
  Behaviour for a single component's docs page content.

  Each component implements this in its own module (e.g.
  `FlintUIDocsWeb.Docs.Button`) so the controls, prose, examples, and live
  renders for one component live together.

  `use FlintUIDocsWeb.Docs.Page, component: :button` imports `FlintUI` (for the
  base components used in render callbacks), imports the `<.preview>` function
  component, records the component name, and provides defaults for every
  section.

  ## Page shape

  Every component page has one layout:

    * a title, subtitle, and header links
    * a Styled tab: main preview, overview, features, usage sections, examples,
      API reference, and setup
    * a Base tab: overview, anatomy, features (including accessibility and
      keyboard), architecture, structure, usage, examples, and API reference
    * a CSS tab: the styled layer's CSS contract

  Sections are authored as plain data where they do not render a preview:

    * `usage/0` - `[%{id, title, layer, covers, body, code | codes}]`. `layer` is
      `:base` or `:styled`; the Styled tab shows the `:styled` entries, the Base
      tab the `:base` ones. `covers` names the attribute(s) the entry documents
      and is checked by the docs tests.
    * `examples/0` - `[%{id, title, description, layer, code | codes}]`. Base
      examples render as prose + code; styled examples render through
      `render_section/1`.
    * `anatomy/0` - `%{body, nodes}` describing the rendered element tree, or `nil`
    * `architecture/0` - `[%{name, description}]` for each subcomponent, or `nil`
    * `structure/0` - a plain code snippet shown on the Base tab
    * `styling/0` - plain CSS for the base component (used by the Styling guide)
    * `css/0` - the styled layer's CSS contract

  ## Previews

  Every Styled preview is a `<.preview>` call. The demo is the inner block and
  the teaching snippet is the `code` (or `codes`) attribute, so the two stay in
  one place: the `render_section/1` clause passes `code={code(:variant)}`, and a
  small `code/1` helper beside it returns the teaching snippet.

  `render_main/1` returns the hero preview. `render_section/1` returns one
  usage or example preview and matches on `kind` and `block`. Styled usage and
  example entries therefore omit `code`; base entries keep it because the Base
  tab renders code without a live preview.

  `code` also accepts a 1-arity function of the current props, which keeps the
  playground snippet in step with its controls.
  """

  @callback component() :: atom()
  @callback title() :: String.t()
  @callback subtitle() :: String.t() | nil
  @callback links() :: [map()]
  @callback controls() :: [map()]
  @callback styled_overview() :: String.t() | nil
  @callback base_overview() :: String.t() | nil
  @callback styled_features() :: [String.t() | map()]
  @callback base_features() :: [String.t() | map()]
  @callback usage() :: [map()]
  @callback examples() :: [map()]
  @callback anatomy() :: map() | nil
  @callback architecture() :: [map()] | nil
  @callback accessibility() :: String.t() | nil
  @callback structure() :: String.t() | nil
  @callback styling() :: map() | nil
  @callback css() :: map() | nil
  @callback render_main(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil
  @callback render_section(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil

  defmacro __using__(opts) do
    component = Keyword.fetch!(opts, :component)

    quote do
      @behaviour FlintUIDocsWeb.Docs.Page

      use FlintUI
      import FlintUIDocsWeb.Preview

      @component unquote(component)

      @doc "The component this page documents."
      def component, do: @component

      @doc "The page title. Override when the component name is not enough."
      def title do
        @component
        |> Atom.to_string()
        |> String.split("_")
        |> Enum.map_join(" ", &String.capitalize/1)
      end

      @doc "A short description shown under the title."
      def subtitle, do: FlintUI.Docs.description(@component)

      @doc "Header links beside the title (source, hex docs, ...)."
      def links do
        [
          %{
            label: "Source",
            href: FlintUIDocsWeb.Docs.source_url(@component),
            icon: "lucide-github"
          }
        ]
      end

      @doc "Playground controls available to previews on this page."
      def controls, do: []

      @doc "Longer prose shown after the Styled main preview."
      def styled_overview, do: nil

      @doc "Longer prose shown at the top of the Base tab."
      def base_overview, do: styled_overview()

      @doc "Key features of the styled component."
      def styled_features, do: []

      @doc "Key features of the base component. Accessibility and keyboard are appended by the page."
      def base_features, do: []

      @doc "Usage sections. Styled entries render through `render_section/1`; base entries render as prose + code."
      def usage, do: []

      @doc "Examples. Styled entries render through `render_section/1`; base entries render as prose + code."
      def examples, do: []

      @doc "Structured anatomy of the rendered markup, or `nil`."
      def anatomy, do: nil

      @doc "Subcomponents that make up the component, or `nil`."
      def architecture, do: nil

      @doc "Accessibility prose, read from the component's moduledoc by default."
      def accessibility, do: FlintUI.Docs.section(@component, "Accessibility")

      @doc "Legacy anatomy fallback: the structural snippet shown when `anatomy/0` is `nil`."
      def structure, do: nil

      @doc "Plain-CSS styling snippets for the base component."
      def styling, do: nil

      @doc "The styled layer's CSS contract: prose, selectors, and customization snippets."
      def css, do: nil

      @doc "Renders the Styled main preview. Override and return a `<.preview>`."
      def render_main(_assigns), do: nil

      @doc "Renders one Styled usage or example preview. Match on `:kind` and `:block`."
      def render_section(_assigns), do: nil

      defoverridable component: 0,
                     title: 0,
                     subtitle: 0,
                     links: 0,
                     controls: 0,
                     styled_overview: 0,
                     base_overview: 0,
                     styled_features: 0,
                     base_features: 0,
                     usage: 0,
                     examples: 0,
                     anatomy: 0,
                     architecture: 0,
                     accessibility: 0,
                     structure: 0,
                     styling: 0,
                     css: 0,
                     render_main: 1,
                     render_section: 1
    end
  end
end
