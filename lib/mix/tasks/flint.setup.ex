if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Setup do
    @shortdoc "Sets up FlintUI theming and the generated components module"

    @moduledoc """
    Sets up FlintUI in a Phoenix project:

      * creates `MyAppWeb.Components` (where `mix flint.add` generates wrappers),
      * copies the theme stylesheet to `assets/css/flint.css` and imports it,
      * imports `MyAppWeb.Components` into your HTML helpers, so generated
        components are available as `<.button>`, `<.toggle>`, and so on.

    Pass `--tailwind` to also map the FlintUI tokens onto Tailwind utilities
    (`bg-primary`, `border-border`, …) in `assets/css/app.css`.
    """

    use Igniter.Mix.Task

    alias FlintUI.Installer

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{schema: [tailwind: :boolean]}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      web = Igniter.Libs.Phoenix.web_module(igniter)
      components = Igniter.Libs.Phoenix.web_module_name(igniter, "Components")
      tailwind? = igniter.args.options[:tailwind]

      igniter
      |> Installer.ensure_components_module(components)
      |> Installer.install_theme_css()
      |> Installer.import_components(web, components)
      |> maybe_tailwind(tailwind?)
    end

    defp maybe_tailwind(igniter, true), do: Installer.tailwind_bridge(igniter)
    defp maybe_tailwind(igniter, _), do: igniter
  end
end
