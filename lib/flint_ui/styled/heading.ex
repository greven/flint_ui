defmodule FlintUI.Styled.Heading do
  @moduledoc false

  alias FlintUI.Styled.{Entry, Prop, Var}

  def entry do
    %Entry{
      name: :heading,
      base: FlintUI.Base.Heading,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add heading",
      css: "styled/heading.css",
      tokens: [:color, :font, :spacing],
      primitives: [:typography],
      related: [:text],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ~w(auto xs sm md lg xl 2xl 3xl 4xl 5xl 6xl),
          default: "auto",
          resolved: ["auto"],
          primitive: :typography,
          doc:
            "The visual scale. `auto` follows the semantic level: `h1` uses `5xl`, `h2` `4xl`, `h3` `3xl`, `h4` `2xl`, `h5` `xl`, and `h6` `lg`. Pass a step to decouple the visual size from the document outline."
        ),
        Prop.new(
          name: :color,
          values:
            ~w(default highlighted toned muted dimmed inverted neutral info success warning error primary secondary),
          default: "highlighted",
          allow_custom: true,
          primitive: :typography,
          doc:
            "The heading ink: a text tier such as `highlighted` (the default) or `toned`, a semantic role such as `primary` or `error`, or a raw CSS color such as `#1D72FE`. `dimmed` is below AA and belongs to decoration only."
        ),
        Prop.new(
          name: :weight,
          values: ~w(thin extralight light normal medium semibold bold extrabold black),
          default: "semibold",
          primitive: :typography,
          doc: "The heading font weight."
        ),
        Prop.new(
          name: :align,
          values: ~w(start center end justify),
          default: "start",
          primitive: :typography,
          doc: "The text alignment of the kicker, heading, and subtitle."
        ),
        Prop.new(
          name: :truncate,
          values: [true, false],
          default: false,
          doc:
            "Whether the heading title is truncated to a single line with an ellipsis. The kicker and subtitle stay visible. `line_clamp` takes precedence."
        ),
        Prop.new(
          name: :line_clamp,
          values: [1, 2, 3, 4, 5, 6],
          default: nil,
          allow_custom: true,
          type: :integer,
          doc:
            "The number of title lines before the heading is clamped with an ellipsis. Values `1` to `6` are documented, and any positive integer works. Takes precedence over `truncate`."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-heading-kicker-color",
          default: "var(--fl-color-text-muted)",
          doc: "The kicker ink."
        ),
        Var.new(
          name: "--fl-heading-subtitle-color",
          default: "var(--fl-color-text-toned)",
          doc: "The subtitle ink."
        ),
        Var.new(
          name: "--fl-heading-gap",
          default: "var(--fl-spacing-sm)",
          doc: "The space between the kicker, heading, and subtitle."
        ),
        Var.new(
          name: "--fl-heading-line-clamp",
          default: nil,
          doc:
            "The title line count used by `line_clamp`. The prop writes it inline so a custom count works."
        )
      ],
      color_vars: [on_text: "--fl-typography-color"]
    }
  end
end
