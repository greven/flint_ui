defmodule FlintUI.Styled.Collapsible do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :collapsible,
      base: FlintUI.Base.Collapsible,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add collapsible",
      css: "styled/collapsible.css",
      tokens: [:color, :radius, :duration, :ease],
      slots: [],
      vars: [
        Var.new(
          name: "--fl-collapsible-duration",
          default: "var(--fl-duration-base)",
          doc: "Duration of the open/close reveal."
        ),
        Var.new(
          name: "--fl-collapsible-easing",
          default: "var(--fl-ease-in-out)",
          doc: "Timing function of the reveal."
        )
      ],
      props: []
    }
  end
end
