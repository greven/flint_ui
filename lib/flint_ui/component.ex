defmodule FlintUI.Component do
  defmacro __using__(_) do
    quote do
      use Phoenix.Component
      use FlintUI.API

      alias Phoenix.LiveView.JS
    end
  end

  @doc """
  Converts a module name to space separated atom.
  Gets the last part of the module name, converts it to
  snake case and then to atom.

  ## Example:

        iex> FlintUI.Component.module_to_component_name(FlintUI.Badge)
        :badge
        iex> FlintUI.Component.module_to_component_name(FlintUI.BadgeButton)
        :badge_button
  """
  def module_to_component_name(module_name) do
    module_name
    |> Module.split()
    |> List.last()
    |> String.replace(~r/([A-Z])/, "_\\1")
    |> String.replace_prefix("_", "")
    |> String.downcase()
    |> String.to_atom()
  end

  @doc """
  Converts a string to a component name atom.

  ## Example:

        iex> FlintUI.Component.string_to_component_name("Badge")
        :badge
        iex> FlintUI.Component.string_to_component_name("Badge Button")
        :badge_button
  """
  def string_to_component_name(string) do
    string
    |> String.replace(" ", "_")
    |> String.downcase()
    |> String.to_atom()
  end

  @doc """
  Converts a component name atom to a string.

  ## Example:

        iex> FlintUI.Component.humanize_component_name(:badge)
        "Badge"
        iex> FlintUI.Component.humanize_component_name(:badge_button)
        "Badge Button"
  """
  def humanize_component_name(component_name) when is_atom(component_name) do
    component_name
    |> Atom.to_string()
    |> String.replace("_", " ")
  end
end
