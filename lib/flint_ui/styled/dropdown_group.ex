defmodule FlintUI.Styled.DropdownGroup do
  @moduledoc false

  alias FlintUI.Styled.Entry

  def entry do
    %Entry{
      name: :dropdown_group,
      base: FlintUI.Base.DropdownGroup,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add dropdown_group",
      css: "styled/dropdown_group.css",
      tokens: [:spacing],
      related: [:dropdown],
      slots: [],
      props: [],
      vars: []
    }
  end
end
