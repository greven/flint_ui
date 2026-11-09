defmodule FlintUIDocsWeb.DocsTest do
  use ExUnit.Case, async: true

  alias FlintUIDocsWeb.Docs
  alias FlintUIDocsWeb.Docs.Source

  @ignored_attrs [:rest, :class, :flint_parts]

  test "no component doc source uses a placeholder" do
    for {name, module} <- Docs.modules(),
        section <- Docs.sections(name),
        {:ok, source} <- [Source.extract(module, section.section, section[:id])] do
      refute String.contains?(source.code, "..."),
             "expected no `...` placeholder in the #{section.section} section of #{name}"
    end
  end

  test "every public attribute and styled prop has a doc" do
    for {name, _module} <- Docs.modules() do
      for attr <- base_attrs(name) do
        assert is_binary(attr.doc) and attr.doc != "",
               "expected #{name} attribute #{inspect(attr.name)} to have a doc"
      end

      for prop <- styled_props(name) do
        assert is_binary(prop.doc) and prop.doc != "",
               "expected #{name} styled prop #{inspect(prop.name)} to have a doc"
      end

      for attr <- styled_content_attrs(name) do
        assert is_binary(attr.doc) and attr.doc != "",
               "expected #{name} styled content attribute #{inspect(attr.name)} to have a doc"
      end
    end
  end

  test "every component page has a title, subtitle, and meta" do
    for {name, _module} <- Docs.modules() do
      assert is_binary(Docs.title(name)) and Docs.title(name) != ""
      assert is_binary(Docs.subtitle(name)) and Docs.subtitle(name) != ""
      assert %FlintUI.Meta{} = Docs.meta(name)
    end
  end

  test "every related and dependency component has a docs page" do
    for {name, _module} <- Docs.modules() do
      for related <- FlintUI.Docs.related(name) ++ FlintUI.Docs.dependencies(name) do
        assert Map.has_key?(Docs.modules(), related),
               "expected #{name} to relate to a documented component, got #{inspect(related)}"

        refute related == name, "expected #{name} not to relate to itself"
      end
    end
  end

  test "every component has a styled section with a render clause" do
    for {name, module} <- Docs.modules() do
      assert [first | _rest] = Docs.sections(name, :styled)

      assert {:ok, _} = Source.extract(module, first.section, first[:id]),
             "expected #{name} to expose a render_section/1 clause for " <>
               inspect({first.section, first[:id]})
    end
  end

  test "section keys are unique per tab" do
    for {name, _module} <- Docs.modules() do
      keys = Enum.map(Docs.sections(name), &{section_tab(&1), &1.section, &1[:id]})

      assert keys == Enum.uniq(keys),
             "expected #{name} to declare each {tab, section, id} once, got #{inspect(keys)}"
    end
  end

  test "sections carry valid metadata" do
    for {name, _module} <- Docs.modules(), section <- Docs.sections(name) do
      assert is_atom(section.section)
      assert section_tab(section) in [:styled, :base, :css]
      assert is_nil(section[:id]) or is_atom(section[:id])
      assert is_nil(section[:title]) or is_binary(section[:title])
    end
  end

  test "every component's base docs resolve and include the API reference" do
    for {name, _module} <- Docs.modules() do
      groups = Docs.base_groups(name)

      assert Enum.any?(groups, &(&1.section == :api)),
             "expected #{name} base docs to include :api"

      assert Enum.all?(groups, &(is_binary(&1.title) and &1.title != "")),
             "expected #{name} base docs to have titles"
    end
  end

  test "section anchors and preview ids keep their documented shape" do
    assert Docs.preview_id(:button, %{section: :usage, id: :basic}) ==
             "usage-button-basic"

    assert Docs.section_anchor(:button, %{section: :usage, id: :basic}) == "usage-basic"

    assert Docs.preview_id(:button, %{section: :usage, id: :variant}) ==
             "usage-button-variant"

    assert Docs.section_anchor(:button, %{section: :usage, id: :variant}) == "usage-variant"

    assert Docs.preview_id(:button, %{section: :examples, id: :icon}) ==
             "example-button-icon-preview"

    assert Docs.section_anchor(:button, %{section: :examples, id: :icon}) ==
             "example-button-icon"
  end

  test "section anchors and group ids use dashes, not underscores" do
    assert Docs.preview_id(:badge, %{section: :examples, id: :inside_button}) ==
             "example-badge-inside-button-preview"

    assert Docs.section_anchor(:badge, %{section: :examples, id: :inside_button}) ==
             "example-badge-inside-button"

    assert Docs.section_anchor(:tabs, %{tab: :base, section: :js_helpers}) ==
             "base-js-helpers"

    [group] =
      Docs.group_sections(
        [%{tab: :styled, section: :custom_things, id: :some_example, title: "Custom things"}],
        :styled
      )

    assert group.id == "custom-things"
  end

  test "the first section supplies the group heading" do
    [group] =
      Docs.group_sections(
        [
          %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
          %{tab: :styled, section: :usage, id: :variant, title: "Variant"}
        ],
        :styled
      )

    assert group.title == "Usage"
    assert Enum.map(group.sections, & &1.id) == [:basic, :variant]
  end

  test "a group_title names the group and makes every section a subsection" do
    [group] =
      Docs.group_sections(
        [
          %{
            tab: :styled,
            section: :examples,
            id: :custom_color,
            title: "Custom Color",
            group_title: "Examples"
          },
          %{
            tab: :styled,
            section: :examples,
            id: :destructive_confirmation,
            title: "Destructive Confirmation"
          }
        ],
        :styled
      )

    assert group.title == "Examples"
    assert Enum.map(group.sections, & &1.id) == [:custom_color, :destructive_confirmation]
  end

  test "a group without a first-section title has no heading" do
    [group] =
      Docs.group_sections(
        [
          %{tab: :styled, section: :usage, id: :basic},
          %{tab: :styled, section: :usage, id: :variant, title: "Variant"}
        ],
        :styled
      )

    assert is_nil(group.title)
  end

  test "a section without a render clause returns nil for an empty section" do
    assert Docs.render_section(:card, %{section: :usage, id: :missing}) == nil
  end

  test "every declared control has a default" do
    for {name, _module} <- Docs.modules() do
      for control <- Docs.controls(name) do
        assert is_atom(control.key)
        assert Map.has_key?(control, :default)
      end
    end
  end

  defp base_attrs(name) do
    name
    |> FlintUI.Docs.attrs()
    |> Enum.reject(&(&1.name in @ignored_attrs))
  end

  defp styled_props(name) do
    case FlintUI.Styled.get(name) do
      nil -> []
      entry -> entry.props
    end
  end

  defp styled_content_attrs(name) do
    case FlintUI.Styled.get(name) do
      nil -> []
      entry -> entry.content_attrs
    end
  end

  defp section_tab(section), do: Map.get(section, :tab, :styled)
end
