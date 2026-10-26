defmodule FlintUIDocs.Theme do
  @moduledoc """
  Writes the assembled FlintUI base theme into the docs assets tree.

  The docs app imports the theme as `./flint.css`. Keeping a copy inside
  `docs/assets/css` (rather than importing the library's `priv/static/flint.css`
  across projects) means the Tailwind watcher rebuilds whenever the theme
  changes. The copy is derived at compile time and from `FlintUIDocs.ThemeWatcher`
  in dev.

  The color theme is **not** generated at build time. The docs map FlintUI's
  semantic role scales onto the site's Tailwind `--color-*` variables in
  `app.css`, after the theme import. This mirrors the consumer contract:
  generated base theme, then site-owned color tokens and overrides in the app
  stylesheet.
  """

  @relative "assets/css/flint.css"

  @doc "Absolute path of the docs' copy of the assembled theme."
  def path, do: Path.expand(@relative, project_root())

  @doc """
  Writes the assembled theme when it differs from the current copy.

  Returns `:ok` when it rewrites and `:noop` when the copy is already current.
  """
  def write! do
    write_if_changed!(path(), FlintUI.Generator.theme_source())
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
