defmodule FlintUI.Styled.Popover do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :popover,
      base: FlintUI.Base.Popover,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add popover",
      css: "styled/popover.css",
      tokens: [:color, :radius, :spacing, :font, :elevation, :duration, :ease],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-popover-max-width",
          default: "20rem",
          doc: "Maximum width of the popover before its content wraps."
        ),
        Var.new(
          name: "--fl-popover-padding",
          default: "var(--fl-spacing-md)",
          doc: "Inner padding of the popover content."
        ),
        Var.new(
          name: "--fl-popover-surface",
          default: "var(--fl-color-surface-raised)",
          doc:
            "Background color of the popover content. It feeds `--fl-elevation-fill`, so the content uses the shared raised-surface trim and elevation."
        ),
        Var.new(
          name: "--fl-popover-border",
          default: "var(--fl-color-border)",
          doc:
            "Border color of the popover content. It feeds `--fl-elevation-border`; tune the depth with `--fl-elevation-level`."
        ),
        Var.new(
          name: "--fl-popover-text",
          default: "var(--fl-color-text)",
          doc: "Text color of the popover content."
        ),
        Var.new(
          name: "--fl-popover-arrow-gap",
          default: "4px",
          doc:
            "Extra distance added to `offset` when `arrow` is set, so the arrow tip keeps a small gap instead of touching the trigger. Raise it for more air."
        )
      ],
      props: []
    }
  end
end
