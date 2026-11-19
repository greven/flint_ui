defmodule FlintUI.Styled.Modal do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :modal,
      base: FlintUI.Base.Modal,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add modal",
      css: "styled/modal.css",
      tokens: [:color, :radius, :spacing, :duration, :ease],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ~w(sm md lg xl full),
          default: "md",
          doc:
            "The maximum width of the dialog. `full` fills the available viewport width while keeping the edge gutter."
        ),
        Prop.new(
          name: :placement,
          values: ~w(center top bottom left right),
          default: "center",
          doc:
            "Where the dialog sits in the viewport. Edge placements keep the same gutter and stay centered on the other axis."
        ),
        Prop.new(
          name: :backdrop,
          values: ~w(dim blur none),
          default: "dim",
          doc:
            "The backdrop treatment. `dim` darkens the page, `blur` darkens it through a blur filter, and `none` leaves it visible while the browser keeps it inert."
        ),
        Prop.new(
          name: :body,
          values: [
            "seamless",
            "inset",
            "flush",
            "divided",
            "separated",
            "separated-header",
            "separated-footer"
          ],
          default: "divided",
          forwarded_to: :card,
          doc:
            "How the card surface sets its header, body, and footer apart. `divided` draws hairlines, and the `separated` values tint the bands, so `separated-footer` gives the actions a tinted footer."
        ),
        Prop.new(
          name: :spacing,
          values: ~w(xs sm md lg xl),
          default: "md",
          forwarded_to: :card,
          doc:
            "The internal spacing of the card surface. It sets the header, body, and footer inset and the gap between regions."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-modal-max-width",
          default: "32rem",
          doc: "The maximum dialog width. The `size` prop sets it."
        ),
        Var.new(
          name: "--fl-modal-gutter",
          default: "var(--fl-spacing-lg)",
          doc:
            "The minimum space between the dialog and the viewport edge. It also caps the dialog height."
        ),
        Var.new(
          name: "--fl-modal-backdrop",
          default: "light-dark(rgb(0 0 0 / 0.35), rgb(0 0 0 / 0.55))",
          doc: "The backdrop color behind the dialog."
        )
      ],
      dependencies: [:card, :icon],
      related: [:alert, :popover]
    }
  end
end
