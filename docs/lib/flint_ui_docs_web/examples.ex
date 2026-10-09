defmodule FlintUIDocsWeb.Examples do
  @moduledoc """
  Facade over the per-component example modules.

  Each component has a module under `FlintUIDocsWeb.Examples`
  (e.g. `FlintUIDocsWeb.Examples.Button`) that implements
  `FlintUIDocsWeb.Examples.Example`.

  Register it in `@modules` below; anything not registered
  falls back to `FlintUIDocsWeb.Examples.Default`.

  Components declare:

    * `controls/0` - interactive properties shown in the controls panel
    * `variants/0` - labelled states rendered in the examples matrix
    * `structure/0` - the anatomy snippet shown under "Structure"
    * `render_example/1` - the function component that renders a live example
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Examples.{
    Button,
    Collapsible,
    Default,
    Icon,
    Loading
  }

  @modules %{
    button: Button,
    collapsible: Collapsible,
    icon: Icon,
    loading: Loading
  }

  attr(:name, :atom, required: true)
  attr(:props, :map, required: true)
  attr(:id, :string, required: true)

  def render_example(assigns) do
    module(assigns.name).render_example(assigns)
  end

  @doc """
  Returns the registered `{name, module}` example definitions.
  """
  def modules, do: @modules

  def controls(name), do: module(name).controls()
  def variants(name), do: module(name).variants()
  def structure(name), do: module(name).structure()
  def defaults(name), do: module(name).defaults()

  defp module(name), do: Map.get(@modules, name, Default)
end
