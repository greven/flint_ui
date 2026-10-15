defmodule FlintUIDocsWeb.Examples.Snippet do
  @moduledoc """
  Small helpers for rendering a component's HEEx source from playground props.

  Example modules use these in `render_code/1` so the generated snippet in the
  Code tab stays in step with the live props without hand-built string
  concatenation. Attributes equal to their default (or blank) are omitted, so
  the snippet only shows what the current props actually set.
  """

  @doc """
  A boolean attribute: emits `name` when `true`, otherwise `nil`.
  """
  def flag(name, true), do: name
  def flag(_name, _value), do: nil

  @doc """
  An attribute line, omitted when the value is blank or matches `default`.

  Strings are quoted; other values are emitted as Elixir literals.
  """
  def attr(name, value, default \\ nil)

  def attr(_name, value, default) when value in [nil, ""] or value == default, do: nil
  def attr(name, value, _default) when is_binary(value), do: ~s(#{name}="#{value}")
  def attr(name, value, _default), do: ~s(#{name}={#{inspect(value)}})

  @doc """
  Renders a component with attributes and an inner body.
  """
  def tag(name, attrs, body) do
    body =
      body
      |> String.split("\n")
      |> Enum.map_join("\n", &("  " <> &1))

    case lines(attrs) do
      "" -> "<#{name}>\n#{body}\n</#{name}>"
      lines -> "<#{name}\n#{lines}\n>\n#{body}\n</#{name}>"
    end
  end

  @doc """
  Renders a self-closing component with attributes.
  """
  def component(name, attrs) do
    case lines(attrs) do
      "" -> "<#{name} />"
      lines -> "<#{name}\n#{lines}\n/>"
    end
  end

  defp lines(attrs) do
    attrs
    |> Enum.reject(&is_nil/1)
    |> Enum.map_join("\n", &("  " <> &1))
  end
end
