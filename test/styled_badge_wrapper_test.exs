defmodule FlintUI.StyledBadgeWrapperTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  alias FlintUI.Generator

  setup_all do
    module = Module.concat([FlintUITest, :GeneratedBadge])

    source = """
    defmodule #{inspect(module)} do
      use Phoenix.Component

      #{Generator.component_source(:badge)}

      def defaults(assigns) do
        ~H\"\"\"
        <.badge>New</.badge>
        \"\"\"
      end

      def content(assigns) do
        ~H\"\"\"
        <.badge as="div" icon="lucide-sparkles" text="Ignored" uppercase>
          <:leading><span id="lead">L</span></:leading>
          Beta
          <:trailing><span id="trail">T</span></:trailing>
        </.badge>
        \"\"\"
      end

      def link(assigns) do
        ~H\"\"\"
        <.badge as="div" href="/releases">v1.2.0</.badge>
        \"\"\"
      end

      def raw_color(assigns) do
        ~H\"\"\"
        <.badge color="#1D72FE">New</.badge>
        \"\"\"
      end

      def dot(assigns) do
        ~H\"\"\"
        <.badge variant="dot" color="success">Online</.badge>
        \"\"\"
      end
    end
    """

    Code.compile_string(source)
    %{wrapper: module}
  end

  defp render(module, fun) do
    render_component(fn assigns -> apply(module, fun, [assigns]) end, %{})
    |> LazyHTML.from_fragment()
  end

  defp root(document), do: LazyHTML.query(document, ~s([data-element="badge"]))
  defp attr(document, name), do: LazyHTML.attribute(root(document), name)

  test "renders the subtle defaults", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document)) == ["span"]
    assert attr(document, "data-variant") == ["subtle"]
    assert attr(document, "data-size") == ["md"]
    assert attr(document, "data-radius") == ["md"]
    assert attr(document, "data-uppercase") == []
    assert attr(document, "data-inset") == []
    assert attr(document, "data-wide") == []
  end

  test "renders leading, icon, content, and trailing in order", %{wrapper: wrapper} do
    document = render(wrapper, :content)
    text = root(document) |> LazyHTML.text() |> String.replace(~r/\s+/, " ") |> String.trim()

    assert LazyHTML.tag(root(document)) == ["div"]
    assert attr(document, "data-uppercase") == [""]
    assert text == "L Beta T"
    refute text =~ "Ignored"
    assert LazyHTML.query(document, ~s(#lead)) |> LazyHTML.text() == "L"
    assert LazyHTML.query(document, ~s(#trail)) |> LazyHTML.text() == "T"

    assert LazyHTML.query(document, ~s(#lead + [data-element="icon"]))
           |> LazyHTML.attribute("class") == ["lucide-sparkles"]
  end

  test "a link destination wins over as", %{wrapper: wrapper} do
    document = render(wrapper, :link)

    assert LazyHTML.tag(root(document)) == ["a"]
    assert attr(document, "href") == ["/releases"]
  end

  test "a raw color sets the badge public inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr("style") |> List.first()

    assert attr(document, "data-color") == []
    assert style =~ "--fl-badge-color: #1D72FE"
    assert style =~ "--fl-badge-color-content:"
    assert style =~ "--fl-badge-text: light-dark("
  end

  test "renders the dot variant with its role color", %{wrapper: wrapper} do
    document = render(wrapper, :dot)

    assert attr(document, "data-variant") == ["dot"]
    assert attr(document, "data-color") == ["success"]
    assert root(document) |> LazyHTML.text() |> String.trim() == "Online"
  end
end
