defmodule FlintUI.Styled.Text do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :text,
      base: FlintUI.Base.Text,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add text",
      css: "styled/text.css",
      tokens: [:color, :font],
      primitives: [:typography],
      related: [:heading],
      slots: [],
      props: [
        Prop.new(
          name: :size,
          values: ~w(xs sm md lg xl 2xl 3xl 4xl 5xl 6xl),
          default: "md",
          primitive: :typography,
          doc: "The text size, from the shared type scale."
        ),
        Prop.new(
          name: :color,
          values:
            ~w(default highlighted toned muted dimmed inverted neutral info success warning danger primary secondary),
          default: "default",
          allow_custom: true,
          primitive: :typography,
          doc:
            "The text ink: a text tier such as `default` or `toned`, a semantic role such as `primary` or `danger`, or a raw CSS color such as `#1D72FE`. `dimmed` is below AA and belongs to decoration only. A link in the default tier uses the primary ink."
        ),
        Prop.new(
          name: :weight,
          values: ~w(thin extralight light normal medium semibold bold extrabold black),
          default: "normal",
          primitive: :typography,
          doc: "The text font weight."
        ),
        Prop.new(
          name: :align,
          values: ~w(start center end justify),
          default: "start",
          primitive: :typography,
          doc: "The text alignment."
        ),
        Prop.new(
          name: :external,
          values: [true, false],
          default: false,
          doc:
            "Whether the link leaves the site. Adds a trailing arrow inside the link and the `data-external` hook. It only applies to the link form and does not change where the link opens; set `target` and `rel` when it should open in a new tab."
        ),
        Prop.new(
          name: :truncate,
          values: [true, false],
          default: false,
          doc:
            "Whether the text is truncated to a single line with an ellipsis. The root becomes a block box. `line_clamp` takes precedence."
        ),
        Prop.new(
          name: :line_clamp,
          values: [1, 2, 3, 4, 5, 6],
          default: nil,
          allow_custom: true,
          type: :integer,
          doc:
            "The number of lines before the text is clamped with an ellipsis. Values `1` to `6` are documented, and any positive integer works. Takes precedence over `truncate`."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :external_icon,
          type: :string,
          default: "lucide-arrow-up-right",
          doc:
            "The icon class for the external-link arrow. Set it to a class from your icon set, or to an empty string to keep the `data-external` hook without an arrow."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-text-line-clamp",
          default: nil,
          doc:
            "The line count used by `line_clamp`. The prop writes it inline so a custom count works."
        )
      ],
      color_vars: [on_text: "--fl-typography-color"]
    }
  end
end
