defmodule Mix.Tasks.Flint.Icons.Generate do
  @shortdoc "Generates plain CSS for installed FlintUI icon sets"

  @moduledoc """
  Writes plain CSS for the icon and flag assets in `deps/`.

      mix flint.icons.generate lucide
      mix flint.icons.generate heroicons simple_icons flags
      mix flint.icons.generate --all

  By default every icon in the selected sets is emitted. To match the classes
  actually used in your app, add `--scan`:

      mix flint.icons.generate lucide --scan
      mix flint.icons.generate --all --scan --safelist lucide-wifi

  `--scan` reads the default source globs (`lib/**/*.{ex,exs,heex,eex,leex}`,
  `assets/js/**/*.{js,ts,tsx}`, and `priv/**/*.{heex,eex}`) and emits only the
  names found there. Dynamic names are invisible to the scanner; add them with
  `--safelist` or list them with `--only`. Both accept full class names such as
  `lucide-house` or `flag-pt-square`.

  Output defaults to `assets/css/flint-<set>.css`. Run the task again after
  updating an asset dependency.
  """

  use Mix.Task

  alias FlintUI.Icons
  alias FlintUI.Icons.Scanner

  @impl Mix.Task
  def run(args) do
    {options, positional, invalid} =
      OptionParser.parse(args,
        strict: [
          all: :boolean,
          output: :string,
          scan: :boolean,
          source: :keep,
          safelist: :keep,
          only: :keep
        ],
        aliases: [a: :all, o: :output]
      )

    if invalid != [] do
      Mix.raise("Invalid option(s): #{Enum.map_join(invalid, ", ", &elem(&1, 0))}")
    end

    sets = resolve_sets(positional, options)
    output_dir = options[:output] || "assets/css"
    classes = classes(options)

    if is_struct(classes, MapSet) and MapSet.size(classes) == 0 do
      Mix.shell().info(
        "No icon classes found in the scanned source; the generated CSS will be empty. " <>
          "Add dynamic names with --safelist."
      )
    end

    write(sets, output_dir, classes: classes)
  end

  defp write(sets, output_dir, opts) do
    try do
      paths = Icons.write_css!(sets, Keyword.put(opts, :output_dir, output_dir))

      Mix.shell().info("Generated #{Enum.map_join(paths, ", ", &Path.relative_to_cwd/1)}")
    rescue
      error in ArgumentError -> Mix.raise(Exception.message(error))
    end
  end

  defp classes(options) do
    only = values(options, :only)
    safelist = values(options, :safelist)
    scanned? = options[:scan] || only != [] || safelist != []

    cond do
      not scanned? ->
        nil

      options[:scan] ->
        source_globs = values(options, :source)
        source_globs = if source_globs == [], do: Scanner.default_globs(), else: source_globs

        Scanner.scan(source_globs, safelist: safelist)
        |> add_classes(only)

      true ->
        MapSet.new(safelist ++ only)
    end
  end

  defp add_classes(classes, only) do
    Enum.reduce(only, classes, &MapSet.put(&2, &1))
  end

  defp values(options, key) do
    options
    |> Keyword.get_values(key)
    |> List.flatten()
    |> Enum.filter(&is_binary/1)
    |> Enum.flat_map(&String.split(&1, ",", trim: true))
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp resolve_sets(positional, options) do
    cond do
      options[:all] ->
        Icons.sets()

      positional != [] ->
        names_to_sets(positional)

      true ->
        installed =
          case Icons.css_sets() do
            [] -> Icons.installed_sets()
            css_sets -> css_sets
          end

        if installed == [] do
          Mix.raise(
            "No icon assets found in deps/. Run `mix flint.icons` first, or " <>
              "`mix deps.get` after adding an asset dependency."
          )
        end

        installed
    end
  end

  defp names_to_sets(names) do
    {sets, unknown} =
      Enum.reduce(names, {[], []}, fn name, {sets, unknown} ->
        case Icons.normalize(name) do
          nil -> {sets, unknown ++ [name]}
          set -> {sets ++ [set], unknown}
        end
      end)

    if unknown != [] do
      Mix.raise(
        "Unknown icon set(s): #{Enum.join(unknown, ", ")}. " <>
          "Available: #{Enum.map_join(Icons.sets(), ", ", &Atom.to_string/1)}."
      )
    end

    Enum.uniq(sets)
  end
end
