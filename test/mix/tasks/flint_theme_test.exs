defmodule Mix.Tasks.Flint.ThemeTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  test "writes the theme and utility stylesheets and imports them" do
    igniter =
      test_project(
        app_name: :my_app,
        files: %{"assets/css/app.css" => ~s(@import "tailwindcss";\n)}
      )
      |> Igniter.compose_task("flint.theme", [])

    assert_creates(igniter, "assets/css/flint.css")
    assert_creates(igniter, "assets/css/flint-utilities.css")
    assert content(igniter, "assets/css/flint.css") =~ "--fl-color-primary"
    assert content(igniter, "assets/css/flint-utilities.css") =~ ".fl-stack"
    assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint.css";)
    assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint-utilities.css";)
  end

  test "--no-utilities leaves the utility layer alone" do
    igniter =
      test_project(
        app_name: :my_app,
        files: %{"assets/css/app.css" => ~s(@import "tailwindcss";\n)}
      )
      |> Igniter.compose_task("flint.theme", ["--no-utilities"])

    refute_creates(igniter, "assets/css/flint-utilities.css")
    refute content(igniter, "assets/css/app.css") =~ "flint-utilities.css"
  end

  test "overwrites existing generated stylesheets" do
    igniter =
      test_project(
        app_name: :my_app,
        files: %{
          "assets/css/flint.css" => "/* __old_theme__ */\n",
          "assets/css/flint-utilities.css" => "/* __old_utilities__ */\n"
        }
      )
      |> Igniter.compose_task("flint.theme", [])

    refute content(igniter, "assets/css/flint.css") =~ "__old_theme__"
    refute content(igniter, "assets/css/flint-utilities.css") =~ "__old_utilities__"
    assert content(igniter, "assets/css/flint.css") =~ "--fl-color-primary"
    assert content(igniter, "assets/css/flint-utilities.css") =~ ".fl-stack"
  end
end
