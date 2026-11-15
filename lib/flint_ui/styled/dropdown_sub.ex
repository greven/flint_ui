defmodule FlintUI.Styled.DropdownSub do
  @moduledoc false

  alias FlintUI.Styled.Entry

  def entry do
    %Entry{
      name: :dropdown_sub,
      base: FlintUI.Base.DropdownSub,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add dropdown_sub",
      css: "styled/dropdown_sub.css",
      tokens: [:color, :spacing, :font, :duration, :ease],
      related: [:dropdown],
      slots: [],
      props: [],
      vars: []
    }
  end
end
