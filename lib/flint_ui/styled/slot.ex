defmodule FlintUI.Styled.Slot do
  @moduledoc """
  Describes an extra slot added by a generated styled component.

  Slots are layered on top of the headless base component's own slots. The
  generator merges the base's declared slots with an entry's extra slots into
  the wrapper's `slot/2` declarations, so each is declared once at its source.
  """

  @type t :: %__MODULE__{
          name: atom(),
          required: boolean(),
          doc: String.t() | nil
        }

  @enforce_keys [:name]
  defstruct [:name, required: false, doc: nil]

  @doc """
  Builds a slot.
  """
  def new(fields), do: struct!(__MODULE__, fields)
end
