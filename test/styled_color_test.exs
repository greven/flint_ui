defmodule FlintUI.Styled.ColorTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.{Color, Contrast}
  alias FlintUI.Styled.Color, as: StyledColor

  @roles ~w(primary secondary success info warning error neutral)

  @vars [
    fill: "--fl-button-color",
    on_fill: "--fl-button-color-foreground",
    on_page: "--fl-button-text",
    on_tint: "--fl-button-soft-text"
  ]

  @colors ~w(#1D72FE #FFE066 #111827 #22C55E #F43F5E)

  test "valid?/1 accepts roles and raw colors" do
    assert StyledColor.valid?("primary")
    assert StyledColor.valid?("inherit")
    assert StyledColor.valid?("#1D72FE")
    assert StyledColor.valid?("rgb(29 114 254)")
    refute StyledColor.valid?("nope")
    refute StyledColor.valid?(nil)
  end

  describe "apply/3" do
    test "role values keep the data hook and leave the style alone" do
      assigns =
        StyledColor.apply(
          %{color: "primary", rest: %{style: "color: red"}, __changed__: %{}},
          @roles,
          @vars
        )

      assert assigns.data_color == "primary"
      assert assigns.rest == %{style: "color: red"}
    end

    test "raw values drop the data hook and set every color input" do
      assigns = StyledColor.apply(%{color: "#1D72FE", rest: %{}, __changed__: %{}}, @roles, @vars)

      assert assigns.data_color == nil
      assert assigns.rest.style =~ "--fl-button-color: #1D72FE"
      assert assigns.rest.style =~ "--fl-button-color-foreground"
      assert assigns.rest.style =~ "--fl-button-text"
      assert assigns.rest.style =~ "--fl-button-soft-text"
      refute assigns.rest.style =~ "data-color"
    end

    test "the caller's style wins over the derived inputs" do
      assigns =
        StyledColor.apply(
          %{
            color: "#1D72FE",
            rest: %{style: "--fl-button-color-foreground: white"},
            __changed__: %{}
          },
          @roles,
          @vars
        )

      assert String.ends_with?(assigns.rest.style, "; --fl-button-color-foreground: white")
    end

    test "marks the derived assigns as changed on updates" do
      assigns = StyledColor.apply(%{color: "primary", rest: %{}, __changed__: %{}}, @roles, @vars)

      assert assigns.__changed__[:data_color]
      assert assigns.__changed__[:rest]
    end

    test "invalid values raise with the accepted forms" do
      error =
        assert_raise ArgumentError, fn ->
          StyledColor.apply(%{color: "not-a-color", rest: %{}, __changed__: %{}}, @roles, @vars)
        end

      assert error.message =~ "primary"
      assert error.message =~ "#rrggbb"
      assert error.message =~ "oklch"
    end
  end

  describe "derive/2" do
    test "uses the exact fill and the best available label" do
      {:ok, color} = Color.parse("#1D72FE")
      derived = StyledColor.derive("#1D72FE", color)

      assert derived.fill == "#1D72FE"
      assert derived.on_fill == Color.black()

      assert Contrast.ratio(color.css, derived.on_fill) >=
               Contrast.ratio(color.css, Color.white())
    end

    test "maps a semantic output onto the `color` property when requested" do
      {:ok, color} = Color.parse("#1D72FE")
      style = StyledColor.style("#1D72FE", color, on_page: :color)

      assert style =~ "color: light-dark("
      refute style =~ "--fl-"
    end

    test "keeps the requested color as text when it already clears AA" do
      {:ok, color} = Color.parse("#111827")
      derived = StyledColor.derive("#111827", color)

      assert derived.on_page |> elem(0) == "#111827"
    end

    test "text and tinted labels clear AA in both schemes" do
      for value <- @colors do
        {:ok, color} = Color.parse(value)
        derived = StyledColor.derive(value, color)

        {light_page, dark_page} = derived.on_page
        {light_tint, dark_tint} = derived.on_tint

        assert ratio(light_page, Contrast.light_background()) >= 4.5
        assert ratio(dark_page, Contrast.dark_background()) >= 4.5

        assert ratio(light_tint, tint(color, Contrast.light_background())) >= 4.5
        assert ratio(dark_tint, tint(color, Contrast.dark_background())) >= 4.5
      end
    end
  end

  # The derived value is either the exact color or a color-mix toward black or
  # white. Resolve the mix with the same oklab math the palette tooling uses.
  defp ratio(css, background) do
    case Regex.run(~r/^color-mix\(in oklab, (.+), (oklch\([^)]*\)) (\d+)%\)$/, css) do
      [_, fill, endpoint, percent] ->
        mixed = Contrast.mix(endpoint, fill, String.to_integer(percent) / 100)
        Contrast.ratio(mixed, background)

      nil ->
        {:ok, color} = Color.parse(css)
        Contrast.ratio(color.css, background)
    end
  end

  defp tint(color, background), do: Contrast.mix(color.css, background, 0.15)
end
