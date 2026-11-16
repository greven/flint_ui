defmodule FlintUI.Styled.DropdownHeader do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Var}

  def entry do
    %Entry{
      name: :dropdown_header,
      base: FlintUI.Base.DropdownHeader,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add dropdown_header",
      css: "styled/dropdown_header.css",
      tokens: [:color, :spacing, :font],
      related: [:dropdown],
      slots: [],
      props: [],
      vars: [
        Var.new(
          name: "--fl-dropdown-header-text",
          default: "var(--fl-color-text-muted)",
          doc: "The header label color. The default is the muted ink tier."
        )
      ]
    }
  end
end
