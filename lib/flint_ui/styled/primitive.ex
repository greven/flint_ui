defmodule FlintUI.Styled.Primitive do
  @moduledoc """
  Describes a shared styling primitive used by one or more styled components.

  A primitive is a CSS part that owns a reusable visual recipe, such as the
  control shell and its variants or the text-field chrome. Components opt into a
  primitive by carrying its `marker` attribute on the styled root. The primitive
  stylesheet is assembled once into the theme, before the component parts.

  `:vars` names the primitive's public CSS inputs. The docs merge them with the
  component's own variables, and the theme contract checks them against the
  primitive stylesheet rather than each component's part.
  """

  alias FlintUI.Styled.Var

  @type t :: %__MODULE__{
          name: atom(),
          css: String.t(),
          marker: String.t(),
          doc: String.t(),
          vars: [Var.t()],
          props: [atom()]
        }

  @enforce_keys [:name, :css, :marker]
  defstruct [:name, :css, :marker, :doc, vars: [], props: []]
end
