defmodule FlintUI.Styled.Cluster do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :cluster,
      base: FlintUI.Base.Cluster,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add cluster",
      css: "styled/cluster.css",
      tokens: [:spacing],
      slots: [],
      related: [:stack, :container, :group],
      props: [
        Prop.new(
          name: :align,
          values: ["start", "center", "end", "stretch", "baseline"],
          default: "center",
          doc:
            "The cross-axis alignment of the children. `start` and `end` follow the writing direction; `stretch` makes the children fill the row's block size."
        ),
        Prop.new(
          name: :gap,
          values: ["0", "xs", "sm", "md", "lg", "xl", "2xl", "3xl"],
          default: "md",
          doc:
            "The space between children on the shared `--fl-spacing-*` scale. The same gap separates wrapped lines. `0` joins them with no gap."
        ),
        Prop.new(
          name: :justify,
          values: ["start", "center", "end", "between", "around", "evenly", "split"],
          default: "start",
          doc:
            "The main-axis distribution of each line. `between` spreads the children across a line and is the usual choice for a leading title with trailing actions. `split` keeps the leading children at the start and pins the last child to the inline end on every line, so the trailing group stays right aligned after it wraps."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-cluster-align",
          default: "center",
          doc: "The cross-axis alignment; the `align` prop sets it from the scale."
        ),
        Var.new(
          name: "--fl-cluster-gap",
          default: "var(--fl-spacing-md)",
          doc:
            "The space between children and between wrapped lines; the `gap` prop sets it from the spacing scale."
        ),
        Var.new(
          name: "--fl-cluster-justify",
          default: "flex-start",
          doc:
            "The main-axis distribution; the `justify` prop sets it from the scale. `split` also sets it to `flex-start` and pins the last child to the inline end."
        )
      ]
    }
  end
end
