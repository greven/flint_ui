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

  @app_js """
  import {Socket} from "phoenix"
  import {LiveSocket} from "phoenix_live_view"

  const liveSocket = new LiveSocket("/live", Socket, {
    longPollFallbackMs: 2500,
  })
  """

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  defp run_setup(extra \\ [], args \\ []) do
    files =
      Map.merge(
        %{
          "lib/my_app_web.ex" => @web,
          "assets/css/app.css" => @app_css,
          "assets/js/app.js" => @app_js
        },
        Map.new(extra)
      )

    test_project(app_name: :my_app, files: files)
    |> Igniter.compose_task("flint.setup", args)
  end

  test "creates the components module and the theme stylesheet" do
    igniter = run_setup()

    assert_creates(igniter, "lib/my_app_web/components.ex")
    assert_creates(igniter, "assets/css/flint.css")

    assert content(igniter, "lib/my_app_web/components.ex") =~ "use Phoenix.Component"
    assert content(igniter, "assets/css/flint.css") =~ "--fl-color-primary"
  end

  test "imports the components module into the HTML helpers" do
    source = content(run_setup(), "lib/my_app_web.ex")
    assert source =~ "import MyAppWeb.Components"
  end

  test "imports the theme stylesheet" do
    source = content(run_setup(), "assets/css/app.css")
    assert source =~ ~s(@import "./flint.css";)
    refute source =~ "--fl-color-primary"
  end

  test "registers the core hooks in app.js" do
    source = content(run_setup(), "assets/js/app.js")

    assert source =~
             ~s(import {hooks as flintHooks} from "../../deps/flint_ui/priv/static/flint.js")

    assert source =~ "hooks: {...flintHooks}"
    refute source =~ "flint-sound.js"
    refute source =~ "soundHooks"
  end

  test "merges into an existing hooks object" do
    app_js = """
    import {hooks as colocatedHooks} from "phoenix-colocated/my_app"

    const liveSocket = new LiveSocket("/live", Socket, {
      hooks: {...colocatedHooks},
    })
    """

    source = content(run_setup(%{"assets/js/app.js" => app_js}), "assets/js/app.js")

    assert source =~ "hooks: {...flintHooks, ...colocatedHooks}"
  end

  test "--sound also registers the sound bundle" do
    source = content(run_setup([], ["--sound"]), "assets/js/app.js")

    assert source =~
             ~s(import {hooks as soundHooks} from "../../deps/flint_ui/priv/static/flint-sound.js")

    assert source =~ "hooks: {...flintHooks, ...soundHooks}"
  end

  test "--no-js leaves app.js untouched" do
    igniter = run_setup([], ["--no-js"])
    assert_unchanged(igniter, "assets/js/app.js")
  end

  test "is idempotent" do
    igniter = run_setup()
    igniter = Igniter.compose_task(igniter, "flint.setup", [])
    source = content(igniter, "assets/js/app.js")

    assert length(String.split(source, "import {hooks as flintHooks}")) == 2
    assert length(String.split(source, "...flintHooks")) == 2
  end

  test "falls back to a notice when app.js is missing" do
    igniter =
      test_project(
        app_name: :my_app,
        files: %{"lib/my_app_web.ex" => @web, "assets/css/app.css" => @app_css}
      )
      |> Igniter.compose_task("flint.setup", [])

    assert_has_notice(igniter, &String.contains?(&1, "assets/js/app.js was not found"))
  end

  test "falls back to a notice when hooks is not an object literal" do
    app_js = """
    const liveSocket = new LiveSocket("/live", Socket, {hooks: myHooks})
    """

    igniter = run_setup(%{"assets/js/app.js" => app_js})
    source = content(igniter, "assets/js/app.js")

    refute source =~ "hooks: {...flintHooks"
    assert_has_notice(igniter, &String.contains?(&1, "Register FlintUI's hooks"))
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
