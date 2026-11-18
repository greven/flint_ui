defmodule FlintUI.Styled do
  @moduledoc """
  The registry of styled (generated) components.

  Each entry (see `FlintUI.Styled.Entry`) describes how a headless (base)
  FlintUI component is lifted into a styled wrapper: the base module, the generated
  target, the shared styling primitives it opts into, the extra attributes and
  slots it adds, the public CSS variables it exposes, and the theme tokens it
  consumes. Primitives (see `FlintUI.Styled.Primitive`) own reusable recipes such
  as the control shell and the field chrome.

  The generator (`mix flint.add`) and the docs both read from here, so the
  styled API has a single source of truth.
  """

  alias FlintUI.Styled.{Entry, Primitive, Var}

  @primitives [
    %Primitive{
      name: :control,
      css: "primitives/control.css",
      marker: "data-control",
      doc:
        "Shared shell, variants, colors, sizes, shape, depth, and interaction treatment for button-like controls.",
      props: [
        :variant,
        :dashed,
        :color,
        :size,
        :radius,
        :pill,
        :square,
        :wide,
        :justify,
        :depth,
        :inset,
        :active_variant,
        :active_color
      ],
      vars: [
        Var.new(
          name: "--fl-control-color",
          default: "var(--fl-color-inverted)",
          doc: "The fill, the outline border, and the source for tinted surfaces and focus."
        ),
        Var.new(
          name: "--fl-control-color-content",
          default: "var(--fl-color-text-inverted)",
          doc: "The label color on a solid fill."
        ),
        Var.new(
          name: "--fl-control-text",
          default: "var(--fl-control-color)",
          doc: "The label color on tinted, bordered, ghost, and link variants."
        ),
        Var.new(
          name: "--fl-control-soft",
          default: "color-mix(in oklab, var(--fl-control-color) 10%, var(--fl-color-surface))",
          doc: "The tinted surface behind soft and subtle variants."
        ),
        Var.new(
          name: "--fl-control-soft-border",
          default:
            "color-mix(in oklab, var(--fl-control-color) var(--fl-border-strength-soft), var(--fl-color-surface))",
          doc: "The border color for subtle and surface variants."
        ),
        Var.new(
          name: "--fl-control-active-color",
          default: "var(--fl-control-color)",
          doc: "The fill, border, and tint source while a stateful control is on."
        ),
        Var.new(
          name: "--fl-control-active-color-content",
          default: "var(--fl-control-color-content)",
          doc: "The label color on a solid fill while a stateful control is on."
        ),
        Var.new(
          name: "--fl-control-active-text",
          default: "var(--fl-control-text)",
          doc: "The label color on non-solid variants while a stateful control is on."
        ),
        Var.new(
          name: "--fl-control-active-soft",
          default: "var(--fl-control-soft)",
          doc: "The tinted surface while a stateful control is on."
        ),
        Var.new(
          name: "--fl-control-active-soft-border",
          default: "var(--fl-control-soft-border)",
          doc: "The subtle and surface border while a stateful control is on."
        )
      ]
    },
    %Primitive{
      name: :field,
      css: "primitives/field.css",
      marker: "data-field",
      doc: "Shared box chrome, sizing, states, and supporting typography for text-entry fields.",
      props: [:size, :radius],
      vars: [
        Var.new(
          name: "--fl-field-fill",
          default: "var(--fl-color-surface)",
          doc: "The field box background."
        ),
        Var.new(
          name: "--fl-field-border",
          default: "var(--fl-color-border)",
          doc: "The field box border color at rest."
        ),
        Var.new(
          name: "--fl-field-placeholder",
          default: "var(--fl-color-text-dimmed)",
          doc: "The placeholder text color."
        )
      ]
    }
  ]

  @modules [
    FlintUI.Styled.Accordion,
    FlintUI.Styled.AccordionItem,
    FlintUI.Styled.Alert,
    FlintUI.Styled.Avatar,
    FlintUI.Styled.AvatarGroup,
    FlintUI.Styled.Badge,
    FlintUI.Styled.Button,
    FlintUI.Styled.Card,
    FlintUI.Styled.Checkbox,
    FlintUI.Styled.CheckboxGroup,
    FlintUI.Styled.Collapsible,
    FlintUI.Styled.CopyButton,
    FlintUI.Styled.Dropdown,
    FlintUI.Styled.DropdownGroup,
    FlintUI.Styled.DropdownHeader,
    FlintUI.Styled.DropdownItem,
    FlintUI.Styled.DropdownSeparator,
    FlintUI.Styled.DropdownSub,
    FlintUI.Styled.Flag,
    FlintUI.Styled.Group,
    FlintUI.Styled.Icon,
    FlintUI.Styled.Indicator,
    FlintUI.Styled.Input,
    FlintUI.Styled.Kbd,
    FlintUI.Styled.KnownDate,
    FlintUI.Styled.Label,
    FlintUI.Styled.Loading,
    FlintUI.Styled.LoadingText,
    FlintUI.Styled.Popover,
    FlintUI.Styled.Progress,
    FlintUI.Styled.ProgressGroup,
    FlintUI.Styled.Radio,
    FlintUI.Styled.RadioGroup,
    FlintUI.Styled.Separator,
    FlintUI.Styled.Slider,
    FlintUI.Styled.Switch,
    FlintUI.Styled.SwitchGroup,
    FlintUI.Styled.Tabs,
    FlintUI.Styled.Textarea,
    FlintUI.Styled.Toggle,
    FlintUI.Styled.Tooltip
  ]

  @doc """
  Returns every registered styled entry.
  """
  def entries, do: Enum.map(@modules, & &1.entry())

  @doc """
  Returns every registered styling primitive.
  """
  def primitives, do: @primitives

  @doc """
  Returns the primitive with the given name, or `nil`.
  """
  def get_primitive(name) when is_atom(name) do
    Enum.find(primitives(), &(&1.name == name))
  end

  @doc """
  Returns the names of the registered primitives.
  """
  def primitive_names, do: Enum.map(primitives(), & &1.name)

  @doc """
  Returns the entry for a component name, or `nil`.
  """
  def get(name) when is_atom(name) do
    Enum.find(entries(), &(&1.name == name))
  end

  @doc """
  Returns the names of the registered styled components.
  """
  def names, do: Enum.map(entries(), & &1.name)

  @doc """
  Validates every primitive and entry and returns `:ok` or `{:error, reason}`.
  """
  def validate_all do
    primitives()
    |> Enum.reduce_while(:ok, fn primitive, :ok ->
      case validate_primitive(primitive) do
        :ok -> {:cont, :ok}
        error -> {:halt, error}
      end
    end)
    |> case do
      :ok ->
        Enum.reduce_while(entries(), :ok, fn entry, :ok ->
          case validate(entry) do
            :ok -> {:cont, :ok}
            error -> {:halt, error}
          end
        end)

      error ->
        error
    end
  end

  @doc """
  Validates a single primitive.
  """
  def validate_primitive(%Primitive{} = primitive) do
    cond do
      primitive.css in [nil, ""] ->
        {:error, {:missing_primitive_css, primitive.name}}

      not is_binary(primitive.marker) or
          not Regex.match?(~r/^data-[a-z0-9_-]+$/, primitive.marker) ->
        {:error, {:invalid_primitive_marker, primitive.name, primitive.marker}}

      true ->
        :ok
    end
  end

  @doc """
  Validates a single entry.
  """
  def validate(%Entry{} = entry) do
    expected = FlintUI.API.component_module(entry.name)

    cond do
      entry.base != expected ->
        {:error, {:base_mismatch, entry.name, entry.base, expected}}

      entry.target in [nil, ""] ->
        {:error, {:missing_target, entry.name}}

      entry.css in [nil, ""] and entry.primitives == [] ->
        {:error, {:missing_style, entry.name}}

      Entry.unknown_primitives(entry) != [] ->
        {:error, {:unknown_primitive, entry.name, Entry.unknown_primitives(entry)}}

      Entry.unowned_primitive_props(entry) != [] ->
        {:error, {:unowned_primitive_prop, entry.name, Entry.unowned_primitive_props(entry)}}

      custom_color_without_vars?(entry) ->
        {:error, {:missing_color_vars, entry.name}}

      active_color_without_vars?(entry) ->
        {:error, {:missing_active_color_vars, entry.name}}

      invalid_relations(entry) != [] ->
        {:error, {:unknown_relation, entry.name, invalid_relations(entry)}}

      true ->
        :ok
    end
  end

  defp invalid_relations(entry) do
    components = FlintUI.components()

    (Entry.related(entry) ++ Entry.dependencies(entry))
    |> Enum.reject(&(&1 in components and &1 != entry.name))
    |> Enum.uniq()
  end

  defp custom_color_without_vars?(entry) do
    case Entry.prop(entry, :color) do
      %{allow_custom: true} -> entry.color_vars == []
      _ -> false
    end
  end

  # An active color is only actionable when the wrapper knows where to write a
  # raw value and what to do with the "follow the base color" sentinel.
  defp active_color_without_vars?(entry) do
    case entry.active_color do
      %{prop: prop, vars: [_ | _]} ->
        case Entry.prop(entry, prop) do
          %{allow_custom: true} -> false
          _ -> true
        end

      nil ->
        false

      _ ->
        true
    end
  end
end
