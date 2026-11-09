defmodule FlintUI.Styled.FlagTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:flag, ~S'''
      def defaults(assigns) do
        ~H"""
        <.flag name="flag-pt" />
        """
      end

      def configured(assigns) do
        ~H"""
        <.flag
          name="flag-us-square"
          size="lg"
          radius="full"
          overlay="wave"
          border
          shadow
          label="United States"
          class="extra"
          data-role="test"
        />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default treatment onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :flag)) == ["span"]
    assert attr(document, :flag, "data-flag") == [""]
    assert attr(document, :flag, "data-size") == ["md"]
    assert attr(document, :flag, "data-radius") == ["xs"]
    assert attr(document, :flag, "data-overlay") == ["none"]
    assert attr(document, :flag, "data-border") == []
    assert attr(document, :flag, "data-shadow") == []
    assert attr(document, :flag, "class") == ["flag-pt"]
    assert attr(document, :flag, "aria-hidden") == ["true"]
  end

  test "maps overrides, forwards the name and label, and keeps globals", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :flag, "data-size") == ["lg"]
    assert attr(document, :flag, "data-radius") == ["full"]
    assert attr(document, :flag, "data-overlay") == ["wave"]
    assert attr(document, :flag, "data-border") == [""]
    assert attr(document, :flag, "data-shadow") == [""]
    assert attr(document, :flag, "class") == ["flag-us-square extra"]
    assert attr(document, :flag, "role") == ["img"]
    assert attr(document, :flag, "aria-label") == ["United States"]
    assert attr(document, :flag, "data-role") == ["test"]
  end
end
