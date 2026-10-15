defmodule FlintUIDocsWeb.ComponentDocs.Page do
  @moduledoc """
  Behaviour for a single component's docs page content.

  Each component implements this in its own module (e.g.
  `FlintUIDocsWeb.ComponentDocs.Button`) so the controls, usage notes, examples,
  styling snippets, and live renders for one component live together instead of
  in one growing catch-all module.

  `use FlintUIDocsWeb.ComponentDocs.Page, component: :button` brings in `FlintUI`
  (for the components used in the render callbacks), records the component name,
  and provides defaults for every section: `controls/0`, `defaults/0`, the
  `accessibility/0` prose (read from the component's moduledoc), and empty
  `usage/0`, `examples/0`, `anatomy/0`, and `styling/0`.

  Sections are authored as plain data. The component page renders them across
  two tabs (Docs and Base), so every section declares which layer it belongs to
  and both tabs read from the same source:

    * `usage/0` - `[%{id, title, layer, body, code}]`, one entry per attribute,
      slot, or behaviour. `layer` is `:base` or `:styled`; the Docs tab shows
      every entry, the Base tab only the `:base` ones.
    * `examples/0` - `[%{id, title, description, code}]`, rendered by
      `render_block/1` in the Docs Examples section
    * `anatomy/0` - `%{body, nodes}` describing the rendered element tree, or `nil`
    * `styling/0` - `%{body, snippets: [%{title, code}]}`, plain CSS for the base
  """

  @callback component() :: atom()
  @callback controls() :: [map()]
  @callback defaults() :: map()
  @callback usage() :: [map()]
  @callback examples() :: [map()]
  @callback anatomy() :: map() | nil
  @callback accessibility() :: String.t() | nil
  @callback structure() :: String.t() | nil
  @callback styling() :: map() | nil
  @callback render_playground(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  @callback render_code(assigns :: map()) :: String.t() | nil
  @callback render_usage(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil
  @callback render_block(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil

  defmacro __using__(opts) do
    component = Keyword.fetch!(opts, :component)

    quote do
      @behaviour FlintUIDocsWeb.ComponentDocs.Page

      use FlintUI

      @component unquote(component)

      @doc "The component this page documents."
      def component, do: @component

      @doc "Playground controls for the Docs tab (base and styled attributes)."
      def controls, do: []

      @doc "Usage sections. Override to document attribute groups."
      def usage, do: []

      @doc "Example sections rendered through `render_block/1`."
      def examples, do: []

      @doc "Structured anatomy of the rendered markup, or `nil`."
      def anatomy, do: nil

      @doc "Plain-CSS styling snippets for the base component."
      def styling, do: nil

      @doc "Legacy anatomy fallback: the structural snippet shown when `anatomy/0` is `nil`."
      def structure, do: nil

      @doc "Renders the interactive playground for a layer (`:base` or `:styled`)."
      def render_playground(_assigns), do: nil

      @doc "Generates the HEEx source for the current playground props, or `nil` to hide the Code tab."
      def render_code(_assigns), do: nil

      @doc "Renders one usage subsection preview. Override and match on `:block`."
      def render_usage(_assigns), do: nil

      @doc "Renders one example or recipe preview. Override and match on `:block`."
      def render_block(_assigns), do: nil

      @doc "Accessibility prose, read from the component's moduledoc by default."
      def accessibility, do: FlintUI.Docs.section(@component, "Accessibility")

      @doc "Default props derived from `controls/0`."
      def defaults do
        Map.new(controls(), fn control -> {control.key, control.default} end)
      end

      defoverridable component: 0,
                     controls: 0,
                     usage: 0,
                     examples: 0,
                     anatomy: 0,
                     styling: 0,
                     structure: 0,
                     render_playground: 1,
                     render_code: 1,
                     render_usage: 1,
                     render_block: 1,
                     accessibility: 0,
                     defaults: 0
    end
  end
end
