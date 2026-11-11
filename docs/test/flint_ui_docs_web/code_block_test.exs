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
    assert count(document, "[data-element='collapsible'][data-collapsible]") == 1
    assert count(document, "[data-code-header][phx-hook]") == 1
    assert count(document, "[data-code-collapse][aria-expanded='true']") == 1
    assert count(document, "[data-code-body]:not([hidden])") == 1
    assert count(document, "[data-code-close]") == 0
    assert count(document, "button[aria-label='Copy code']") == 1
  end

  test "leads a single-snippet caption with its language icon" do
    css = render_code(%{lang: :css})

    assert count(css, "[data-code-header] .lucide-palette") == 1

    elixir = render_code(%{lang: :elixir})
    assert count(elixir, "[data-code-header] .lucide-droplet") == 1
  end

  test "shows the close footer only for tall collapsible panels" do
    tall_code = Enum.map_join(1..9, "\n", &"<.button>Save #{&1}</.button>")

    tall = render_code(%{code: tall_code})
    assert count(tall, "[data-code-close][phx-click]") == 1

    not_collapsible = render_code(%{code: tall_code, collapsible: false})
    assert count(not_collapsible, "[data-code-close]") == 0
  end

  test "starts collapsed when asked" do
    document = render_code(%{collapsed: true})

    assert count(document, "[data-element='collapsible'][data-state='closed']") == 1
    assert count(document, "[data-code-body][hidden]") == 1
  end

  test "centers the copy button when the panel has no header" do
    document = render_code(%{collapsible: false})

    assert count(document, "[data-code-header]") == 0
    assert count(document, "[data-code-close]") == 0

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
