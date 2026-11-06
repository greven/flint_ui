defmodule FlintUI.Styled.Prop do
  @moduledoc """
  Describes an extra, presentational prop added by a generated styled component.

  Props are layered on top of the headless base component's own attributes; a
  prop never changes behavior, only how a variant resolves to classes.

  A prop can opt into a free-form value with `allow_custom: true`. The generated
  wrapper then omits `values:` from its `attr/3` declaration, so the prop accepts
  any string. `values` still lists the documented presets and keeps driving the
  theme contract; the wrapper is responsible for validating the extra values
  (see `FlintUI.Styled.Color` for `:color`).

  A prop can also accept a space-separated combination of its values with
  `multi: true` (see `multi?/1`). Its default is `false` to mean "none selected".
  """

  @type t :: %__MODULE__{
          name: atom(),
          values: [term()],
          default: term(),
          doc: String.t() | nil,
          allow_custom: boolean(),
          multi: boolean()
        }

  @enforce_keys [:name, :values, :default]
  defstruct [:name, :values, :default, :doc, allow_custom: false, multi: false]

  @doc """
  Builds a prop, raising when `:default` is not one of `:values`.

  A multi prop (`multi: true`) may default to `false` to mean "none selected"
  even though `false` is not one of the documented values.
  """
  def new(fields) do
    prop = struct!(__MODULE__, fields)

    unless prop.default in prop.values or (prop.multi and prop.default == false) do
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

  Boolean props are declared as `:boolean` attributes. Their data hook is
  present when the prop is `true` and absent when it is `false`, so read it with
  `[data-hook]` or `:not([data-hook])` rather than a string value.

      iex> FlintUI.Styled.Prop.boolean?(%FlintUI.Styled.Prop{name: :depth, values: [true, false], default: true})
      true
  """
  def boolean?(%__MODULE__{values: values}), do: values == [true, false]

  @doc """
  Whether the prop accepts a space-separated combination of its values.

  A multi prop is declared as `:any` so a bare attribute (`inset`), a single
  value (`inset="top"`), and a combination (`inset="top bottom"`) all work.
  `false` (or `nil`) means no value is selected. Boolean props are not multi.

      iex> FlintUI.Styled.Prop.multi?(%FlintUI.Styled.Prop{name: :inset, values: ["top"], default: false, multi: true})
      true
  """
  def multi?(%__MODULE__{multi: multi}), do: multi
end
