defmodule FlintUI.Styled do
  @moduledoc """
  The registry of styled (generated) components.

  Each entry (see `FlintUI.Styled.Entry`) describes how a headless (base)
  FlintUI component is lifted into a styled wrapper: the base module, the generated
  target, the extra attributes and slots it adds, and the theme tokens it consumes.

  The generator (`mix flint.add`) and the docs both read from here, so the
  styled API has a single source of truth.
  """

  alias FlintUI.Styled.Entry

  @modules [
    FlintUI.Styled.Button,
    FlintUI.Styled.Card,
    FlintUI.Styled.Collapsible,
    FlintUI.Styled.Group,
    FlintUI.Styled.Icon,
    FlintUI.Styled.Loading,
    FlintUI.Styled.Toggle
  ]

  @doc """
  Returns every registered styled entry.
  """
  def entries, do: Enum.map(@modules, & &1.entry())

  @doc """
  Returns the entry for a component name, or `nil`.
  """
  def get(name) when is_atom(name) do
    Enum.find(entries(), &(&1.name == name))
  end

  @doc """
  Returns the names of the registered styled components.
  """
  def names, do: Enum.map(entries(), & &1.name)

  @doc """
  Validates every entry and returns `:ok` or `{:error, reason}`.
  """
  def validate_all do
    Enum.reduce_while(entries(), :ok, fn entry, :ok ->
      case validate(entry) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
  end

  @doc """
  Validates a single entry.
  """
  def validate(%Entry{} = entry) do
    expected = FlintUI.API.component_module(entry.name)

    cond do
      entry.base != expected ->
        {:error, {:base_mismatch, entry.name, entry.base, expected}}

      entry.target in [nil, ""] ->
        {:error, {:missing_target, entry.name}}

      true ->
        :ok
    end
  end
end
