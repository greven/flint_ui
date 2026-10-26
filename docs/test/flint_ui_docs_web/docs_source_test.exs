defmodule FlintUIDocsWeb.DocsSourceTest do
  use ExUnit.Case, async: false

  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.Docs.Source

  setup do
    previous = Application.get_env(:flint_ui_docs, :dev_tools)

    on_exit(fn ->
      case previous do
        nil -> Application.delete_env(:flint_ui_docs, :dev_tools)
        value -> Application.put_env(:flint_ui_docs, :dev_tools, value)
      end
    end)

    :ok
  end

  test "extracts the main callback source" do
    assert {:ok, source} = Source.extract(Docs.Button, :main, layer: :styled)

    assert source.callback == "render_main/1"
    assert source.line > 0
    assert source.path =~ "button.ex"
    assert source.code =~ "<Components.button"
    refute source.code =~ "~H"
  end

  test "extracts the usage clause matching the kind and block" do
    assert {:ok, source} =
             Source.extract(Docs.Button, :section,
               kind: :usage,
               block: :variant,
               layer: :styled
             )

    assert source.callback == "render_section/1"
    assert source.code =~ "Components.button"
  end

  test "extracts the example clause matching the kind and block" do
    assert {:ok, source} =
             Source.extract(Docs.Button, :section,
               kind: :example,
               block: :icon,
               layer: :styled
             )

    assert source.callback == "render_section/1"
    assert source.code =~ ~s(<:leading>)
    assert source.code =~ "New project"
  end

  test "unknown blocks have no source" do
    assert :error =
             Source.extract(Docs.Button, :section,
               kind: :usage,
               block: :does_not_exist,
               layer: :styled
             )
  end

  test "get/3 respects the dev_tools flag" do
    Application.put_env(:flint_ui_docs, :dev_tools, false)
    assert Source.get(Docs.Button, :main, layer: :styled) == nil

    Application.put_env(:flint_ui_docs, :dev_tools, true)
    assert %{code: code} = Source.get(Docs.Button, :main, layer: :styled)
    assert code =~ "<Components.button"
  end
end
