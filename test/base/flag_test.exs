defmodule FlintUI.Base.FlagTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def default_example(assigns) do
      ~H"""
      <.flag code="pt" />
      """
    end

    def flag_example(assigns) do
      ~H"""
      <.flag
        code={@code}
        shape={@shape}
        path={@path}
        class={@class}
        label={@label}
        style={@style}
        phx-click="clicked"
        data-role="test"
      />
      """
    end
  end

  defp render(overrides \\ %{}) do
    assigns =
      Map.merge(
        %{code: "pt", shape: "regular", path: nil, class: nil, label: nil, style: nil},
        Map.new(overrides)
      )

    render_component(&TestComponent.flag_example/1, assigns) |> LazyHTML.from_fragment()
  end

  defp default_fragment do
    render_component(&TestComponent.default_example/1, %{}) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  defp class_list(html),
    do: attr(html, "class") |> Enum.join(" ") |> String.split(" ", trim: true)

  describe "flag" do
    test "builds the 4:3 URL from the code" do
      html = default_fragment()

      assert tag(html) == ["span"]
      assert attr(html, "data-element") == ["flag"]
      assert attr(html, "data-name") == ["flag-pt"]
      assert attr(html, "data-shape") == ["regular"]
      assert attr(html, "style") == [~s|background-image: url("/images/flags/pt.svg")|]
      assert class_list(html) == []
    end

    test "maps square and round to the 1:1 URL" do
      html = render(shape: "square")
      assert attr(html, "data-name") == ["flag-pt-square"]
      assert attr(html, "data-shape") == ["square"]
      assert attr(html, "style") == [~s|background-image: url("/images/flags/pt-square.svg")|]

      html = render(shape: "round")
      assert attr(html, "data-name") == ["flag-pt-square"]
      assert attr(html, "data-shape") == ["round"]
      assert attr(html, "style") == [~s|background-image: url("/images/flags/pt-square.svg")|]
    end

    test "normalizes the code" do
      html = render(code: "  PT ")
      assert attr(html, "data-name") == ["flag-pt"]
      assert attr(html, "style") == [~s|background-image: url("/images/flags/pt.svg")|]
    end

    test "rejects a code that would break the URL" do
      assert_raise ArgumentError, ~r/invalid flag code/, fn ->
        render(code: "pt'); color: red; x: url('")
      end
    end

    test "path overrides the default asset base" do
      html = render(path: "/assets/flags/")
      assert attr(html, "style") == [~s|background-image: url("/assets/flags/pt.svg")|]
    end

    test "merges a caller style after the background image" do
      html = render(style: "opacity: 0.5")

      assert attr(html, "style") == [
               ~s|background-image: url("/images/flags/pt.svg"); opacity: 0.5|
             ]
    end

    test "is decorative by default" do
      html = render()

      assert attr(html, "aria-hidden") == ["true"]
      assert attr(html, "role") == []
      assert attr(html, "aria-label") == []
    end

    test "keeps extra classes" do
      html = render(class: "rounded shadow")
      classes = class_list(html)

      assert "rounded" in classes
      assert "shadow" in classes
    end

    test "a label exposes the flag as an image" do
      html = render(label: "Portugal")

      assert attr(html, "role") == ["img"]
      assert attr(html, "aria-label") == ["Portugal"]
      assert attr(html, "aria-hidden") == []
    end

    test "passes through global attributes" do
      html = render()

      assert attr(html, "phx-click") == ["clicked"]
      assert attr(html, "data-role") == ["test"]
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :flag, type: :element} = FlintUI.Base.Flag.meta()

      parts = FlintUI.Base.Flag.parts_attrs()

      assert %FlintUI.Meta.PartAttr{value: "flag"} =
               Enum.find(parts.root, &(&1.name == "[data-element]"))

      assert %FlintUI.Meta.PartAttr{name: "[data-name]"} =
               Enum.find(parts.root, &(&1.name == "[data-name]"))
    end
  end
end
