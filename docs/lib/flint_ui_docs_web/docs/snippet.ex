defmodule FlintUIDocsWeb.Docs.Snippet do
  @moduledoc """
  Small helpers for rendering a component's HEEx source from playground props.

  Example modules use these in their `main_code/1` helpers so the generated
  snippet in the code block stays in step with the live props without hand-built
  string concatenation. Attributes equal to their default (or blank) are
  omitted, so the snippet only shows what the current props actually set.
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

  @inline_width 80

  @doc """
  Renders a component with attributes and an inner body.

  A short, single-line body stays inline (`<.button>Button</.button>`). A body
  with multiple lines, or a tag that would not fit on one line, is indented on
  its own lines.
  """
  def tag(name, attrs, body) do
    body = String.trim(body)
    attrs = Enum.reject(attrs, &is_nil/1)

    if String.contains?(body, "\n") do
      block_tag(name, attrs, body)
    else
      inline = inline_tag(name, attrs, body)

      if String.length(inline) <= @inline_width do
        inline
      else
        block_tag(name, attrs, body)
      end
    end
  end

  @doc """
  Renders a self-closing component with attributes.

  Short tags stay on one line; longer ones break the attributes out.
  """
  def component(name, attrs) do
    attrs = Enum.reject(attrs, &is_nil/1)

    inline =
      case attrs do
        [] -> "<#{name} />"
        attrs -> "<#{name} #{Enum.join(attrs, " ")} />"
      end

    if String.length(inline) <= @inline_width do
      inline
    else
      "<#{name}\n#{lines(attrs)}\n/>"
    end
  end

  defp inline_tag(name, [], body), do: "<#{name}>#{body}</#{name}>"

  defp inline_tag(name, attrs, body),
    do: "<#{name} #{Enum.join(attrs, " ")}>#{body}</#{name}>"

  defp block_tag(name, attrs, body) do
    body =
      body
      |> String.split("\n")
      |> Enum.map_join("\n", &("  " <> &1))

    case lines(attrs) do
      "" -> "<#{name}>\n#{body}\n</#{name}>"
      lines -> "<#{name}\n#{lines}\n>\n#{body}\n</#{name}>"
    end
  end

  defp lines(attrs) do
    attrs
    |> Enum.map_join("\n", &("  " <> &1))
  end
end
