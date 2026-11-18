defmodule FlintUI.Styled.CopyButtonTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:copy_button, ~S'''
      def defaults(assigns) do
        ~H"""
        <.copy_button from="install-command" />
        """
      end

      def configured(assigns) do
        ~H"""
        <.copy_button
          value="mix flint.add copy_button"
          from="install-command"
          attribute="data-command"
          property="value"
          label="Copy install command"
          success_label="Command copied"
          error_label="Copy failed"
          feedback_duration={800}
          variant="outline"
          dashed
          color="primary"
          size="lg"
          radius="lg"
          pill
          square
          wide
          justify="end"
          depth={false}
          inset="top"
          disabled
          class="extra"
          data-role="test"
        >
          Copy
        </.copy_button>
        """
      end

      def custom_icons(assigns) do
        ~H"""
        <.copy_button
          from="install-command"
          icon="lucide-clipboard"
          success_icon="lucide-thumbs-up"
          error_icon="lucide-thumbs-down"
        >
          <:success><span id="success">Done</span></:success>
          <:error><span id="error">Nope</span></:error>
        </.copy_button>
        """
      end

      def no_icons(assigns) do
        ~H"""
        <.copy_button from="install-command" icon="" success_icon="" error_icon="" />
        """
      end

      def with_aria_label(assigns) do
        ~H"""
        <.copy_button from="install-command" aria-label="Copy install command" />
        """
      end

      def text_only(assigns) do
        ~H"""
        <.copy_button from="install-command" text="Copy" />
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.copy_button from="install-command" color="#1D72FE">Copy</.copy_button>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the defaults onto the data hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :copy_button)) == ["button"]
    assert attr(document, :copy_button, "type") == ["button"]
    assert attr(document, :copy_button, "data-copy_button") == [""]
    assert attr(document, :copy_button, "data-control") == [""]
    assert attr(document, :copy_button, "data-copy") == [""]
    assert attr(document, :copy_button, "data-variant") == ["ghost"]
    assert attr(document, :copy_button, "data-color") == ["neutral"]
    assert attr(document, :copy_button, "data-size") == ["sm"]
    assert attr(document, :copy_button, "data-radius") == ["md"]
    assert attr(document, :copy_button, "data-justify") == ["center"]
    assert attr(document, :copy_button, "data-depth") == [""]
    assert attr(document, :copy_button, "data-square") == [""]
    assert attr(document, :copy_button, "data-copy-from") == ["install-command"]
    assert attr(document, :copy_button, "aria-label") == ["Copy"]
    assert attr(document, :copy_button, "data-state") == []
  end

  test "renders the default copy icon in a square icon-only button", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert Enum.count(LazyHTML.query(document, ".lucide-copy")) == 1
    assert Enum.count(LazyHTML.query(document, ~s([data-element="icon"]))) == 3
    assert count_part(document, "success_state") == 1
    assert count_part(document, "error_state") == 1
    assert LazyHTML.text(part(document, "copy_state")) |> String.trim() == ""
  end

  test "maps every override and forwards the base contract", %{wrapper: wrapper} do
    document = render(wrapper, :configured)

    assert attr(document, :copy_button, "data-copy-value") == ["mix flint.add copy_button"]
    assert attr(document, :copy_button, "data-copy-from") == ["install-command"]
    assert attr(document, :copy_button, "data-copy-attribute") == ["data-command"]
    assert attr(document, :copy_button, "data-copy-property") == ["value"]
    assert attr(document, :copy_button, "aria-label") == ["Copy install command"]
    assert attr(document, :copy_button, "data-copy-success-label") == ["Command copied"]
    assert attr(document, :copy_button, "data-copy-error-label") == ["Copy failed"]
    assert attr(document, :copy_button, "data-copy-duration") == ["800"]
    assert attr(document, :copy_button, "data-variant") == ["outline"]
    assert attr(document, :copy_button, "data-dashed") == [""]
    assert attr(document, :copy_button, "data-color") == ["primary"]
    assert attr(document, :copy_button, "data-size") == ["lg"]
    assert attr(document, :copy_button, "data-radius") == ["lg"]
    assert attr(document, :copy_button, "data-pill") == [""]
    assert attr(document, :copy_button, "data-square") == [""]
    assert attr(document, :copy_button, "data-wide") == [""]
    assert attr(document, :copy_button, "data-justify") == ["end"]
    assert attr(document, :copy_button, "data-depth") == []
    assert attr(document, :copy_button, "data-inset") == ["top"]
    assert attr(document, :copy_button, "disabled") == [""]
    assert attr(document, :copy_button, "data-disabled") == [""]
    assert attr(document, :copy_button, "class") == ["extra"]
    assert attr(document, :copy_button, "data-role") == ["test"]
    assert LazyHTML.text(part(document, "copy_state")) |> String.trim() == "Copy"
  end

  test "a visible label keeps the inline padding instead of a square box", %{wrapper: wrapper} do
    document = render(wrapper, :text_only)

    assert attr(document, :copy_button, "data-square") == []
    assert LazyHTML.text(part(document, "copy_state")) |> String.trim() == "Copy"
  end

  test "a raw color writes the shared control inputs", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)
    style = document |> attr(:copy_button, "style") |> List.first()

    assert attr(document, :copy_button, "data-color") == []
    assert style =~ "--fl-control-color: #1D72FE"
    assert style =~ "--fl-control-color-content"
    assert style =~ "--fl-control-text"
  end

  test "renders custom icons and state content", %{wrapper: wrapper} do
    document = render(wrapper, :custom_icons)

    assert Enum.count(LazyHTML.query(document, ".lucide-clipboard")) == 1
    assert Enum.count(LazyHTML.query(document, ".lucide-thumbs-up")) == 1
    assert Enum.count(LazyHTML.query(document, ".lucide-thumbs-down")) == 1
    assert LazyHTML.text(part(document, "success_state")) =~ "Done"
    assert LazyHTML.text(part(document, "error_state")) =~ "Nope"
  end

  test "can omit the decorative icons", %{wrapper: wrapper} do
    document = render(wrapper, :no_icons)

    assert document |> LazyHTML.query(~s([data-element="icon"])) |> LazyHTML.to_html() == ""
    assert count_part(document, "success_state") == 0
    assert count_part(document, "error_state") == 0
  end

  test "allows a caller aria-label to override the default", %{wrapper: wrapper} do
    document = render(wrapper, :with_aria_label)

    assert attr(document, :copy_button, "aria-label") == ["Copy install command"]
  end
end
