defmodule FlintUI.Styled.Attr do
  @moduledoc """
  Describes a non-presentational attribute added by a generated styled component.

  Props map to `data-*` hooks the theme targets. Content attributes are ordinary
  attributes the wrapper reads directly while rendering, such as a text fallback,
  an icon name, or a CSS-variable-backed input. They are declared on the wrapper
  for validation and docs, but are not forwarded to the headless base.

  `fills_content` marks an attribute that can replace the default slot, such as
  `text` or `icon`. The wrapper relaxes a required `inner_block` only when one of
  these exists; an input such as `offset` leaves the slot required.
  """

  @type t :: %__MODULE__{
          name: atom(),
          type: atom(),
          default: term(),
          doc: String.t() | nil,
          fills_content: boolean()
        }

  @enforce_keys [:name, :type]
  defstruct [:name, :type, :doc, default: nil, fills_content: false]

  @doc """
  Builds a content attribute.
  """
  def new(fields), do: struct!(__MODULE__, fields)
end
