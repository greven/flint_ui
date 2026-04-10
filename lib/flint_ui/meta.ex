defmodule FlintUI.Meta do
  @moduledoc """
  FlintUI component metadata.
  """

  @type type :: :data | :overlay | :input | :button | :feedback | :misc

  @type t :: %__MODULE__{
          name: String.t(),
          type: type(),
          since: String.t()
        }

  @enforce_keys [:name, :type, :since]
  defstruct [:name, :type, :since]
end
