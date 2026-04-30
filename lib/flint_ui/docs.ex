defmodule FlintUI.Docs do
  @moduledoc """
  Provides macros to fetch the documentation for a given component.
  """

  import FlintUI.API, only: [component_module: 1]

  @doc """
  Fetches the documentation for a component's attributes (`:attrs`).
  """
  def attrs(component) when is_atom(component) do
    component_module(component).__components__()[:render][:attrs]
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
end
