if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Theme do
    @shortdoc "Refreshes the FlintUI theme and utility stylesheets from the library"

    @moduledoc """
    Overwrites `assets/css/flint.css` and `assets/css/flint-utilities.css` with
    the current library versions and makes sure both are imported from your app
    stylesheet.

        mix flint.theme

    Pass `--tailwind` to also refresh the `@theme` token bridge. Pass
    `--no-utilities` to leave the utility stylesheet and its import alone.

    Both stylesheets are generated: re-running this task overwrites them. Put
    your own token overrides in your app stylesheet after the imports.
    """

    use Igniter.Mix.Task

    alias FlintUI.Installer

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{schema: [tailwind: :boolean, utilities: :boolean]}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      tailwind? = igniter.args.options[:tailwind]
      utilities? = Keyword.get(igniter.args.options, :utilities) != false

      igniter
      |> Installer.install_theme_css(on_exists: :overwrite)
      |> maybe_utilities(utilities?)
      |> maybe_tailwind(tailwind?)
    end

    defp maybe_utilities(igniter, true),
      do: Installer.install_utilities_css(igniter, on_exists: :overwrite)

    defp maybe_utilities(igniter, false), do: igniter

    defp maybe_tailwind(igniter, true), do: Installer.tailwind_bridge(igniter)
    defp maybe_tailwind(igniter, _), do: igniter
  end
end
