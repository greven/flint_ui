defmodule Mix.Tasks.Flint.AddTest do
  use ExUnit.Case, async: true

  import Igniter.Test

  defp content(igniter, path) do
    igniter.rewrite.sources[path]
    |> Rewrite.Source.get(:content)
  end

  test "generates a thin styled wrapper into MyAppWeb.Components" do
    igniter =
      test_project(app_name: :my_app)
      |> Igniter.compose_task("flint.add", ["button"])

    assert_creates(igniter, "lib/my_app_web/components.ex")

    source = content(igniter, "lib/my_app_web/components.ex")

    assert source =~ "defmodule MyAppWeb.Components"
    assert source =~ "use Phoenix.Component"
    assert source =~ "def button(assigns)"
    assert source =~ "data-variant={@variant}"
    assert source =~ "data-color={@data_color}"
    assert source =~ "data-size={@size}"
    assert source =~ "<FlintUI.button"
  end

  test "--all adds every registered component" do
    igniter =
      test_project(app_name: :my_app)
      |> Igniter.compose_task("flint.add", ["--all"])

    source = content(igniter, "lib/my_app_web/components.ex")

    for name <- FlintUI.Styled.names() do
      assert source =~ "def #{name}(assigns)"
    end
  end

  test "reports an unknown component" do
    igniter =
      test_project(app_name: :my_app)
      |> Igniter.compose_task("flint.add", ["nope"])

    assert_has_issue(igniter, fn issue -> issue =~ "Unknown component" end)
  end

  describe "input replaces the core component" do
    @core_source """
    defmodule MyAppWeb.CoreComponents do
      use Phoenix.Component

      @doc \"\"\"
      Renders an input with label and error messages.
      \"\"\"
      attr :id, :any, default: nil
      attr :name, :any
      attr :field, Phoenix.HTML.FormField
      attr :rest, :global, include: ~w(disabled placeholder)

      def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
        assigns = assign(assigns, :id, assigns.id || field.id)
        input(assigns)
      end

      def input(%{type: "checkbox"} = assigns) do
        ~H\"<input type=\\\"checkbox\\\" />\"
      end

      def input(assigns) do
        ~H\"<input />\"
      end

      defp error(assigns) do
        ~H\"<p>error</p>\"
      end

      @doc \"Renders a header.\"
      def header(assigns) do
        ~H\"<header></header>\"
      end
    end
    """

    test "removes input/1 and the unused error/1 and keeps the rest" do
      igniter =
        test_project(app_name: :my_app)
        |> Igniter.create_new_file(
          "lib/my_app_web/components/core_components.ex",
          @core_source
        )
        |> Igniter.compose_task("flint.add", ["input"])

      core = content(igniter, "lib/my_app_web/components/core_components.ex")

      refute core =~ "def input("
      refute core =~ "defp error("
      refute core =~ "Renders an input"
      assert core =~ "def header(assigns)"

      components = content(igniter, "lib/my_app_web/components.ex")
      assert components =~ "def input(assigns)"
    end

    test "keeps error/1 when another function still calls it" do
      source =
        String.replace(
          @core_source,
          "def header(assigns) do",
          "def header(assigns) do\n    error(assigns)"
        )

      igniter =
        test_project(app_name: :my_app)
        |> Igniter.create_new_file("lib/my_app_web/components/core_components.ex", source)
        |> Igniter.compose_task("flint.add", ["input"])

      core = content(igniter, "lib/my_app_web/components/core_components.ex")

      refute core =~ "def input("
      assert core =~ "defp error(assigns)"
    end

    test "--all removes the core input too" do
      igniter =
        test_project(app_name: :my_app)
        |> Igniter.create_new_file(
          "lib/my_app_web/components/core_components.ex",
          @core_source
        )
        |> Igniter.compose_task("flint.add", ["--all"])

      core = content(igniter, "lib/my_app_web/components/core_components.ex")

      refute core =~ "def input("
      assert content(igniter, "lib/my_app_web/components.ex") =~ "def input(assigns)"
    end

    test "leaves a project without CoreComponents alone" do
      igniter =
        test_project(app_name: :my_app)
        |> Igniter.compose_task("flint.add", ["input"])

      assert content(igniter, "lib/my_app_web/components.ex") =~ "def input(assigns)"
    end
  end
end
