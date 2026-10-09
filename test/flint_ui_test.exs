defmodule FlintUITest do
  use ExUnit.Case, async: true

  test "components/0 lists the registered components" do
    assert :button in FlintUI.components()
    assert :collapsible in FlintUI.components()
    assert :icon in FlintUI.components()
    assert :loading in FlintUI.components()
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
end
