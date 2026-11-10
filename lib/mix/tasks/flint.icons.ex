if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Icons do
    @shortdoc "Installs icon and flag assets for FlintUI"

    @moduledoc """
    Installs one or more icon or flag asset sets.

        mix flint.icons lucide
        mix flint.icons lucide flags --tailwind
        mix flint.icons --all --css

    Supported sets: `heroicons`, `lucide`, `simple_icons`, and `flags`.

    The task adds an asset-only dependency (no app, no compilation), then wires
    the assets in one of three ways:

      * `--tailwind` — writes a vendor plugin to `assets/vendor/` and adds the
        matching `@plugin` line to `assets/css/app.css`. Tailwind emits the
        classes it finds in your source.
      * `--css` — writes plain CSS to `assets/css/flint-<set>.css` from the
        downloaded SVGs and imports it from `assets/css/app.css`. No Tailwind
        required.
      * `--assets` — copies the Flag Icons SVGs into
        `priv/static/images/flags` as `<code>.svg` and `<code>-square.svg`. The
        `<.flag>` component builds the URL from `code` and `shape`, so dynamic
        flags need no class and no safelist. This mode is only for `flags`.

    Add `--scan` to the plain CSS mode to emit only the icon classes found in
    your source instead of every icon in the set. This also installs the
    `:flint_icons` compiler so the CSS is refreshed on `mix compile`:

        mix flint.icons lucide --css --scan

    Names built at runtime cannot be scanned; pass them with
    `--safelist lucide-wifi,lucide-house`. `--source` overrides the default
    source globs, and `--only` copies or emits a subset.

    Use `--assets` for the `<.flag>` component and the class modes for direct
    `flag-*` classes:

        mix flint.icons flags --assets
        mix flint.icons flags --assets --only pt,us,br

    Without a mode flag the task picks Tailwind when `app.css` imports it and
    plain CSS otherwise.

    Choose the set by the class prefixes it produces:

      * `heroicons` — `hero-<name>`, `hero-<name>-solid`, `hero-<name>-mini`,
        `hero-<name>-micro`
      * `lucide` — `lucide-<name>`
      * `simple_icons` — `si-<name>`
      * `flags` — `flag-<country>` and `flag-<country>-square`; `--assets`
        instead copies the SVGs for the `<.flag>` component

    Assets keep their upstream licenses: Heroicons (MIT), Lucide (ISC),
    Simple Icons (CC0-1.0), and Flag Icons (MIT).
    """

    use Igniter.Mix.Task

    alias FlintUI.{Icons, Installer}

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{
        positional: [{:sets, [optional: true, rest: true]}],
        schema: [
          all: :boolean,
          tailwind: :boolean,
          css: :boolean,
          assets: :boolean,
          scan: :boolean,
          safelist: :keep,
          source: :keep,
          only: :keep
        ],
        aliases: [a: :all]
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      sets = resolve_sets(igniter.args.positional[:sets] || [], igniter.args.options)
      mode = resolve_mode(igniter, igniter.args.options)

      with {:ok, sets} <- sets,
           {:ok, mode} <- mode,
           :ok <- validate_mode(sets, mode) do
        install(igniter, sets, mode, igniter.args.options)
      else
        {:error, message} -> Igniter.add_issue(igniter, message)
      end
    end

    defp validate_mode([:flag_icons], :assets), do: :ok

    defp validate_mode(_sets, :assets) do
      {:error, "`--assets` is only available for the `flags` set."}
    end

    defp validate_mode(_sets, _mode), do: :ok

    defp resolve_sets(positional, options) do
      names = if options[:all], do: Icons.sets(), else: positional
      names = if names == [], do: [:lucide_icons], else: names

      {sets, unknown} =
        Enum.reduce(names, {[], []}, fn name, {sets, unknown} ->
          case Icons.normalize(name) do
            nil -> {sets, unknown ++ [to_string(name)]}
            set -> {sets ++ [set], unknown}
          end
        end)

      cond do
        unknown != [] ->
          {:error,
           "Unknown icon set(s): #{Enum.join(unknown, ", ")}. " <>
             "Available: #{Enum.map_join(Icons.sets(), ", ", &set_name/1)}."}

        true ->
          {:ok, Enum.uniq(sets)}
      end
    end

    defp resolve_mode(igniter, options) do
      selected = for key <- [:tailwind, :css, :assets], options[key], do: key

      case selected do
        [mode] ->
          {:ok, mode}

        [_ | _] ->
          {:error, "Pass only one of `--tailwind`, `--css`, or `--assets`."}

        [] ->
          if tailwind?(igniter) do
            {:ok, :tailwind}
          else
            {:ok, :css}
          end
      end
    end

    defp tailwind?(igniter) do
      case app_css(igniter) do
        nil ->
          false

        content ->
          String.contains?(content, "tailwindcss") or String.contains?(content, "@plugin")
      end
    end

    defp app_css(igniter) do
      path = "assets/css/app.css"

      case igniter.rewrite.sources[path] do
        nil ->
          case File.read(path) do
            {:ok, content} -> content
            _ -> nil
          end

        source ->
          Rewrite.Source.get(source, :content)
      end
    end

    defp install(igniter, sets, mode, options) do
      igniter = Enum.reduce(sets, igniter, &Installer.add_icon_dep(&2, &1))

      igniter =
        case mode do
          :tailwind ->
            Enum.reduce(sets, igniter, fn set, acc ->
              acc
              |> Installer.install_icon_plugin(set)
              |> Installer.append_app_css(Icons.plugin_import(set))
            end)

          :css ->
            Enum.reduce(sets, igniter, fn set, acc ->
              acc
              |> Installer.install_icon_css_stub(set)
              |> Installer.append_app_css(Icons.css_import(set))
            end)

          :assets ->
            igniter
        end

      igniter =
        if mode == :css and options[:scan] do
          igniter
          |> Installer.add_icon_compiler()
          |> Installer.configure_icon_scanner(
            source_globs: values(options, :source),
            safelist: values(options, :safelist)
          )
        else
          igniter
        end

      igniter
      |> Igniter.add_task("deps.get")
      |> maybe_generate(sets, mode, options)
      |> maybe_scan_notice(mode, options)
      |> Igniter.add_notice(notice(sets, mode, options))
    end

    defp maybe_generate(igniter, _sets, :tailwind, _options), do: igniter

    defp maybe_generate(igniter, _sets, :assets, options) do
      args =
        case values(options, :only) do
          [] -> []
          only -> ["--only", Enum.join(only, ",")]
        end

      Igniter.add_task(igniter, "flint.icons.copy_flags", args)
    end

    defp maybe_generate(igniter, sets, :css, options) do
      args =
        Enum.map(sets, &set_name/1) ++
          if(options[:scan], do: ["--scan"], else: []) ++
          flag_args(options)

      Igniter.add_task(igniter, "flint.icons.generate", args)
    end

    defp flag_args(options) do
      for {key, flag} <- [safelist: "--safelist", source: "--source", only: "--only"],
          value <- values(options, key) do
        [flag, value]
      end
      |> List.flatten()
    end

    defp maybe_scan_notice(igniter, :tailwind, options) do
      if options[:scan] do
        Igniter.add_notice(
          igniter,
          "`--scan` applies to plain CSS mode. Tailwind mode already scans your source."
        )
      else
        igniter
      end
    end

    defp maybe_scan_notice(igniter, _mode, _options), do: igniter

    defp values(options, key) do
      options
      |> Keyword.get_values(key)
      |> List.flatten()
      |> Enum.filter(&is_binary/1)
      |> Enum.flat_map(&String.split(&1, ",", trim: true))
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))
    end

    defp notice(sets, mode, options) do
      names = Enum.map_join(sets, ", ", &Icons.get!(&1).label)

      case mode do
        :tailwind ->
          """
          Installed #{names} as Tailwind vendor plugins. Restart `mix assets.watch` \
          or `mix phx.server` if either is already running. Tailwind only emits \
          classes it finds literally in your source; safelist any icon names you \
          build at runtime.
          """

        :css ->
          if options[:scan] do
            """
            Installed #{names} and wrote scanned plain CSS imports. The `:flint_icons` \
            compiler will refresh the CSS on `mix compile`. Add dynamic names with \
            `config :flint_ui, icon_safelist: [...]` or \
            `mix flint.icons.generate --scan --safelist ...`.
            """
          else
            """
            Installed #{names} and wrote plain CSS imports. `mix deps.get` and \
            `mix flint.icons.generate` will run now. Re-run the generate task after \
            updating an asset dependency, or install with `--scan` to emit only the \
            icons your source uses.
            """
          end

        :assets ->
          """
          Installed #{names} and copied the SVGs to `priv/static/images/flags`. \
          The `<.flag>` component builds the image URL from `code` and `shape`, so \
          the code can be dynamic and no safelist is needed. Re-run \
          `mix flint.icons.copy_flags` after updating the dependency; pass \
          `--only pt,us` to copy a subset.
          """
      end
    end

    defp set_name(set) do
      case set do
        :heroicons -> "heroicons"
        :lucide_icons -> "lucide"
        :simple_icons -> "simple_icons"
        :flag_icons -> "flags"
      end
    end
  end
end
