defmodule FlintUI.Styled.LoadingTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:loading, ~S'''
      def defaults(assigns) do
        ~H"""
        <.loading />
        """
      end

      def configured(assigns) do
        ~H"""
        <.loading
          variant="dots-fade"
          color="primary"
          size="lg"
          label="Saving"
          class="extra"
          data-role="test"
        />
        """
      end

      def animated(assigns) do
        ~H"""
        <.loading variant="ring" duration={300} weight={3} />
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.loading color="#1D72FE" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default variant, color, and size", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :loading)) == ["svg"]
    assert attr(document, :loading, "data-loading") == [""]
    assert attr(document, :loading, "data-variant") == ["ring"]
    assert attr(document, :loading, "data-color") == ["inherit"]
    assert attr(document, :loading, "data-size") == ["md"]
  end

  test "maps the variant, color, size, and forwarded base attributes", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :loading, "data-variant") == ["dots-fade"]
    assert attr(document, :loading, "data-color") == ["primary"]
    assert attr(document, :loading, "data-size") == ["lg"]
    assert attr(document, :loading, "class") == ["extra"]
    assert attr(document, :loading, "data-role") == ["test"]
    assert attr(document, :loading, "role") == ["img"]
    assert attr(document, :loading, "aria-label") == ["Saving"]
  end

  test "forwards the animation duration and weight", %{wrapper: wrapper} do
    document = render(wrapper, :animated)
    html = LazyHTML.to_html(document)

    assert html =~ "animation-duration: 300ms"
    assert html =~ ~s(stroke-width="3)
  end

  test "a raw color sets the color property directly", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:loading, "style") |> List.first()

    assert attr(document, :loading, "data-color") == []
    assert style =~ "color: light-dark("
  end
end
