defmodule FlintUI.Styled.Stack do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :stack,
      base: FlintUI.Base.Stack,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add stack",
      css: "styled/stack.css",
      tokens: [:spacing],
      slots: [],
      props: [
        Prop.new(
          name: :align,
          values: ["start", "center", "end", "stretch", "baseline"],
          default: "stretch",
          doc:
            "The cross-axis alignment of the children. `start` and `end` follow the writing direction; `stretch` makes the children fill the stack's inline size."
        ),
        Prop.new(
          name: :gap,
          values: ["0", "xs", "sm", "md", "lg", "xl", "2xl", "3xl"],
          default: "md",
          doc:
            "The space between children on the shared `--fl-spacing-*` scale. `0` joins them with no gap. In a pile it is the base distance each layer moves from the one in front."
        ),
        Prop.new(
          name: :justify,
          values: ["start", "center", "end", "between", "around", "evenly"],
          default: "start",
          doc:
            "The main-axis distribution of the children. It only has an effect when the stack is taller than its content."
        ),
        Prop.new(
          name: :pile,
          values: [true, false],
          default: false,
          doc:
            "Whether the children overlap along the depth axis as a pile. The last child is the front layer and earlier children recede along `direction`, narrowing by `shrink`,
            so append the newest item last. `gap` sets the base distance between layers, `limit` caps the visible layers, and `align` and `justify` no longer apply.
            A pile is a preview: hidden layers leave the accessibility tree, so render a count or another way to reach them."
        ),
        Prop.new(
          name: :limit,
          values: ["2", "3", "4", "5"],
          default: "3",
          doc:
            "How many layers a pile shows. Earlier children beyond the limit are hidden, in layout and from the accessibility tree. Only applies with `pile`."
        ),
        Prop.new(
          name: :direction,
          values: ["up", "down"],
          default: "up",
          doc:
            "The side earlier layers peek out on. `up` stacks them above the front layer, for a pile anchored to the bottom of a region; `down`
            stacks them below it. Only applies with `pile`."
        ),
        Prop.new(
          name: :shrink,
          values: ["none", "sm", "md", "lg"],
          default: "sm",
          doc:
            "How much narrower each layer becomes. `none` keeps every layer the same width, so the pile reads as a flat stack; `sm` and above taper the
            layers behind the front one. Only applies with `pile`."
        ),
        Prop.new(
          name: :depth,
          values: ["none", "soft", "strong"],
          default: "soft",
          doc:
            "How much each layer behind the front one recedes. `soft` darkens the layers in even steps and lets the front layer cast a shadow onto them; `strong`
            exaggerates both for image-heavy piles; `none` leaves the pile as pure geometry. The shading is decorative and changes neither the children
            nor the accessibility tree. Only applies with `pile`."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-stack-align",
          default: "stretch",
          doc: "The cross-axis alignment; the `align` prop sets it from the scale."
        ),
        Var.new(
          name: "--fl-stack-gap",
          default: "var(--fl-spacing-md)",
          doc:
            "The space between children; the `gap` prop sets it from the spacing scale. In a pile it is also the peek distance between layers."
        ),
        Var.new(
          name: "--fl-stack-justify",
          default: "flex-start",
          doc: "The main-axis distribution; the `justify` prop sets it from the scale."
        ),
        Var.new(
          name: "--fl-stack-pile-offset",
          default: "calc(var(--fl-stack-gap) * -1)",
          doc:
            "The signed distance each layer moves from the front one in a pile; `direction` sets its sign from `gap`."
        ),
        Var.new(
          name: "--fl-stack-pile-shrink",
          default: "0.03",
          doc:
            "The fraction each layer narrows on the inline axis in a pile; the `shrink` prop sets it."
        )
      ]
    }
  end
end
