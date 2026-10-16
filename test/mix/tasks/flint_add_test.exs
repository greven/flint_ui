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
    assert source =~ "data-color={@color}"
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
end
