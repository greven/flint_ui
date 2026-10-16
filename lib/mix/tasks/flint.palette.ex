if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Palette do
    @shortdoc "Imports a color palette into the FlintUI theme tokens"

    @moduledoc """
    Maps a named color palette onto FlintUI's semantic color scales and writes
    the result to `assets/css/flint-palette.css`, imported right after
    `flint.css`.

    Colors are resolved through a `FlintUI.Palette` implementation. Tailwind's
    default palette ships with FlintUI, so no Tailwind install is required:

        mix flint.palette                                   # the built-in default mapping
        mix flint.palette --primary indigo --neutral zinc   # pick specific colors
        mix flint.palette --warning amber-400               # pin a role to a shade
        mix flint.palette --primary indigo --theme brand    # emit as a `data-theme` preset

    When no role flags are given every role is written using the built-in
    mapping (~ the default theme's colors). Pass `--from tailwind-refs` to emit
    `var(--color-*)` references instead of literal values, so a project's own
    Tailwind theme stays the source of truth.

    Options:

      * `--from` - `tailwind` (default) or `tailwind-refs`
      * `--theme` - emit under `[data-theme="<name>"]` instead of `:root`
      * `--light-shade` / `--dark-shade` - the shade a role resolves to per
        scheme (defaults `600` / `600`)
      * `--contrast` - `aa` (default), `aaa`, or a ratio for the computed
        label/text shades
      * `--primary`, `--secondary`, `--neutral`, `--success`, `--info`,
        `--warning`, `--error` - the palette color per role. Append a shade to
        pin it for that role alone, e.g. `--warning amber-400`.
    """

    use Igniter.Mix.Task

    alias FlintUI.Installer
    alias FlintUI.Palette
    alias FlintUI.Palette.CSS

    @roles ~w(primary secondary neutral success info warning error)
    @defaults %{
      "primary" => "neutral",
      "secondary" => "neutral",
      "neutral" => "neutral",
      "success" => "green",
      "info" => "blue",
      "warning" => "amber-400",
      "error" => "red"
    }
    @sources %{
      "tailwind" => {FlintUI.Palette.Tailwind, false},
      "tailwind-refs" => {FlintUI.Palette.Tailwind, true}
    }

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{
        schema: [
          from: :string,
          theme: :string,
          contrast: :string,
          light_shade: :integer,
          dark_shade: :integer,
          primary: :string,
          secondary: :string,
          neutral: :string,
          success: :string,
          info: :string,
          warning: :string,
          error: :string
        ]
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      opts = igniter.args.options

      with {:ok, source, refs?} <- source(opts),
           {:ok, mapping, role_shades} <- mapping(source, opts),
           {:ok, shades} <- shades(opts),
           {:ok, contrast} <- contrast(opts) do
        css =
          CSS.render(mapping,
            theme: opts[:theme],
            light_shade: shades.light,
            dark_shade: shades.dark,
            shades: role_shades,
            contrast: contrast,
            refs: refs?
          )

        Installer.install_palette_css(igniter, css)
      else
        {:error, message} -> Igniter.add_issue(igniter, message)
      end
    end

    defp source(opts) do
      from = opts[:from] || "tailwind"

      case Map.fetch(@sources, from) do
        {:ok, {module, refs?}} -> {:ok, module, refs?}
        :error -> {:error, "Unknown palette source `#{from}`. Use one of: #{enum(@sources)}."}
      end
    end

    defp mapping(source, opts) do
      provided = Enum.filter(@roles, &opts[String.to_atom(&1)])

      roles = if provided == [], do: @roles, else: provided

      Enum.reduce_while(roles, {:ok, [], %{}}, fn role, {:ok, acc, shades} ->
        value = opts[String.to_atom(role)] || @defaults[role]

        case parse_color(source, value) do
          {:ok, color, shade} ->
            shades = if shade, do: Map.put(shades, String.to_atom(role), shade), else: shades
            {:cont, {:ok, [{String.to_atom(role), {source, color}} | acc], shades}}

          :error ->
            {:halt,
             {:error,
              "Color `#{value}` is not in the #{source.name()} palette. Available: " <>
                enum(source.colors()) <> "."}}
        end
      end)
      |> case do
        {:ok, mapping, shades} -> {:ok, Enum.reverse(mapping), shades}
        error -> error
      end
    end

    # A role color is a palette name (`amber`), optionally pinning a shade
    # (`amber-400`). The pinned shade overrides the global `--light/dark-shade`
    # for that role.
    defp parse_color(source, value) do
      colors = Enum.map(source.colors(), &Atom.to_string/1)

      case String.split(value, "-", parts: 2) do
        [name] ->
          if name in colors, do: {:ok, String.to_atom(name), nil}, else: :error

        [name, shade] ->
          with true <- name in colors,
               {parsed, ""} <- Integer.parse(shade),
               true <- parsed in Palette.shade_keys() do
            {:ok, String.to_atom(name), parsed}
          else
            _ -> :error
          end
      end
    end

    defp shades(opts) do
      light = opts[:light_shade] || 600
      dark = opts[:dark_shade] || 600

      cond do
        light not in Palette.shade_keys() ->
          {:error, "Invalid --light-shade `#{light}`. Use one of: #{enum(Palette.shade_keys())}."}

        dark not in Palette.shade_keys() ->
          {:error, "Invalid --dark-shade `#{dark}`. Use one of: #{enum(Palette.shade_keys())}."}

        true ->
          {:ok, %{light: light, dark: dark}}
      end
    end

    defp contrast(opts) do
      case opts[:contrast] do
        nil ->
          {:ok, :aa}

        "aa" ->
          {:ok, :aa}

        "aaa" ->
          {:ok, :aaa}

        value ->
          case Float.parse(value) do
            {ratio, ""} when ratio > 0 ->
              {:ok, ratio}

            _ ->
              {:error, "Invalid --contrast `#{value}`. Use `aa`, `aaa`, or a ratio."}
          end
      end
    end

    defp enum(values), do: values |> Enum.map_join(", ", &to_string/1)
  end
end
