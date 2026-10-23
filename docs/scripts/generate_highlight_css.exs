# Generates the docs' syntax-highlighting stylesheet from Makeup's style maps.
#
#     mix run scripts/generate_highlight_css.exs > assets/css/highlight.css
#
# Light mode uses Paraiso Light; dark mode uses Paraiso Dark. Token colours are
# emitted with light-dark(), so one stylesheet follows the docs' color scheme.
# The .highlight background is transparent: the code panel supplies its own
# subtle surface so it can sit inside the preview card.

light = Makeup.Styles.HTML.StyleMap.paraiso_light_style()
dark = Makeup.Styles.HTML.StyleMap.paraiso_dark_style()

base_light = light.styles[:text].color || "#2f1e2e"
base_dark = dark.styles[:text].color || "#ABB2BF"

types =
  (Map.keys(light.styles) ++ Map.keys(dark.styles))
  |> Enum.uniq()
  |> Enum.reject(&(&1 == :text))
  |> Enum.sort_by(&Makeup.Token.Utils.css_class_for_token_type/1)

color = fn style, fallback ->
  (style && style.color) || fallback
end

merged_attr = fn l, d, field ->
  case {l && Map.get(l, field), d && Map.get(d, field)} do
    {nil, nil} -> nil
    {value, nil} -> value
    {nil, value} -> value
    {value, _} -> value
  end
end

render_token = fn type ->
  l = light.styles[type]
  d = dark.styles[type]
  class = Makeup.Token.Utils.css_class_for_token_type(type)
  color_decl = "color: light-dark(#{color.(l, base_light)}, #{color.(d, base_dark)});"

  extra =
    [
      {"font-style", merged_attr.(l, d, :font_style)},
      {"font-weight", merged_attr.(l, d, :font_weight)}
    ]
    |> Enum.reject(fn {_, value} -> is_nil(value) end)
    |> Enum.map_join(" ", fn {name, value} -> "#{name}: #{value};" end)

  bg =
    case {l && l.background_color, d && d.background_color} do
      {nil, nil} -> ""
      {light_bg, nil} -> "background-color: #{light_bg};"
      {nil, dark_bg} -> "background-color: #{dark_bg};"
      {light_bg, dark_bg} -> "background-color: light-dark(#{light_bg}, #{dark_bg});"
    end

  border =
    case {l && l.border, d && d.border} do
      {nil, nil} -> ""
      {light_border, nil} -> "border: #{light_border};"
      {nil, dark_border} -> "border: #{dark_border};"
      {light_border, dark_border} -> "border: light-dark(#{light_border}, #{dark_border});"
    end

  decoration =
    case merged_attr.(l, d, :text_decoration) do
      nil -> ""
      value -> "text-decoration: #{value};"
    end

  decls = Enum.reject([color_decl, extra, bg, border, decoration], &(&1 == ""))

  ".highlight .#{class} { #{Enum.join(decls, " ")} } /* :#{type} */"
end

hll =
  case {light.highlight_color, dark.highlight_color} do
    {same, same} -> "background-color: #{same};"
    {light_color, dark_color} -> "background-color: light-dark(#{light_color}, #{dark_color});"
  end

css = [
  "/* Generated from Makeup's Paraiso Light (light) and Paraiso Dark (dark) styles:",
  "   mix run scripts/generate_highlight_css.exs > assets/css/highlight.css",
  "   The token colours are scoped under .highlight and selected with light-dark().",
  "   The panel background is supplied by the host so it can match the surrounding card. */",
  ".highlight { color: light-dark(#{base_light}, #{base_dark}); background-color: transparent; }",
  ".highlight .hll { #{hll} }",
  ".highlight .unselectable {",
  "  -webkit-touch-callout: none;",
  "  -webkit-user-select: none;",
  "  -khtml-user-select: none;",
  "  -moz-user-select: none;",
  "  -ms-user-select: none;",
  "  user-select: none;",
  "}",
  ""
] ++ Enum.map(types, render_token)

IO.puts(Enum.join(css, "\n"))
