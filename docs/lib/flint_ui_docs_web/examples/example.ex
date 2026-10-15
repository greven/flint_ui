defmodule FlintUIDocsWeb.Examples.Example do
  @moduledoc """
  Behaviour for a single component's docs page content.

  Each component implements this in its own module (e.g.
  `FlintUIDocsWeb.Examples.Button`) so the controls, usage notes, examples,
  styling snippets, and live renders for one component live together instead of
  in one growing catch-all module.

  `use FlintUIDocsWeb.Examples.Example, component: :button` brings in `FlintUI`
  (for the components used in `render_example/1`), records the component name,
  and provides defaults for every section: `controls/0`, `defaults/0`, the
  `accessibility/0` prose (read from the component's moduledoc), and empty
  `usage/0`, `examples/0`, and `styling/0`.

  Sections are authored as plain data:

    * `usage/0` - `[%{id, title, body, code}]`, one entry per attribute group
    * `examples/0` - `[%{id, title, description, code}]`, rendered by `render_block/1`
    * `styling/0` - `%{body, snippets: [%{title, code}]}`, plain CSS for the base
    * `styled/0` - `%{description, code}` for the generated component
  """

  @callback component() :: atom()
  @callback controls() :: [map()]
  @callback defaults() :: map()
  @callback usage() :: [map()]
  @callback examples() :: [map()]
  @callback styling() :: map() | nil
  @callback accessibility() :: String.t() | nil
  @callback structure() :: String.t() | nil
  @callback render_example(assigns :: map()) :: Phoenix.LiveView.Rendered.t()
  @callback render_code(assigns :: map()) :: String.t() | nil
  @callback render_block(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil
  @callback styled() :: map() | nil
  @callback render_styled(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil

  defmacro __using__(opts) do
    component = Keyword.fetch!(opts, :component)

    quote do
      @behaviour FlintUIDocsWeb.Examples.Example

      use FlintUI

      @component unquote(component)

      @doc "The component this page documents."
      def component, do: @component

      @doc "Usage sections. Override to document attribute groups."
      def usage, do: []

      @doc "Example sections rendered through `render_block/1`."
      def examples, do: []

      @doc "Plain-CSS styling snippets for the base component."
      def styling, do: nil

      @doc "Renders one example or recipe preview. Override and match on `:block`."
      def render_block(_assigns), do: nil

      @doc "Generates the HEEx source for the current playground props, or `nil` to hide the Code tab."
      def render_code(_assigns), do: nil

      @doc "Styled-layer preview and snippet for the generated component."
      def styled, do: nil

      @doc "Renders the styled-layer preview for the generated component."
      def render_styled(_assigns), do: nil

      @doc "Accessibility prose, read from the component's moduledoc by default."
      def accessibility, do: FlintUI.Docs.section(@component, "Accessibility")

      @doc "Default props derived from `controls/0`."
      def defaults do
        Map.new(controls(), fn control -> {control.key, control.default} end)
      end

      defoverridable component: 0,
                     usage: 0,
                     examples: 0,
                     styling: 0,
                     render_block: 1,
                     render_code: 1,
                     styled: 0,
                     render_styled: 1,
                     accessibility: 0,
                     defaults: 0
    end
  end
end
