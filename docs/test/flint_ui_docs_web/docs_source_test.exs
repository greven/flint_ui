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

  test "extracts the playground callback source" do
    assert {:ok, source} = Source.extract(Docs.Button, :playground, layer: :styled)

    assert source.callback == "render_playground/1"
    assert source.line > 0
    assert source.path =~ "button.ex"
    assert source.code =~ "<Components.button"
    refute source.code =~ "~H"
  end

  test "extracts the usage clause matching the block" do
    assert {:ok, source} = Source.extract(Docs.Button, :usage, block: :disabled, layer: :styled)

    assert source.callback == "render_usage/1"
    assert source.code =~ "<Components.button disabled>Delete</Components.button>"
  end

  test "extracts the example clause matching the block" do
    assert {:ok, source} = Source.extract(Docs.Button, :block, block: :icon, layer: :styled)

    assert source.callback == "render_block/1"
    assert source.code =~ ~s(<:leading>)
    assert source.code =~ "New project"
  end

  test "unknown blocks have no source" do
    assert :error = Source.extract(Docs.Button, :usage, block: :does_not_exist, layer: :styled)
  end

  test "every styled preview has an extractable source" do
    for {name, module} <- Docs.modules() do
      assert {:ok, _} =
               Source.extract(module, :playground, layer: :styled),
             "expected #{name} to expose a render_playground/1 source"

      for entry <- Docs.styled_usage(name), entry[:preview] != false do
        assert {:ok, _} =
                 Source.extract(module, :usage, block: entry.id, layer: :styled),
               "expected #{name} usage #{entry.id} to expose a render_usage/1 source"
      end

      for entry <- Docs.styled_examples(name), entry[:preview] != false do
        assert {:ok, _} =
                 Source.extract(module, :block, block: entry.id, layer: :styled),
               "expected #{name} example #{entry.id} to expose a render_block/1 source"
      end
    end
  end

  test "get/3 respects the dev_tools flag" do
    Application.put_env(:flint_ui_docs, :dev_tools, false)
    assert Source.get(Docs.Button, :playground, layer: :styled) == nil

    Application.put_env(:flint_ui_docs, :dev_tools, true)
    assert %{code: code} = Source.get(Docs.Button, :playground, layer: :styled)
    assert code =~ "<Components.button"
  end
end
