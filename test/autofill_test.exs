defmodule FlintUI.AutofillTest do
  use ExUnit.Case, async: true

  test "ignore_attributes/0 opts out of the common password managers" do
    attrs = FlintUI.Autofill.ignore_attributes()

    assert attrs.autocomplete == "off"
    assert attrs[:"data-1p-ignore"] == true
    assert attrs[:"data-op-ignore"] == true
    assert attrs[:"data-lpignore"] == "true"
    assert attrs[:"data-bwignore"] == "true"
    assert attrs[:"data-protonpass-ignore"] == "true"
    assert attrs[:"data-form-type"] == "other"
  end

  test "ignore_class/0 returns Keeper's opt-out class" do
    assert FlintUI.Autofill.ignore_class() == "keeper-ignore"
  end
end
