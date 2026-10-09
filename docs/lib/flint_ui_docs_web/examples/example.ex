defmodule FlintUIDocsWeb.Examples.Example do
  @moduledoc """
  Behaviour for a single component's docs example.

  Each component implements this in its own module (e.g.
  `FlintUIDocsWeb.Examples.Button`) so the controls, variants, structure snippet,
  and live render for one component live together instead of in one growing
  catch-all module.

  `use FlintUIDocsWeb.Examples.Example` brings in `FlintUI` (for the components
  used in `render_example/1`) and a `defaults/0` helper derived from `controls/0`.
  """

  @callback controls() :: [map()]
  @callback variants() :: [{String.t(), map()}]
  @callback structure() :: String.t() | nil
  @callback render_example(assigns :: map()) :: Phoenix.LiveView.Rendered.t()

  defmacro __using__(_opts) do
    quote do
      @behaviour FlintUIDocsWeb.Examples.Example

      use FlintUI

      @doc "Default props derived from `controls/0`."
      def defaults do
        Map.new(controls(), fn control -> {control.key, control.default} end)
      end

      defoverridable defaults: 0
    end
  end
end
