if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Setup do
    @shortdoc "Sets up FlintUI theming, components, and JS hooks"

    @moduledoc """
    Sets up FlintUI in a Phoenix project:

      * creates `MyAppWeb.Components` (where `mix flint.add` generates wrappers),
      * copies the theme stylesheet to `assets/css/flint.css` and imports it,
      * imports `MyAppWeb.Components` into your HTML helpers, so generated
        components are available as `<.button>`, `<.toggle>`, and so on,
      * registers FlintUI's LiveView hooks in `assets/js/app.js`.

    ## Options

      * `--tailwind` - also map the FlintUI tokens onto Tailwind utilities
        (`bg-primary`, `border-default`, …) in `assets/css/app.css`.
      * `--sound` - also register the optional sound bundle
        (`flint-sound.js`) and its `FlintUI.Sound` hook. This only registers the
        hook; mount `<FlintUI.sound_provider enabled={false} theme="default" />`
        once in your layout to use it.
      * `--no-js` - skip the `assets/js/app.js` wiring.
    """

    use Igniter.Mix.Task

    alias FlintUI.Installer

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{schema: [tailwind: :boolean, sound: :boolean, js: :boolean]}
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      web = Igniter.Libs.Phoenix.web_module(igniter)
      components = Igniter.Libs.Phoenix.web_module_name(igniter, "Components")
      tailwind? = igniter.args.options[:tailwind]
      sound? = igniter.args.options[:sound] == true
      js? = Keyword.get(igniter.args.options, :js) != false

      igniter
      |> Installer.ensure_components_module(components)
      |> Installer.install_theme_css()
      |> Installer.import_components(web, components)
      |> maybe_install_js(js?, sound?)
      |> maybe_tailwind(tailwind?)
    end

    defp maybe_install_js(igniter, true, sound?),
      do: Installer.install_js_hooks(igniter, sound: sound?)

    defp maybe_install_js(igniter, false, _sound?), do: igniter

    defp maybe_tailwind(igniter, true), do: Installer.tailwind_bridge(igniter)
    defp maybe_tailwind(igniter, _), do: igniter
  end
end
