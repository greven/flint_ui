defmodule FlintUIDocsWeb.CodeBlockTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.CodeBlock

  defp render_code(attrs) do
    attrs =
      Map.merge(
        %{code: ~s(<.button>Save</.button>), lang: :heex},
        attrs
      )

    render_component(fn assigns -> CodeBlock.code(assigns) end, attrs)
    |> LazyHTML.from_fragment()
  end

  defp count(document, selector) do
    document
    |> LazyHTML.query(selector)
    |> Enum.count()
  end

  test "renders a collapsible header with copy by default" do
    document = render_code(%{})

    assert count(document, "[data-code-block]") == 1
    assert count(document, "[data-code-header][phx-hook]") == 1
    assert count(document, "[data-code-collapse][aria-expanded='true']") == 1
    assert count(document, "[data-code-body]:not([hidden])") == 1
    assert count(document, "button[aria-label='Copy code']") == 1
  end

  test "starts collapsed when asked" do
    document = render_code(%{collapsed: true})

    assert count(document, "[data-element='collapsible'][data-state='closed']") == 1
    assert count(document, "[data-code-body][hidden]") == 1
  end

  test "centers the copy button when the panel has no header" do
    document = render_code(%{collapsible: false})

    assert count(document, "[data-code-header]") == 0

    assert count(
             document,
             ".absolute.inset-y-0.right-2.flex.items-center button[aria-label='Copy code']"
           ) == 1
  end

  test "can hide the copy button" do
    document = render_code(%{collapsible: false, copy: false})

    assert count(document, "button[aria-label='Copy code']") == 0
  end
end
