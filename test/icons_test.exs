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
    assert Icons.normalize("simple-icons") == :simple_icons
    assert Icons.normalize("flags") == :flag_icons
    assert Icons.normalize("nope") == nil
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
               "si-github",
               "flag-pt-square"
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

  test "ships a plugin for every set" do
    assert Icons.plugin_source(:heroicons) =~ "deps/heroicons/optimized"
    assert Icons.plugin_source(:lucide_icons) =~ "deps/lucide_icons/icons"
    assert Icons.plugin_source(:simple_icons) =~ "deps/simple_icons/icons"
    assert Icons.plugin_source(:flag_icons) =~ "deps/flag_icons/flags"
  end

  test "reports a missing asset directory" do
    assert_raise ArgumentError, ~r/no SVG files found/, fn ->
      Icons.generate_css(:lucide_icons, source_dir: Path.join(@fixtures, "missing"))
    end
  end
end
