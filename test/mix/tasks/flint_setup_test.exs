defmodule Mix.Tasks.Flint.SetupTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  @web """
  defmodule MyAppWeb do
    def router do
      quote do
        use Phoenix.Router
      end
    end

    defp html_helpers do
      quote do
        import Phoenix.HTML
        import MyAppWeb.CoreComponents
      end
    end
  end
  """

  @app_css """
  @import "tailwindcss";
  """

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  defp setup(extra \\ []) do
    files =
      Map.merge(
        %{"lib/my_app_web.ex" => @web, "assets/css/app.css" => @app_css},
        Map.new(extra)
      )

    test_project(app_name: :my_app, files: files)
    |> Igniter.compose_task("flint.setup", [])
  end

  test "creates the components module and the theme stylesheet" do
    igniter = setup()

    assert_creates(igniter, "lib/my_app_web/components.ex")
    assert_creates(igniter, "assets/css/flint.css")

    assert content(igniter, "lib/my_app_web/components.ex") =~ "use Phoenix.Component"
    assert content(igniter, "assets/css/flint.css") =~ "--fl-color-primary"
  end

  test "imports the components module into the HTML helpers" do
    source = content(setup(), "lib/my_app_web.ex")
    assert source =~ "import MyAppWeb.Components"
  end

  test "imports the theme stylesheet" do
    source = content(setup(), "assets/css/app.css")
    assert source =~ ~s(@import "./flint.css";)
    refute source =~ "--fl-color-primary"
  end

  test "--tailwind also maps tokens onto Tailwind utilities" do
    igniter =
      test_project(
        app_name: :my_app,
        files: %{"lib/my_app_web.ex" => @web, "assets/css/app.css" => @app_css}
      )
      |> Igniter.compose_task("flint.setup", ["--tailwind"])

    source = content(igniter, "assets/css/app.css")
    assert source =~ "@theme inline {"
    assert source =~ "--color-primary: var(--fl-color-primary);"
  end
end
