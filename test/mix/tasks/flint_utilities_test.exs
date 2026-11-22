defmodule Mix.Tasks.Flint.UtilitiesTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  @app_css """
  @import "tailwindcss";
  @import "./flint.css";
  """

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  defp run_utilities(extra \\ [], args \\ []) do
    files = Map.merge(%{"assets/css/app.css" => @app_css}, Map.new(extra))

    test_project(app_name: :my_app, files: files)
    |> Igniter.compose_task("flint.utilities", args)
  end

  test "writes the utility stylesheet and imports it" do
    igniter = run_utilities()

    assert_creates(igniter, "assets/css/flint-utilities.css")
    assert content(igniter, "assets/css/flint-utilities.css") =~ ".fl-stack"
    assert content(igniter, "assets/css/flint-utilities.css") =~ "@layer utilities {"
    assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint-utilities.css";)
  end

  test "also installs the theme when it is missing" do
    igniter = run_utilities()

    assert_creates(igniter, "assets/css/flint.css")
    assert content(igniter, "assets/css/app.css") =~ ~s(@import "./flint.css";)
  end

  test "is idempotent" do
    igniter = run_utilities()
    igniter = Igniter.compose_task(igniter, "flint.utilities", [])
    source = content(igniter, "assets/css/app.css")

    assert length(String.split(source, ~s(@import "./flint-utilities.css";))) == 2
  end

  test "overwrites an existing generated stylesheet" do
    igniter =
      run_utilities([{"assets/css/flint-utilities.css", "/* __old__ */\n"}])

    refute content(igniter, "assets/css/flint-utilities.css") =~ "__old__"
    assert content(igniter, "assets/css/flint-utilities.css") =~ ".fl-stack"
  end

  test "--no-import leaves the app stylesheet alone apart from the theme import" do
    igniter = run_utilities([], ["--no-import"])
    source = content(igniter, "assets/css/app.css")

    refute source =~ "flint-utilities.css"
  end

  test "--no-reset omits the base reset" do
    igniter = run_utilities([], ["--no-reset"])
    source = content(igniter, "assets/css/flint-utilities.css")

    refute source =~ "box-sizing: border-box"
    assert source =~ "@layer utilities {"
  end
end
