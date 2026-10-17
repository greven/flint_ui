defmodule FlintUIDocsWeb.ComponentDocs do
  @moduledoc """
  Facade over the per-component docs page modules.

  Each component has a module under `FlintUIDocsWeb.ComponentDocs`
  (e.g. `FlintUIDocsWeb.ComponentDocs.Button`) that implements
  `FlintUIDocsWeb.ComponentDocs.Page`.

  Register it in `@modules` below; anything not registered falls back to
  `FlintUIDocsWeb.ComponentDocs.Default`.

  Components declare (`ComponentDocs.Page` for the full contract):

    * `controls/0` - interactive properties shown in the Docs playground
    * `usage/0` - usage sections, one per attribute, tagged `:base` or `:styled`
    * `examples/0` - example sections rendered in the Examples block
    * `anatomy/0` - structured element tree for the Base tab
    * `styling/0` - plain-CSS styling snippets for the base
    * `accessibility/0` - accessibility prose
    * `render_playground/1` - the live playground render for a layer
    * `render_usage/1` - the render for a usage subsection preview
    * `render_block/1` - the render for an example or recipe preview
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.ComponentDocs.{
    Button,
    Card,
    Collapsible,
    Default,
    Group,
    Icon,
    Loading,
    Toggle
  }

  @modules %{
    button: Button,
    card: Card,
    collapsible: Collapsible,
    group: Group,
    icon: Icon,
    loading: Loading,
    toggle: Toggle
  }

  attr(:name, :atom, required: true)
  attr(:layer, :atom, default: :base)
  attr(:props, :map, default: %{})
  attr(:id, :string, required: true)

  def render_playground(assigns) do
    module(assigns.name).render_playground(assigns)
  end

  attr(:name, :atom, required: true)
  attr(:layer, :atom, default: :base)
  attr(:props, :map, default: %{})
  attr(:id, :string, required: true)

  def render_code(assigns) do
    module(assigns.name).render_code(assigns)
  end

  attr(:name, :atom, required: true)
  attr(:layer, :atom, default: :base)
  attr(:block, :atom, required: true)
  attr(:props, :map, default: %{})
  attr(:id, :string, required: true)

  def render_usage(assigns) do
    module(assigns.name).render_usage(assigns)
  end

  attr(:name, :atom, required: true)
  attr(:block, :atom, required: true)
  attr(:props, :map, default: %{})
  attr(:id, :string, required: true)

  def render_block(assigns) do
    module(assigns.name).render_block(assigns)
  end

  @doc """
  Returns the registered `{name, module}` page modules.
  """
  def modules, do: @modules

  def controls(name), do: module(name).controls()
  def defaults(name), do: module(name).defaults()
  def usage(name), do: module(name).usage()
  def base_usage(name), do: Enum.filter(usage(name), &(&1.layer == :base))
  def styled_usage(name), do: Enum.filter(usage(name), &(&1.layer == :styled))
  def examples(name), do: module(name).examples()
  def styling(name), do: module(name).styling()
  def anatomy(name), do: module(name).anatomy()
  def accessibility(name), do: module(name).accessibility()
  def structure(name), do: module(name).structure()

  defp module(name), do: Map.get(@modules, name, Default)
end
