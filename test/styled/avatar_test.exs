defmodule FlintUI.Styled.AvatarTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:avatar, ~S'''
      def defaults(assigns) do
        ~H"""
        <.avatar src="https://example.com/jane.jpg" alt="Jane Doe" />
        """
      end

      def numeric_size(assigns) do
        ~H"""
        <.avatar alt="Jane Doe" size={40} />
        """
      end

      def square(assigns) do
        ~H"""
        <.avatar alt="Jane Doe" shape="square" radius="lg" color="primary" />
        """
      end

      def initials(assigns) do
        ~H"""
        <.avatar alt="Jane Doe" color="initials" />
        """
      end

      def initials_again(assigns) do
        ~H"""
        <.avatar alt="Jane Doe" color="initials" />
        """
      end

      def initials_light_fill(assigns) do
        ~H"""
        <.avatar alt="Green" color="initials" />
        """
      end

      def raw_color(assigns) do
        ~H"""
        <.avatar alt="Jane Doe" color="#1D72FE" />
        """
      end

      def nameless(assigns) do
        ~H"""
        <.avatar />
        """
      end

      def text_only(assigns) do
        ~H"""
        <.avatar text="+3" />
        """
      end

      def custom_icon(assigns) do
        ~H"""
        <.avatar fallback_icon="lucide-users" />
        """
      end

      def custom_fallback(assigns) do
        ~H"""
        <.avatar alt="Jane Doe">
          <:fallback><span id="custom">Custom</span></:fallback>
        </.avatar>
        """
      end

      def forwarded(assigns) do
        ~H"""
        <.avatar
          src="https://example.com/jane.jpg"
          alt="Jane Doe"
          class="extra"
          loading="lazy"
          data-role="test"
          style="object-position: top"
        />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp attr(node, name), do: LazyHTML.attribute(node, name)
  defp fallback(document), do: LazyHTML.query(document, ~s([data-part="fallback"]))
  defp image(document), do: LazyHTML.query(document, ~s([data-part="image"]))
  defp style(document), do: document |> attr(:avatar, "style") |> List.first()

  test "renders the default hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert attr(document, :avatar, "data-avatar") == [""]
    assert attr(document, :avatar, "data-size") == ["md"]
    assert attr(document, :avatar, "data-radius") == ["none"]
    assert attr(document, :avatar, "data-shape") == ["circle"]
    assert attr(document, :avatar, "data-color") == ["neutral"]
    assert attr(image(document), "src") == ["https://example.com/jane.jpg"]
    assert attr(image(document), "alt") == ["Jane Doe"]
    assert LazyHTML.attribute(fallback(document), "hidden") == []
    assert LazyHTML.text(fallback(document)) |> String.trim() == "JD"
  end

  test "converts a numeric size from pixels to rem", %{wrapper: wrapper} do
    document = render(wrapper, :numeric_size)

    assert attr(document, :avatar, "data-size") == []
    assert style(document) =~ "--fl-avatar-size: 2.5rem"
  end

  test "maps shape, radius, and color", %{wrapper: wrapper} do
    document = render(wrapper, :square)

    assert attr(document, :avatar, "data-shape") == ["square"]
    assert attr(document, :avatar, "data-radius") == ["lg"]
    assert attr(document, :avatar, "data-color") == ["primary"]
  end

  test "initials color is deterministic and lives on the root", %{wrapper: wrapper} do
    first = render(wrapper, :initials)
    second = render(wrapper, :initials_again)

    assert attr(first, :avatar, "data-color") == []
    assert style(first) =~ "--fl-avatar-color:"
    assert style(first) =~ "--fl-avatar-color-content:"
    assert style(first) == style(second)
  end

  test "initials keep a white label unless white is unreadable", %{wrapper: wrapper} do
    document = render(wrapper, :initials_light_fill)

    assert style(document) =~ "--fl-avatar-color-content: #{FlintUI.Palette.Color.white()}"
  end

  test "a raw color sets the fallback inputs on the root", %{wrapper: wrapper} do
    document = render(wrapper, :raw_color)

    assert attr(document, :avatar, "data-color") == []
    assert style(document) =~ "--fl-avatar-color: #1D72FE"
    assert style(document) =~ "--fl-avatar-color-content:"
  end

  test "renders the user icon when no alt or text is available", %{wrapper: wrapper} do
    document = render(wrapper, :nameless)

    assert attr(fallback(document), "data-fallback") == ["slot"]

    assert LazyHTML.attribute(LazyHTML.query(document, ~s([data-element="icon"])), "class") ==
             ["lucide-user"]
  end

  test "renders text instead of initials and suppresses the default icon", %{wrapper: wrapper} do
    document = render(wrapper, :text_only)

    assert attr(fallback(document), "data-fallback") == ["text"]
    assert attr(fallback(document), "aria-label") == ["+3"]
    assert LazyHTML.text(fallback(document)) |> String.trim() == "+3"
    assert document |> LazyHTML.query(~s([data-element="icon"])) |> LazyHTML.to_html() == ""
  end

  test "fallback_icon replaces the default icon", %{wrapper: wrapper} do
    document = render(wrapper, :custom_icon)

    assert LazyHTML.attribute(LazyHTML.query(document, ~s([data-element="icon"])), "class") ==
             ["lucide-users"]
  end

  test "a custom fallback slot wins over the default icon", %{wrapper: wrapper} do
    document = render(wrapper, :custom_fallback)

    assert document |> LazyHTML.query(~s(#custom)) |> LazyHTML.text() == "Custom"
    assert document |> LazyHTML.query(~s([data-element="icon"])) |> LazyHTML.to_html() == ""
  end

  test "forwards class to the root and the remaining attributes to the image", %{
    wrapper: wrapper
  } do
    document = render(wrapper, :forwarded)

    assert attr(document, :avatar, "class") == ["extra"]
    assert attr(image(document), "loading") == ["lazy"]
    assert attr(image(document), "data-role") == ["test"]
    assert attr(image(document), "style") == ["object-position: top"]
  end
end
