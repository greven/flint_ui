defmodule FlintUIDocsWeb.Examples do
  @moduledoc """
  Facade over the per-component docs page modules.

  Each component has a module under `FlintUIDocsWeb.Examples`
  (e.g. `FlintUIDocsWeb.Examples.Button`) that implements
  `FlintUIDocsWeb.Examples.Example`.

  Register it in `@modules` below; anything not registered
  falls back to `FlintUIDocsWeb.Examples.Default`.

  Components declare:

    * `controls/0` - interactive properties shown in the controls panel
    * `usage/0` - usage sections, one per attribute group
    * `examples/0` - example sections rendered in the Examples block
    * `styling/0` - plain-CSS styling snippets for the base
    * `accessibility/0` - accessibility prose
    * `structure/0` - the anatomy snippet shown under Usage
    * `render_example/1` - the live playground render
    * `render_block/1` - the render for an example or recipe preview
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Examples.{
    Button,
    Collapsible,
    Default,
    Icon,
    Loading,
    Toggle
  }

  @modules %{
    button: Button,
    collapsible: Collapsible,
    icon: Icon,
    loading: Loading,
    toggle: Toggle
  }

  attr(:name, :atom, required: true)
  attr(:props, :map, required: true)
  attr(:id, :string, required: true)

  def render_example(assigns) do
    module(assigns.name).render_example(assigns)
  end

  attr(:name, :atom, required: true)
  attr(:block, :atom, required: true)
  attr(:props, :map, required: true)
  attr(:id, :string, required: true)

  def render_block(assigns) do
    module(assigns.name).render_block(assigns)
  end

  attr(:name, :atom, required: true)
  attr(:props, :map, default: %{})
  attr(:id, :string, required: true)

  def render_styled(assigns) do
    module(assigns.name).render_styled(assigns)
  end

  @doc """
  Returns the registered `{name, module}` page modules.
  """
  def modules, do: @modules

  def controls(name), do: module(name).controls()
  def defaults(name), do: module(name).defaults()
  def usage(name), do: module(name).usage()
  def examples(name), do: module(name).examples()
  def styling(name), do: module(name).styling()
  def styled(name), do: module(name).styled()
  def accessibility(name), do: module(name).accessibility()
  def structure(name), do: module(name).structure()

  defp module(name), do: Map.get(@modules, name, Default)
end
