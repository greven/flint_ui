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
          default: "18rem",
          doc: "Maximum width of the tooltip before its text wraps."
        )
      ],
      props: []
    }
  end
end
