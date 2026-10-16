defmodule FlintUIDocs.Theme do
  @moduledoc """
  Writes the assembled FlintUI theme into the docs assets tree.

  The docs app imports the theme as `./flint.css`. Keeping a copy inside
  `docs/assets/css` (rather than importing the library's `priv/static/flint.css`
  across projects) means the Tailwind watcher rebuilds whenever the theme
  changes. The copy is derived at compile time and from `FlintUIDocs.ThemeWatcher`
  in dev.

  The docs also ship a real color palette (see `palette/0`), so the component
  showcase demonstrates distinct color roles rather than the default neutral
  theme. It is written to `./flint-palette.css`, imported after the theme. The
  mapping takes Nuxt UI's defaults for the state roles (`success` green, `info`
  blue, `error` red) with `warning` on amber (Fluxon UI's warning), and adds a
  red `primary` plus an indigo `secondary`; `neutral` stays achromatic so
  components reading it render plain black/white.
  """

  @relative "assets/css/flint.css"
  @palette_relative "assets/css/flint-palette.css"

  @doc "Absolute path of the docs' copy of the assembled theme."
  def path, do: Path.expand(@relative, project_root())

  @doc "Absolute path of the docs' generated color palette."
  def palette_path, do: Path.expand(@palette_relative, project_root())

  @doc """
  The docs' semantic color mapping: role to `{palette_module, color_name}`.

  FlintUI's default theme is neutral, so the roles would otherwise be
  indistinguishable. This follows Nuxt UI's defaults for the states
  (`success` green, `info` blue, `error` red) but maps `warning` to amber
  (Fluxon UI's warning), and gives the showcase a branded red `primary` plus an
  indigo `secondary` (Nuxt ships `secondary` and `info` as the same hue; we give
  `secondary` its own).
  """
  def palette do
    source = FlintUI.Palette.Tailwind

    [
      primary: {source, :red},
      secondary: {source, :indigo},
      neutral: {source, :neutral},
      success: {source, :green},
      info: {source, :blue},
      warning: {source, :amber},
      error: {source, :red}
    ]
  end

  @doc """
  Writes the assembled theme and palette when they differ from the current copy.

  Returns `:ok` when it (re)writes and `:noop` when both copies are already
  current.
  """
  def write! do
    theme = write_if_changed!(path(), FlintUI.Generator.theme_source())
    palette = write_if_changed!(palette_path(), palette_source())

    if theme == :ok or palette == :ok, do: :ok, else: :noop
  end

  defp palette_source do
    # `warning` pins to amber-400 (Fluxon's warning); `success` pins to green-700
    # so its solid label can be near-white at AA (green-600 cannot clear AA
    # against white). Everything else uses the global 600 anchor in both schemes
    # — the fill stays equally saturated in dark instead of washing out; the
    # label/`-text` shades are computed.
    FlintUI.Palette.CSS.render(palette(), shades: %{warning: 400, success: 700})
  end

  defp write_if_changed!(output, css) do
    if File.read(output) == {:ok, css} do
      :noop
    else
      File.mkdir_p!(Path.dirname(output))
      File.write!(output, css)
      :ok
    end
  end

  defp project_root, do: Path.dirname(Mix.Project.project_file())
end
