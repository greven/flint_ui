defmodule FlintUI.Styled.InputTest do
  use FlintUI.StyledCase, async: true

  alias Phoenix.Component

  setup_all do
    wrapper =
      compile_wrapper!(:input, ~S'''
      def basic(assigns) do
        ~H"""
        <.input
          name="email"
          label="Email"
          value={@value}
          type={@type}
          errors={@errors}
          hint={@hint}
          size={@size}
          radius={@radius}
          class={@class}
        />
        """
      end

      def field_input(assigns) do
        ~H"""
        <.input field={@field} type="email" label="Email" />
        """
      end

      def select(assigns) do
        ~H"""
        <.input name="role" type="select" label="Role" options={["Admin": "admin"]} value="admin" />
        """
      end

      def checkbox(assigns) do
        ~H"""
        <.input name="remember" type="checkbox" label="Remember me" />
        """
      end

      def affixes(assigns) do
        ~H"""
        <.input name="search" label="Search">
          <:outer_prefix class="outer-prefix"><span data-test="outer-prefix">https://</span></:outer_prefix>
          <:inner_prefix class="inner-prefix"><span data-test="inner-prefix">@</span></:inner_prefix>
          <:inner_suffix class="inner-suffix"><span data-test="inner-suffix">.com</span></:inner_suffix>
          <:outer_suffix class="outer-suffix"><span data-test="outer-suffix">Open</span></:outer_suffix>
        </.input>
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        value: nil,
        type: "text",
        errors: [],
        hint: nil,
        size: "md",
        radius: "md",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps size and radius onto the field root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :input, "data-element") == ["input"]
    assert attr(document, :input, "data-input") == [""]
    assert attr(document, :input, "data-field") == [""]
    assert part_attr(document, "box", "data-field-control") == [""]
    assert attr(document, :input, "data-size") == ["md"]
    assert attr(document, :input, "data-radius") == ["md"]
  end

  test "renders the sizes and radius values on the root", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl), radius <- ~w(none xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size, radius: radius))

      assert attr(document, :input, "data-size") == [size]
      assert attr(document, :input, "data-radius") == [radius]
    end
  end

  test "a numeric size is the native size attribute, not a scale hook", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: 12))

    assert attr(document, :input, "data-size") == []
    assert part_attr(document, "control", "size") == ["12"]
  end

  test "keeps the control hooks off the root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", radius: "xl"))

    assert part_attr(document, "control", "data-part") == ["control"]
    assert part_attr(document, "control", "data-size") == []
    assert attr(document, :input, "data-part") == ["root"]
  end

  test "forwards the caller class to the native control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "w-48"))

    assert part_attr(document, "control", "class") == ["w-48"]
    assert attr(document, :input, "class") == []
  end

  test "forwards field structs to the headless component", %{wrapper: wrapper} do
    form = Component.to_form(%{"email" => "a@b.test"}, as: :user)
    document = render(wrapper, :field_input, %{field: form[:email]})

    assert part_attr(document, "control", "id") == ["user_email"]
    assert part_attr(document, "control", "name") == ["user[email]"]
    assert part_attr(document, "control", "value") == ["a@b.test"]
  end

  test "forwards select type and options", %{wrapper: wrapper} do
    document = render(wrapper, :select, %{})

    assert LazyHTML.tag(part(document, "control")) == ["select"]
    assert part_attr(document, "label", "data-part") == ["label"]
    assert part_attr(document, "select_indicator", "aria-hidden") == ["true"]
    assert LazyHTML.text(LazyHTML.query(document, ~s(option[value="admin"]))) == "Admin"
    assert part_attr(document, "control", "name") == ["role"]
  end

  test "keeps the checkbox indicator in the wrapper output", %{wrapper: wrapper} do
    document = render(wrapper, :checkbox, %{})

    assert part_attr(document, "indicator", "aria-hidden") == ["true"]
    assert part_attr(document, "control", "type") == ["checkbox"]
  end

  test "renders errors and the hint parts", %{wrapper: wrapper} do
    document =
      render(wrapper, :basic, defaults(errors: ["is invalid"], hint: "Work address"))

    assert part_attr(document, "error", "data-part") == ["error"]
    assert part_attr(document, "hint", "data-part") == ["hint"]
    assert attr(document, :input, "data-invalid") == [""]
  end

  test "forwards the inner and outer slots", %{wrapper: wrapper} do
    document = render(wrapper, :affixes, %{})

    for part <- ~w(row outer_prefix box inner_prefix inner_suffix outer_suffix) do
      assert part_attr(document, part, "data-part") == [part]
    end

    for part <- ~w(outer_prefix inner_prefix inner_suffix outer_suffix) do
      assert part_attr(document, part, "class") == [String.replace(part, "_", "-")]
    end

    assert LazyHTML.text(part(document, "outer_prefix")) |> String.trim() == "https://"
    assert LazyHTML.text(part(document, "inner_prefix")) |> String.trim() == "@"
    assert LazyHTML.text(part(document, "inner_suffix")) |> String.trim() == ".com"
    assert LazyHTML.text(part(document, "outer_suffix")) |> String.trim() == "Open"
  end

  test "does not render wrappers for the wrapper's blank forwarded slots", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    for part <- ~w(outer_prefix inner_prefix inner_suffix outer_suffix) do
      assert count_part(document, part) == 0
    end

    assert count_part(document, "row") == 1
    assert count_part(document, "box") == 1
  end
end
