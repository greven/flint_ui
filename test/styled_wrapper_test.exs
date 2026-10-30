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
end
