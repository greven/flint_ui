defmodule FlintUI.Icons do
  @moduledoc """
  Icon and flag asset sets installed by `mix flint.icons`.

  FlintUI does not ship icon assets. The supported sets are downloaded as
  asset-only dependencies and are exposed either through a Tailwind plugin or
  as generated plain CSS. Either way, the component contract is unchanged:
  `name` is applied verbatim as a class.

  The generated class names match the upstream conventions:

    * Heroicons — `hero-<name>`, `hero-<name>-solid`, `hero-<name>-mini`,
      `hero-<name>-micro`
    * Lucide — `lucide-<name>`
    * Phosphor — `ph-<name>`, `ph-<name>-thin`, `ph-<name>-light`,
      `ph-<name>-bold`, `ph-<name>-fill`, `ph-<name>-duotone`
    * Simple Icons — `si-<name>`
    * Flag Icons — `flag-<country>` and `flag-<country>-square`

  Phosphor ships every weight as its own SVG geometry, not as a configurable
  stroke. All six weights are installed from one checkout and share the
  upstream file names, so `fill` and `duotone` are separate classes rather than
  a modifier on `ph-<name>`.
  """

  @sets %{
    heroicons: %{
      dep: :heroicons,
      dep_spec:
        {:heroicons,
         [
           github: "tailwindlabs/heroicons",
           tag: "v2.2.0",
           sparse: "optimized",
           app: false,
           compile: false,
           depth: 1
         ]},
      label: "Heroicons",
      cli: "heroicons",
      license: "MIT",
      source: "https://github.com/tailwindlabs/heroicons",
      version: "v2.2.0",
      classes: "hero-<name>, hero-<name>-solid, hero-<name>-mini, hero-<name>-micro",
      plugin: "heroicons.js",
      css: "flint-heroicons.css",
      dir: "optimized"
    },
    lucide_icons: %{
      dep: :lucide_icons,
      dep_spec:
        {:lucide_icons,
         [
           github: "lucide-icons/lucide",
           tag: "1.72.0",
           sparse: "icons",
           app: false,
           compile: false,
           depth: 1
         ]},
      label: "Lucide",
      cli: "lucide",
      license: "ISC",
      source: "https://github.com/lucide-icons/lucide",
      version: "1.72.0",
      classes: "lucide-<name>",
      plugin: "lucide.js",
      css: "flint-lucide.css",
      dir: "icons"
    },
    phosphor_icons: %{
      dep: :phosphor_icons,
      dep_spec:
        {:phosphor_icons,
         [
           github: "phosphor-icons/core",
           ref: "2b75f3ad12b420c9504ef05df8d2564a28f8500e",
           sparse: "assets",
           app: false,
           compile: false,
           depth: 1
         ]},
      label: "Phosphor",
      cli: "phosphor",
      license: "MIT",
      source: "https://github.com/phosphor-icons/core",
      version: "2.1.1",
      classes: "ph-<name> (regular) and ph-<name>-{thin,light,bold,fill,duotone}",
      plugin: "phosphor.js",
      css: "flint-phosphor.css",
      dir: "assets"
    },
    simple_icons: %{
      dep: :simple_icons,
      dep_spec:
        {:simple_icons,
         [
           github: "simple-icons/simple-icons",
           tag: "16.37.0",
           sparse: "icons",
           app: false,
           compile: false,
           depth: 1
         ]},
      label: "Simple Icons",
      cli: "simple_icons",
      license: "CC0-1.0",
      source: "https://github.com/simple-icons/simple-icons",
      version: "16.37.0",
      classes: "si-<name>",
      plugin: "simple-icons.js",
      css: "flint-simple-icons.css",
      dir: "icons"
    },
    flag_icons: %{
      dep: :flag_icons,
      dep_spec:
        {:flag_icons,
         [
           github: "lipis/flag-icons",
           tag: "v7.6.0",
           sparse: "flags",
           app: false,
           compile: false,
           depth: 1
         ]},
      label: "Flag Icons",
      cli: "flags",
      license: "MIT",
      source: "https://github.com/lipis/flag-icons",
      version: "v7.6.0",
      classes: "flag-<country>, flag-<country>-square",
      plugin: "flag-icons.js",
      css: "flint-flags.css",
      dir: "flags"
    }
  }

  @aliases %{
    "hero" => :heroicons,
    "heroicons" => :heroicons,
    "lucide" => :lucide_icons,
    "lucide_icons" => :lucide_icons,
    "lucide-icons" => :lucide_icons,
    "phosphor" => :phosphor_icons,
    "phosphor_icons" => :phosphor_icons,
    "phosphor-icons" => :phosphor_icons,
    "simple" => :simple_icons,
    "simple_icons" => :simple_icons,
    "simple-icons" => :simple_icons,
    "flag" => :flag_icons,
    "flags" => :flag_icons,
    "flag_icons" => :flag_icons,
    "flag-icons" => :flag_icons
  }

  @type set ::
          :heroicons | :lucide_icons | :phosphor_icons | :simple_icons | :flag_icons

  @doc "Every supported set, in a stable order."
  @spec sets() :: [set()]
  def sets, do: [:heroicons, :lucide_icons, :phosphor_icons, :simple_icons, :flag_icons]

  @doc "Returns a set's metadata."
  @spec get!(set()) :: map()
  def get!(set) when is_map_key(@sets, set), do: Map.fetch!(@sets, set)
  def get!(set), do: raise(ArgumentError, "unknown icon set: #{inspect(set)}")

  @doc """
  The upstream page for exactly the assets the task installs.

  A tag-pinned set links to its tag. A set pinned to a commit has no tag to
  link to, so it links to the repository root and is labelled "latest" by
  `version_label/1`.
  """
  @spec source_url(set()) :: String.t()
  def source_url(set) do
    meta = get!(set)
    opts = elem(meta.dep_spec, 1)

    if tag = opts[:tag], do: "#{meta.source}/tree/#{tag}", else: meta.source
  end

  @doc """
  The version label the docs table shows beside the source link.

  Tag-pinned sets show their tag; a set that links to the repository root has
  no tag to name and is labelled `latest`.
  """
  @spec version_label(set()) :: String.t()
  def version_label(set) do
    meta = get!(set)

    if source_url(set) == meta.source, do: "latest", else: meta.version
  end

  @doc "The `mix flint.icons` name for a set."
  @spec cli_name(set()) :: String.t()
  def cli_name(set), do: get!(set).cli

  @doc "Normalizes a CLI name or alias to a set."
  @spec normalize(String.t() | atom()) :: set() | nil
  def normalize(name) when is_atom(name), do: normalize(Atom.to_string(name))

  def normalize(name) when is_binary(name) do
    Map.get(@aliases, name |> String.trim() |> String.downcase())
  end

  def normalize(_name), do: nil

  @doc "The vendor plugin filename for a set."
  def plugin_file(set), do: get!(set).plugin

  @doc "The generated CSS filename for a set."
  def css_file(set), do: get!(set).css

  @doc "The `@plugin` line a host app needs in its stylesheet."
  def plugin_import(set) do
    ~s(@plugin "../vendor/#{Path.rootname(plugin_file(set))}";)
  end

  @doc "The `@import` line a host app needs in its stylesheet."
  def css_import(set), do: ~s(@import "./#{css_file(set)}";)

  @doc "A placeholder written before the plain CSS is generated."
  def css_stub(set) do
    meta = get!(set)

    """
    /* Generated by `mix flint.icons.generate` from #{meta.label} #{meta.version}.
     * Run the task after `mix deps.get`; do not edit this file by hand. */
    """
  end

  @doc "The Tailwind vendor plugin source for a set."
  def plugin_source(set) do
    Path.join([:code.priv_dir(:flint_ui), "templates", "icons", plugin_file(set)])
    |> File.read!()
  end

  @doc """
  Generates the plain CSS for a set.

  Options:

    * `:source_dir` — override the asset directory (useful in tests)
    * `:output_dir` — used by `write_css!/2`
  """
  @spec generate_css(set(), keyword()) :: String.t()
  def generate_css(set, opts \\ []) do
    meta = get!(set)
    dir = opts[:source_dir] || Path.join(deps_path(meta.dep), meta.dir)
    rules = rules(set, dir, opts[:classes])

    """
    /* Generated by `mix flint.icons.generate` from #{meta.label} #{meta.version}.
     * Source: #{meta.source} (#{meta.license}).
     * Do not edit by hand; re-run the task after updating the dependency. */
    @layer components {
    #{indent(Enum.join(rules, "\n\n"), 2)}
    }
    """
  end

  @doc "Writes the generated CSS for each set and returns the written paths."
  @spec write_css!([set()], keyword()) :: [Path.t()]
  def write_css!(sets, opts \\ []) do
    output_dir = opts[:output_dir] || "assets/css"
    File.mkdir_p!(output_dir)

    Enum.map(sets, fn set ->
      path = Path.join(output_dir, css_file(set))
      File.write!(path, generate_css(set, opts))
      path
    end)
  end

  @doc "The sets whose asset dependencies are present in the project."
  def installed_sets do
    Enum.filter(sets(), &File.dir?(deps_path(&1)))
  end

  @doc """
  The sets whose generated CSS is imported by `assets/css/app.css`.

  The compiler uses this to keep regenerating a set even when its generated CSS
  is gitignored and absent from a fresh checkout.
  """
  def css_sets(app_css \\ "assets/css/app.css") do
    case File.read(app_css) do
      {:ok, content} ->
        Enum.filter(sets(), &String.contains?(content, css_import(&1)))

      _ ->
        []
    end
  end

  @doc "The checkout directory for a set's asset dependency."
  @spec deps_path(set() | atom()) :: Path.t()
  def deps_path(set) when is_atom(set) do
    dep = if Map.has_key?(@sets, set), do: get!(set).dep, else: set

    # Use the checkout root instead of `deps_paths/0`: a `sparse:` git dep
    # reports its sparse subdirectory as its path, which would double `dir`.
    Path.join(Mix.Project.deps_path(), Atom.to_string(dep))
  end

  @doc "The installed Flag Icons SVG directory."
  def flag_source_dir, do: Path.join(deps_path(:flag_icons), "flags")

  @doc "The default public directory for copied flag SVGs."
  def flag_public_dir, do: Path.join(["priv", "static", "images", "flags"])

  @doc """
  Copies Flag Icons SVGs into a public directory.

  The 4:3 SVGs become `<code>.svg` and the 1:1 SVGs become `<code>-square.svg`,
  matching the URL the Flag component builds. Pass `:only` to copy a subset and
  `:source`/`:dest` to override the directories. Returns the copied paths.
  """
  @spec copy_flag_assets!(keyword()) :: [Path.t()]
  def copy_flag_assets!(opts \\ []) do
    source = opts[:source] || flag_source_dir()
    dest = opts[:dest] || flag_public_dir()
    only = opts[:only] |> List.wrap() |> Enum.map(&normalize_code/1) |> MapSet.new()

    unless File.dir?(source) do
      raise ArgumentError,
            "Flag Icons assets not found at #{source}. Run `mix deps.get` first."
    end

    for {subdir, suffix} <- [{"4x3", ""}, {"1x1", "-square"}],
        file <- Path.wildcard(Path.join([source, subdir, "*.svg"])),
        code = Path.basename(file, ".svg"),
        copy?(code, only) do
      target = Path.join(dest, "#{code}#{suffix}.svg")
      File.mkdir_p!(Path.dirname(target))
      File.cp!(file, target)
      target
    end
  end

  defp copy?(code, only), do: MapSet.size(only) == 0 or MapSet.member?(only, code)

  defp normalize_code(code) do
    code |> to_string() |> String.trim() |> String.downcase()
  end

  ## Rules

  defp rules(:heroicons, dir, classes) do
    variants()
    |> Enum.flat_map(fn {variant, path, size} ->
      dir
      |> Path.join(path)
      |> svg_files()
      |> Enum.flat_map(fn {name, file} ->
        class = if variant == :outline, do: "hero-#{name}", else: "hero-#{name}-#{variant}"

        if keep?(class, classes), do: [icon_rule(class, File.read!(file), size)], else: []
      end)
    end)
  end

  defp rules(:lucide_icons, dir, classes) do
    dir
    |> svg_files()
    |> Enum.flat_map(fn {name, file} ->
      class = "lucide-#{name}"

      if keep?(class, classes),
        do: [icon_rule(class, file |> File.read!() |> clean_lucide(), "1.5rem")],
        else: []
    end)
  end

  defp rules(:phosphor_icons, dir, classes) do
    phosphor_weights()
    |> Enum.flat_map(fn weight ->
      dir
      |> Path.join(weight)
      |> svg_files()
      |> Enum.flat_map(fn {name, file} ->
        # Upstream file names already carry the weight suffix ("acorn.svg" vs
        # "acorn-duotone.svg"), so the class is the upstream file name.
        class = "ph-#{name}"

        if keep?(class, classes),
          do: [icon_rule(class, file |> File.read!() |> clean_phosphor(), "1.5rem")],
          else: []
      end)
    end)
  end

  defp rules(:simple_icons, dir, classes) do
    dir
    |> svg_files()
    |> Enum.flat_map(fn {name, file} ->
      class = "si-#{name}"

      if keep?(class, classes),
        do: [icon_rule(class, file |> File.read!() |> clean_simple_icon(), "1.25rem")],
        else: []
    end)
  end

  defp rules(:flag_icons, dir, classes) do
    for {shape, subdir, aspect} <- [{"", "4x3", "4 / 3"}, {"-square", "1x1", "1"}] do
      dir
      |> Path.join(subdir)
      |> svg_files()
      |> Enum.flat_map(fn {name, file} ->
        class = "flag-#{name}#{shape}"

        if keep?(class, classes),
          do: [flag_rule(class, File.read!(file), aspect)],
          else: []
      end)
    end
    |> List.flatten()
  end

  defp keep?(_class, nil), do: true
  defp keep?(class, %MapSet{} = classes), do: MapSet.member?(classes, class)
  defp keep?(class, classes), do: class in classes

  defp variants do
    [
      {:outline, "24/outline", "1.5rem"},
      {:solid, "24/solid", "1.5rem"},
      {:mini, "20/solid", "1.25rem"},
      {:micro, "16/solid", "1rem"}
    ]
  end

  defp phosphor_weights, do: ~w(regular thin light bold fill duotone)

  defp icon_rule(class, svg, size) do
    """
    .#{class} {
      --#{class}: url('data:image/svg+xml;utf8,#{encode_svg(svg)}');
      -webkit-mask: var(--#{class}) center / contain no-repeat;
      mask: var(--#{class}) center / contain no-repeat;
      background-color: currentColor;
      display: inline-block;
      width: var(--fl-icon-size, #{size});
      height: var(--fl-icon-size, #{size});
      vertical-align: middle;
    }
    """
  end

  defp flag_rule(class, svg, aspect) do
    """
    .#{class} {
      --#{class}: url('data:image/svg+xml;utf8,#{encode_svg(svg)}');
      background-image: var(--#{class});
      background-repeat: no-repeat;
      background-size: cover;
      background-position: center;
      vertical-align: middle;
      display: inline-block;
      aspect-ratio: #{aspect};
      width: var(--fl-flag-size, 1.5rem);
    }
    """
  end

  ## SVG helpers

  defp svg_files(dir) do
    files = Path.wildcard(Path.join(dir, "*.svg")) |> Enum.sort()

    if files == [] do
      raise ArgumentError,
            "no SVG files found in #{Path.relative_to_cwd(dir)}. " <>
              "Run `mix deps.get` before generating icon CSS."
    end

    Enum.map(files, fn file -> {Path.basename(file, ".svg"), file} end)
  end

  defp clean_lucide(svg) do
    svg
    |> strip_newlines()
    |> String.replace(~r/\s(?:width|height)="24"/, "")
    |> String.replace(~r/stroke-width="2"/, ~s(stroke-width="1.5"))
    |> String.replace(~r/stroke="[^"]+"/, ~s(stroke="currentColor"))
  end

  # Phosphor already inherits `fill="currentColor"` from the root element and
  # carries its second tone as a path-level `opacity`, which the mask keeps as
  # alpha. Only normalize the box and any hard-coded fill.
  defp clean_phosphor(svg) do
    svg
    |> strip_newlines()
    |> String.replace(~r/\s(?:width|height)="\d+"/, "")
    |> String.replace(~r/fill="[^"]+"/, ~s(fill="currentColor"))
  end

  defp clean_simple_icon(svg) do
    svg
    |> strip_newlines()
    |> String.replace(~r/fill="[^"]+"/, ~s(fill="currentColor"))
  end

  defp strip_newlines(svg), do: String.replace(svg, ~r/\r?\n|\r/, "")

  defp encode_svg(svg), do: URI.encode(svg, &URI.char_unreserved?/1)

  defp indent(text, spaces) do
    prefix = String.duplicate(" ", spaces)

    text
    |> String.split("\n")
    |> Enum.map_join("\n", &(prefix <> &1))
  end
end
