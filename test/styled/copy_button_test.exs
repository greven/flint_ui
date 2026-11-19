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
        <.copy_button from="install-command" text="Copy token" />
        """
      end

      def text_with_label(assigns) do
        ~H"""
        <.copy_button from="install-command" text="Copy" label="Copy install command" />
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.copy_button from="install-command" color="#1D72FE">Copy</.copy_button>
        """
      end

      def with_tooltip(assigns) do
        ~H"""
        <.copy_button
          from="install-command"
          label="Copy install command"
          success_label="Command copied"
          error_label="Nothing to copy"
          tooltip="right"
          class="extra"
          data-role="test"
        />
        """
      end

      def with_default_tooltip(assigns) do
        ~H"""
        <.copy_button from="install-command" tooltip />
        """
      end

      def with_success_color(assigns) do
        ~H"""
        <.copy_button from="install-command" success_color="success">Copy</.copy_button>
        """
      end

      def with_success_slot_and_text(assigns) do
        ~H"""
        <.copy_button from="install-command" text="Copy">
          <:success>Copied</:success>
        </.copy_button>
        """
      end

      def with_success_slot_only(assigns) do
        ~H"""
        <.copy_button from="install-command">
          <:success>Copied</:success>
        </.copy_button>
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

  test "omits the tooltip and the success color by default", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert Enum.count(LazyHTML.query(document, ~s([data-element="tooltip"]))) == 0
    assert attr(document, :copy_button, "data-success-color") == []
  end

  test "wraps the button in a state-aware tooltip", %{wrapper: wrapper} do
    document = render(wrapper, :with_tooltip)
    tooltip = LazyHTML.query(document, ~s([data-element="tooltip"]))

    assert Enum.count(tooltip) == 1
    assert LazyHTML.attribute(tooltip, "data-tooltip") == [""]
    assert LazyHTML.attribute(tooltip, "data-copy-tooltip") == [""]
    assert LazyHTML.attribute(tooltip, "data-placement") == ["right"]

    assert attr(document, :copy_button, "data-part") == ["root"]
    assert attr(document, :copy_button, "class") == ["extra"]
    assert attr(document, :copy_button, "data-role") == ["test"]

    for {state, text} <- [
          {"idle", "Copy install command"},
          {"success", "Command copied"},
          {"error", "Nothing to copy"}
        ] do
      span = LazyHTML.query(document, ~s([data-copy-tooltip-text="#{state}"]))
      assert LazyHTML.text(span) |> String.trim() == text
    end
  end

  test "a bare tooltip defaults to the top placement", %{wrapper: wrapper} do
    document = render(wrapper, :with_default_tooltip)
    tooltip = LazyHTML.query(document, ~s([data-element="tooltip"]))

    assert Enum.count(tooltip) == 1
    assert LazyHTML.attribute(tooltip, "data-placement") == ["top"]
  end

  test "recolors the control for the success state", %{wrapper: wrapper} do
    document = render(wrapper, :with_success_color)

    assert attr(document, :copy_button, "data-success-color") == ["success"]
  end

  test "text renders when the body contains only a named slot", %{wrapper: wrapper} do
    document = render(wrapper, :with_success_slot_and_text)

    assert attr(document, :copy_button, "aria-label") == ["Copy"]
    assert attr(document, :copy_button, "data-square") == []
    assert LazyHTML.text(part(document, "copy_state")) |> String.trim() == "Copy"
    assert LazyHTML.text(part(document, "success_state")) =~ "Copied"
  end

  test "a named slot alone keeps the icon-only square box", %{wrapper: wrapper} do
    document = render(wrapper, :with_success_slot_only)

    assert attr(document, :copy_button, "data-square") == [""]
    assert LazyHTML.text(part(document, "copy_state")) |> String.trim() == ""
    assert LazyHTML.text(part(document, "success_state")) =~ "Copied"
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

  test "text becomes the accessible name and keeps the inline padding", %{wrapper: wrapper} do
    document = render(wrapper, :text_only)

    assert attr(document, :copy_button, "data-square") == []
    assert attr(document, :copy_button, "aria-label") == ["Copy token"]
    assert LazyHTML.text(part(document, "copy_state")) |> String.trim() == "Copy token"
  end

  test "an explicit label wins over text", %{wrapper: wrapper} do
    document = render(wrapper, :text_with_label)

    assert attr(document, :copy_button, "aria-label") == ["Copy install command"]
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
