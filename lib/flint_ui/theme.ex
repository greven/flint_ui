defmodule FlintUI.Theme do
  @moduledoc """
  The registry of shipped theme presets.

  A preset is a CSS part under `priv/templates/themes/` that selects under
  `[data-theme="<name>"]` and overrides only the tokens it changes. It carries
  no `color-scheme`, so a preset composes with the light/dark `data-color-scheme`
  control. The default theme is `:root` (see `tokens.css`) and is implicit.

  `:default` is a selectable preset with no stylesheet: it is the `:root`
  baseline, so selecting it means clearing `data-theme` on `<html>`. It is listed
  by `presets/0` (the UI-selectable list) but not by `themes/0` (the CSS-part
  registry the generator consumes).

  `FlintUI.Generator.part_paths/0` concatenates these parts after `base.css`,
  before the component stylesheets.
  """

  @themes [
    %{name: :pastel, css: "themes/pastel.css"},
    %{name: :modern, css: "themes/modern.css"}
  ]

  @doc "Returns every shipped theme preset."
  def themes, do: @themes

  @doc "Returns the names of the shipped theme presets."
  def names, do: Enum.map(@themes, & &1.name)

  @doc """
  Returns the selectable presets, default first.

  `:default` has no stylesheet — it is the `:root` baseline — so selecting it
  means clearing `data-theme` on `<html>`.
  """
  def presets, do: [:default | names()]
end
