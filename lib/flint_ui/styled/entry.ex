defmodule FlintUI.Styled.Entry do
  @moduledoc """
  Describes the styled surface generated for a headless FlintUI component.

  An entry ties a component's headless base module (`:base`) to the styled
  wrapper the generator produces (`:target`), the extra presentational attributes
  it adds (`:props`), the extra slots it adds (`:slots`), the public CSS variables
  it exposes (`:vars`), the theme token namespaces it consumes (`:tokens`), and
  its theme stylesheet part (`:css`, relative to `priv/templates`). The docs and
  the generator both read from here.

  `:content_attrs` are ordinary attributes the wrapper reads while rendering,
  such as a text fallback, an icon name, or a CSS-variable-backed input. Unlike
  `:props`, they do not map to a `data-*` hook and are not forwarded to the base.
  Only attributes with `fills_content: true` relax a required `inner_block`.

  `:color_vars` maps the semantic outputs of a raw `color` value onto the
  component's public CSS variables: `:fill` (the exact color), `:on_fill` (the
  label on a solid fill), and `:on_text` (the color as text on the page and on
  tinted surfaces). A value may be the atom `:color` for components that use the
  `color` property directly instead of a custom variable. Entries without a
  customizable `color` prop leave this empty.

  `:active_color` declares a second, free-form color prop for components whose
  pressed state can carry a different color, such as the toggle's
  `active_color`. It is a map with the prop name (`:prop`), the variables a raw
  value writes (`:vars`, same shape as `:color_vars`), and the sentinel value
  that means "follow the base color" (`:inherit`, optional). The wrapper
  resolves the prop into the `data-active-color` hook, or the inset values plus
  the variables for a raw value, and omits both for the sentinel. The theme then
  derives the pressed color's variables from the base ones when the hook is
  absent.

  `:related` names components that are closely connected to this one, such as
  `:avatar` and `:avatar_group`. It is not a dependency: both components stand
  on their own and merely link to each other in the docs. A relation may also be
  written as `{name, nav: true}` when the related component belongs under this
  one in the docs sidebar. Only a component that makes no sense apart from its
  companion should opt into that grouping; a broadly reusable component such as
  Group stays at the top level on a Button page.

  `:dependencies` names components this one is built on, such as Indicator using
  Badge. Dependencies are one-way and do not imply a related link.

  The generator merges `:slots` with the base component's own slots when it
  renders the wrapper's `slot/2` declarations.
  """

  @type relation :: atom() | {atom(), keyword()}

  @type active_color :: %{
          prop: atom(),
          vars: keyword(),
          inherit: term()
        }

  @type t :: %__MODULE__{
          name: atom(),
          base: module(),
          target: String.t(),
          install: String.t() | nil,
          css: String.t() | nil,
          tokens: [atom()],
          props: [FlintUI.Styled.Prop.t()],
          content_attrs: [FlintUI.Styled.Attr.t()],
          slots: [FlintUI.Styled.Slot.t()],
          vars: [FlintUI.Styled.Var.t()],
          color_vars: keyword(),
          active_color: active_color() | nil,
          related: [relation()],
          dependencies: [atom()]
        }

  @enforce_keys [:name, :base, :target]
  defstruct name: nil,
            base: nil,
            target: nil,
            install: nil,
            css: nil,
            tokens: [],
            props: [],
            content_attrs: [],
            slots: [],
            vars: [],
            color_vars: [],
            active_color: nil,
            related: [],
            dependencies: []

  @doc """
  Returns the extra attribute with the given name, or `nil`.
  """
  def prop(%__MODULE__{props: props}, name), do: Enum.find(props, &(&1.name == name))

  @doc """
  Returns the names of the components this component relates to.
  """
  def related(%__MODULE__{related: related}), do: Enum.map(related, &relation_name/1)

  @doc """
  Returns the related component names nested under this component in the docs
  sidebar.
  """
  def nav_related(%__MODULE__{related: related}) do
    for {name, opts} <- related, Keyword.get(opts, :nav, false), do: name
  end

  @doc """
  Returns the names of the components this component is built on.
  """
  def dependencies(%__MODULE__{dependencies: dependencies}), do: dependencies

  defp relation_name({name, _opts}), do: name
  defp relation_name(name), do: name

  @doc """
  Returns a map of attribute name to the data attribute a generated wrapper sets,
  e.g. `%{variant: "data-variant", size: "data-size"}`.
  """
  def hooks(%__MODULE__{props: props}) do
    Map.new(props, fn prop -> {prop.name, FlintUI.Styled.Prop.attribute(prop)} end)
  end
end
