defmodule FlintUI.UtilitiesTest do
  use ExUnit.Case, async: true

  alias FlintUI.{Generator, Utilities}

  setup_all do
    %{css: Utilities.source(), classes: Utilities.classes()}
  end

  test "declares the shared layer order before the reset", %{css: css} do
    assert css =~ "@layer base, components, utilities, focus;"
    assert css =~ "@layer base {"
    assert css =~ "@layer utilities {"
    assert index(css, "@layer base, components, utilities, focus;") < index(css, "@layer base {")
  end

  test "the reset is small and can be omitted" do
    css = Utilities.source(reset: false)

    refute css =~ "box-sizing: border-box"
    refute css =~ "body {"
    assert css =~ "@layer utilities {"
  end

  test "every class is prefixed and unique", %{classes: classes} do
    names = Enum.map(classes, & &1.class)

    assert length(names) == length(Enum.uniq(names))

    assert Enum.all?(names, &String.starts_with?(&1, Utilities.prefix() <> "-")),
           "expected every utility class to start with #{Utilities.prefix()}-"
  end

  test "every documented class appears in the generated stylesheet", %{css: css, classes: classes} do
    for %{class: class} <- classes do
      assert css =~ ".#{class}",
             "expected #{class} in the generated utility stylesheet"
    end
  end

  test "semantic layout primitives are present", %{css: css} do
    for class <- ~w(
          fl-stack
          fl-cluster
          fl-split
          fl-split-column
          fl-flank
          fl-flank-end
          fl-frame
          fl-frame-square
          fl-frame-landscape
          fl-frame-portrait
          fl-grid
          fl-grid-span-full
          fl-container
          fl-container-fluid
          fl-container-7xl
        ) do
      assert css =~ ".#{class}"
    end

    assert css =~ "--fl-stack-gap"
    assert css =~ "--fl-cluster-gap"
    assert css =~ "--fl-split-gap"
    assert css =~ "--fl-flank-size"
    assert css =~ "--fl-grid-min"
    assert css =~ "--fl-frame-ratio"
  end

  test "spacing, sizing, type, and radius read the tokens", %{css: css} do
    assert css =~ ".fl-p-md { padding: var(--fl-spacing-md) }"
    assert css =~ ".fl-mx-auto { margin-inline: auto }"
    assert css =~ ".fl-gap-lg { gap: var(--fl-spacing-lg) }"

    assert css =~
             ".fl-text-lg { font-size: var(--fl-font-size-lg); line-height: var(--fl-line-height-lg) }"

    assert css =~ ".fl-font-semibold { font-weight: var(--fl-font-weight-semibold) }"
    assert css =~ ".fl-rounded-md { border-radius: var(--fl-radius-md) }"
    assert css =~ ".fl-shadow-md { box-shadow: var(--fl-shadow-md) }"
    assert css =~ ".fl-border { border-width: 1px; border-style: solid }"
    refute css =~ ".fl-border { border:"
  end

  test "colors expose roles, chrome, and tone indirection", %{css: css} do
    assert css =~ ".fl-bg-primary { background-color: var(--fl-color-primary) }"

    assert css =~
             ".fl-text-primary { color: var(--fl-color-primary-on-soft) }"

    assert css =~ ".fl-border-primary { border-color: var(--fl-color-primary) }"

    assert css =~
             ".fl-tone-success { --fl-tone: var(--fl-color-success); --fl-tone-on: var(--fl-color-success-on);"

    assert css =~ ".fl-bg-surface { background-color: var(--fl-color-surface) }"
    assert css =~ ".fl-text-muted { color: var(--fl-color-text-muted) }"
    assert css =~ ".fl-border-default { border-color: var(--fl-color-border) }"
  end

  test "motion utilities wrap the shared keyframes", %{css: css} do
    assert css =~ ".fl-animate-pulse {"
    assert css =~ "animation: fl-pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;"
    assert css =~ "animation: fl-spin 1s linear infinite;"
    assert css =~ "animation: fl-ping 1s cubic-bezier(0, 0, 0.2, 1) infinite;"
    assert css =~ "animation: fl-bounce 1s infinite;"
    assert css =~ "animation: fl-fade-in var(--fl-duration-base) var(--fl-ease-out) both;"
    assert css =~ "animation: fl-shake 500ms var(--fl-ease-in-out);"
    assert css =~ ".fl-animate-none {"
    assert css =~ "animation: none;"
    assert css =~ "animation-duration: var(--fl-duration-slow);"
    assert css =~ "animation-timing-function: linear;"

    assert css =~ ~r/@media \(prefers-reduced-motion: reduce\) \{\s+\.fl-animate-fade-in,/
    assert css =~ ~r/\.fl-animate-pulse,\s+\.fl-animate-bounce,/
  end

  test "responsive display classes use the token breakpoints as literals", %{css: css} do
    assert css =~ "@media (min-width: 40rem)"
    assert css =~ "@media (min-width: 48rem)"
    assert css =~ "@media (min-width: 64rem)"
    assert css =~ "@media (min-width: 80rem)"
    assert css =~ "@media (min-width: 96rem)"
    assert css =~ ".fl-sm-hidden { display: none; }"
    assert css =~ ".fl-md-flex { display: flex; }"
    assert css =~ ".fl-2xl-block { display: block; }"
  end

  test "the surface utility applies the shared elevation recipe", %{css: css} do
    assert css =~ ".fl-surface {"
    assert css =~ "background-color: var(--fl-elevation-fill, var(--fl-color-surface));"
    assert css =~ "box-shadow: var(--fl-elevation-surface);"

    refute css =~ "--_fl-elevation-scale"
    refute css =~ "--fl-elevation-depth:"
    refute css =~ "--fl-elevation-surface:"
  end

  test "the utility layer stays out of the component theme" do
    refute Generator.theme_source() =~ ".fl-stack"
    refute Generator.theme_source() =~ ".fl-surface {"
    refute Enum.any?(Generator.part_paths(), &(&1 =~ "utilities.css"))
  end

  test "families and classes agree", %{classes: classes} do
    family_ids = Enum.map(Utilities.families(), & &1.id)

    assert Enum.all?(classes, &(&1.family in family_ids))
    assert Enum.all?(classes, &is_binary(&1.declaration))
  end

  defp index(string, pattern) do
    {index, _length} = :binary.match(string, pattern)
    index
  end
end
