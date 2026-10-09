defmodule FlintUI.Docs do
  @moduledoc """
  Provides macros to fetch the documentation for a given component.
  """

  import FlintUI.API, only: [component_module: 1]

  @doc """
  Fetches the metadata (`FlintUI.Meta`) for a component.
  """
  def meta(component) when is_atom(component) do
    component_module(component).meta()
  end

  @doc """
  Returns all registered components grouped by their `FlintUI.Meta` type.

  Groups are ordered by `FlintUI.Meta.types/0`, types without components are
  omitted, and components within each group are sorted by name. Returns a list
  of `{type, [component]}` tuples.
  """
  def grouped_components do
    types = FlintUI.Meta.types()

    FlintUI.components()
    |> Enum.group_by(&meta(&1).type)
    |> Enum.sort_by(fn {type, _} -> Enum.find_index(types, &(&1 == type)) || length(types) end)
    |> Enum.map(fn {type, components} -> {type, Enum.sort(components)} end)
  end

  @doc """
  Returns a short, single-line description for a component, taken from the first
  non-empty line of its moduledoc.
  """
  def description(component) when is_atom(component) do
    case Code.fetch_docs(component_module(component)) do
      {:docs_v1, _, _, _, %{"en" => doc}, _, _} ->
        doc
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> Enum.find(&(&1 != ""))

      _ ->
        nil
    end
  end

  @doc """
  Fetches the documentation for a component's attributes (`:attrs`).
  """
  def attrs(component) when is_atom(component) do
    component_module(component).__components__()[:render][:attrs]
    |> Enum.reject(&(&1.name == :flint_parts))
    |> Enum.sort_by(&{not &1.required, &1.name})
  end

  @doc """
  Fetches the documentation for a component's slots (`:slots`).
  """
  def slots(component) when is_atom(component) do
    component_module(component).__components__()[:render][:slots]
    |> Enum.sort_by(&{not &1.required, &1.name})
  end

  @doc """
  Fetches the documentation for a component's part attributes (`:parts_attrs`).
  Returns a map of part names to lists of `FlintUI.Meta.PartAttr` structs.
  """
  def parts_attrs(component) when is_atom(component) do
    component_module = component_module(component)

    if function_exported?(component_module, :parts_attrs, 0) do
      component_module.parts_attrs()
    else
      %{}
    end
  end

  @doc """
  Fetches the CSS custom properties for a component (`:css_vars`).
  Returns a list of `FlintUI.Meta.CSSVar` structs.
  """
  def css_vars(component) when is_atom(component) do
    component_module = component_module(component)

    if function_exported?(component_module, :css_vars, 0) do
      component_module.css_vars()
    else
      []
    end
  end

  @doc """
  """
  def events(component) when is_atom(component) do
    component_module = component_module(component)

    if function_exported?(component_module, :events, 0) do
      component_module.events()
    else
      []
    end
  end

  @doc """
  Fetches the keyboard interactions for a component (`:keyboard`).
  Returns a list of `FlintUI.Meta.Keyboard` structs.
  """
  def keyboard(component) when is_atom(component) do
    component_module = component_module(component)

    if function_exported?(component_module, :keyboard, 0) do
      component_module.keyboard()
    else
      []
    end
  end
end
