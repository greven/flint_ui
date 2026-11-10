defmodule FlintUI.Styled.IconTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:icon, ~S'''
      def defaults(assigns) do
        ~H"""
        <.icon name="lucide-house" />
        """
      end

      def sized(assigns) do
        ~H"""
        <.icon
          name="lucide-search"
          size="lg"
          class="text-red-500"
          label="Search"
          data-role="test"
        />
        """
      end

      def numeric(assigns) do
        ~H"""
        <.icon name="lucide-star" size={40} style="opacity: 0.5" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "maps the default size and keeps the icon decorative", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :icon)) == ["span"]
    assert attr(document, :icon, "data-icon") == [""]
    assert attr(document, :icon, "data-size") == ["md"]
    assert attr(document, :icon, "class") == ["lucide-house"]
    assert attr(document, :icon, "aria-hidden") == ["true"]
  end

  test "maps the size and forwards the icon name, class, label, and globals", %{
    wrapper: wrapper
  } do
    document = render(wrapper, :sized)

    assert attr(document, :icon, "data-size") == ["lg"]
    assert "lucide-search" in classes(document)
    assert "text-red-500" in classes(document)
    assert attr(document, :icon, "role") == ["img"]
    assert attr(document, :icon, "aria-label") == ["Search"]
    assert attr(document, :icon, "data-role") == ["test"]
  end

  test "a numeric size writes the icon input instead of a data hook", %{wrapper: wrapper} do
    document = render(wrapper, :numeric)

    assert attr(document, :icon, "data-size") == []

    assert attr(document, :icon, "style") == [
             "--fl-icon-size: 2.5rem; opacity: 0.5"
           ]

    assert "lucide-star" in classes(document)
  end

  defp classes(document) do
    document
    |> attr(:icon, "class")
    |> Enum.join(" ")
    |> String.split(" ", trim: true)
  end
end
