defmodule Mix.Tasks.Flint.IconsTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  defp run(args, app_css \\ ~s(@import "tailwindcss";\n)) do
    test_project(
      app_name: :my_app,
      files: %{"assets/css/app.css" => app_css}
    )
    |> Igniter.compose_task("flint.icons", args)
  end

  test "defaults to Lucide" do
    igniter = run([])

    assert_creates(igniter, "assets/vendor/lucide.js")
    assert content(igniter, "mix.exs") =~ ":lucide_icons"
  end

  test "Tailwind mode writes vendor plugins and imports them" do
    igniter = run(["lucide", "--tailwind"])

    assert_creates(igniter, "assets/vendor/lucide.js")
    assert content(igniter, "assets/css/app.css") =~ ~s(@plugin "../vendor/lucide";)
    assert content(igniter, "mix.exs") =~ ":lucide_icons"
  end

  test "plain CSS mode writes a stub and imports it" do
    igniter = run(["lucide", "--css"])

    assert_creates(igniter, "assets/css/flint-lucide.css")
    assert content(igniter, "assets/css/flint-lucide.css") =~ "flint.icons.generate"
    assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint-lucide.css";)
    refute content(igniter, "mix.exs") =~ ":flint_icons"
  end

  test "scan mode installs the compiler and stores its config" do
    igniter =
      run(["lucide", "--css", "--scan", "--safelist", "lucide-wifi", "--source", "lib/**/*.ex"])

    assert content(igniter, "mix.exs") =~ "compilers: Mix.compilers() ++ [:flint_icons]"
    assert content(igniter, "config/config.exs") =~ "icon_source_globs: [\"lib/**/*.ex\"]"
    assert content(igniter, "config/config.exs") =~ "icon_safelist: [\"lucide-wifi\"]"

    assert Enum.any?(igniter.tasks, fn {task, args} ->
             task == "flint.icons.generate" and "--scan" in args
           end)
  end

  test "auto-detects Tailwind from app.css" do
    igniter = run(["lucide"], ~s(@import "tailwindcss";\n))

    assert_creates(igniter, "assets/vendor/lucide.js")
    refute content(igniter, "assets/css/app.css") =~ "flint-lucide.css"
  end

  test "auto-detects plain CSS from app.css" do
    igniter = run(["lucide"], "/* no tailwind here */\n")

    assert_creates(igniter, "assets/css/flint-lucide.css")
    refute content(igniter, "assets/css/app.css") =~ "@plugin"
  end

  test "installs every set with --all" do
    igniter = run(["--all", "--css"])

    for set <- ["heroicons", "lucide", "simple-icons", "flags"] do
      assert_creates(igniter, "assets/css/flint-#{set}.css")
      assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint-#{set}.css";)
    end

    source = content(igniter, "mix.exs")
    assert source =~ ":heroicons"
    assert source =~ ":lucide_icons"
    assert source =~ ":simple_icons"
    assert source =~ ":flag_icons"
  end

  test "is idempotent" do
    igniter =
      run(["lucide", "--tailwind"])
      |> Igniter.compose_task("flint.icons", ["lucide", "--tailwind"])

    source = content(igniter, "assets/css/app.css")

    assert length(String.split(source, ~s(@plugin "../vendor/lucide";))) == 2
  end

  test "rejects unknown sets" do
    igniter = run(["nope"])

    assert_has_issue(igniter, fn issue ->
      String.contains?(issue, "Unknown icon set(s): nope")
    end)
  end

  test "rejects both install modes" do
    igniter = run(["lucide", "--tailwind", "--css"])

    assert_has_issue(igniter, fn issue ->
      String.contains?(issue, "Pass only one of")
    end)
  end
end
