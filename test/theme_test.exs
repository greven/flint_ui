defmodule FlintUI.ThemeTest do
  use ExUnit.Case, async: true

  alias FlintUI.Theme

  test "themes are the CSS-backed presets" do
    assert Enum.all?(Theme.themes(), &(&1.css =~ "themes/"))

    refute :default in Theme.names()
  end

  test "presets list the default first, then every theme" do
    assert Theme.presets() == [:default | Theme.names()]
    assert hd(Theme.presets()) == :default
  end
end
