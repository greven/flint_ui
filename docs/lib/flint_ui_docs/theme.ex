defmodule FlintUIDocs.Theme do
  @moduledoc """
  Writes the assembled FlintUI theme into the docs assets tree.

  The docs app imports the theme as `./flint.css`. Keeping a copy inside
  `docs/assets/css` (rather than importing the library's `priv/static/flint.css`
  across projects) means the Tailwind watcher rebuilds whenever the theme
  changes. The copy is derived at compile time and from `FlintUIDocs.ThemeWatcher`
  in dev.
  """

  @relative "assets/css/flint.css"

  @doc "Absolute path of the docs' copy of the assembled theme."
  def path, do: Path.expand(@relative, project_root())

  @doc """
  Writes the assembled theme when it differs from the current copy.

  Returns `:ok` when it (re)writes and `:noop` when the copy is already current.
  """
  def write! do
    output = path()
    css = FlintUI.Generator.theme_source()

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
