defmodule FlintUI.API.DOM do
  @moduledoc false

  @doc """
  Generates a unique id for a DOM element.
  """
  def use_id(prefix \\ "fl") do
    "#{prefix}-" <> uuid_to_id() <> "-#{System.unique_integer([:positive])}"
  end

  # ID string using the first 16 chars of a base65 UUIDv4 string
  defp uuid_to_id do
    Uniq.UUID.uuid4()
    |> Base.encode64()
    |> String.slice(0..15)
  end
end
