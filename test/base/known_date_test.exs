defmodule FlintUI.Base.KnownDateTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest, only: [render_component: 2]

  defmodule TestComponent do
    use FlintUI

    def date(assigns) do
      ~H"""
      <.known_date
        id={@id}
        name={@name}
        label={@label}
        sublabel={@sublabel}
        value={@value}
        locale={@locale}
        min={@min}
        max={@max}
        autocomplete={@autocomplete}
        description={@description}
        hint={@hint}
        errors={@errors}
        disabled={@disabled}
        readonly={@readonly}
        required={@required}
        class={@class}
      />
      """
    end

    def field(assigns) do
      ~H"""
      <.known_date field={@field} label="Date of birth" hint="For example, 27 3 2007" />
      """
    end

    def with_lang(assigns) do
      ~H"""
      <.known_date name="dob" label="Date" lang={@lang} />
      """
    end
  end

  @defaults %{
    id: "dob",
    name: "date_of_birth",
    label: "Date of birth",
    sublabel: nil,
    value: nil,
    locale: nil,
    min: nil,
    max: nil,
    autocomplete: nil,
    description: nil,
    hint: nil,
    errors: [],
    disabled: false,
    readonly: false,
    required: false,
    class: nil
  }

  defp render(overrides) do
    assigns = Map.merge(@defaults, Map.new(overrides))
    render_component(&TestComponent.date/1, assigns) |> LazyHTML.from_fragment()
  end

  defp root(html), do: LazyHTML.query(html, ~s([data-part="root"]))
  defp root_attr(html, name), do: LazyHTML.attribute(root(html), name)
  defp fields(html), do: LazyHTML.query(html, ~s([data-part="fields"] > [data-part="field"]))
  defp field(html, name), do: LazyHTML.query(html, ~s([data-part="field"][data-field="#{name}"]))

  defp input(html, name),
    do: LazyHTML.query(html, ~s([data-part="control"][data-field="#{name}"]))

  defp hidden(html), do: LazyHTML.query(html, ~s([data-part="value"]))

  test "renders a labeled fieldset with the three parts in European order by default" do
    html = render(value: "2007-03-27")

    assert LazyHTML.tag(root(html)) == ["fieldset"]
    assert root_attr(html, "data-element") == ["known_date"]
    assert root_attr(html, "data-order") == ["dmy"]
    assert root_attr(html, "phx-hook") == ["FlintUI.KnownDate"]
    assert root_attr(html, "id") == ["dob"]

    assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="label"]))) |> String.trim() ==
             "Date of birth"

    assert fields(html)
           |> Enum.map(&LazyHTML.attribute(&1, "data-field"))
           |> List.flatten() == ["day", "month", "year"]

    assert LazyHTML.text(LazyHTML.query(field(html, "day"), ~s([data-part="field_label"]))) ==
             "Day"

    assert LazyHTML.text(LazyHTML.query(field(html, "month"), ~s([data-part="field_label"]))) ==
             "Month"

    assert LazyHTML.text(LazyHTML.query(field(html, "year"), ~s([data-part="field_label"]))) ==
             "Year"
  end

  test "derives part ids and values from the ISO value" do
    html = render(value: "2007-03-27")

    assert LazyHTML.attribute(input(html, "day"), "id") == ["dob-day"]
    assert LazyHTML.attribute(input(html, "month"), "id") == ["dob-month"]
    assert LazyHTML.attribute(input(html, "year"), "id") == ["dob-year"]

    assert LazyHTML.attribute(input(html, "day"), "value") == ["27"]
    assert LazyHTML.attribute(input(html, "month"), "value") == ["03"]
    assert LazyHTML.attribute(input(html, "year"), "value") == ["2007"]

    for name <- ~w(day month year) do
      assert LazyHTML.attribute(input(html, name), "type") == ["text"]
      assert LazyHTML.attribute(input(html, name), "inputmode") == ["numeric"]
      assert LazyHTML.attribute(input(html, name), "pattern") == ["[0-9]*"]
    end
  end

  test "submits one canonical ISO value through the hidden input" do
    html = render(value: "2007-03-27", name: "user[date_of_birth]")

    assert LazyHTML.attribute(hidden(html), "type") == ["hidden"]
    assert LazyHTML.attribute(hidden(html), "name") == ["user[date_of_birth]"]
    assert LazyHTML.attribute(hidden(html), "value") == ["2007-03-27"]
    assert LazyHTML.attribute(hidden(html), "disabled") == []

    for name <- ~w(day month year) do
      assert LazyHTML.attribute(input(html, name), "name") == []
    end
  end

  test "omits and disables the hidden value while the date is incomplete or invalid" do
    html = render(value: nil)

    assert LazyHTML.attribute(hidden(html), "value") == []
    assert LazyHTML.attribute(hidden(html), "disabled") == [""]

    html = render(value: "2007-02-30")

    assert LazyHTML.attribute(hidden(html), "value") == []
    assert LazyHTML.attribute(hidden(html), "disabled") == [""]
  end

  test "locale selects the field order and the labels stay the same" do
    html = render(locale: "en-US")

    assert root_attr(html, "data-order") == ["mdy"]

    assert fields(html)
           |> Enum.map(&LazyHTML.attribute(&1, "data-field"))
           |> List.flatten() == ["month", "day", "year"]

    assert LazyHTML.text(LazyHTML.query(field(html, "day"), ~s([data-part="field_label"]))) ==
             "Day"

    assert root_attr(render(locale: "ja-JP"), "data-order") == ["ymd"]
    assert root_attr(render(locale: "en-GB"), "data-order") == ["dmy"]
    assert root_attr(render(locale: "de-DE"), "data-order") == ["dmy"]
  end

  test "inherits the order from a lang attribute when locale is omitted" do
    html =
      render_component(&TestComponent.with_lang/1, %{lang: "en-US"})
      |> LazyHTML.from_fragment()

    assert root_attr(html, "data-order") == ["mdy"]

    html =
      render_component(&TestComponent.with_lang/1, %{lang: "en-GB"})
      |> LazyHTML.from_fragment()

    assert root_attr(html, "data-order") == ["dmy"]
  end

  test "links the description, hint, and errors from every part" do
    html =
      render(
        description: "As printed on the passport.",
        hint: "For example, 27 3 2007",
        errors: ["is invalid"]
      )

    assert root_attr(html, "data-invalid") == [""]
    assert LazyHTML.attribute(root(html), "aria-invalid") == ["true"]

    assert LazyHTML.attribute(LazyHTML.query(html, ~s(#dob-description)), "id") == [
             "dob-description"
           ]

    assert LazyHTML.attribute(LazyHTML.query(html, ~s(#dob-hint)), "id") == ["dob-hint"]

    for name <- ~w(day month year) do
      assert LazyHTML.attribute(input(html, name), "aria-invalid") == ["true"]

      assert LazyHTML.attribute(input(html, name), "aria-describedby") == [
               "dob-description dob-hint dob-error-1"
             ]
    end
  end

  test "keeps the field root state on the fieldset and the native state on the parts" do
    html = render(disabled: true, readonly: true, required: true)

    assert root_attr(html, "data-disabled") == [""]
    assert root_attr(html, "data-readonly") == [""]
    assert root_attr(html, "data-required") == [""]
    assert LazyHTML.attribute(root(html), "disabled") == [""]

    for name <- ~w(day month year) do
      assert LazyHTML.attribute(input(html, name), "disabled") == [""]
      assert LazyHTML.attribute(input(html, name), "readonly") == [""]
      assert LazyHTML.attribute(input(html, name), "required") == [""]
    end

    assert LazyHTML.attribute(hidden(html), "disabled") == [""]
  end

  test "keeps a read-only value in the submission" do
    html = render(value: "2007-03-27", readonly: true)

    assert LazyHTML.attribute(input(html, "day"), "readonly") == [""]
    assert LazyHTML.attribute(hidden(html), "disabled") == []
    assert LazyHTML.attribute(hidden(html), "value") == ["2007-03-27"]
  end

  test "renders min and max as data hooks for the client validator" do
    html = render(min: "1900-01-01", max: "2099-12-31")

    assert root_attr(html, "data-min") == ["1900-01-01"]
    assert root_attr(html, "data-max") == ["2099-12-31"]
  end

  test "accepts Date structs for min and max" do
    html = render(min: ~D[1900-01-01], max: ~D[2099-12-31])

    assert root_attr(html, "data-min") == ["1900-01-01"]
    assert root_attr(html, "data-max") == ["2099-12-31"]
  end

  test "expands bday autocomplete into per-field tokens" do
    html = render(autocomplete: "bday")

    assert LazyHTML.attribute(input(html, "day"), "autocomplete") == ["bday-day"]
    assert LazyHTML.attribute(input(html, "month"), "autocomplete") == ["bday-month"]
    assert LazyHTML.attribute(input(html, "year"), "autocomplete") == ["bday-year"]

    html = render(autocomplete: "on")

    for name <- ~w(day month year) do
      assert LazyHTML.attribute(input(html, name), "autocomplete") == ["on"]
    end

    html = render(autocomplete: "cc-exp")

    assert LazyHTML.attribute(input(html, "day"), "autocomplete") == []
    assert LazyHTML.attribute(input(html, "year"), "autocomplete") == ["cc-exp"]
  end

  test "forwards a form field and derives id, name, value, and errors" do
    form =
      Phoenix.Component.to_form(%{"date_of_birth" => "2007-03-27"},
        as: :user
      )

    html =
      render_component(&TestComponent.field/1, %{field: form[:date_of_birth]})
      |> LazyHTML.from_fragment()

    assert root_attr(html, "id") == ["user_date_of_birth"]
    assert LazyHTML.attribute(input(html, "day"), "id") == ["user_date_of_birth-day"]
    assert LazyHTML.attribute(hidden(html), "name") == ["user[date_of_birth]"]
    assert LazyHTML.attribute(hidden(html), "value") == ["2007-03-27"]
    assert root_attr(html, "data-invalid") == []

    assert LazyHTML.attribute(input(html, "day"), "aria-describedby") == [
             "user_date_of_birth-hint"
           ]
  end

  test "shows field errors once the field has been used" do
    form =
      Phoenix.Component.to_form(%{"date_of_birth" => ""},
        as: :user,
        errors: [date_of_birth: {"can't be blank", [validation: :required]}]
      )

    html =
      render_component(&TestComponent.field/1, %{field: form[:date_of_birth]})
      |> LazyHTML.from_fragment()

    assert root_attr(html, "data-invalid") == [""]
    assert LazyHTML.text(LazyHTML.query(html, ~s([data-part="error"]))) =~ "can't be blank"
  end

  test "puts the caller class on the group root" do
    html = render(class: "max-w-sm")

    assert LazyHTML.attribute(root(html), "class") == ["max-w-sm"]
  end

  test "declares a documented contract" do
    assert %FlintUI.Meta{name: :known_date, type: :form} = FlintUI.Base.KnownDate.meta()

    parts = FlintUI.Base.KnownDate.parts_attrs()
    assert parts |> hd() |> elem(0) == :root

    for part <-
          ~w(root label label_text sublabel description fields field field_label control value hint error error_icon) do
      assert Keyword.has_key?(parts, String.to_existing_atom(part))
    end

    assert Enum.any?(parts[:root], &(&1.name == "phx-hook"))
    assert Enum.any?(parts[:value], &(&1.name == "value"))

    assert Enum.any?(FlintUI.Base.KnownDate.keyboard(), &(&1.keys == "Tab"))
    assert Enum.any?(FlintUI.Base.KnownDate.states(), &(&1.name == "invalid"))
  end
end
