defmodule FlintUI.Palette do
  @moduledoc """
  Behaviour for a named color palette that can be imported into theme tokens.

  A palette exposes a list of color names and, for each color, a shade map. The
  built-in `FlintUI.Palette.Tailwind` is the first implementation; other sources
  (OpenColors, Radix, …) can implement the same behaviour and feed
  `FlintUI.Palette.CSS.render/2`.

  FlintUI ships no raw palette variables in the default theme. Importing one
  through `mix flint.palette` emits `--fl-palette-{color}-{shade}` variables plus
  the semantic `--fl-color-{role}-{shade}` scales and role aliases.
  """

  @shade_keys [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]

  @doc "The ordered shade keys a palette is expected to provide."
  def shade_keys, do: @shade_keys

  @doc false
  def build(values) when is_list(values) do
    @shade_keys |> Enum.zip(values) |> Map.new()
  end

  @callback name() :: atom()
  @callback colors() :: [atom()]
  @callback shades(color :: atom()) :: %{optional(atom()) => String.t()}
end
