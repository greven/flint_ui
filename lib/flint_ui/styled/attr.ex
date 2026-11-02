defmodule FlintUI.Styled.Attr do
  @moduledoc """
  Describes a non-presentational attribute added by a generated styled component.

  Props map to `data-*` hooks the theme targets. Content attributes are ordinary
  attributes the wrapper reads directly while rendering content, such as a text
  fallback or an icon name. They are declared on the wrapper for validation and
  docs, but are not forwarded to the headless base.
  """

  @type t :: %__MODULE__{
          name: atom(),
          type: atom(),
          default: term(),
          doc: String.t() | nil
        }

  @enforce_keys [:name, :type]
  defstruct [:name, :type, :doc, default: nil]

  @doc """
  Builds a content attribute.
  """
  def new(fields), do: struct!(__MODULE__, fields)
end
