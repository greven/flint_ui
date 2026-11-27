defmodule FlintUI.Styled.Header do
  @moduledoc false

  alias FlintUI.Styled.{Attr, Entry, Prop, Var}

  def entry do
    %Entry{
      name: :header,
      base: FlintUI.Base.Header,
      target: "lib/my_app_web/components.ex",
      install: "mix flint.add header",
      css: "styled/header.css",
      tokens: [:color, :font, :spacing, :radius, :control, :duration, :ease],
      slots: [],
      props: [
        Prop.new(
          name: :sticky,
          values: [true, false],
          default: true,
          doc:
            "Whether the header sticks to the top of the scroll container. Set the top offset with `--fl-header-offset` when a banner sits above it."
        ),
        Prop.new(
          name: :surface,
          values: ~w(solid soft strong transparent),
          default: "solid",
          doc:
            "The header's background surface. `solid` is the page surface, `soft` and `strong` step up the neutral tint, and `transparent` drops the fill while keeping the bottom border. Set `--fl-header-border: transparent` to remove the border too."
        ),
        Prop.new(
          name: :blur,
          values: [true, false],
          default: false,
          doc:
            "Frosts the selected surface: the fill turns translucent and a backdrop blur softens the content scrolling behind it. It is most useful on the default sticky header. When backdrop blur is unavailable or the user prefers reduced transparency, the header falls back to the opaque surface."
        ),
        Prop.new(
          name: :nav_position,
          values: ~w(start center end),
          default: "center",
          doc:
            "Where the navigation sits in the bar. `center` is the three-section layout: brand at the start, navigation in the middle, actions at the end. `start` keeps the navigation next to the brand, and `end` keeps it next to the actions."
        ),
        Prop.new(
          name: :toggle_position,
          values: ~w(start end),
          default: "end",
          doc:
            "Which side of the bar the mobile toggle sits on. `end` places it after the actions and `start` before the brand. The panel always flows under the bar."
        ),
        Prop.new(
          name: :collapse,
          values: ~w(always sm md lg xl 2xl never),
          default: "lg",
          doc:
            "The breakpoint below which the navigation collapses into the toggle panel. `always` keeps the collapsed layout at every width, and `never` keeps the navigation inline and hides the toggle."
        ),
        Prop.new(
          name: :container,
          values: [true, false],
          default: false,
          doc:
            "Caps the bar and the secondary row at `--fl-header-container-size` and centers them. The header surface and border stay full width."
        )
      ],
      content_attrs: [
        Attr.new(
          name: :toggle_icon,
          type: :string,
          default: "",
          doc:
            "The icon class rendered inside the mobile toggle while the panel is closed. Set it to a class from your icon set. Empty, the default, uses the built-in hamburger mark that morphs into a close mark."
        ),
        Attr.new(
          name: :toggle_icon_open,
          type: :string,
          default: "lucide-x",
          doc:
            "The icon class rendered inside the mobile toggle while the panel is open. The default is `lucide-x`. Set it to an empty string to keep the closed icon in both states; it has no effect when `toggle_icon` is empty."
        )
      ],
      vars: [
        Var.new(
          name: "--fl-header-surface",
          default: "var(--fl-color-surface)",
          doc:
            "The header's base background surface; `surface` selects it. `blur` paints it as a translucent mix so the page shows through."
        ),
        Var.new(
          name: "--fl-header-border",
          default: "var(--fl-color-border)",
          doc: "The header's bottom border and the rule above the secondary row."
        ),
        Var.new(
          name: "--fl-header-padding-inline",
          default: "var(--fl-spacing-lg)",
          doc: "The inline padding of the bar, the secondary row, and the mobile panel."
        ),
        Var.new(
          name: "--fl-header-container-size",
          default: "var(--fl-container-7xl)",
          doc: "The maximum inline size when `container` is set."
        ),
        Var.new(
          name: "--fl-header-offset",
          default: "0px",
          doc: "The sticky offset from the top of the scroll container."
        )
      ],
      dependencies: [:icon],
      related: [:container, :navbar]
    }
  end
end
