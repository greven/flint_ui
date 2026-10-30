defmodule FlintUI.Palette.ColorTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.Color

  test "parses short and long hex" do
    assert {:ok, %{l: l, css: css}} = Color.parse("#fff")
    assert_in_delta l, 1.0, 0.0001
    assert css =~ "oklch("

    assert {:ok, %{css: hex_css}} = Color.parse("#1D72FE")
    assert {:ok, %{css: rgb_css}} = Color.parse("rgb(29 114 254)")
    assert hex_css == rgb_css
  end

  test "parses oklch with a percentage or a unitless lightness" do
    assert {:ok, %{l: 0.58, c: 0.2, h: 264.0}} = Color.parse("oklch(58% 0.2 264)")
    assert {:ok, %{l: 0.58}} = Color.parse("oklch(0.58 0.2 264)")
  end

  test "rejects alpha, named colors, and malformed values" do
    for value <- ["#1D72FE80", "#1D72F", "rgb(29 114 254 / 0.5)", "red", "not-a-color", ""] do
      assert Color.parse(value) == :error, "expected #{inspect(value)} to be rejected"
    end
  end
end
