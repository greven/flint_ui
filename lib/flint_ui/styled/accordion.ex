defmodule FlintUI.Styled.Accordion do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :accordion,
      base: FlintUI.Base.Accordion,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add accordion",
      css: "styled/accordion.css",
      tokens: [:color, :radius, :spacing, :font, :duration, :ease, :shadow],
      related: [{:accordion_item, nav: true}],
      dependencies: [:collapsible],
      slots: [],
      props: [
        Prop.new(
          name: :variant,
          values: ["simple", "contained", "separated"],
          default: "simple",
          doc:
            "The layout treatment. `simple` uses dividers only, `contained` wraps the stack in one bordered surface, and `separated` gives every item its own bordered surface."
        ),
        Prop.new(
          name: :surface,
          values: ["solid", "soft", "strong", "ghost"],
          default: "solid",
          doc:
            "The neutral surface and edge treatment. `contained` and `separated` paint the surface and outline; `simple` uses the same steps for the divider strength. `ghost` removes the simple divider and the card surface."
        ),
        Prop.new(
          name: :indicator_position,
          values: ["left", "right"],
          default: "right",
          doc: "Which side of the header the indicator sits on."
        ),
        Prop.new(
          name: :transition,
          values: [true, false],
          default: true,
          doc:
            "Whether the panel animates and the default chevron rotates. Set false for an instant toggle."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :duration,
          type: :integer,
          default: 200,
          doc: "Transition duration in milliseconds."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-accordion-surface",
          default: "var(--fl-color-surface)",
          doc: "The surface for `contained` and `separated`; `surface` selects it."
        ),
        Var.new(
          name: "--fl-accordion-border",
          default: "var(--fl-color-border)",
          doc:
            "The surface outline, the simple divider, and the divider inside a contained accordion."
        ),
        Var.new(
          name: "--fl-accordion-shadow",
          default: "var(--fl-shadow-base)",
          doc:
            "The elevation for `contained` and `separated`; set it to `0 0 #0000` to remove the shadow."
        ),
        Var.new(
          name: "--fl-accordion-gap",
          default: "var(--fl-spacing-sm)",
          doc: "The gap between items in the `separated` variant."
        ),
        Var.new(
          name: "--fl-accordion-duration",
          default: "var(--fl-duration-base)",
          doc: "The reveal and indicator duration; the `duration` prop sets it."
        ),
        Var.new(
          name: "--fl-accordion-highlight-opacity",
          default: "var(--fl-control-hover-opacity)",
          doc:
            "The hover and open-item highlight opacity, as a `0`–`1` number. Defaults to the shared control hover opacity."
        )
      ]
    }
  end
end
