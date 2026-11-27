defmodule FlintUI.Styled.ClusterTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:cluster, ~S'''
      def defaults(assigns) do
        ~H"""
        <.cluster>
          <span>Design</span>
          <span>Shipped</span>
        </.cluster>
        """
      end

      def semantic(assigns) do
        ~H"""
        <.cluster as="section" aria-labelledby="cluster-title" class="custom">
          <h2 id="cluster-title">Statuses</h2>
        </.cluster>
        """
      end

      def custom(assigns) do
        ~H"""
        <.cluster
          align="start"
          gap="lg"
          justify="between"
          class="custom"
          id="cluster"
          role="group"
          aria-label="Statuses"
        >
          <span>Design</span>
        </.cluster>
        """
      end

      def split(assigns) do
        ~H"""
        <.cluster justify="split" gap="sm">
          <span>Deployment</span>
          <span>Redeploy</span>
        </.cluster>
        """
      end

      def list(assigns) do
        ~H"""
        <.cluster as="ul" gap="sm">
          <li>Design</li>
          <li>Shipped</li>
        </.cluster>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  test "renders the cluster with the default layout hooks", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert LazyHTML.tag(root(document, :cluster)) == ["div"]
    assert attr(document, :cluster, "data-cluster") == [""]
    assert attr(document, :cluster, "data-align") == ["center"]
    assert attr(document, :cluster, "data-gap") == ["md"]
    assert attr(document, :cluster, "data-justify") == ["start"]
    assert attr(document, :cluster, "class") == []
  end

  test "maps align, gap, and justify onto their hooks", %{wrapper: wrapper} do
    document = render(wrapper, :custom)

    assert attr(document, :cluster, "data-align") == ["start"]
    assert attr(document, :cluster, "data-gap") == ["lg"]
    assert attr(document, :cluster, "data-justify") == ["between"]
  end

  test "renders the element chosen by as and keeps the cluster hooks", %{wrapper: wrapper} do
    document = render(wrapper, :semantic)

    assert LazyHTML.tag(root(document, :cluster)) == ["section"]
    assert attr(document, :cluster, "data-cluster") == [""]
    assert attr(document, :cluster, "data-align") == ["center"]
    assert attr(document, :cluster, "data-list") == []
    assert attr(document, :cluster, "aria-labelledby") == ["cluster-title"]
  end

  test "maps split onto the justify hook", %{wrapper: wrapper} do
    document = render(wrapper, :split)

    assert attr(document, :cluster, "data-justify") == ["split"]
    assert attr(document, :cluster, "data-gap") == ["sm"]
  end

  test "marks a list root for the list reset", %{wrapper: wrapper} do
    document = render(wrapper, :list)

    assert LazyHTML.tag(root(document, :cluster)) == ["ul"]
    assert attr(document, :cluster, "data-list") == [""]
    assert LazyHTML.tag(LazyHTML.query(root(document, :cluster), "li")) == ["li", "li"]
  end

  test "forwards class and rest attributes", %{wrapper: wrapper} do
    document = render(wrapper, :custom)

    assert attr(document, :cluster, "class") == ["custom"]
    assert attr(document, :cluster, "id") == ["cluster"]
    assert attr(document, :cluster, "role") == ["group"]
    assert attr(document, :cluster, "aria-label") == ["Statuses"]
  end

  test "renders the clustered children", %{wrapper: wrapper} do
    document = render(wrapper, :defaults)

    assert root(document, :cluster) |> LazyHTML.text() |> String.split() == ["Design", "Shipped"]
  end
end
