defmodule FlintUI.Styled.DropdownSeparator do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :dropdown_separator,
      base: FlintUI.Base.DropdownSeparator,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add dropdown_separator",
      css: "styled/dropdown_separator.css",
      tokens: [:color, :spacing],
      related: [:dropdown],
      slots: [],
      props: [],
      vars: [
        Var.new(
          name: "--fl-dropdown-separator-color",
          default: "var(--fl-color-border-subtle)",
          doc: "The separator line color."
        )
      ]
    }
  end
end
