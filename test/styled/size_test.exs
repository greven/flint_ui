defmodule FlintUI.Styled.SizeTest do
  use ExUnit.Case, async: true

  alias FlintUI.Styled.Size

  test "keeps scale values and returns nil for custom sizes" do
    assert Size.scale("xs") == "xs"
    assert Size.scale("xl") == "xl"
    assert Size.scale(40) == nil
    assert Size.scale("2.5rem") == nil
  end

  test "converts numeric pixels and numeric strings to rem" do
    assert Size.style(40, "--fl-icon-size") == "--fl-icon-size: 2.5rem"
    assert Size.style("32", "--fl-flag-size") == "--fl-flag-size: 2rem"
    assert Size.style("2.5rem", "--fl-flag-size") == nil
  end

  test "keeps a caller style after the generated declaration" do
    assert Size.put_style(%{}, "--fl-icon-size: 2.5rem") == %{
             style: "--fl-icon-size: 2.5rem"
           }

    assert Size.put_style(%{style: "opacity: 0.5"}, "--fl-icon-size: 2.5rem") == %{
             style: "--fl-icon-size: 2.5rem; opacity: 0.5"
           }

    assert Size.put_style(%{style: ["opacity: 0.5", "color: red"]}, "--fl-icon-size: 2.5rem") ==
             %{
               style: "--fl-icon-size: 2.5rem; opacity: 0.5; color: red"
             }
  end
end
