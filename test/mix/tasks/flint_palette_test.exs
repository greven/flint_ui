defmodule Mix.Tasks.Flint.PaletteTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  defp project do
    test_project(
      app_name: :my_app,
      files: %{
        "assets/css/app.css" => ~s(@import "tailwindcss";\n@import "./flint.css";\n)
      }
    )
  end

  test "writes the palette and imports it right after flint.css" do
    igniter = project() |> Igniter.compose_task("flint.palette", ["--primary", "indigo"])

    assert_creates(igniter, "assets/css/flint-palette.css")

    assert content(igniter, "assets/css/flint-palette.css") =~
             "--fl-color-primary-600: var(--fl-palette-indigo-600);"

    assert content(igniter, "assets/css/app.css") =~
             ~s(@import "./flint.css";\n@import "./flint-palette.css";)
  end

  test "defaults to the built-in mapping for every role" do
    igniter = project() |> Igniter.compose_task("flint.palette", [])
    css = content(igniter, "assets/css/flint-palette.css")

    for role <- ~w(primary secondary neutral success info warning error) do
      assert css =~ "--fl-color-#{role}-600:"
    end
  end

  test "the built-in warning maps to amber-400 in both schemes" do
    igniter = project() |> Igniter.compose_task("flint.palette", [])
    css = content(igniter, "assets/css/flint-palette.css")

    assert css =~ "--fl-color-warning-400: var(--fl-palette-amber-400);"

    assert css =~
             "--fl-color-warning: light-dark(\n    var(--fl-color-warning-400),\n    var(--fl-color-warning-400)"
  end

  test "pins a role to a shade from the flag value" do
    igniter = project() |> Igniter.compose_task("flint.palette", ["--warning", "amber-400"])
    css = content(igniter, "assets/css/flint-palette.css")

    assert css =~ "--fl-color-warning-400: var(--fl-palette-amber-400);"

    assert css =~
             "--fl-color-warning: light-dark(\n    var(--fl-color-warning-400),\n    var(--fl-color-warning-400)"

    refute css =~ "--fl-color-primary-600:"
  end

  test "emits a preset when --theme is given" do
    igniter =
      project()
      |> Igniter.compose_task("flint.palette", ["--primary", "indigo", "--theme", "brand"])

    assert content(igniter, "assets/css/flint-palette.css") =~ ~s([data-theme="brand"] {)
  end

  test "reports an unknown color" do
    igniter = project() |> Igniter.compose_task("flint.palette", ["--primary", "nope"])

    assert_has_issue(igniter, fn issue -> issue =~ "not in the tailwind palette" end)
  end

  test "raises computed shade contrast with --contrast aaa" do
    igniter =
      project()
      |> Igniter.compose_task("flint.palette", ["--primary", "red", "--contrast", "aaa"])

    assert content(igniter, "assets/css/flint-palette.css") =~
             "--fl-color-primary-text: light-dark(\n    var(--fl-color-primary-900),"
  end

  test "reports an invalid contrast" do
    igniter = project() |> Igniter.compose_task("flint.palette", ["--contrast", "nope"])

    assert_has_issue(igniter, fn issue -> issue =~ "Invalid --contrast" end)
  end
end
