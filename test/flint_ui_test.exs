defmodule FlintUITest do
  use ExUnit.Case, async: true

  test "components/0 lists the registered components" do
    assert :badge in FlintUI.components()
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
      assert is_list(FlintUI.Docs.parts_attrs(name))
      assert is_list(FlintUI.Docs.events(name))
      assert is_list(FlintUI.Docs.keyboard(name))
      assert is_list(FlintUI.Docs.css_vars(name))
      assert is_list(FlintUI.Docs.states(name))
    end
  end

  test "every component declares its parts once, in a documented order" do
    for name <- FlintUI.components() do
      parts = FlintUI.Docs.parts_attrs(name)
      part_names = Enum.map(parts, &elem(&1, 0))

      assert length(part_names) == length(Enum.uniq(part_names)),
             "#{name} declares a part twice: #{inspect(part_names -- Enum.uniq(part_names))}"

      assert part_names != [] and hd(part_names) == :root,
             "#{name} must declare :root first: #{inspect(part_names)}"

      for {part, attrs} <- parts do
        assert is_atom(part) and is_list(attrs), "#{name}.#{part} is not an attribute list"

        assert Enum.any?(attrs, &(&1.name == "[data-part]")),
               "#{name}.#{part} declares no [data-part] hook"
      end

      hooks = name |> FlintUI.Docs.parts() |> Enum.map(& &1.hook)

      assert length(hooks) == length(Enum.uniq(hooks)),
             "#{name} exposes duplicate data-part hooks: #{inspect(hooks)}"
    end
  end

  describe "Docs.description/1" do
    test "returns the first sentence, joining a description wrapped across lines" do
      assert FlintUI.Docs.description(:avatar) ==
               "Shows a person or entity as an image, falling back to initials, fixed text, or custom content."

      assert FlintUI.Docs.description(:card) ==
               "A container that groups related content into an optional header, sections and an optional footer."
    end

    test "returns a single-line description" do
      assert FlintUI.Docs.description(:button) ==
               "Renders a button that performs an action, or a link styled as a button."
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
