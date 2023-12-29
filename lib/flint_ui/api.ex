defmodule FlintUI.API do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import FlintUI.API.{
        DOM
      }
    end
  end

  @doc """
  Tries to convert an user input value value to an integer value
  and returns a default value if the conversion fails.
  """
  def as_integer(value, default \\ nil)
  def as_integer(value, _default) when is_integer(value), do: value
  def as_integer(value, _default) when is_float(value), do: trunc(value)

  def as_integer(value, default) when is_binary(value) do
    try do
      String.to_integer(value)
    rescue
      ArgumentError -> default
    end
  end

  def as_integer(_value, default), do: default

  @doc """
  Tries to convert an user input value to a boolean value
  and returns a default value if the conversion fails.
  """
  def as_boolean(value, default \\ false)
  def as_boolean(value, _default) when is_boolean(value), do: value

  def as_boolean("true", _default), do: true
  def as_boolean("1", _default), do: true
  def as_boolean("false", _default), do: false
  def as_boolean("0", _default), do: false

  def as_boolean(value, default) when is_binary(value) do
    case Integer.parse(value) do
      {int, _rest} -> as_boolean(int, default)
      _ -> default
    end
  end

  def as_boolean(value, _default) when is_number(value) do
    if value > 0, do: true, else: false
  end

  def as_boolean(_value, default), do: default
end
