defmodule FlintUI.Styled.KnownDateTest do
  use FlintUI.StyledCase, async: true

  alias Phoenix.Component

  setup_all do
    wrapper =
      compile_wrapper!(:known_date, ~S'''
      def basic(assigns) do
        ~H"""
        <.known_date
          id="dob"
          name="date_of_birth"
          label="Date of birth"
          sublabel={@sublabel}
          description={@description}
          hint={@hint}
          value={@value}
          locale={@locale}
          errors={@errors}
          size={@size}
          radius={@radius}
          class={@class}
        />
        """
      end

      def field_date(assigns) do
        ~H"""
        <.known_date field={@field} label="Date of birth" />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        sublabel: "Optional",
        description: nil,
        hint: nil,
        value: "2007-03-27",
        locale: nil,
        errors: [],
        size: "md",
        radius: "md",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the group root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :known_date, "data-element") == ["known_date"]
    assert attr(document, :known_date, "data-known_date") == [""]
    assert attr(document, :known_date, "data-field") == [""]
    assert part_attr(document, "control", "data-field-control") == ["", "", ""]
    assert attr(document, :known_date, "data-size") == ["md"]
    assert attr(document, :known_date, "data-radius") == ["md"]
  end

  test "renders every size and radius value on the root", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl), radius <- ~w(none xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size, radius: radius))

      assert attr(document, :known_date, "data-size") == [size]
      assert attr(document, :known_date, "data-radius") == [radius]
    end
  end

  test "forwards the value and locale to the headless component", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(locale: "en-US"))

    assert attr(document, :known_date, "data-order") == ["mdy"]
    assert part_attr(document, "value", "value") == ["2007-03-27"]
    assert part_attr(document, "value", "name") == ["date_of_birth"]
  end

  test "forwards field structs", %{wrapper: wrapper} do
    form = Component.to_form(%{"date_of_birth" => "2007-03-27"}, as: :user)
    document = render(wrapper, :field_date, %{field: form[:date_of_birth]})

    assert attr(document, :known_date, "id") == ["user_date_of_birth"]
    assert part_attr(document, "value", "name") == ["user[date_of_birth]"]

    assert LazyHTML.attribute(LazyHTML.query(document, ~s(#user_date_of_birth-day)), "value") == [
             "27"
           ]
  end

  test "keeps the root hooks off the part controls", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert part_attr(document, "control", "data-size") == []
    assert part_attr(document, "control", "data-radius") == []
    assert part_attr(document, "control", "data-known_date") == []
  end

  test "puts the caller class on the root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "max-w-sm"))

    assert attr(document, :known_date, "class") == ["max-w-sm"]
    assert part_attr(document, "control", "class") == []
  end

  test "renders the description, hint, and errors", %{wrapper: wrapper} do
    document =
      render(
        wrapper,
        :basic,
        defaults(
          description: "As printed on the passport.",
          hint: "For example, 27 3 2007",
          errors: ["is invalid"]
        )
      )

    assert LazyHTML.text(part(document, "description")) |> String.trim() ==
             "As printed on the passport."

    assert LazyHTML.text(part(document, "hint")) |> String.trim() == "For example, 27 3 2007"
    assert count_part(document, "error") == 1
    assert part_attr(document, "control", "aria-invalid") == ["true", "true", "true"]
  end
end
