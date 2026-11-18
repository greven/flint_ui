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
      tokens: [:color, :radius, :spacing, :font, :shadow, :duration, :ease],
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
        )
      ],
      vars: [
        Var.new(
          name: "--fl-modal-max-width",
          default: "32rem",
          doc: "The maximum dialog width. The `size` prop sets it."
        ),
        Var.new(
          name: "--fl-modal-padding",
          default: "var(--fl-spacing-lg)",
          doc: "The inline padding of the header, body, and footer."
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
      dependencies: [:icon],
      related: [:alert, :popover]
    }
  end
end
