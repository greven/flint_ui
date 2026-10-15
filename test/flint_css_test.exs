defmodule FlintUI.FlintCSSTest do
  use ExUnit.Case, async: true

  setup_all do
    %{css: FlintUI.Generator.theme_source()}
  end

  test "defines prefixed tokens with automatic light/dark", %{css: css} do
    assert css =~ "color-scheme: light dark;"
    assert css =~ "--fl-color-primary: light-dark("
    assert css =~ "--fl-radius-md:"
    assert css =~ "--fl-font-sans:"
  end

  test "supports manual and custom themes through data-theme", %{css: css} do
    assert css =~ ~s([data-theme="light"])
    assert css =~ ~s([data-theme="dark"])
    assert css =~ ~s([data-theme="pastel"])
  end

  test "styles each component behind its wrapper hook", %{css: css} do
    assert css =~ "@layer components {"
    assert css =~ ~s([data-element="button"][data-variant])
    assert css =~ ~s([data-element="toggle"][data-variant])
    assert css =~ ~s([data-element="loading"][data-size])
    assert css =~ ~s([data-element="icon"][data-size])
    assert css =~ ~s([data-element="collapsible"][data-collapsible])
  end
end
