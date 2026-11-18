defmodule FlintUI.Base.CopyButtonTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def copy_example(assigns) do
      ~H"""
      <.copy_button
        value={@value}
        from={@from}
        attribute={@attribute}
        property={@property}
        label={@label}
        success_label={@success_label}
        error_label={@error_label}
        feedback_duration={@feedback_duration}
        disabled={@disabled}
        data-role="test"
      >
        Copy
        <:success><span id="success-content">Copied!</span></:success>
        <:error><span id="error-content">Failed!</span></:error>
      </.copy_button>
      """
    end

    def without_states(assigns) do
      ~H"""
      <.copy_button value="hello" aria-label="Copy greeting">Copy</.copy_button>
      """
    end

    def overrides_aria(assigns) do
      ~H"""
      <.copy_button value="hello" aria-label="Copy greeting">Hello</.copy_button>
      """
    end
  end

  @defaults %{
    value: nil,
    from: nil,
    attribute: nil,
    property: nil,
    label: "Copy",
    success_label: "Copied",
    error_label: "Copy failed",
    feedback_duration: 2000,
    disabled: false
  }

  defp raw(overrides) do
    render_component(&TestComponent.copy_example/1, Map.merge(@defaults, Map.new(overrides)))
  end

  defp render(overrides \\ %{}) do
    raw(overrides) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp tag(html), do: LazyHTML.tag(root(html))
  defp attr(html, name), do: LazyHTML.attribute(root(html), name)

  describe "rendering" do
    test "renders a native button that never submits" do
      html = render()

      assert tag(html) == ["button"]
      assert attr(html, "type") == ["button"]
      assert attr(html, "data-element") == ["copy_button"]
      assert attr(html, "data-part") == ["root"]
      assert attr(html, "data-control") == []
      assert attr(html, "disabled") == []
      assert attr(html, "data-disabled") == []
    end

    test "marks the trigger and carries the default feedback contract" do
      html = render()

      assert attr(html, "data-copy") == [""]
      assert attr(html, "aria-label") == ["Copy"]
      assert attr(html, "data-copy-duration") == ["2000"]
      assert attr(html, "data-copy-success-label") == ["Copied"]
      assert attr(html, "data-copy-error-label") == ["Copy failed"]
      assert attr(html, "data-state") == []
    end

    test "stacks the states in the state wrapper" do
      html = render()

      assert Enum.count(LazyHTML.query(html, ~s([data-part="states"]))) == 1
    end

    test "renders the default content in the copy state" do
      html = render()

      text =
        html
        |> LazyHTML.query(~s([data-part="copy_state"]))
        |> LazyHTML.text()
        |> String.trim()

      assert text == "Copy"
    end

    test "renders the success and error content as decorative state content" do
      html = render()

      success = LazyHTML.query(html, ~s([data-part="success_state"]))
      error = LazyHTML.query(html, ~s([data-part="error_state"]))

      assert success |> LazyHTML.text() |> String.trim() == "Copied!"
      assert error |> LazyHTML.text() |> String.trim() == "Failed!"
      assert LazyHTML.attribute(success, "aria-hidden") == ["true"]
      assert LazyHTML.attribute(error, "aria-hidden") == ["true"]
    end

    test "omits a state part when its slot is not given" do
      html =
        render_component(&TestComponent.without_states/1, %{})
        |> LazyHTML.from_fragment()

      assert Enum.count(LazyHTML.query(html, ~s([data-part="success_state"]))) == 0
      assert Enum.count(LazyHTML.query(html, ~s([data-part="error_state"]))) == 0
    end

    test "passes through global attributes" do
      assert attr(render(), "data-role") == ["test"]
    end
  end

  describe "sources" do
    test "renders a literal value" do
      html = render(value: "mix flint.add copy_button")

      assert attr(html, "data-copy-value") == ["mix flint.add copy_button"]
      assert attr(html, "data-copy-from") == []
    end

    test "renders the target id and the optional attribute or property" do
      html = render(from: "install-command", attribute: "data-command")

      assert attr(html, "data-copy-from") == ["install-command"]
      assert attr(html, "data-copy-attribute") == ["data-command"]
      assert attr(html, "data-copy-property") == []

      html = render(from: "email", property: "value")

      assert attr(html, "data-copy-property") == ["value"]
      assert attr(html, "data-copy-attribute") == []
    end

    test "keeps both sources when they are both set" do
      html = render(value: "literal", from: "target")

      assert attr(html, "data-copy-value") == ["literal"]
      assert attr(html, "data-copy-from") == ["target"]
    end
  end

  describe "states" do
    test "disables the native button and marks the visual state" do
      html = render(disabled: true)

      assert attr(html, "disabled") == [""]
      assert attr(html, "data-disabled") == [""]
    end

    test "uses the configured labels and duration" do
      html =
        render(success_label: "Link copied", error_label: "Try again", feedback_duration: 800)

      assert attr(html, "data-copy-success-label") == ["Link copied"]
      assert attr(html, "data-copy-error-label") == ["Try again"]
      assert attr(html, "data-copy-duration") == ["800"]
    end
  end

  describe "accessibility" do
    test "keeps the accessible name stable across states" do
      html = render(label: "Copy install command")

      assert attr(html, "aria-label") == ["Copy install command"]
    end

    test "allows a caller aria-label to override the label attribute" do
      html =
        render_component(&TestComponent.overrides_aria/1, %{})
        |> LazyHTML.from_fragment()

      assert attr(html, "aria-label") == ["Copy greeting"]
      assert length(LazyHTML.attribute(root(html), "aria-label")) == 1
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :copy_button, type: :action, status: :draft} =
               FlintUI.Base.CopyButton.meta()

      assert is_list(FlintUI.Base.CopyButton.parts_attrs())
      assert FlintUI.Base.CopyButton.parts_attrs() |> Enum.any?()
      assert Enum.any?(FlintUI.Base.CopyButton.parts_attrs(), &(elem(&1, 0) == :states))
      assert [%FlintUI.Meta.Keyboard{keys: "Tab"} | _] = FlintUI.Base.CopyButton.keyboard()
      assert Enum.any?(FlintUI.Base.CopyButton.states(), &(&1.name == "success"))
      assert Enum.any?(FlintUI.Base.CopyButton.states(), &(&1.name == "error"))
    end
  end
end
