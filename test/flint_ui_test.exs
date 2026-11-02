defmodule FlintUITest do
  use ExUnit.Case, async: true

  test "components/0 lists the registered components" do
    assert :button in FlintUI.components()
    assert :card in FlintUI.components()
    assert :collapsible in FlintUI.components()
    assert :group in FlintUI.components()
    assert :icon in FlintUI.components()
    assert :loading in FlintUI.components()
    assert :loading_text in FlintUI.components()
    assert :tabs in FlintUI.components()
    assert :toggle in FlintUI.components()
  end

  test "every registered component exposes a complete, valid contract" do
    for name <- FlintUI.components() do
      assert %FlintUI.Meta{} = meta = FlintUI.Docs.meta(name)
      assert meta.status in [:experimental, :developing, :refining, :stable, :draft, :deprecated]

      assert is_list(FlintUI.Docs.attrs(name))
      assert is_list(FlintUI.Docs.slots(name))
      assert is_map(FlintUI.Docs.parts_attrs(name))
      assert is_list(FlintUI.Docs.events(name))
      assert is_list(FlintUI.Docs.keyboard(name))
      assert is_list(FlintUI.Docs.css_vars(name))
    end
  end

  describe "Docs.doc_sections/1" do
    test "splits the moduledoc into an intro and slugged sections" do
      doc = FlintUI.Docs.doc_sections(:button)

      assert doc.intro =~ "Renders a button"
      assert Enum.any?(doc.sections, &(&1.key == :accessibility))
      assert Enum.any?(doc.sections, &(&1.key == :keyboard))
      assert Enum.all?(doc.sections, &(is_binary(&1.title) and is_binary(&1.body)))
    end

    test "slugifies multi-word headings" do
      doc = FlintUI.Docs.doc_sections(:tabs)

      assert Enum.any?(doc.sections, &(&1.key == :custom_triggers))
      assert Enum.any?(doc.sections, &(&1.key == :find_in_page))
    end
  end

  describe "Docs.section/2" do
    test "extracts a moduledoc section, stripped of shared indentation" do
      assert FlintUI.Docs.section(:button, "Accessibility") =~
               "Always provide an accessible name."

      refute FlintUI.Docs.section(:button, "Accessibility") =~ "  Always provide"
    end

    test "returns nil for a missing section" do
      assert FlintUI.Docs.section(:button, "Nope") == nil
    end
  end
end
