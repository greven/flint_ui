defmodule Mix.Tasks.Flint.Palette do
  @shortdoc "Generates a custom palette hue with shades and tone hooks"

  @moduledoc """
  Generates a custom palette hue from a seed color or an existing Tailwind hue.

      mix flint.palette brand --from "#8b5cf6"
      mix flint.palette brand --from tailwind:rose
      mix flint.palette brand --from "#8b5cf6" --write assets/css/flint-brand.css

  The generated block contains the eleven shades, the derived `-on`,
  `-on-soft`, `-soft`, and `-soft-border` tokens, and the base and active
  `[data-color]` hooks. Add the hue to your config so `color="brand"` passes
  validation:

      config :flint_ui, extra_hues: [:brand]

  Names that would shadow a semantic role or chrome token — `primary`, `text`,
  `surface`, `border`, and so on — are reserved. Choose a distinct hue name.

  Import the written file after `flint.css`. The task appends the import to
  `assets/css/app.css` when that file exists.

  ## Options

    * `--from` - required; a raw color (`#8b5cf6`, `rgb(...)`, `oklch(...)`) or
      an existing Tailwind ramp (`tailwind:rose`).
    * `--write` - write the CSS to this path instead of printing it.
    * `--core` - the shade used as the core fill (default `600` for a seed,
      or the source hue's core for `tailwind:<hue>`).
    * `--contrast` - `aa` (default), `aaa`, or a numeric ratio for label and
      text derivation.
  """

  use Mix.Task

  alias FlintUI.Palette
  alias FlintUI.Palette.{CSS, Seed, Tailwind}

  @switches [from: :string, write: :string, core: :integer, contrast: :string]
  @aliases [f: :from, w: :write]

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, argv} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    name = parse_name(argv)
    from = Keyword.get(opts, :from) || Mix.raise("Pass --from COLOR or --from tailwind:<hue>.")
    {shades, source_core} = parse_source(from)
    core = Keyword.get(opts, :core, source_core)
    contrast = parse_contrast(Keyword.get(opts, :contrast))

    unless core in Palette.shade_keys() do
      Mix.raise("--core must be one of #{Enum.join(Palette.shade_keys(), ", ")}.")
    end

    css = CSS.render_custom_hue(name, shades, core: core, contrast: contrast)

    case Keyword.get(opts, :write) do
      nil ->
        Mix.shell().info(css)
        config_notice(name)

      path ->
        write!(path, css)
        import_into_app_css!(path)
        config_notice(name)
    end

    :ok
  end

  defp parse_name([name]) do
    unless Regex.match?(~r/^[a-z][a-z0-9-]*$/, name) do
      Mix.raise("Hue names must be lowercase identifiers, for example `brand`.")
    end

    if name in Palette.hue_names() do
      Mix.raise("#{name} is already a shipped hue. Choose another name or remap its shades.")
    end

    if Palette.reserved_hue_name?(name) do
      Mix.raise("#{name} is reserved for a semantic role or chrome token. Choose another name.")
    end

    name
  end

  defp parse_name(_),
    do: Mix.raise("Pass exactly one hue name, for example: mix flint.palette brand")

  defp parse_source("tailwind:" <> hue) do
    atom = String.to_atom(hue)

    unless atom in Tailwind.colors() do
      Mix.raise("Unknown Tailwind hue #{inspect(hue)}.")
    end

    {Tailwind.shades(atom), Palette.core_shade(atom)}
  end

  defp parse_source(value), do: {Seed.from_color(value), 600}

  defp parse_contrast(nil), do: :aa
  defp parse_contrast("aa"), do: :aa
  defp parse_contrast("aaa"), do: :aaa

  defp parse_contrast(value) do
    case Float.parse(value) do
      {number, ""} -> number
      _ -> Mix.raise("--contrast must be aa, aaa, or a number.")
    end
  end

  defp write!(path, css) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, css)
    Mix.shell().info([:green, "* writing ", :reset, path])
  end

  defp import_into_app_css!(path) do
    app_css = "assets/css/app.css"
    line = ~s(@import "./#{Path.basename(path)}";)

    if File.exists?(app_css) do
      source = File.read!(app_css)

      unless String.contains?(source, line) do
        File.write!(app_css, String.trim_trailing(source) <> "\n\n" <> line <> "\n")

        Mix.shell().info([
          :green,
          "* importing ",
          :reset,
          line,
          :green,
          " from ",
          :reset,
          app_css
        ])
      end
    else
      Mix.shell().info("Add #{line} to your main stylesheet after the flint.css import.")
    end
  end

  defp config_notice(name) do
    Mix.shell().info("""
    Add the hue to your config so `color="#{name}"` is accepted:

        config :flint_ui, extra_hues: [:#{name}]
    """)
  end
end
