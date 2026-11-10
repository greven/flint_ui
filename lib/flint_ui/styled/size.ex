defmodule FlintUI.Styled.Size do
  @moduledoc false

  @scale ~w(xs sm md lg xl)

  @doc """
  Returns the scale value for one of `xs`..`xl`, or `nil` for a custom size.
  """
  def scale(size) when size in @scale, do: size
  def scale(_size), do: nil

  @doc """
  Returns a CSS declaration for a numeric pixel size, or `nil`.

  Numbers and numeric strings are divided by 16; `40` and `"40"` both become
  `2.5rem`. Other strings are left to `style` or `class`.
  """
  def style(size, property) when is_number(size), do: declaration(property, size)

  def style(size, property) when is_binary(size) do
    case Float.parse(size) do
      {number, ""} -> declaration(property, number)
      _ -> nil
    end
  end

  def style(_size, _property), do: nil

  @doc """
  Adds a generated declaration to a global attribute map.

  The caller's `style` is kept after the generated declaration, so an explicit
  style still wins over the size input.
  """
  def put_style(rest, nil), do: rest

  def put_style(rest, declaration) do
    case Map.get(rest, :style) do
      nil ->
        Map.put(rest, :style, declaration)

      "" ->
        Map.put(rest, :style, declaration)

      user_style when is_list(user_style) ->
        Map.put(rest, :style, Enum.join([declaration | user_style], "; "))

      user_style ->
        Map.put(rest, :style, declaration <> "; " <> user_style)
    end
  end

  defp declaration(property, number) do
    value = number / 16

    value =
      if value == trunc(value) do
        Integer.to_string(trunc(value))
      else
        Float.to_string(value)
      end

    "#{property}: #{value}rem"
  end
end
