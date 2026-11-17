defmodule FlintUI.Base.TextareaTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def basic(assigns) do
      ~H"""
      <.textarea
        id={@id}
        name={@name}
        label={@label}
        sublabel={@sublabel}
        description={@description}
        hint={@hint}
        value={@value}
        errors={@errors}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
      />
      """
    end

    def rest_attrs(assigns) do
      ~H"""
      <.textarea
        name="bio"
        label="Bio"
        value="Hello"
        placeholder="Tell us about yourself"
        rows="5"
        maxlength="280"
        class="font-mono"
        data-test="bio"
      />
      """
    end

    def field_textarea(assigns) do
      ~H"""
      <.textarea field={@field} label="Bio" description="A short introduction." rows="6" />
      """
    end

    def described_by(assigns) do
      ~H"""
      <.textarea
        id="bio"
        name="bio"
        label="Bio"
        errors={["is invalid"]}
        aria-describedby="extra-note"
      />
      """
    end
  end

  @defaults %{
    id: "bio",
    name: "bio",
    label: "Bio",
    sublabel: nil,
    description: nil,
    hint: nil,
    value: nil,
    errors: [],
    disabled: false,
    readonly: false,
    required: false
  }

  defp render(overrides \\ %{}) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.basic/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp label(html), do: LazyHTML.query(html, ~s([data-part="label"]))
  defp control(html), do: LazyHTML.query(html, ~s([data-part="control"]))
  defp control_attr(html, name), do: LazyHTML.attribute(control(html), name)
  defp description(html), do: LazyHTML.query(html, ~s([data-part="description"]))

  test "renders a field root around a native textarea" do
    html = render()

    assert root_attr(html, "data-element") == ["textarea"]
    assert LazyHTML.tag(control(html)) == ["textarea"]
    assert control_attr(html, "id") == ["bio"]
    assert control_attr(html, "name") == ["bio"]
    assert root_attr(html, "data-invalid") == []
    assert root_attr(html, "data-disabled") == []
    assert root_attr(html, "data-readonly") == []
    assert root_attr(html, "data-required") == []
  end

  test "renders the value as the control's text" do
    html = render(value: "Hello there")

    assert LazyHTML.text(control(html)) |> String.trim() == "Hello there"
  end

  test "renders a label associated through for" do
    html = render()

    assert LazyHTML.tag(label(html)) == ["label"]
    assert LazyHTML.attribute(label(html), "for") == ["bio"]
    assert LazyHTML.text(label(html)) |> String.trim() == "Bio"
    assert Enum.count(LazyHTML.query(label(html), "textarea")) == 0
    assert LazyHTML.text(control(html)) |> String.trim() == ""
  end

  test "renders the sublabel inside the label" do
    html = render(sublabel: "Optional")

    text = LazyHTML.query(html, ~s([data-part="label_text"]))
    assert LazyHTML.text(text) =~ ~r/Bio\s+Optional/

    sublabel = LazyHTML.query(html, ~s([data-part="sublabel"]))
    assert LazyHTML.text(sublabel) |> String.trim() == "Optional"
    assert LazyHTML.text(label(html)) =~ "Optional"
  end

  test "renders the description outside the label with a derived id" do
    html = render(description: "A short introduction.")

    assert LazyHTML.attribute(description(html), "id") == ["bio-description"]
    assert LazyHTML.text(description(html)) |> String.trim() == "A short introduction."
    refute LazyHTML.text(label(html)) =~ "introduction"
    assert control_attr(html, "aria-describedby") == ["bio-description"]
  end

  test "does not derive the id from the name" do
    html = render(id: nil, description: "A visual note.")

    assert control_attr(html, "id") == []
    assert LazyHTML.attribute(label(html), "for") == []
    assert LazyHTML.attribute(description(html), "id") == []
    assert control_attr(html, "aria-describedby") == []
  end

  test "renders the hint below the control with a derived id" do
    html = render(hint: "Up to 280 characters.")

    hint = LazyHTML.query(html, ~s([data-part="hint"]))

    assert LazyHTML.attribute(hint, "id") == ["bio-hint"]
    assert LazyHTML.text(hint) |> String.trim() == "Up to 280 characters."
    assert control_attr(html, "aria-describedby") == ["bio-hint"]
  end

  test "orders description, hint, and error ids in aria-describedby" do
    html =
      render(
        description: "A short introduction.",
        hint: "Up to 280 characters.",
        errors: ["is too long"]
      )

    assert control_attr(html, "aria-describedby") == [
             "bio-description bio-hint bio-error-1"
           ]
  end

  test "renders errors, marks the field invalid, and links every message" do
    html =
      render(
        description: "A short introduction.",
        errors: ["can't be blank", "is too long"]
      )

    assert root_attr(html, "data-invalid") == [""]
    assert control_attr(html, "aria-invalid") == ["true"]

    assert control_attr(html, "aria-describedby") == [
             "bio-description bio-error-1 bio-error-2"
           ]

    errors = LazyHTML.query(html, ~s([data-part="error"]))
    assert Enum.count(errors) == 2

    assert Enum.count(LazyHTML.query(html, ~s([data-part="error"] > [data-part="error_icon"]))) ==
             2

    assert LazyHTML.text(LazyHTML.query(html, "#bio-error-1")) |> String.trim() ==
             "can't be blank"
  end

  test "interpolates raw error tuples" do
    html = render(errors: [{"is too long for %{name}", [name: "a bio"]}])

    assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) |> String.trim() ==
             "is too long for a bio"
  end

  test "preserves a caller-supplied aria-describedby" do
    html =
      render_component(&TestComponent.described_by/1, %{})
      |> LazyHTML.from_fragment()

    assert control_attr(html, "aria-describedby") == ["extra-note bio-error-1"]
  end

  test "reflects disabled, readonly, and required on the root and control" do
    html = render(disabled: true, readonly: true, required: true)

    assert root_attr(html, "data-disabled") == [""]
    assert root_attr(html, "data-readonly") == [""]
    assert root_attr(html, "data-required") == [""]

    assert control_attr(html, "disabled") == [""]
    assert control_attr(html, "readonly") == [""]
    assert control_attr(html, "required") == [""]
  end

  test "puts class and rest on the control, not the root" do
    html = render_component(&TestComponent.rest_attrs/1, %{}) |> LazyHTML.from_fragment()

    assert root_attr(html, "class") == []
    assert root_attr(html, "data-test") == []

    assert control_attr(html, "class") == ["font-mono"]
    assert control_attr(html, "data-test") == ["bio"]
    assert control_attr(html, "placeholder") == ["Tell us about yourself"]
    assert control_attr(html, "rows") == ["5"]
    assert control_attr(html, "maxlength") == ["280"]
  end

  describe "field structs" do
    test "derives the id, name, and value" do
      form =
        Phoenix.Component.to_form(%{"bio" => "Hello"},
          as: :user
        )

      html =
        render_component(&TestComponent.field_textarea/1, %{field: form[:bio]})
        |> LazyHTML.from_fragment()

      assert control_attr(html, "id") == ["user_bio"]
      assert control_attr(html, "name") == ["user[bio]"]
      assert LazyHTML.text(control(html)) |> String.trim() == "Hello"

      assert root_attr(html, "data-invalid") == []
      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"]))) == 0
    end

    test "hides the errors of an unused field" do
      form =
        Phoenix.Component.to_form(%{},
          as: :user,
          errors: [bio: {"is too long", [validation: :length]}]
        )

      html =
        render_component(&TestComponent.field_textarea/1, %{field: form[:bio]})
        |> LazyHTML.from_fragment()

      assert root_attr(html, "data-invalid") == []
      assert Enum.count(LazyHTML.query(html, ~s([data-part="error"]))) == 0
    end

    test "renders errors once the field has been used" do
      form =
        Phoenix.Component.to_form(%{"bio" => ""},
          as: :user,
          errors: [bio: {"can't be blank", [validation: :required]}]
        )

      html =
        render_component(&TestComponent.field_textarea/1, %{field: form[:bio]})
        |> LazyHTML.from_fragment()

      assert root_attr(html, "data-invalid") == [""]
      assert control_attr(html, "aria-invalid") == ["true"]

      assert control_attr(html, "aria-describedby") == [
               "user_bio-description user_bio-error-1"
             ]

      assert LazyHTML.text(LazyHTML.query(html, "#user_bio-error-1")) |> String.trim() ==
               "can't be blank"
    end
  end

  describe "metadata" do
    test "declares a documented contract" do
      assert %FlintUI.Meta{name: :textarea, type: :form} = FlintUI.Base.Textarea.meta()

      parts = FlintUI.Base.Textarea.parts_attrs()
      assert parts |> hd() |> elem(0) == :root

      assert Enum.map(parts, &elem(&1, 0)) ==
               [
                 :root,
                 :label,
                 :label_text,
                 :sublabel,
                 :description,
                 :control,
                 :hint,
                 :error,
                 :error_icon
               ]

      assert Enum.any?(parts[:control], &(&1.name == "aria-describedby"))
      assert Enum.any?(parts[:hint], &(&1.name == "id"))
    end

    test "documents keyboard interactions and states" do
      assert Enum.any?(FlintUI.Base.Textarea.keyboard(), &(&1.keys == "Enter"))

      states = FlintUI.Base.Textarea.states()
      assert Enum.any?(states, &(&1.name == "readonly" and &1.selector =~ "data-readonly"))
      assert Enum.any?(states, &(&1.name == "required" and &1.selector =~ "data-required"))
    end
  end
end
