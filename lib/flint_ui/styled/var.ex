defmodule FlintUI.Styled.Var do
  @moduledoc """
  Describes a public CSS custom property exposed by a styled component.

  These are the supported per-instance inputs a consumer can override through
  `class` or `style`. Internal `--_fl-*` values are implementation details and
  are intentionally not listed here.
  """

  @type t :: %__MODULE__{
          name: String.t(),
          default: String.t() | nil,
          doc: String.t() | nil
        }

  @enforce_keys [:name]
  defstruct [:name, :default, :doc]

  @doc """
  Builds a variable description.
  """
  def new(fields), do: struct!(__MODULE__, fields)
end
