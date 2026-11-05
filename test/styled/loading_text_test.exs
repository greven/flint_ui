defmodule FlintUI.Styled.LoadingTextTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:loading_text, ~S'''
      def defaults(assigns) do
        ~H"""
        <.loading_text text="Saving" />
        """
      end

      def custom_dots(assigns) do
        ~H"""
        <.loading_text text="Syncing" dots={5} />
        """
      end

      def configured(assigns) do
        ~H"""
        <.loading_text
          text="Syncing"
          variant="shimmer"
          color="success"
          duration={300}
          class="extra"
          data-role="test"
        />
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.loading_text text="Saving" color="#1D72FE" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp text_part(document) do
    document |> part("text") |> LazyHTML.text() |> String.trim()
  end

  test "maps the defaults and renders the copy with its dots", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :loading_text)) == ["span"]
    assert attr(document, :loading_text, "data-loading_text") == [""]
    assert attr(document, :loading_text, "data-variant") == ["dots"]
    assert attr(document, :loading_text, "data-color") == ["inherit"]
    assert text_part(document) == "Saving"
    assert count_part(document, "dot") == 3
  end

  test "forwards the dot count", %{wrapper: wrapper} do
    document = render(wrapper, :custom_dots)

    assert text_part(document) == "Syncing"
    assert count_part(document, "dot") == 5
  end

  test "maps the variant, color, duration, and global attributes", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :loading_text, "data-variant") == ["shimmer"]
    assert attr(document, :loading_text, "data-color") == ["success"]
    assert attr(document, :loading_text, "class") == ["extra"]
    assert attr(document, :loading_text, "data-role") == ["test"]
    assert part_attr(document, "text", "style") == ["animation-duration: 300ms"]
  end

  test "a raw color sets the color property directly", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:loading_text, "style") |> List.first()

    assert attr(document, :loading_text, "data-color") == []
    assert style =~ "color: light-dark("
  end
end
