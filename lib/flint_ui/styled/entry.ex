defmodule FlintUI.Styled.Entry do
  @moduledoc """
  Describes the styled surface generated for a headless FlintUI component.

  An entry ties a component's headless base module (`:base`) to the styled
  wrapper the generator produces (`:target`), the extra presentational attributes
  it adds (`:props`), the extra slots it adds (`:slots`), the public CSS variables
  it exposes (`:vars`), the theme token namespaces it consumes (`:tokens`), and
  its theme stylesheet part (`:css`, relative to `priv/templates`). The docs and
  the generator both read from here.

  `:color_vars` maps the semantic outputs of a raw `color` value onto the
  component's public CSS variables: `:fill` (the exact color), `:on_fill` (the
  label on a solid fill), and `:on_text` (the color as text on the page and on
  tinted surfaces). A value may be the atom `:color` for components that use the
  `color` property directly instead of a custom variable. Entries without a
  customizable `color` prop leave this empty.

  The generator merges `:slots` with the base component's own slots when it
  renders the wrapper's `slot/2` declarations.
  """

  @type t :: %__MODULE__{
          name: atom(),
          base: module(),
          target: String.t(),
          install: String.t() | nil,
          css: String.t() | nil,
          tokens: [atom()],
          props: [FlintUI.Styled.Prop.t()],
          slots: [FlintUI.Styled.Slot.t()],
          vars: [FlintUI.Styled.Var.t()],
          color_vars: keyword()
        }

  @enforce_keys [:name, :base, :target]
  defstruct name: nil,
            base: nil,
            target: nil,
            install: nil,
            css: nil,
            tokens: [],
            props: [],
            slots: [],
            vars: [],
            color_vars: []

  @doc """
  Returns the extra attribute with the given name, or `nil`.
  """
  def prop(%__MODULE__{props: props}, name), do: Enum.find(props, &(&1.name == name))

  @doc """
  Returns a map of attribute name to the data attribute a generated wrapper sets,
  e.g. `%{variant: "data-variant", size: "data-size"}`.
  """
  def hooks(%__MODULE__{props: props}) do
    Map.new(props, fn prop -> {prop.name, FlintUI.Styled.Prop.attribute(prop)} end)
  end
end
