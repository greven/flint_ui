defmodule FlintUI.Base.LabelTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.label
        for={@for}
        label={@label}
        sublabel={@sublabel}
        required={@required}
        description={@description}
        class={@class}
      />
      """
    end

    def inner_block(assigns) do
      ~H"""
      <.label for="email" label="Ignored">
        <strong>Email</strong>
      </.label>
      """
    end

    def rest_attrs(assigns) do
      ~H"""
      <.label
        id="email-label"
        label="Email"
        description="We only use this for receipts."
        data-test="label"
      />
      """
    end
  end

  @defaults %{
    for: "email",
    label: "Email",
    sublabel: nil,
    required: false,
    description: nil,
    class: nil
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.basic/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp label(html), do: LazyHTML.query(html, ~s([data-part="label"]))
  defp description(html), do: LazyHTML.query(html, ~s([data-part="description"]))

  test "renders a native label associated through for" do
    html = render()

    assert root_attr(html, "data-element") == ["label"]
    assert LazyHTML.tag(label(html)) == ["label"]
    assert LazyHTML.attribute(label(html), "for") == ["email"]
    assert LazyHTML.text(label(html)) |> String.trim() == "Email"
  end

  test "renders the sublabel after the label text inside the label" do
    html = render(sublabel: "Optional")

    text = LazyHTML.query(html, ~s([data-part="label_text"]))
    assert LazyHTML.text(text) =~ ~r/Email\s+Optional/

    sublabel = LazyHTML.query(html, ~s([data-part="sublabel"]))
    assert LazyHTML.text(sublabel) |> String.trim() == "Optional"
    assert LazyHTML.text(label(html)) =~ "Optional"
  end

  test "renders a decorative required marker after the label text" do
    html = render(required: true)

    assert root_attr(html, "data-required") == [""]

    marker = LazyHTML.query(html, ~s([data-part="required"]))
    assert LazyHTML.text(marker) |> String.trim() == "*"
    assert LazyHTML.attribute(marker, "aria-hidden") == ["true"]
    assert LazyHTML.text(label(html)) =~ ~r/Email\s+\*/
  end

  test "omits the required marker when the label is not required" do
    html = render()

    assert root_attr(html, "data-required") == []
    assert Enum.count(LazyHTML.query(html, ~s([data-part="required"]))) == 0
  end

  test "renders the description outside the label with a derived id" do
    html = render(description: "We only use this for receipts.")

    assert LazyHTML.attribute(description(html), "id") == ["email-description"]
    assert LazyHTML.text(description(html)) |> String.trim() == "We only use this for receipts."
    refute LazyHTML.text(label(html)) =~ "receipts"
  end

  test "derives the description id from the root id when for is absent" do
    html =
      render_component(&TestComponent.rest_attrs/1, %{}) |> LazyHTML.from_fragment()

    assert LazyHTML.attribute(label(html), "id") == ["email-label"]
    assert LazyHTML.attribute(label(html), "data-test") == ["label"]
    assert LazyHTML.attribute(description(html), "id") == ["email-label-description"]
  end

  test "omits the description id when there is nothing to derive it from" do
    html = render(for: nil, description: "A visual note.")

    assert LazyHTML.attribute(description(html), "id") == []
  end

  test "omits the description when it is not set" do
    html = render()

    assert Enum.count(description(html)) == 0
  end

  test "custom inner content replaces the label" do
    html =
      render_component(&TestComponent.inner_block/1, %{}) |> LazyHTML.from_fragment()

    assert LazyHTML.text(label(html)) =~ "Email"
    refute LazyHTML.text(label(html)) =~ "Ignored"
  end

  test "puts the caller class on the root and keeps hooks off the label" do
    html = render(class: "font-medium")

    assert root_attr(html, "class") == ["font-medium"]
    assert LazyHTML.attribute(label(html), "class") == []
  end

  test "declares a documented contract in DOM order" do
    assert %FlintUI.Meta{name: :label, type: :form} = FlintUI.Base.Label.meta()

    assert [:root, :label, :label_text, :required, :sublabel, :description] ==
             FlintUI.Base.Label.parts_attrs() |> Enum.map(&elem(&1, 0))

    assert FlintUI.Base.Label.parts_attrs()
           |> Enum.all?(fn {_part, attrs} ->
             Enum.any?(attrs, &(&1.name == "[data-part]"))
           end)
  end
end
