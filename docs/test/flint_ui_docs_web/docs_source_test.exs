defmodule FlintUIDocsWeb.DocsSourceTest.Sample do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :button

  @impl true
  def base_docs, do: :all

  @impl true
  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <div data-sample="variant">Variant</div>
    """
  end
end

defmodule FlintUIDocsWeb.DocsSourceTest do
  use ExUnit.Case, async: false

  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.Docs.Source
  alias FlintUIDocsWeb.DocsSourceTest.Sample

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

  test "extracts the first styled section source" do
    first = hd(Docs.sections(:button, :styled))
    assert {:ok, source} = Source.extract(Docs.Button, first.section, first[:id])

    assert source.callback == "render_section/1"
    assert source.line > 0
    assert source.path =~ "button.ex"
    assert source.code =~ "<Components.button"
    refute source.code =~ "~H"
  end

  test "extracts the clause matching the section and id" do
    assert {:ok, source} = Source.extract(Sample, :usage, :variant)

    assert source.callback == "render_section/1"
    assert source.code =~ ~s(data-sample="variant")
    assert source.path =~ "docs_source_test.exs"
  end

  test "unknown sections have no source" do
    assert :error = Source.extract(Sample, :usage, :does_not_exist)
    assert :error = Source.extract(Sample, :examples, nil)
  end

  test "get/3 respects the dev_tools flag" do
    first = hd(Docs.sections(:button, :styled))

    Application.put_env(:flint_ui_docs, :dev_tools, false)
    assert Source.get(Docs.Button, first.section, first[:id]) == nil

    Application.put_env(:flint_ui_docs, :dev_tools, true)
    assert %{code: code} = Source.get(Docs.Button, first.section, first[:id])
    assert code =~ "<Components.button"
  end
end
