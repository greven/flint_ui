defmodule FlintUITest.SoundTest do
  use ExUnit.Case, async: true

  @recipes Path.join([__DIR__, "..", "assets", "src", "lib", "sound", "recipes.ts"])

  test "every documented cue exists in the synthesised recipes" do
    source = File.read!(@recipes)

    for name <- FlintUI.Sound.names() do
      assert Regex.match?(~r/^  #{Regex.escape(name)}:/m, source),
             "expected #{name} in assets/src/lib/sound/recipes.ts"
    end
  end

  test "every default cue names a real cue" do
    names = FlintUI.Sound.names()

    for kind <- [
          :click,
          :press,
          :release,
          :hover,
          :type,
          :enter,
          :exit,
          :change,
          :open,
          :close,
          :toggle_on,
          :toggle_off,
          :success,
          :error,
          :warning,
          :loading,
          :complete
        ] do
      assert FlintUI.Sound.default_for(kind) in names
    end
  end

  test "every cue belongs to a declared family" do
    families = MapSet.new(FlintUI.Sound.families(), & &1.id)

    for cue <- FlintUI.Sound.cues() do
      assert cue.family in families, "#{cue.name} has unknown family #{inspect(cue.family)}"
    end
  end

  test "families group every cue exactly once" do
    grouped = FlintUI.Sound.by_family() |> Enum.flat_map(& &1.cues) |> Enum.map(& &1.name)

    assert Enum.sort(grouped) == Enum.sort(FlintUI.Sound.names())
  end
end
