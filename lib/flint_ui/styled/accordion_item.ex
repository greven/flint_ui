defmodule FlintUI.Styled.AccordionItem do
  @moduledoc false

  alias FlintUI.Styled.Entry

  def entry do
    %Entry{
      name: :accordion_item,
      base: FlintUI.Base.AccordionItem,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add accordion_item",
      css: "styled/accordion_item.css",
      tokens: [:color, :radius, :spacing, :font, :duration, :ease],
      related: [:accordion],
      dependencies: [:collapsible],
      slots: [],
      props: [],
      vars: []
    }
  end
end
