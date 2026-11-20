defmodule FlintUI.Palette.ExtraHuesTest do
  use ExUnit.Case, async: false

  alias FlintUI.Palette
  alias FlintUI.Styled.Color, as: StyledColor

  setup do
    previous = Application.get_env(:flint_ui, :extra_hues)

    Application.put_env(:flint_ui, :extra_hues, [:brand, "accent", :primary, :pink, :brand])

    on_exit(fn ->
      if previous do
        Application.put_env(:flint_ui, :extra_hues, previous)
      else
        Application.delete_env(:flint_ui, :extra_hues)
      end
    end)
  end

  test "extra hues are accepted as presence hooks" do
    assert Palette.extra_hues() == [:brand, :accent]
    assert Palette.extra_hue_names() == ["brand", "accent"]
    assert "brand" in Palette.known_hue_names()
    assert "pink" in Palette.known_hue_names()

    for hue <- ~w(brand accent) do
      assigns =
        StyledColor.apply(
          %{color: hue, rest: %{style: "color: red"}, __changed__: %{}},
          ~w(primary),
          []
        )

      assert assigns.data_color == hue
      assert assigns.rest == %{style: "color: red"}
    end
  end

  test "reserved role names and canonical hues are not extra hues" do
    refute :primary in Palette.extra_hues()
    refute :pink in Palette.extra_hues()
  end

  test "unknown names still raise" do
    assert_raise ArgumentError, fn ->
      StyledColor.apply(%{color: "nope", rest: %{}, __changed__: %{}}, ~w(primary), [])
    end
  end
end
