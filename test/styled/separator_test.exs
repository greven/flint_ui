defmodule FlintUI.Styled.SeparatorTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:separator, ~S'''
      def defaults(assigns) do
        ~H"""
        <.separator />
        """
      end

      def labelled(assigns) do
        ~H"""
        <.separator
          label="or"
          type="dashed"
          variant="strong"
          position="start"
          size="lg"
          color="primary"
          id="or"
        />
        """
      end

      def icon(assigns) do
        ~H"""
        <.separator icon="lucide-star" />
        """
      end

      def slot(assigns) do
        ~H"""
        <.separator label="ignored" icon="lucide-star">Custom</.separator>
        """
      end

      def custom_size(assigns) do
        ~H"""
        <.separator size={4} decorative />
        """
      end

      def vertical(assigns) do
        ~H"""
        <.separator orientation="vertical" label="or" />
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.separator color="#ff0000" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the default separator hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :separator)) == ["div"]
    assert attr(document, :separator, "data-type") == ["solid"]
    assert attr(document, :separator, "data-variant") == ["default"]
    assert attr(document, :separator, "data-position") == ["center"]
    assert attr(document, :separator, "data-size") == ["xs"]
    assert attr(document, :separator, "data-color") == ["neutral"]
    assert attr(document, :separator, "data-orientation") == ["horizontal"]
    assert attr(document, :separator, "role") == ["separator"]
    assert count_part(document, "content") == 0
  end

  test "maps type, variant, position, size, color, and forwarded attributes", %{wrapper: wrapper} do
    document = render(wrapper, :labelled)

    assert attr(document, :separator, "data-type") == ["dashed"]
    assert attr(document, :separator, "data-variant") == ["strong"]
    assert attr(document, :separator, "data-position") == ["start"]
    assert attr(document, :separator, "data-size") == ["lg"]
    assert attr(document, :separator, "data-color") == ["primary"]
    assert attr(document, :separator, "id") == ["or"]
    assert root(document, :separator) |> LazyHTML.text() |> String.trim() == "or"
  end

  test "renders an icon shortcut", %{wrapper: wrapper} do
    document = render(wrapper, :icon)

    assert count_part(document, "content") == 1

    icon = LazyHTML.query(document, ~s([data-element="separator"] [data-element="icon"]))
    assert LazyHTML.attribute(icon, "class") == ["lucide-star"]
    assert icon |> LazyHTML.text() |> String.trim() == ""
  end

  test "the default slot wins over label and icon", %{wrapper: wrapper} do
    document = render(wrapper, :slot)

    assert root(document, :separator) |> LazyHTML.text() |> String.trim() == "Custom"

    assert LazyHTML.query(document, ~s([data-element="separator"] [data-element="icon"]))
           |> LazyHTML.to_html() == ""
  end

  test "converts a numeric size to rem and omits the scale hook", %{wrapper: wrapper} do
    document = render(wrapper, :custom_size)

    assert attr(document, :separator, "data-size") == []
    assert attr(document, :separator, "role") == ["none"]

    assert attr(document, :separator, "style")
           |> Enum.join(" ")
           |> String.contains?("--fl-separator-size: 0.25rem")
  end

  test "forwards orientation and exposes aria-orientation", %{wrapper: wrapper} do
    document = render(wrapper, :vertical)

    assert attr(document, :separator, "data-orientation") == ["vertical"]
    assert attr(document, :separator, "aria-orientation") == ["vertical"]
  end

  test "writes a raw color to the public input", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)

    assert attr(document, :separator, "data-color") == []

    assert attr(document, :separator, "style")
           |> Enum.join(" ")
           |> String.contains?("--fl-separator-color: #ff0000")
  end
end
