defmodule FlintUIDocsWeb.Docs do
  @moduledoc """
  Facade over the per-component docs page modules.

  Each component has a module under `FlintUIDocsWeb.Docs`
  (e.g. `FlintUIDocsWeb.Docs.Button`) that implements
  `FlintUIDocsWeb.Docs.Page`.

  Register it in `@modules` below; anything not registered falls back to
  `FlintUIDocsWeb.Docs.Default`.

  Components declare (`Docs.Page` for the full contract):

    * `controls/0` - interactive properties shown in the Docs playground
    * `usage/0` - usage sections, one per attribute, tagged `:base` or `:styled`
    * `examples/0` - example sections rendered in the Examples block
    * `anatomy/0` - structured element tree for the Base tab
    * `styling/0` - plain-CSS styling snippets for the base
    * `css/0` - the styled layer's CSS contract
    * `accessibility/0` - accessibility prose
    * `render_playground/1` - the live playground render for the Styled tab
    * `render_usage/1` - the render for a Styled usage subsection preview
    * `render_block/1` - the render for a Styled example preview
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Docs.{
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
  attr(:layer, :atom, default: :styled)
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
  def base_examples(name), do: Enum.filter(examples(name), &(&1[:layer] == :base))
  def styled_examples(name), do: Enum.reject(examples(name), &(&1[:layer] == :base))
  def styling(name), do: module(name).styling()
  def css(name), do: module(name).css()
  def anatomy(name), do: module(name).anatomy()
  def accessibility(name), do: module(name).accessibility()
  def structure(name), do: module(name).structure()

  defp module(name), do: Map.get(@modules, name, Default)
end
