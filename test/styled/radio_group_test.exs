defmodule FlintUI.Styled.RadioGroupTest do
  use FlintUI.StyledCase, async: true

  alias Phoenix.Component

  setup_all do
    wrapper =
      compile_wrapper!(:radio_group, ~S'''
      def group_basic(assigns) do
        ~H"""
        <.radio_group
          id="plan"
          name="plan"
          label="Plan"
          description={@description}
          value={@value}
          orientation={@orientation}
          variant={@variant}
          size={@size}
          radius={@radius}
          class={@class}
        >
          <:radio value="free" label="Free" sublabel="Recommended" />
          <:radio value="pro" label="Pro" />
          <:radio value="team" label="Team" disabled />
        </.radio_group>
        """
      end

      def field_group(assigns) do
        ~H"""
        <.radio_group field={@field} label="Plan">
          <:radio value="free" label="Free" />
          <:radio value="pro" label="Pro" />
        </.radio_group>
        """
      end

      def inner_group(assigns) do
        ~H"""
        <.radio_group name="plan">
          <:radio value="pro" label="Ignored">
            <strong>Pro plan</strong>
          </:radio>
        </.radio_group>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        description: nil,
        value: nil,
        orientation: "vertical",
        variant: "simple",
        size: "md",
        radius: "sm",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps orientation and variant onto the group root", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults())

    assert attr(document, :radio_group, "data-element") == ["radio_group"]
    assert attr(document, :radio_group, "data-radio_group") == [""]
    assert attr(document, :radio_group, "data-orientation") == ["vertical"]
    assert attr(document, :radio_group, "data-variant") == ["simple"]
  end

  test "forwards variant, size, and radius to every radio", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults(variant: "card", size: "lg", radius: "xl"))

    roots = LazyHTML.query(document, ~s([data-element="radio"][data-radio]))

    assert Enum.count(roots) == 3

    for root <- roots do
      assert LazyHTML.attribute(root, "data-variant") == ["card"]
      assert LazyHTML.attribute(root, "data-size") == ["lg"]
      assert LazyHTML.attribute(root, "data-radius") == ["xl"]
    end
  end

  test "renders every orientation and variant", %{wrapper: wrapper} do
    for orientation <- ~w(vertical horizontal), variant <- ~w(simple card) do
      document =
        render(wrapper, :group_basic, defaults(orientation: orientation, variant: variant))

      assert attr(document, :radio_group, "data-orientation") == [orientation]
      assert attr(document, :radio_group, "data-variant") == [variant]
    end
  end

  test "renders the fieldset, legend, and no hidden input", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults())

    assert LazyHTML.tag(LazyHTML.query(document, "fieldset")) == ["fieldset"]

    assert LazyHTML.text(LazyHTML.query(document, "legend")) |> String.trim() == "Plan"

    assert Enum.count(LazyHTML.query(document, ~s(input[type="hidden"]))) == 0
  end

  test "checks the option from the group value", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults(value: "pro"))

    checked = LazyHTML.query(document, ~s([data-part="control"][checked]))
    assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["pro"]]
  end

  test "forwards a field struct", %{wrapper: wrapper} do
    form = Component.to_form(%{"plan" => "pro"}, as: :user)
    document = render(wrapper, :field_group, %{field: form[:plan]})

    names = LazyHTML.query(document, ~s([data-part="control"]))

    assert Enum.map(names, &LazyHTML.attribute(&1, "name")) ==
             [["user[plan]"], ["user[plan]"]]

    checked = LazyHTML.query(document, ~s([data-part="control"][checked]))
    assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["pro"]]
  end

  test "renders custom option content", %{wrapper: wrapper} do
    document = render(wrapper, :inner_group, %{})

    assert LazyHTML.text(LazyHTML.query(document, "strong")) == "Pro plan"
  end
end
