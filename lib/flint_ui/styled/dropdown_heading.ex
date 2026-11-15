defmodule FlintUI.Styled.DropdownHeading do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :dropdown_heading,
      base: FlintUI.Base.DropdownHeading,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add dropdown_heading",
      css: "styled/dropdown_heading.css",
      tokens: [:color, :spacing, :font],
      related: [:dropdown],
      slots: [],
      props: [],
      vars: [
        Var.new(
          name: "--fl-dropdown-heading-text",
          default: "var(--fl-color-text-muted)",
          doc: "The heading label color. The default is the muted ink tier."
        )
      ]
    }
  end
end
