defmodule FlintUI.Styled.FlagTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:flag, ~S'''
      def defaults(assigns) do
        ~H"""
        <.flag code="pt" />
        """
      end

      def configured(assigns) do
        ~H"""
        <.flag
          code="us"
          shape="square"
          size="lg"
          radius="xl"
          overlay="wave"
          border
          shadow
          label="United States"
          class="extra"
          data-role="test"
        />
        """
      end

      def round(assigns) do
        ~H"""
        <.flag code="br" shape="round" />
        """
      end

      def numeric(assigns) do
        ~H"""
        <.flag code="pt" size={40} style="opacity: 0.5" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :flag)) == ["span"]
    assert attr(document, :flag, "data-flag") == [""]
    assert attr(document, :flag, "data-name") == ["flag-pt"]
    assert attr(document, :flag, "data-shape") == ["regular"]
    assert attr(document, :flag, "data-size") == ["md"]
    assert attr(document, :flag, "data-radius") == ["xs"]
    assert attr(document, :flag, "data-overlay") == ["none"]
    assert attr(document, :flag, "data-border") == []
    assert attr(document, :flag, "data-shadow") == []
    assert attr(document, :flag, "class") == [""]
    assert attr(document, :flag, "style") == [~s|background-image: url("/images/flags/pt.svg")|]
    assert attr(document, :flag, "aria-hidden") == ["true"]
  end

  test "maps overrides and keeps the base contract", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :flag, "data-name") == ["flag-us-square"]
    assert attr(document, :flag, "data-shape") == ["square"]
    assert attr(document, :flag, "data-size") == ["lg"]
    assert attr(document, :flag, "data-radius") == ["xl"]
    assert attr(document, :flag, "data-overlay") == ["wave"]
    assert attr(document, :flag, "data-border") == [""]
    assert attr(document, :flag, "data-shadow") == [""]
    assert attr(document, :flag, "class") == ["extra"]

    assert attr(document, :flag, "style") == [
             ~s|background-image: url("/images/flags/us-square.svg")|
           ]

    assert attr(document, :flag, "role") == ["img"]
    assert attr(document, :flag, "aria-label") == ["United States"]
    assert attr(document, :flag, "data-role") == ["test"]
  end

  test "round uses the square asset and is marked for a full radius", %{wrapper: wrapper} do
    document = render(wrapper, :round)

    assert attr(document, :flag, "data-name") == ["flag-br-square"]
    assert attr(document, :flag, "data-shape") == ["round"]

    assert attr(document, :flag, "style") == [
             ~s|background-image: url("/images/flags/br-square.svg")|
           ]

    assert attr(document, :flag, "class") == [""]
  end

  test "a numeric size writes the flag input instead of a data hook", %{wrapper: wrapper} do
    document = render(wrapper, :numeric)

    assert attr(document, :flag, "data-size") == []

    assert attr(document, :flag, "style") == [
             ~s|background-image: url("/images/flags/pt.svg"); --fl-flag-size: 2.5rem; opacity: 0.5|
           ]
  end
end
