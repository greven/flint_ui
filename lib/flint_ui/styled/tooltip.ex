defmodule FlintUI.Styled.Tooltip do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :tooltip,
      base: FlintUI.Base.Tooltip,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add tooltip",
      css: "styled/tooltip.css",
      tokens: [:color, :radius, :spacing, :font, :shadow, :duration, :ease],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-tooltip-max-width",
          default: "20rem",
          doc: "Maximum width of the tooltip before its text wraps."
        ),
        Var.new(
          name: "--fl-tooltip-arrow-gap",
          default: "2px",
          doc:
            "Extra distance added to `offset` when `arrow` is set, so the arrow tip keeps a small gap instead of touching the trigger. Raise it for more air."
        )
      ],
      props: []
    }
  end
end
