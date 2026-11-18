defmodule FlintUI.Styled.TextareaTest do
  use FlintUI.StyledCase, async: true

  alias Phoenix.Component

  setup_all do
    wrapper =
      compile_wrapper!(:textarea, ~S'''
      def basic(assigns) do
        ~H"""
        <.textarea
          id="bio"
          name="bio"
          label="Bio"
          sublabel="Optional"
          description={@description}
          hint={@hint}
          value="Hello"
          errors={@errors}
          rows="4"
          placeholder="Tell us about yourself"
          size={@size}
          radius={@radius}
          resize={@resize}
          class={@class}
        />
        """
      end

      def field_textarea(assigns) do
        ~H"""
        <.textarea field={@field} label="Bio" rows="6" />
        """
      end

      def autogrow(assigns) do
        ~H"""
        <.textarea
          name="message"
          label="Message"
          autogrow={@autogrow}
          min_rows={@min_rows}
          max_rows={@max_rows}
          rows={@rows}
          style={@style}
          placeholder="Type to see the field grow"
        />
        """
      end
      ''')

    %{wrapper: wrapper}
  end

  defp defaults(overrides \\ %{}) do
    Map.merge(
      %{
        description: nil,
        hint: nil,
        errors: [],
        size: "md",
        radius: "md",
        resize: "vertical",
        class: nil
      },
      Map.new(overrides)
    )
  end

  test "maps its props onto the field root", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert attr(document, :textarea, "data-element") == ["textarea"]
    assert attr(document, :textarea, "data-textarea") == [""]
    assert attr(document, :textarea, "data-field") == [""]
    assert part_attr(document, "control", "data-field-control") == [""]
    assert attr(document, :textarea, "data-size") == ["md"]
    assert attr(document, :textarea, "data-radius") == ["md"]
    assert attr(document, :textarea, "data-resize") == ["vertical"]
  end

  test "renders every size value", %{wrapper: wrapper} do
    for size <- ~w(xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(size: size))

      assert attr(document, :textarea, "data-size") == [size]
    end
  end

  test "renders every radius value", %{wrapper: wrapper} do
    for radius <- ~w(none xs sm md lg xl) do
      document = render(wrapper, :basic, defaults(radius: radius))

      assert attr(document, :textarea, "data-radius") == [radius]
    end
  end

  test "renders every resize value", %{wrapper: wrapper} do
    for resize <- ~w(none vertical horizontal both) do
      document = render(wrapper, :basic, defaults(resize: resize))

      assert attr(document, :textarea, "data-resize") == [resize]
    end
  end

  test "forwards the native attributes to the control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults())

    assert part_attr(document, "control", "rows") == ["4"]
    assert part_attr(document, "control", "placeholder") == ["Tell us about yourself"]
    assert part_attr(document, "control", "name") == ["bio"]
    assert part_attr(document, "control", "id") == ["bio"]
    assert LazyHTML.text(part(document, "control")) |> String.trim() == "Hello"
  end

  test "keeps the root hooks off the control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(size: "lg", radius: "xl", resize: "both"))

    assert part_attr(document, "control", "data-size") == []
    assert part_attr(document, "control", "data-radius") == []
    assert part_attr(document, "control", "data-resize") == []
    assert part_attr(document, "control", "data-textarea") == []
  end

  test "renders the description and errors and links them from the control", %{
    wrapper: wrapper
  } do
    document =
      render(
        wrapper,
        :basic,
        defaults(
          description: "A short introduction.",
          errors: ["can't be blank", "is too long"]
        )
      )

    assert LazyHTML.text(part(document, "description")) |> String.trim() ==
             "A short introduction."

    assert part_attr(document, "description", "id") == ["bio-description"]
    assert LazyHTML.text(part(document, "sublabel")) |> String.trim() == "Optional"
    assert LazyHTML.text(part(document, "label")) =~ "Bio"

    assert count_part(document, "error") == 2

    assert part_attr(document, "control", "aria-invalid") == ["true"]

    assert part_attr(document, "control", "aria-describedby") == [
             "bio-description bio-error-1 bio-error-2"
           ]
  end

  test "renders the hint below the control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(hint: "Up to 280 characters."))

    assert LazyHTML.text(part(document, "hint")) |> String.trim() == "Up to 280 characters."
    assert part_attr(document, "hint", "id") == ["bio-hint"]
    assert part_attr(document, "control", "aria-describedby") == ["bio-hint"]
    assert Enum.count(LazyHTML.query(part(document, "label"), "textarea")) == 0
  end

  test "forwards one field", %{wrapper: wrapper} do
    form = Component.to_form(%{"bio" => "Hello"}, as: :user)

    document = render(wrapper, :field_textarea, %{field: form[:bio]})

    assert part_attr(document, "control", "id") == ["user_bio"]
    assert part_attr(document, "control", "name") == ["user[bio]"]
    assert part_attr(document, "control", "rows") == ["6"]
    assert LazyHTML.text(part(document, "control")) |> String.trim() == "Hello"
  end

  test "forwards the caller class to the control", %{wrapper: wrapper} do
    document = render(wrapper, :basic, defaults(class: "font-mono"))

    assert part_attr(document, "control", "class") == ["font-mono"]
    assert attr(document, :textarea, "class") == []
  end

  describe "autogrow" do
    defp autogrow_defaults(overrides \\ %{}) do
      Map.merge(
        %{autogrow: true, min_rows: 2, max_rows: 8, rows: nil, style: nil},
        Map.new(overrides)
      )
    end

    test "maps the flag onto the root and writes the row limits to the control", %{
      wrapper: wrapper
    } do
      document = render(wrapper, :autogrow, autogrow_defaults())

      assert attr(document, :textarea, "data-autogrow") == [""]

      style = part_attr(document, "control", "style") |> Enum.join("")

      assert style =~ "--fl-textarea-min-rows: 2"
      assert style =~ "--fl-textarea-max-rows: 8"

      # The native rows value is the fallback for browsers without field-sizing.
      assert part_attr(document, "control", "rows") == ["2"]
    end

    test "keeps an explicit rows value and composes a caller style", %{
      wrapper: wrapper
    } do
      document =
        render(wrapper, :autogrow, autogrow_defaults(rows: "9", style: "margin-block: 1rem"))

      assert part_attr(document, "control", "rows") == ["9"]

      style = part_attr(document, "control", "style") |> Enum.join("")

      assert style =~ "margin-block: 1rem"
      assert style =~ "--fl-textarea-min-rows: 2"
    end

    test "clamps the limits to at least one row and keeps max above min", %{
      wrapper: wrapper
    } do
      document = render(wrapper, :autogrow, autogrow_defaults(min_rows: 0, max_rows: 1))

      style = part_attr(document, "control", "style") |> Enum.join("")

      assert style =~ "--fl-textarea-min-rows: 1"
      assert style =~ "--fl-textarea-max-rows: 1"

      document = render(wrapper, :autogrow, autogrow_defaults(min_rows: 5, max_rows: 2))
      style = part_attr(document, "control", "style") |> Enum.join("")

      assert style =~ "--fl-textarea-min-rows: 5"
      assert style =~ "--fl-textarea-max-rows: 5"
    end

    test "leaves the control untouched when autogrow is off", %{wrapper: wrapper} do
      document = render(wrapper, :autogrow, autogrow_defaults(autogrow: false))

      assert attr(document, :textarea, "data-autogrow") == []
      assert part_attr(document, "control", "rows") == []
      assert part_attr(document, "control", "style") == []
    end
  end
end
