defmodule FlintUI.Palette do
  @moduledoc """
  The registry and behaviour for color palettes.

  A palette is the lowest color layer: it answers "what is pink?" without
  knowing what pink means. Every palette defines the same eighteen hues, each
  with the `50..950` shades, so a component can use `color="pink"` against any
  palette. Themes and semantic roles sit above this layer: they decide which
  hue a role points at, never what a hue looks like.

  The eighteen hues are portable across palettes. The default palette mirrors
  the Tailwind CSS v4 colors, with `gray` sourced from Tailwind's neutral ramp
  so the chrome starts achromatic; override the `--fl-color-gray-*`
  variables to use a warmer or cooler neutral.

  Applications can add a hue name with `config :flint_ui, extra_hues: [:brand]`.
  The app supplies that hue's palette block and tone hooks; `FlintUI.Styled.Color`
  accepts the configured names.

  A palette source implements this behaviour and feeds
  `FlintUI.Palette.CSS.render_palette/2`. The rendered CSS is shipped as a
  plain stylesheet under `priv/templates/palettes/`. Selecting a palette is a
  document-level choice (`data-palette` on `<html>`), like `data-theme`.
  """

  @shade_keys [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]

  @hues [
    :red,
    :orange,
    :amber,
    :yellow,
    :lime,
    :green,
    :emerald,
    :teal,
    :cyan,
    :sky,
    :blue,
    :indigo,
    :violet,
    :purple,
    :fuchsia,
    :pink,
    :rose,
    :gray
  ]

  @reserved [
    :primary,
    :secondary,
    :neutral,
    :info,
    :success,
    :warning,
    :error,
    :inherit,
    :dark,
    :light,
    :text,
    :surface,
    :background,
    :border,
    :ring,
    :inverted,
    :overlay,
    :shadow,
    :focus
  ]

  @palettes [
    %{name: :tailwind, css: "palettes/tailwind.css", module: __MODULE__.Tailwind, default: true},
    %{name: :natural, css: "palettes/natural.css", module: __MODULE__.Natural},
    %{name: :bright, css: "palettes/bright.css", module: __MODULE__.Bright},
    %{name: :mono, css: "palettes/mono.css", module: __MODULE__.Mono}
  ]

  @doc "The ordered shade keys every palette provides."
  def shade_keys, do: @shade_keys

  @doc "The ordered hue names every palette provides."
  def hues, do: @hues

  @doc "The hue names as strings, for prop validation and docs."
  def hue_names, do: Enum.map(@hues, &Atom.to_string/1)

  @doc """
  Returns the app-configured extra hue names.

  Set `config :flint_ui, extra_hues: [:brand]` to make `color="brand"` a valid
  hook. The app supplies the palette block and tone hooks. Reserved role and
  chrome names are ignored so an extra hue cannot shadow a semantic token.
  """
  def extra_hues do
    :flint_ui
    |> Application.get_env(:extra_hues, [])
    |> List.wrap()
    |> Enum.map(&normalize_hue/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.reject(&(&1 in @reserved))
    |> Enum.uniq()
    |> Kernel.--(@hues)
  end

  @doc "The app-configured extra hue names as strings."
  def extra_hue_names, do: Enum.map(extra_hues(), &Atom.to_string/1)

  @doc """
  True when a hue name would shadow a semantic role or a chrome token.

  Reserved names are rejected by `extra_hues/0` and by `mix flint.palette`.
  """
  def reserved_hue_name?(name), do: normalize_hue(name) in @reserved

  @doc "Every accepted hue name: the canonical palette plus app extras."
  def known_hue_names, do: hue_names() ++ extra_hue_names()

  @doc """
  Returns every shipped palette.

  Each entry has `:name`, `:css` (relative to `priv/templates`), `:module` (the
  palette source), and `:default` (true for the `:root` baseline).
  """
  def palettes, do: @palettes

  @doc "Returns the names of the shipped palettes."
  def names, do: Enum.map(@palettes, & &1.name)

  @doc "Returns the default palette entry."
  def default, do: Enum.find(@palettes, & &1.default)

  @doc "Returns the palette entry with the given name, or `nil`."
  def get(name) when is_atom(name), do: Enum.find(@palettes, &(&1.name == name))
  def get(_name), do: nil

  @doc """
  Returns the selectable palettes, default first.

  `:default` has no attribute: it is the `:root` palette, so selecting it means
  clearing `data-palette` on `<html>`.
  """
  def presets, do: [:default | names()]

  @doc false
  def build(values) when is_list(values) do
    @shade_keys |> Enum.zip(values) |> Map.new()
  end

  @doc """
  The shade a hue resolves to for its core fill.

  Light chromatic hues use a darker core so a light label clears AA; amber-like
  hues stay bright and take a dark label. A palette can override these choices
  by wrapping its source, but the defaults keep `color="<hue>"` visually
  consistent across palettes.
  """
  def core_shade(:orange), do: 600
  def core_shade(:amber), do: 500
  def core_shade(:yellow), do: 500
  def core_shade(:green), do: 700
  def core_shade(:emerald), do: 700
  def core_shade(:teal), do: 700
  def core_shade(:cyan), do: 700
  def core_shade(:sky), do: 700
  def core_shade(_hue), do: 600

  defp normalize_hue(hue) when is_atom(hue), do: normalize_hue(Atom.to_string(hue))

  defp normalize_hue(hue) when is_binary(hue) do
    if Regex.match?(~r/^[a-z][a-z0-9-]*$/, hue), do: String.to_atom(hue)
  end

  defp normalize_hue(_hue), do: nil

  @callback name() :: atom()
  @callback colors() :: [atom()]
  @callback shades(color :: atom()) :: %{optional(atom()) => String.t()}
end
