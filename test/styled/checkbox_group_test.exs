defmodule FlintUI.Styled.CheckboxGroupTest do
  use FlintUI.StyledCase, async: true

  alias Phoenix.Component

  setup_all do
    wrapper =
      compile_wrapper!(:checkbox_group, ~S'''
      def group_basic(assigns) do
        ~H"""
        <.checkbox_group
          id="languages"
          name="languages"
          label="Programming languages"
          description={@description}
          value={@value}
          orientation={@orientation}
          variant={@variant}
          size={@size}
          radius={@radius}
          class={@class}
        >
          <:checkbox value="elixir" label="Elixir" sublabel="Recommended" />
          <:checkbox value="rust" label="Rust" />
          <:checkbox value="typescript" label="TypeScript" disabled />
        </.checkbox_group>
        """
      end

      def field_group(assigns) do
        ~H"""
        <.checkbox_group field={@field} label="Languages">
          <:checkbox value="elixir" label="Elixir" />
          <:checkbox value="rust" label="Rust" />
        </.checkbox_group>
        """
      end

      def inner_group(assigns) do
        ~H"""
        <.checkbox_group name="languages">
          <:checkbox value="elixir" label="Ignored">
            <strong>Elixir</strong>
          </:checkbox>
        </.checkbox_group>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        description: nil,
        value: [],
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

    assert attr(document, :checkbox_group, "data-element") == ["checkbox_group"]
    assert attr(document, :checkbox_group, "data-checkbox_group") == [""]
    assert attr(document, :checkbox_group, "data-orientation") == ["vertical"]
    assert attr(document, :checkbox_group, "data-variant") == ["simple"]
  end

  test "forwards variant, size, and radius to every checkbox", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults(variant: "card", size: "lg", radius: "xl"))

    roots = LazyHTML.query(document, ~s([data-element="checkbox"][data-checkbox]))

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

      assert attr(document, :checkbox_group, "data-orientation") == [orientation]
      assert attr(document, :checkbox_group, "data-variant") == [variant]
    end
  end

  test "renders the fieldset, legend, and hidden empty input", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults())

    assert LazyHTML.tag(LazyHTML.query(document, "fieldset")) == ["fieldset"]

    assert LazyHTML.text(LazyHTML.query(document, "legend")) |> String.trim() ==
             "Programming languages"

    hidden = LazyHTML.query(document, ~s(input[type="hidden"]))
    assert LazyHTML.attribute(hidden, "name") == ["languages[]"]
    assert LazyHTML.attribute(hidden, "value") == [""]
  end

  test "checks options from the group value", %{wrapper: wrapper} do
    document = render(wrapper, :group_basic, defaults(value: ["elixir"]))

    checked = LazyHTML.query(document, ~s([data-part="control"][checked]))
    assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["elixir"]]
  end

  test "forwards a field struct", %{wrapper: wrapper} do
    form = Component.to_form(%{"languages" => ["rust"]}, as: :user)
    document = render(wrapper, :field_group, %{field: form[:languages]})

    names = LazyHTML.query(document, ~s([data-part="control"]))

    assert Enum.map(names, &LazyHTML.attribute(&1, "name")) ==
             [["user[languages][]"], ["user[languages][]"]]

    checked = LazyHTML.query(document, ~s([data-part="control"][checked]))
    assert Enum.map(checked, &LazyHTML.attribute(&1, "value")) == [["rust"]]
  end

  test "renders custom option content", %{wrapper: wrapper} do
    document = render(wrapper, :inner_group, %{})

    assert LazyHTML.text(LazyHTML.query(document, "strong")) == "Elixir"
  end
end
