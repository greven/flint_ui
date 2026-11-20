defmodule FlintUI.Styled.BreadcrumbsItem do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop}

  def entry do
    %Entry{
      name: :breadcrumbs_item,
      base: FlintUI.Base.BreadcrumbsItem,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add breadcrumbs_item",
      css: "styled/breadcrumbs_item.css",
      tokens: [:color, :font, :spacing, :radius, :control, :duration, :ease],
      dependencies: [:icon],
      slots: [],
      props: [
        Prop.new(
          name: :separator,
          values: ["chevron", "slash", "arrow", "dot", "none"],
          default: "chevron",
          doc:
            "The decorative separator drawn before the crumb. The first item in a trail never shows one, and `none` removes it entirely."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :icon,
          type: :string,
          fills_content: true,
          doc:
            "An icon CSS class rendered before the crumb's content. The icon is decorative; pass `aria-label` when it is the only visible content."
        ),
        Attr.new(
          name: :text,
          type: :string,
          fills_content: true,
          doc:
            "A text label rendered when the default slot is not given. The default slot wins when both are set."
        )
      ]
    }
  end
end
