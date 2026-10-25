if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Theme do
    @shortdoc "Refreshes the FlintUI theme stylesheet from the library"

    @moduledoc """
    Overwrites `assets/css/flint.css` with the current default theme and makes
    sure it is imported from your app stylesheet.

        mix flint.theme

    Pass `--tailwind` to also refresh the `@theme` token bridge.

    `flint.css` is generated: re-running this task overwrites it. Put your own
    token overrides in your app stylesheet after the `flint.css` import (the same
    file that imports the theme).
    """

    use Igniter.Mix.Task

    alias FlintUI.Installer

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{schema: [tailwind: :boolean]}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      tailwind? = igniter.args.options[:tailwind]

      igniter
      |> Installer.install_theme_css(on_exists: :overwrite)
      |> maybe_tailwind(tailwind?)
    end

    defp maybe_tailwind(igniter, true), do: Installer.tailwind_bridge(igniter)
    defp maybe_tailwind(igniter, _), do: igniter
  end
end
