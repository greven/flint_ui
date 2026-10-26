if Code.ensure_loaded?(Igniter) do
  defmodule FlintUI.Installer do
    @moduledoc false

    alias FlintUI.Generator

    @theme_css "assets/css/flint.css"
    @app_css "assets/css/app.css"
    @app_js "assets/js/app.js"
    @flint_js_import ~s(import {hooks as flintHooks} from "flint_ui")
    @sound_js_import ~s(import {hooks as soundHooks} from "flint_ui/sound")

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

    @doc """
    Registers FlintUI's LiveView hooks in `assets/js/app.js`.

    Adds the core import and merges `...flintHooks` into the `LiveSocket`
    `hooks` option. Pass `sound: true` to also import the optional sound bundle
    and merge `...soundHooks`.

    The patch is deliberately conservative: when `app.js` does not look like a
    plain `new LiveSocket(..., {...})` with an object `hooks:` value, it leaves
    the file alone and adds a notice with the exact snippet instead.
    """
    def install_js_hooks(igniter, opts \\ []) do
      sound? = Keyword.get(opts, :sound, false)

      if Igniter.exists?(igniter, @app_js) do
        igniter =
          Igniter.update_file(igniter, @app_js, fn source ->
            content =
              source
              |> Rewrite.Source.get(:content)
              |> maybe_add_sound_import(sound?)
              |> ensure_import(~s(from "flint_ui"), @flint_js_import)
              |> register_hooks(sound?)

            Rewrite.Source.update(source, :content, content)
          end)

        content = rewritten_content(igniter, @app_js)

        igniter =
          if String.contains?(content, "...flintHooks") do
            igniter
          else
            Igniter.add_notice(igniter, manual_js_notice(sound?))
          end

        if sound? do
          Igniter.add_notice(igniter, sound_provider_notice())
        else
          igniter
        end
      else
        Igniter.add_notice(igniter, missing_js_notice(sound?))
      end
    end

    defp rewritten_content(igniter, path) do
      case igniter.rewrite.sources[path] do
        nil -> ""
        source -> Rewrite.Source.get(source, :content)
      end
    end

    defp ensure_import(content, needle, line) do
      if String.contains?(content, needle), do: content, else: line <> "\n" <> content
    end

    defp maybe_add_sound_import(content, true),
      do: ensure_import(content, ~s(from "flint_ui/sound"), @sound_js_import)

    defp maybe_add_sound_import(content, false), do: content

    defp register_hooks(content, sound?) do
      spread = if sound?, do: "...flintHooks, ...soundHooks", else: "...flintHooks"

      cond do
        String.contains?(content, "...flintHooks") and
            (not sound? or String.contains?(content, "...soundHooks")) ->
          content

        String.contains?(content, "...flintHooks") and sound? ->
          String.replace(content, "...flintHooks", "...flintHooks, ...soundHooks", global: false)

        String.contains?(content, "hooks:") ->
          add_to_hooks_object(content, spread)

        true ->
          add_hooks_option(content, spread)
      end
    end

    # `hooks: {` already exists: inject the spreads right after the brace.
    defp add_to_hooks_object(content, spread) do
      case Regex.run(~r/hooks:\s*\{/, content, return: :index) do
        [{start, _length} | _] ->
          rest = binary_part(content, start, byte_size(content) - start)

          case :binary.match(rest, "{") do
            {brace, _} ->
              at = start + brace + 1

              binary_part(content, 0, at) <>
                spread <> ", " <> binary_part(content, at, byte_size(content) - at)

            :nomatch ->
              content
          end

        nil ->
          content
      end
    end

    # No `hooks:` key: add one as the first option of the LiveSocket call.
    defp add_hooks_option(content, spread) do
      case :binary.match(content, "new LiveSocket(") do
        {pos, _length} ->
          rest = binary_part(content, pos, byte_size(content) - pos)

          case :binary.match(rest, "{") do
            {brace, _} ->
              at = pos + brace + 1
              insertion = "\n  hooks: {#{spread}},"

              binary_part(content, 0, at) <>
                insertion <> binary_part(content, at, byte_size(content) - at)

            :nomatch ->
              content
          end

        :nomatch ->
          content
      end
    end

    defp manual_js_notice(sound?) do
      hooks = if sound?, do: "{...flintHooks, ...soundHooks}", else: "{...flintHooks}"

      imports =
        if sound? do
          """
          import {hooks as flintHooks} from "flint_ui"
          import {hooks as soundHooks} from "flint_ui/sound"
          """
        else
          """
          import {hooks as flintHooks} from "flint_ui"
          """
        end

      """
      Register FlintUI's hooks where you construct LiveSocket:

      #{imports}
      let liveSocket = new LiveSocket("/live", Socket, {hooks: #{hooks}})
      """
    end

    defp missing_js_notice(sound?) do
      "assets/js/app.js was not found. " <> manual_js_notice(sound?)
    end

    defp sound_provider_notice do
      """
      The sound hook is registered, but nothing plays until you mount it once in \
      your shared layout:

          <FlintUI.sound_provider enabled={false} theme="default" />
      """
    end
  end
end
