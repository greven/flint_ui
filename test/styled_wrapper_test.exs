defmodule FlintUI.StyledWrapperTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias FlintUI.Generator

  setup_all do
    module = Module.concat([FlintUITest, :GeneratedButton])

    source = """
    defmodule #{inspect(module)} do
      use Phoenix.Component

      #{Generator.component_source(:button)}

      def example(assigns) do
        ~H\"\"\"
        <.button color={@color} variant="solid" style={@style}>Deploy</.button>
        \"\"\"
      end

      def text_and_icon(assigns) do
        ~H\"\"\"
        <.button icon="lucide-save" text="Save" />
        \"\"\"
      end

      def slot_wins(assigns) do
        ~H\"\"\"
        <.button icon="lucide-save" text="Ignored">Save now</.button>
        \"\"\"
      end

      def icon_only(assigns) do
        ~H\"\"\"
        <.button icon="lucide-search" square aria-label="Search" />
        \"\"\"
      end
    end
    """

    Code.compile_string(source)
    %{wrapper: module}
  end

  defp render(module, color, style \\ nil) do
    render_component(fn assigns -> apply(module, :example, [assigns]) end, %{
      color: color,
      style: style
    })
    |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-element="button"]))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp icon(html), do: LazyHTML.query(html, ~s([data-element="icon"]))

  defp render_function(module, function, assigns \\ %{}) do
    render_component(
      fn component_assigns -> apply(module, function, [component_assigns]) end,
      assigns
    )
    |> LazyHTML.from_fragment()
  end

  test "a role keeps the data hook and emits no inline color", %{wrapper: wrapper} do
    html = render(wrapper, "primary")

    assert attr(html, "data-color") == ["primary"]
    assert attr(html, "style") == []
  end

  test "a raw color omits the data hook and sets the public inputs", %{wrapper: wrapper} do
    html = render(wrapper, "#1D72FE")

    assert attr(html, "data-color") == []
    style = html |> attr("style") |> List.first()

    assert style =~ "--fl-button-color: #1D72FE"
    assert style =~ "--fl-button-color-content: oklch(0% 0 0)"
    assert style =~ "--fl-button-text: light-dark("
  end

  test "an explicit style wins over the derived inputs", %{wrapper: wrapper} do
    html = render(wrapper, "#1D72FE", "--fl-button-color-content: white")
    style = html |> attr("style") |> List.first()

    assert String.ends_with?(style, "; --fl-button-color-content: white")
  end

  test "text and icon are content shortcuts", %{wrapper: wrapper} do
    html = render_function(wrapper, :text_and_icon)

    assert root(html) |> LazyHTML.text() |> String.trim() == "Save"
    assert LazyHTML.attribute(icon(html), "class") == ["lucide-save"]
    assert LazyHTML.attribute(icon(html), "aria-hidden") == ["true"]
  end

  test "the default slot wins over text", %{wrapper: wrapper} do
    html = render_function(wrapper, :slot_wins)

    assert root(html) |> LazyHTML.text() |> String.trim() == "Save now"
    refute root(html) |> LazyHTML.text() |> String.contains?("Ignored")
  end

  test "an icon-only button keeps its aria-label", %{wrapper: wrapper} do
    html = render_function(wrapper, :icon_only)

    assert attr(html, "aria-label") == ["Search"]
    assert LazyHTML.attribute(icon(html), "class") == ["lucide-search"]
  end
end
