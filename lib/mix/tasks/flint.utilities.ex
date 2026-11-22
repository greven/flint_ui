if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Utilities do
    @shortdoc "Writes or refreshes the FlintUI utility stylesheet"

    @moduledoc """
    Writes `assets/css/flint-utilities.css` and imports it from your app
    stylesheet.

        mix flint.utilities

    `mix flint.setup` and `mix flint.theme` install or refresh the utility layer
    by default, so this task is mainly for refreshing the file on its own. The
    file is generated: re-running overwrites it. Put overrides after the import.

    The stylesheet is plain CSS and needs no build step. It declares
    `@layer base, components, utilities, focus;`, so utilities win over the
    component theme while focus treatments stay last.

    ## Options

      * `--no-import` - write the file but do not add its import to
        `assets/css/app.css`.
      * `--no-reset` - omit the minimal base reset (`box-sizing`, zero border
        widths, and `body` margin). Border utilities rely on that reset for
        predictable widths.
    """

    use Igniter.Mix.Task

    alias FlintUI.Installer

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{schema: [import: :boolean, reset: :boolean]}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      import? = Keyword.get(igniter.args.options, :import) != false
      reset? = Keyword.get(igniter.args.options, :reset) != false

      igniter
      |> Installer.install_theme_css()
      |> Installer.install_utilities_css(
        on_exists: :overwrite,
        import: import?,
        reset: reset?
      )
    end
  end
end
