defmodule FlintUI.Styled.Container do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :container,
      base: FlintUI.Base.Container,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add container",
      css: "styled/container.css",
      tokens: [:container, :spacing],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: FlintUI.Styled.ContainerSize.values(),
          default: FlintUI.Styled.ContainerSize.default(),
          allow_custom: true,
          type: :any,
          doc:
            ~s|The maximum inline size. A container token from `xs` to `7xl`; `fluid` to drop the cap; a number of pixels converted to rem (`720` becomes `45rem`); an arbitrary CSS length such as `48rem` or `min(90ch, 60rem)`; or a map of breakpoint overrides such as `%{"2xl" => "7xl", base: "md", md: "xl"}`. Breakpoint keys are `sm`, `md`, `lg`, `xl`, and `2xl` (the last as a string key). Each breakpoint value accepts the same forms.|
        )
      ],
      vars: [
        Var.new(
          name: "--fl-container-size",
          default: "var(--fl-container-6xl)",
          doc: "The maximum inline size. The `size` prop sets it from a token or an inline value."
        ),
        Var.new(
          name: "--fl-container-size-sm",
          default: "var(--fl-container-size)",
          doc: "The maximum inline size at the `sm` breakpoint; it falls back to the base size."
        ),
        Var.new(
          name: "--fl-container-size-md",
          default: "var(--fl-container-size-sm)",
          doc: "The maximum inline size at the `md` breakpoint; it falls back to the `sm` size."
        ),
        Var.new(
          name: "--fl-container-size-lg",
          default: "var(--fl-container-size-md)",
          doc: "The maximum inline size at the `lg` breakpoint; it falls back to the `md` size."
        ),
        Var.new(
          name: "--fl-container-size-xl",
          default: "var(--fl-container-size-lg)",
          doc: "The maximum inline size at the `xl` breakpoint; it falls back to the `lg` size."
        ),
        Var.new(
          name: "--fl-container-size-2xl",
          default: "var(--fl-container-size-xl)",
          doc: "The maximum inline size at the `2xl` breakpoint; it falls back to the `xl` size."
        ),
        Var.new(
          name: "--fl-container-padding",
          default: "var(--fl-spacing-lg)",
          doc: "The inline padding on each side of the content."
        )
      ]
    }
  end
end
