defmodule FlintUI.Styled.ContainerTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:container, ~S'''
      def defaults(assigns) do
        ~H"""
        <.container>
          <p>First</p>
          <p>Second</p>
        </.container>
        """
      end

      def token(assigns) do
        ~H"""
        <.container size="md" class="custom" id="container" role="region" aria-label="Intro">
          <p>First</p>
        </.container>
        """
      end

      def fluid(assigns) do
        ~H"""
        <.container size="fluid">
          <p>First</p>
        </.container>
        """
      end

      def numeric(assigns) do
        ~H"""
        <.container size={720}>
          <p>First</p>
        </.container>
        """
      end

      def css_length(assigns) do
        ~H"""
        <.container size="48rem">
          <p>First</p>
        </.container>
        """
      end

      def responsive(assigns) do
        ~H"""
        <.container size={%{"2xl" => "7xl", base: "sm", md: "xl"}}>
          <p>First</p>
        </.container>
        """
      end

      def responsive_arbitrary(assigns) do
        ~H"""
        <.container size={%{md: "48rem", xl: 960}}>
          <p>First</p>
        </.container>
        """
      end

      def as_section(assigns) do
        ~H"""
        <.container as="section" size="md" class="custom" aria-labelledby="intro-title">
          <h2 id="intro-title">Intro</h2>
        </.container>
        """
      end

      def user_style(assigns) do
        ~H"""
        <.container size="48rem" style="--fl-container-size: 10px">
          <p>First</p>
        </.container>
        """
      end

      def invalid(assigns) do
        ~H"""
        <.container size={%{foo: "md"}}>
          <p>First</p>
        </.container>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the default container hooks and token", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :container)) == ["div"]
    assert attr(document, :container, "data-container") == [""]
    assert attr(document, :container, "data-size") == ["6xl"]
    assert attr(document, :container, "style") == []
    assert attr(document, :container, "class") == []
  end

  test "maps a token onto the data-size hook", %{wrapper: wrapper} do
    document = render(wrapper, :token)

    assert attr(document, :container, "data-size") == ["md"]
    assert attr(document, :container, "style") == []
  end

  test "maps fluid onto the data-size hook", %{wrapper: wrapper} do
    document = render(wrapper, :fluid)

    assert attr(document, :container, "data-size") == ["fluid"]
    assert attr(document, :container, "style") == []
  end

  test "converts a numeric size from pixels to rem", %{wrapper: wrapper} do
    document = render(wrapper, :numeric)

    assert attr(document, :container, "data-size") == []
    assert attr(document, :container, "style") == ["--fl-container-size: 45rem"]
  end

  test "uses an arbitrary CSS length as written", %{wrapper: wrapper} do
    document = render(wrapper, :css_length)

    assert attr(document, :container, "data-size") == []
    assert attr(document, :container, "style") == ["--fl-container-size: 48rem"]
  end

  test "writes breakpoint overrides from a size map", %{wrapper: wrapper} do
    document = render(wrapper, :responsive)

    assert attr(document, :container, "data-size") == ["sm"]

    assert attr(document, :container, "style") == [
             "--fl-container-size-md: var(--fl-container-xl); " <>
               "--fl-container-size-2xl: var(--fl-container-7xl)"
           ]
  end

  test "accepts arbitrary and numeric breakpoint values", %{wrapper: wrapper} do
    document = render(wrapper, :responsive_arbitrary)

    assert attr(document, :container, "data-size") == []

    assert attr(document, :container, "style") == [
             "--fl-container-size-md: 48rem; --fl-container-size-xl: 60rem"
           ]
  end

  test "forwards as, class, and rest attributes", %{wrapper: wrapper} do
    document = render(wrapper, :as_section)

    assert LazyHTML.tag(root(document, :container)) == ["section"]
    assert attr(document, :container, "data-size") == ["md"]
    assert attr(document, :container, "class") == ["custom"]
    assert attr(document, :container, "aria-labelledby") == ["intro-title"]
  end

  test "keeps the caller style after the generated declaration", %{wrapper: wrapper} do
    document = render(wrapper, :user_style)

    assert attr(document, :container, "style") == [
             "--fl-container-size: 48rem; --fl-container-size: 10px"
           ]
  end

  test "renders the container's children", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert root(document, :container) |> LazyHTML.text() |> String.split() == [
             "First",
             "Second"
           ]
  end

  test "raises for an unknown breakpoint key", %{wrapper: wrapper} do
    assert_raise ArgumentError, ~r/unknown container size breakpoint/, fn ->
      render(wrapper, :invalid)
    end
  end

  test "the theme part uses the shared breakpoints" do
    css = File.read!(FlintUI.Generator.part_path("styled/container.css"))

    for {_name, width} <- FlintUI.Utilities.breakpoints() do
      assert css =~ "@media (min-width: #{width})"
    end
  end
end
