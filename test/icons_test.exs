defmodule FlintUI.IconsTest do
  use ExUnit.Case, async: true

  alias FlintUI.Icons
  alias FlintUI.Icons.Scanner

  @fixtures Path.expand("fixtures/icons", __DIR__)

  test "normalizes set names and aliases" do
    assert Icons.normalize("heroicons") == :heroicons
    assert Icons.normalize("hero") == :heroicons
    assert Icons.normalize("lucide") == :lucide_icons
    assert Icons.normalize("lucide_icons") == :lucide_icons
    assert Icons.normalize("phosphor") == :phosphor_icons
    assert Icons.normalize("phosphor-icons") == :phosphor_icons
    assert Icons.normalize("simple-icons") == :simple_icons
    assert Icons.normalize("flags") == :flag_icons
    assert Icons.normalize("nope") == nil
  end

  test "source_url points at the pinned tag, or the repo root when untagged" do
    assert Icons.source_url(:heroicons) ==
             "https://github.com/tailwindlabs/heroicons/tree/v2.2.0"

    assert Icons.source_url(:lucide_icons) ==
             "https://github.com/lucide-icons/lucide/tree/1.72.0"

    assert Icons.source_url(:phosphor_icons) == "https://github.com/phosphor-icons/core"

    assert Icons.source_url(:simple_icons) ==
             "https://github.com/simple-icons/simple-icons/tree/16.37.0"

    for set <- Icons.sets() do
      assert String.starts_with?(Icons.source_url(set), Icons.get!(set).source)
    end
  end

  test "version_label shows the tag, or latest when the link is the repo root" do
    assert Icons.version_label(:heroicons) == "v2.2.0"
    assert Icons.version_label(:lucide_icons) == "1.72.0"
    assert Icons.version_label(:simple_icons) == "16.37.0"
    assert Icons.version_label(:phosphor_icons) == "latest"

    for set <- Icons.sets() do
      tag? = Icons.source_url(set) != Icons.get!(set).source

      assert Icons.version_label(set) == if(tag?, do: Icons.get!(set).version, else: "latest")
    end
  end

  test "every set carries the metadata the CLI and the docs table render" do
    for set <- Icons.sets() do
      meta = Icons.get!(set)

      assert is_binary(meta.cli) and meta.cli != ""
      assert is_binary(meta.classes) and meta.classes != ""
      assert is_binary(meta.label) and meta.label != ""
      assert meta.source =~ ~r{\Ahttps://}
    end

    cli_names = Enum.map(Icons.sets(), &Icons.cli_name/1)

    assert Enum.uniq(cli_names) == cli_names
    assert Icons.cli_name(:lucide_icons) == "lucide"
    assert Icons.cli_name(:flag_icons) == "flags"
  end

  test "generates Lucide CSS with the component size hook" do
    css = Icons.generate_css(:lucide_icons, source_dir: Path.join(@fixtures, "lucide"))

    assert css =~ ".lucide-house"
    assert css =~ "width: var(--fl-icon-size, 1.5rem)"
    assert css =~ "mask: var(--lucide-house) center / contain no-repeat"
    assert css =~ "background-color: currentColor"

    # The plugin normalizes the upstream stroke and drops the fixed box.
    assert css =~ "stroke-width%3D%221.5%22"
    refute css =~ "stroke-width%3D%222%22"
    refute css =~ "width%3D%2224%22"
  end

  test "filters a set to the supplied classes" do
    css =
      Icons.generate_css(:lucide_icons,
        source_dir: Path.join(@fixtures, "lucide"),
        classes: MapSet.new(["lucide-house"])
      )

    assert css =~ ".lucide-house"
    refute css =~ ".lucide-wifi"
  end

  test "filters variants and flag shapes independently" do
    heroicons =
      Icons.generate_css(:heroicons,
        source_dir: Path.join(@fixtures, "heroicons/optimized"),
        classes: MapSet.new(["hero-x-mark-mini"])
      )

    assert heroicons =~ ".hero-x-mark-mini"
    refute heroicons =~ ".hero-x-mark {"
    refute heroicons =~ ".hero-x-mark-solid"
    refute heroicons =~ ".hero-x-mark-micro"

    flags =
      Icons.generate_css(:flag_icons,
        source_dir: Path.join(@fixtures, "flags"),
        classes: MapSet.new(["flag-pt-square"])
      )

    assert flags =~ ".flag-pt-square"
    refute flags =~ ~r/\.flag-pt \{/
  end

  test "scans source files for literal icon classes" do
    classes =
      Scanner.scan([Path.join(@fixtures, "source/*.txt"), Path.join(@fixtures, "source/*.heex")])

    assert classes ==
             MapSet.new([
               "lucide-house",
               "lucide-wifi",
               "hero-x-mark-mini",
               "ph-house-duotone",
               "si-github",
               "flag-pt-square",
               "flag-us",
               "flag-br-square",
               "flag-de"
             ])
  end

  test "the scanner can carry dynamic names through a safelist" do
    classes =
      Scanner.scan(Path.join(@fixtures, "source/*.txt"), safelist: ["lucide-star"])

    assert MapSet.member?(classes, "lucide-star")
    assert MapSet.member?(classes, "lucide-house")
  end

  test "detects the plain CSS sets from app.css imports" do
    dir = Path.join(System.tmp_dir!(), "flint-icons-#{System.unique_integer([:positive])}")
    path = Path.join(dir, "app.css")
    File.mkdir_p!(dir)

    File.write!(path, """
    @import "./flint-lucide.css";
    @import "./flint-flags.css";
    """)

    assert Icons.css_sets(path) == [:lucide_icons, :flag_icons]

    File.rm_rf!(dir)
  end

  test "generates every Heroicons variant with its intended size" do
    css = Icons.generate_css(:heroicons, source_dir: Path.join(@fixtures, "heroicons/optimized"))

    assert css =~ ".hero-x-mark"
    assert css =~ ".hero-x-mark-solid"
    assert css =~ ".hero-x-mark-mini"
    assert css =~ ".hero-x-mark-micro"

    assert css =~ "width: var(--fl-icon-size, 1.5rem)"
    assert css =~ "width: var(--fl-icon-size, 1.25rem)"
    assert css =~ "width: var(--fl-icon-size, 1rem)"
  end

  test "generates every Phosphor weight from one checkout" do
    css = Icons.generate_css(:phosphor_icons, source_dir: Path.join(@fixtures, "phosphor/assets"))

    for class <-
          ~w(ph-house ph-house-thin ph-house-light ph-house-bold ph-house-fill ph-house-duotone) do
      assert css =~ ".#{class} {"
    end

    assert css =~ ".ph-wifi-high"
    assert css =~ "width: var(--fl-icon-size, 1.5rem)"
    assert css =~ "mask: var(--ph-house) center / contain no-repeat"

    # The duotone second tone survives as alpha in the mask.
    assert css =~ "opacity%3D%220.2%22"
    refute css =~ "width%3D%22256%22"
  end

  test "filters Phosphor weights independently" do
    css =
      Icons.generate_css(:phosphor_icons,
        source_dir: Path.join(@fixtures, "phosphor/assets"),
        classes: MapSet.new(["ph-house-duotone"])
      )

    assert css =~ ".ph-house-duotone {"
    refute css =~ ".ph-house {"
    refute css =~ ".ph-house-fill"
  end

  test "generates Simple Icons CSS" do
    css = Icons.generate_css(:simple_icons, source_dir: Path.join(@fixtures, "simple-icons"))

    assert css =~ ".si-github"
    assert css =~ "width: var(--fl-icon-size, 1.25rem)"
    assert css =~ "fill%3D%22currentColor%22"
    refute css =~ "fill%3D%22%23181717%22"
  end

  test "generates both flag shapes" do
    css = Icons.generate_css(:flag_icons, source_dir: Path.join(@fixtures, "flags"))

    assert css =~ ".flag-pt"
    assert css =~ ".flag-pt-square"
    assert css =~ "aspect-ratio: 4 / 3"
    assert css =~ "aspect-ratio: 1"
    assert css =~ "width: var(--fl-flag-size, 1.5rem)"
  end

  test "copies flag SVGs to a public directory" do
    dir = Path.join(System.tmp_dir!(), "flint-flags-#{System.unique_integer([:positive])}")

    paths =
      Icons.copy_flag_assets!(
        source: Path.join(@fixtures, "flags"),
        dest: dir
      )

    assert length(paths) == 4
    assert File.exists?(Path.join(dir, "pt.svg"))
    assert File.exists?(Path.join(dir, "pt-square.svg"))
    assert File.exists?(Path.join(dir, "us.svg"))
    assert File.exists?(Path.join(dir, "us-square.svg"))

    File.rm_rf!(dir)
  end

  test "copies only the requested flag codes" do
    dir = Path.join(System.tmp_dir!(), "flint-flags-#{System.unique_integer([:positive])}")

    paths =
      Icons.copy_flag_assets!(
        source: Path.join(@fixtures, "flags"),
        dest: dir,
        only: ["PT"]
      )

    assert length(paths) == 2
    assert File.exists?(Path.join(dir, "pt.svg"))
    assert File.exists?(Path.join(dir, "pt-square.svg"))
    refute File.exists?(Path.join(dir, "us.svg"))

    File.rm_rf!(dir)
  end

  test "ships a plugin for every set" do
    assert Icons.plugin_source(:heroicons) =~ "deps/heroicons/optimized"
    assert Icons.plugin_source(:lucide_icons) =~ "deps/lucide_icons/icons"
    assert Icons.plugin_source(:phosphor_icons) =~ "deps/phosphor_icons/assets"
    assert Icons.plugin_source(:simple_icons) =~ "deps/simple_icons/icons"
    assert Icons.plugin_source(:flag_icons) =~ "deps/flag_icons/flags"
  end

  test "reports a missing asset directory" do
    assert_raise ArgumentError, ~r/no SVG files found/, fn ->
      Icons.generate_css(:lucide_icons, source_dir: Path.join(@fixtures, "missing"))
    end
  end
end
