defmodule FlintUIDocsWeb.PreviewTest do
  use FlintUIDocsWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias FlintUIDocsWeb.Preview

  defp render_preview(attrs) do
    attrs =
      Map.merge(
        %{preview_id: "test-preview", name: nil, code: ~s(<.button>Save</.button>)},
        attrs
      )

    render_component(fn assigns -> Preview.preview(assigns) end, attrs)
    |> LazyHTML.from_fragment()
  end

  defp count(document, selector) do
    document
    |> LazyHTML.query(selector)
    |> Enum.count()
  end

  test "a normal preview renders the demo canvas and its inner block" do
    document =
      render_preview(%{
        inner_block: [
          %{
            inner_block: fn _changed, _props ->
              Phoenix.HTML.raw(~s(<span data-demo>Demo</span>))
            end
          }
        ]
      })

    assert count(document, "[data-preview-canvas]") == 1
    assert count(document, "[data-preview-canvas] [data-demo]") == 1
    assert count(document, "[data-preview-code]") == 1
  end

  test "code-only renders the code panel without a canvas or controls" do
    document =
      render_preview(%{
        code_only: true,
        controls: [%{key: :color, type: :select, default: "neutral", label: "Color"}]
      })

    assert count(document, "[data-preview]") == 1
    assert count(document, "[data-preview-canvas]") == 0
    assert count(document, "[data-preview-controls]") == 0
    assert count(document, "[data-preview-code].rounded-lg.border") == 1
    assert count(document, "[data-code-header]") == 1
    assert count(document, "code#test-preview-code") == 1
    assert count(document, "button[aria-label='Copy code']") == 1
    assert count(document, "[phx-hook='.PreviewResize']") == 0
  end

  test "code-only keeps code flavors and the source toggle" do
    document =
      render_preview(%{
        code_only: true,
        codes: [
          heex: ~s(<.button>Save</.button>),
          css: ~s([data-element="button"] { color: red; })
        ],
        source: %{
          code: "def render_section(_assigns), do: nil",
          callback: "render_section/1",
          path: "lib/flint_ui_docs_web/docs/button.ex",
          line: 12
        }
      })

    assert count(document, "[data-preview-code] [role='tablist']") == 1
    assert count(document, "[role='tab']") == 2
    assert count(document, "#test-preview-source-toggle") == 1
  end

  test "code-only requires code" do
    assert_raise ArgumentError, ~r/code-only preview needs/, fn ->
      render_preview(%{code_only: true, code: nil})
    end
  end

  test "code-only cannot be combined with preview_only" do
    assert_raise ArgumentError, ~r/cannot also set :preview_only/, fn ->
      render_preview(%{code_only: true, preview_only: true})
    end
  end

  test "a preview with a canvas requires an inner block" do
    assert_raise ArgumentError, ~r/inner_block/, fn ->
      render_preview(%{})
    end
  end
end
