defmodule FlintUI.Styled.Prop do
  @moduledoc """
  Describes an extra, presentational prop added by a generated styled component.

  Props are layered on top of the headless base component's own attributes; a
  prop never changes behavior, only how a variant resolves to classes.
  """

  @type t :: %__MODULE__{
          name: atom(),
          values: [atom()],
          default: atom(),
          doc: String.t() | nil
        }

  @enforce_keys [:name, :values, :default]
  defstruct [:name, :values, :default, :doc]

  @doc """
  Builds a prop, raising when `:default` is not one of `:values`.
  """
  def new(fields) do
    prop = struct!(__MODULE__, fields)

    unless prop.default in prop.values do
      raise ArgumentError,
            "prop #{inspect(prop.name)} default #{inspect(prop.default)} is not one of #{inspect(prop.values)}"
    end

    prop
  end

  @doc """
  The data attribute a generated wrapper sets for this prop.

      iex> FlintUI.Styled.Prop.attribute(%FlintUI.Styled.Prop{name: :variant, values: [:a], default: :a})
      "data-variant"
  """
  def attribute(%__MODULE__{name: name}) do
    "data-" <> (name |> to_string() |> String.replace("_", "-"))
  end

  @doc """
  Whether the prop is an on/off boolean (`values: [true, false]`).

  Boolean props are declared as `:boolean` attributes and set their data hook to
  the string `"true"`/`"false"` so both states have a selector.

      iex> FlintUI.Styled.Prop.boolean?(%FlintUI.Styled.Prop{name: :depth, values: [true, false], default: true})
      true
  """
  def boolean?(%__MODULE__{values: values}), do: values == [true, false]
end
