defmodule FlintUI.Styled.LabelTest do
  use FlintUI.StyledCase, async: true

  setup_all do
    wrapper =
      compile_wrapper!(:label, ~S'''
      def basic(assigns) do
        ~H"""
        <.label
          for={@for}
          label={@label}
          sublabel={@sublabel}
          required={@required}
          description={@description}
          size={@size}
          class={@class}
        />
        """
      end

      def custom(assigns) do
        ~H"""
        <.label for="email" label="Ignored">
          <strong>Custom label</strong>
        </.label>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        for: "email",
        label: "Email",
        sublabel: "Optional",
        required: false,
        description: "We only use this for receipts.",
        size: "md",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the label root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :label, "data-element") == ["label"]
    assert attr(document, :label, "data-label") == [""]
    assert attr(document, :label, "data-size") == ["md"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))

      assert attr(document, :label, "data-size") == [size]
    end
  end

  test "forwards the label, sublabel, description, and for", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert part_attr(document, "label", "for") == ["email"]
    assert LazyHTML.text(part(document, "label")) =~ "Email"
    assert LazyHTML.text(part(document, "sublabel")) |> String.trim() == "Optional"

    assert LazyHTML.text(part(document, "description")) |> String.trim() ==
             "We only use this for receipts."

    assert part_attr(document, "description", "id") == ["email-description"]
  end

  test "renders the required marker and state", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(required: true))

    assert attr(document, :label, "data-required") == [""]
    assert LazyHTML.text(part(document, "required")) |> String.trim() == "*"
    assert part_attr(document, "required", "aria-hidden") == ["true"]
  end

  test "custom inner content replaces the label", %{wrapper: wrapper} do
    document = render(wrapper, :custom, %{})

    assert LazyHTML.text(part(document, "label")) =~ "Custom label"
    refute LazyHTML.text(part(document, "label")) =~ "Ignored"
  end

  test "keeps the root hooks off the native label", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg"))

    assert part_attr(document, "label", "data-size") == []
    assert part_attr(document, "label", "data-label") == []
  end

  test "forwards the caller class to the label root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "font-medium"))

    assert attr(document, :label, "class") == ["font-medium"]
    assert part_attr(document, "label", "class") == []
  end
end
