defmodule FlintUI.Styled.ColorTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.{Color, Contrast, Tailwind}
  alias FlintUI.Styled.Color, as: StyledColor

  @roles ~w(primary secondary success info warning error neutral)

  @vars [
    fill: "--fl-control-color",
    on_fill: "--fl-control-color-content",
    on_text: "--fl-control-text"
  ]

  @colors ~w(#1D72FE #FFE066 #111827 #22C55E #F43F5E)

  test "valid?/1 accepts roles, absolute tones, palette hues, and raw colors" do
    assert StyledColor.valid?("primary")
    assert StyledColor.valid?("inherit")
    assert StyledColor.valid?("dark")
    assert StyledColor.valid?("light")
    assert StyledColor.valid?("#1D72FE")
    assert StyledColor.valid?("rgb(29 114 254)")

    for hue <- FlintUI.Palette.hue_names() do
      assert StyledColor.valid?(hue)
    end

    refute StyledColor.valid?("crimson")
    refute StyledColor.valid?("tw:rose")
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
      assert assigns.rest.style =~ "--fl-control-color: #1D72FE"
      assert assigns.rest.style =~ "--fl-control-color-content"
      assert assigns.rest.style =~ "--fl-control-text"
      refute assigns.rest.style =~ "data-color"
    end

    test "absolute tones keep the data hook even when the entry omits them" do
      for tone <- ~w(dark light) do
        assigns =
          StyledColor.apply(%{color: tone, rest: %{}, __changed__: %{}}, @roles, @vars)

        assert assigns.data_color == tone
        assert assigns.rest == %{}
      end
    end

    test "the caller's style wins over the derived inputs" do
      assigns =
        StyledColor.apply(
          %{
            color: "#1D72FE",
            rest: %{style: "--fl-control-color-content: white"},
            __changed__: %{}
          },
          @roles,
          @vars
        )

      assert String.ends_with?(assigns.rest.style, "; --fl-control-color-content: white")
    end

    test "marks the derived assigns as changed on updates" do
      assigns = StyledColor.apply(%{color: "primary", rest: %{}, __changed__: %{}}, @roles, @vars)

      assert assigns.__changed__[:data_color]
      assert assigns.__changed__[:rest]
    end

    test "resolves a second color prop into its own hook and inputs" do
      assigns = %{
        color: "primary",
        active_color: "#1D72FE",
        rest: %{},
        __changed__: %{}
      }

      assigns =
        StyledColor.apply(
          assigns,
          @roles,
          [fill: "--fl-active-color"],
          prop: :active_color,
          data: :data_active_color
        )

      assert assigns.data_active_color == nil
      assert assigns.rest.style =~ "--fl-active-color: #1D72FE"

      assigns =
        StyledColor.apply(
          %{color: "primary", active_color: "success", rest: %{}, __changed__: %{}},
          @roles,
          [fill: "--fl-active-color"],
          prop: :active_color,
          data: :data_active_color
        )

      assert assigns.data_active_color == "success"
    end

    test "clear/2 marks a color hook absent on updates" do
      assigns = StyledColor.clear(%{rest: %{}, __changed__: %{}}, :data_active_color)

      assert assigns.data_active_color == nil
      assert assigns.__changed__[:data_active_color]
    end

    test "invalid values name the prop that failed" do
      error =
        assert_raise ArgumentError, fn ->
          StyledColor.apply(
            %{color: "primary", active_color: "not-a-color", rest: %{}, __changed__: %{}},
            @roles,
            [fill: "--fl-active-color"],
            prop: :active_color,
            data: :data_active_color
          )
        end

      assert error.message =~ "`active_color`"
    end

    test "invalid values raise with the accepted forms" do
      error =
        assert_raise ArgumentError, fn ->
          StyledColor.apply(%{color: "not-a-color", rest: %{}, __changed__: %{}}, @roles, @vars)
        end

      assert error.message =~ "primary"
      assert error.message =~ "cyan"
      assert error.message =~ "#rrggbb"
      assert error.message =~ "oklch"
    end
  end

  describe "apply_style/3" do
    test "role values keep the data hook and omit the style" do
      assigns =
        StyledColor.apply_style(
          %{color: "primary", rest: %{style: "color: red"}, __changed__: %{}},
          @roles,
          @vars
        )

      assert assigns.data_color == "primary"
      assert assigns.color_style == nil
      assert assigns.rest == %{style: "color: red"}
    end

    test "raw values leave rest alone and return the inputs as color_style" do
      assigns =
        StyledColor.apply_style(
          %{color: "#1D72FE", rest: %{style: "object-position: top"}, __changed__: %{}},
          @roles,
          @vars
        )

      assert assigns.data_color == nil
      assert assigns.rest == %{style: "object-position: top"}
      assert assigns.color_style =~ "--fl-control-color: #1D72FE"
      assert assigns.color_style =~ "--fl-control-color-content"
      assert assigns.color_style =~ "--fl-control-text"
      assert assigns.__changed__[:color_style]
    end
  end

  describe "initials_color/1" do
    test "is stable for the same name and picks a palette hue" do
      first = StyledColor.initials_color("Jane Doe")
      second = StyledColor.initials_color("Jane Doe")

      assert first == second
      assert first in (FlintUI.Palette.hue_names() -- ["gray"])
      assert StyledColor.valid?(first)
    end

    test "blank names stay on the neutral role" do
      assert StyledColor.initials_color("") == "neutral"
      assert StyledColor.initials_color("  ") == "neutral"
      assert StyledColor.initials_color(nil) == "neutral"
    end
  end

  describe "palette hues" do
    test "a hue name keeps the data hook and leaves the style alone" do
      for hue <- ~w(red orange amber yellow green cyan blue indigo purple pink gray) do
        assigns =
          StyledColor.apply(
            %{color: hue, rest: %{style: "color: red"}, __changed__: %{}},
            @roles,
            @vars
          )

        assert assigns.data_color == hue
        assert assigns.rest == %{style: "color: red"}
      end
    end

    test "a hue is distinct from the role with the same name" do
      role = StyledColor.apply(%{color: "neutral", rest: %{}, __changed__: %{}}, @roles, @vars)
      hue = StyledColor.apply(%{color: "gray", rest: %{}, __changed__: %{}}, @roles, @vars)

      assert role.data_color == "neutral"
      assert hue.data_color == "gray"
    end

    test "raw colors still write the public inputs inline" do
      assigns =
        StyledColor.apply(%{color: "#1D72FE", rest: %{}, __changed__: %{}}, @roles, @vars)

      assert assigns.data_color == nil
      assert assigns.rest.style =~ "--fl-control-color: #1D72FE"
      assert assigns.rest.style =~ "--fl-control-color-content"
    end
  end

  describe "derive/2" do
    test "derives the tinted pair for the same raw color" do
      {:ok, color} = Color.parse("#1D72FE")
      derived = StyledColor.derive("#1D72FE", color)

      assert derived.soft == "color-mix(in oklab, #1D72FE 10%, var(--fl-color-surface))"

      assert derived.soft_border ==
               "color-mix(in oklab, #1D72FE var(--fl-border-strength-soft), var(--fl-color-surface))"
    end

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
      style = StyledColor.style("#1D72FE", color, on_text: :color)

      assert style =~ "color: light-dark("
      refute style =~ "--fl-"
    end

    test "keeps the requested color as text when it already clears AA" do
      {:ok, color} = Color.parse("#111827")
      derived = StyledColor.derive("#111827", color)

      assert derived.on_text |> elem(0) == "#111827"
    end

    test "prefer_white keeps white until it falls below 3:1" do
      {:ok, lime} = Color.parse(Tailwind.shades(:lime)[600])

      assert StyledColor.derive(lime.css, lime, on_fill: :prefer_white).on_fill == Color.white()
      assert StyledColor.derive(lime.css, lime).on_fill == Color.black()
    end

    test "prefer_white falls back to black on a pale fill" do
      {:ok, pale} = Color.parse("#FDE68A")
      derived = StyledColor.derive(pale.css, pale, on_fill: :prefer_white)

      assert derived.on_fill == Color.black()
    end

    test "the single text derivation clears AA on the tinted surface" do
      for value <- @colors do
        {:ok, color} = Color.parse(value)
        derived = StyledColor.derive(value, color)

        {light_text, dark_text} = derived.on_text

        assert ratio(light_text, tint(color, Contrast.light_background())) >= 4.5
        assert ratio(dark_text, tint(color, Contrast.dark_background())) >= 4.5
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
