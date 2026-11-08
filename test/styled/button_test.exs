defmodule FlintUI.Styled.ButtonTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:button, ~S'''
      def example(assigns) do
        ~H"""
        <.button color={@color} variant="solid" style={@style}>Deploy</.button>
        """
      end

      def text_and_icon(assigns) do
        ~H"""
        <.button icon="lucide-save" text="Save" />
        """
      end

      def slot_wins(assigns) do
        ~H"""
        <.button icon="lucide-save" text="Ignored">Save now</.button>
        """
      end

      def icon_only(assigns) do
        ~H"""
        <.button icon="lucide-search" square aria-label="Search" />
        """
      end

      def justified(assigns) do
        ~H"""
        <.button wide justify={@justify}>
          <:leading><span id="lead">L</span></:leading>
          Save
          <:trailing><span id="trail">T</span></:trailing>
        </.button>
        """
      end

      def inset_all(assigns) do
        ~H"""
        <.button variant="ghost" inset>Dismiss</.button>
        """
      end

      def inset_sides(assigns) do
        ~H"""
        <.button variant="ghost" inset="top bottom">Top and bottom</.button>
        """
      end

      def pill(assigns) do
        ~H"""
        <.button pill>Deploy</.button>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp icon(document), do: LazyHTML.query(document, ~s([data-element="icon"]))

  defp colored(wrapper, color, style \\ nil) do
    render(wrapper, :example, %{color: color, style: style})
  end

  test "a role keeps the data hook and emits no inline color", %{wrapper: wrapper} do
    document = colored(wrapper, "primary")

    assert attr(document, :button, "data-color") == ["primary"]
    assert attr(document, :button, "style") == []
  end

  test "an absolute tone keeps the data hook and emits no inline color", %{wrapper: wrapper} do
    for tone <- ~w(dark light) do
      document = colored(wrapper, tone)

      assert attr(document, :button, "data-color") == [tone]
      assert attr(document, :button, "style") == []
    end
  end

  test "a raw color omits the data hook and sets the public inputs", %{wrapper: wrapper} do
    document = colored(wrapper, "#1D72FE")

    assert attr(document, :button, "data-color") == []
    style = document |> attr(:button, "style") |> List.first()

    assert style =~ "--fl-button-color: #1D72FE"
    assert style =~ "--fl-button-color-content: oklch(0% 0 0)"
    assert style =~ "--fl-button-text: light-dark("
  end

  test "an explicit style wins over the derived inputs", %{wrapper: wrapper} do
    document = colored(wrapper, "#1D72FE", "--fl-button-color-content: white")
    style = document |> attr(:button, "style") |> List.first()

    assert String.ends_with?(style, "; --fl-button-color-content: white")
  end

  test "text and icon are content shortcuts", %{wrapper: wrapper} do
    document = render(wrapper, :text_and_icon)

    assert root(document, :button) |> LazyHTML.text() |> String.trim() == "Save"
    assert LazyHTML.attribute(icon(document), "class") == ["lucide-save"]
    assert LazyHTML.attribute(icon(document), "aria-hidden") == ["true"]
  end

  test "the default slot wins over text", %{wrapper: wrapper} do
    document = render(wrapper, :slot_wins)

    assert root(document, :button) |> LazyHTML.text() |> String.trim() == "Save now"
    refute root(document, :button) |> LazyHTML.text() |> String.contains?("Ignored")
  end

  test "an icon-only button keeps its aria-label", %{wrapper: wrapper} do
    document = render(wrapper, :icon_only)

    assert attr(document, :button, "aria-label") == ["Search"]
    assert LazyHTML.attribute(icon(document), "class") == ["lucide-search"]
  end

  test "justify defaults to center", %{wrapper: wrapper} do
    document = render(wrapper, :text_and_icon)

    assert attr(document, :button, "data-justify") == ["center"]
  end

  test "justify maps onto its data hook alongside wide", %{wrapper: wrapper} do
    document = render(wrapper, :justified, %{justify: "between"})

    assert attr(document, :button, "data-justify") == ["between"]
    assert attr(document, :button, "data-wide") == [""]
  end

  test "a bare inset keeps the all-sides hook", %{wrapper: wrapper} do
    document = render(wrapper, :inset_all)

    assert attr(document, :button, "data-inset") == [""]
  end

  test "a directional inset keeps its space-separated value", %{wrapper: wrapper} do
    document = render(wrapper, :inset_sides)

    assert attr(document, :button, "data-inset") == ["top bottom"]
  end

  test "maps pill onto its data hook", %{wrapper: wrapper} do
    document = render(wrapper, :pill)

    assert attr(document, :button, "data-pill") == [""]
  end
end
