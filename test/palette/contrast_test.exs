defmodule FlintUI.Palette.ContrastTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.Contrast

  test "the AA threshold is 4.5" do
    assert Contrast.aa() == 4.5
  end

  test "resolves contrast targets" do
    assert Contrast.target(nil) == 4.5
    assert Contrast.target(:aa) == 4.5
    assert Contrast.target(:aaa) == 7.0
    assert Contrast.target(3.0) == 3.0
  end

  test "black on white is the maximum ratio" do
    assert_in_delta Contrast.ratio("oklch(100% 0 none)", "oklch(0% 0 none)"), 21.0, 0.01
  end

  test "matches known Tailwind ratios" do
    # amber-400 on amber-950 (the warning solid combo).
    assert_in_delta Contrast.ratio("oklch(82.8% 0.189 84.429)", "oklch(27.9% 0.077 45.635)"),
                    8.73,
                    0.02

    # red-600 on red-50 (a mid-tone fill, just under AA).
    assert_in_delta Contrast.ratio("oklch(57.7% 0.245 27.325)", "oklch(97.1% 0.013 17.38)"),
                    4.36,
                    0.02
  end

  test "parses percent, bare, and none components" do
    assert is_float(Contrast.luminance("oklch(98.5% 0 none)"))
    assert is_float(Contrast.luminance("oklch(1 0 0)"))
    assert Contrast.luminance("not-a-color") == nil
    assert Contrast.ratio("#fff", "#000") == nil
  end

  test "accepts leading-dot components (minified oklch)" do
    assert_in_delta Contrast.luminance("oklch(62.7% .194 149.214)"),
                    Contrast.luminance("oklch(62.7% 0.194 149.214)"),
                    1.0e-9
  end
end
