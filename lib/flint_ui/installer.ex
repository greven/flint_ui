if Code.ensure_loaded?(Igniter) do
  defmodule FlintUI.Installer do
    @moduledoc false

    alias FlintUI.Generator

    @theme_css "assets/css/flint.css"
    @app_css "assets/css/app.css"

    @doc "Creates the generated components module if it does not exist."
    def ensure_components_module(igniter, module) do
      Igniter.Project.Module.find_and_update_or_create_module(
        igniter,
        module,
        "use Phoenix.Component",
        fn zipper -> {:ok, zipper} end
      )
    end

    @doc """
    Writes the theme stylesheet and imports it from the app stylesheet.

    Defaults to leaving an existing `flint.css` untouched (`:skip`); pass
    `on_exists: :overwrite` to refresh it from the library.
    """
    def install_theme_css(igniter, opts \\ []) do
      on_exists = Keyword.get(opts, :on_exists, :skip)

      igniter
      |> Igniter.create_new_file(@theme_css, Generator.theme_source(), on_exists: on_exists)
      |> import_theme_css()
    end

    @doc "Adds `@import \"./flint.css\";` to the app stylesheet."
    def import_theme_css(igniter) do
      path = @app_css

      if Igniter.exists?(igniter, path) do
        Igniter.update_file(igniter, path, fn source ->
          content = Rewrite.Source.get(source, :content)

          if String.contains?(content, "flint.css") do
            source
          else
            Rewrite.Source.update(
              source,
              :content,
              String.trim_trailing(content) <> "\n\n@import \"./flint.css\";\n"
            )
          end
        end)
      else
        Igniter.add_notice(igniter, "Add `@import \"./flint.css\";` to your main stylesheet.")
      end
    end

    @doc "Maps FlintUI tokens onto Tailwind utilities in the app stylesheet."
    def tailwind_bridge(igniter) do
      bridge = Generator.tailwind_bridge_source()
      path = @app_css

      if Igniter.exists?(igniter, path) do
        Igniter.update_file(igniter, path, fn source ->
          content = Rewrite.Source.get(source, :content)

          if String.contains?(content, "--fl-color-primary") do
            source
          else
            Rewrite.Source.update(
              source,
              :content,
              String.trim_trailing(content) <> "\n\n" <> bridge
            )
          end
        end)
      else
        Igniter.add_notice(igniter, "Add the FlintUI `@theme` bridge to your stylesheet.")
      end
    end

    @doc "Imports the generated components module into the app's HTML helpers."
    def import_components(igniter, web_module, components_module) do
      {exists?, igniter} = Igniter.Project.Module.module_exists(igniter, web_module)

      if exists? do
        Igniter.Project.Module.find_and_update_module!(igniter, web_module, fn zipper ->
          with {:ok, zipper} <- Igniter.Code.Function.move_to_defp(zipper, :html_helpers, 0),
               {:ok, zipper} <- Igniter.Code.Common.move_to_do_block(zipper) do
            {:ok,
             Igniter.Code.Common.add_code(zipper, "import #{inspect(components_module)}",
               placement: :after
             )}
          else
            _ -> {:ok, zipper}
          end
        end)
      else
        Igniter.add_notice(
          igniter,
          "Import #{inspect(components_module)} where your HTML helpers are defined."
        )
      end
    end
  end
end
