defmodule Mix.Tasks.Flint.ThemeTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  test "writes the theme stylesheet and imports it" do
    igniter =
      test_project(
        app_name: :my_app,
        files: %{"assets/css/app.css" => ~s(@import "tailwindcss";\n)}
      )
      |> Igniter.compose_task("flint.theme", [])

    assert_creates(igniter, "assets/css/flint.css")
    assert content(igniter, "assets/css/flint.css") =~ "--fl-color-primary"
    assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint.css";)
  end

  test "overwrites an existing theme stylesheet" do
    igniter =
      test_project(app_name: :my_app, files: %{"assets/css/flint.css" => "/* __old__ */\n"})
      |> Igniter.compose_task("flint.theme", [])

    refute content(igniter, "assets/css/flint.css") =~ "__old__"
    assert content(igniter, "assets/css/flint.css") =~ "--fl-color-primary"
  end
end
