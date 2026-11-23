defmodule FlintUI.Styled.Color do
  @moduledoc """
  Resolves the `color` prop of a generated wrapper.

  Known semantic roles and the absolute tones (`dark` and `light`) stay on
  `data-color`, so the theme's value rules apply unchanged. Any other value is
  parsed as a raw color and expanded into the component's public color inputs.
  The fill is used exactly; labels and text are derived for WCAG contrast,
  preferring the requested color and moving only its lightness when it would be
  unreadable.

  Any palette hue name (`red`, `orange`, `yellow`, `green`, `cyan`, `blue`,
  `indigo`, `purple`, `pink`, `gray`) is also a presence hook. The active
  palette decides what the hue looks like, so the same component follows
  `data-palette` without a rebuild. Hue names are not semantic roles: they do
  not follow role remaps, but they do follow the palette and the color scheme.

  The absolute tones are not semantic roles: they have no scale and do not
  appear in the registry's documented `color` values. They are accepted
  everywhere the prop is free-form so a component can opt into a fixed dark or
  light fill without adding it to the public value list.

  The derived values are inline custom properties, so an explicit `style` on the
  instance wins over them.

  `apply/3` merges a raw value's style into `rest`, which suits a wrapper whose
  root is the component. `apply_style/3` returns the style as a separate
  `:color_style` assign instead, for wrappers whose `rest` targets a nested
  element and whose color inputs belong on the root.

  Pass `on_fill: :prefer_white` to `apply_style/4`, `style/4`, or `derive/3` to
  keep white labels on a raw fill unless white falls below 3:1. That suits
  initials-style colors that read as an image rather than body text; the default
  `:best` always picks the stronger of white and black.
  """

  alias FlintUI.Palette
  alias FlintUI.Palette.{Color, Contrast}

  @roles ~w(primary secondary success info warning danger neutral inherit)
  @absolute ~w(dark light)
  @hues Palette.hue_names()
  # White is kept for image-like labels until it misses the 3:1 large-text floor.
  @prefer_white_min_contrast 3.0

  # Saturated hues used for deterministic initials. Neutrals are deliberately
  # omitted so every name lands on a readable, recognisable fill.
  @initials_colors ~w(red orange amber yellow lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose)

  @doc """
  Whether `value` is a known role, an absolute tone, a palette hue, or a
  parseable raw color.

  This is the union of the documented roles (including `inherit`), the absolute
  tones, the palette hue names, and the accepted raw forms, and is meant for
  sanitizing values before they reach a component. A wrapper validates against
  its own role list.
  """
  def valid?(value) when is_binary(value) do
    resolve(value, @roles) != :error
  end

  def valid?(_value), do: false

  @doc false
  # Expands a raw color prop into the wrapper's assigns. Known values only set
  # the presence hook; raw values also merge the derived style into `rest`. The
  # absolute tones are known everywhere, even when an entry omits them from its
  # public value list.
  #
  # `:prop` names the prop to read (default `:color`) and `:data` names the hook
  # assign it produces (default `:data_color`), so a component can resolve a
  # second, state-specific color such as the toggle's `active_color`.
  def apply(assigns, roles, vars, opts \\ []) do
    prop = Keyword.get(opts, :prop, :color)
    data = Keyword.get(opts, :data, :data_color)
    value = Map.fetch!(assigns, prop)

    {data_color, rest} =
      case resolve(value, roles) do
        {:hook, hook} ->
          {hook, Map.get(assigns, :rest)}

        {:raw, source, color} ->
          {nil, merge_style(Map.get(assigns, :rest), style(source, color, vars))}

        :error ->
          raise ArgumentError, invalid_message(prop, value, roles)
      end

    # Both assigns are derived from the color, and a previous raw value may have
    # added a style to `rest`. Mark them changed so switching between a role and
    # a raw color always updates the rendered attributes.
    assigns
    |> put_assign(data, data_color)
    |> put_assign(:rest, rest)
  end

  @doc false
  # Marks a color hook absent, for a sentinel value such as `inherit`. The theme
  # then falls back to the base color inputs, so no style is written.
  def clear(assigns, data), do: put_assign(assigns, data, nil)

  @doc false
  # Like `apply/4`, but leaves `rest` alone and returns the raw color's inputs
  # as a `:color_style` assign. A wrapper whose root owns the color variables
  # (while `rest` belongs to a nested image) can place that style on the root.
  def apply_style(assigns, roles, vars, opts \\ []) do
    {data_color, color_style} = resolve_style(assigns.color, roles, vars, opts)

    assigns
    |> put_assign(:data_color, data_color)
    |> put_assign(:color_style, color_style)
  end

  @doc false
  # Resolves a free-form color into the `data-color` hook and the inline style
  # without assigns. Wrappers that color repeated children from slot attributes
  # cannot call `apply_style/4`, which writes assigns.
  def resolve_style(color, roles, vars, opts \\ []) do
    case resolve(color, roles) do
      {:hook, hook} ->
        {hook, nil}

      {:raw, source, color} ->
        {nil, style(source, color, vars, opts)}

      :error ->
        raise ArgumentError, invalid_message(:color, color, roles)
    end
  end

  @doc false
  # A stable, per-name color for initials. SHA-256 keeps the mapping stable
  # across nodes and OTP releases. A blank name stays on the theme's neutral
  # role so it follows presets instead of picking an arbitrary hue.
  def initials_color(name) when is_binary(name) do
    case String.trim(name) do
      "" ->
        "neutral"

      name ->
        index =
          :crypto.hash(:sha256, name)
          |> :binary.bin_to_list()
          |> Enum.sum()
          |> rem(length(@initials_colors))

        Enum.at(@initials_colors, index)
    end
  end

  def initials_color(_name), do: "neutral"

  # Resolves a free-form color once, so `valid?/1` and `apply/3` agree on what
  # is accepted. A role, absolute tone, or palette hue is a presence hook;
  # everything else is a raw color, with the CSS string used as the fill.
  defp resolve(value, roles) when is_binary(value) do
    if value in roles or value in @absolute or value in @hues or
         value in Palette.extra_hue_names() do
      {:hook, value}
    else
      raw(value)
    end
  end

  defp resolve(_value, _roles), do: :error

  defp raw(value) do
    case Color.parse(value) do
      {:ok, color} -> {:raw, value, color}
      :error -> :error
    end
  end

  @doc false
  # The inline style for a parsed raw color, keyed by the wrapper's color vars.
  def style(source, color, vars, opts \\ []) do
    values = derive(source, color, opts)

    vars
    |> Enum.map(fn {key, var} ->
      case Map.get(values, key) do
        nil -> nil
        value when var == :color -> "color: #{format(value)}"
        value -> "#{var}: #{format(value)}"
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("; ")
  end

  @doc false
  # The derived values for a raw color. Text values are `{light, dark}` pairs;
  # the label on a fill is a single scheme-independent color. The role text is
  # scored against the tinted surface, the stricter background in both schemes.
  #
  # `:soft` and `:soft_border` mirror the theme's tinted-input fallbacks, so a
  # component whose pressed state carries its own raw color can write the tinted
  # pair for that color instead of reusing the untoggled one.
  def derive(source, color, opts \\ []) do
    target = Contrast.aa()
    light = Contrast.light_background()
    dark = Contrast.dark_background()

    %{
      fill: source,
      on_fill: on_fill(color, opts),
      on_text: {
        readable(source, color, tint(color, light), target),
        readable(source, color, tint(color, dark), target)
      },
      soft: "color-mix(in oklab, #{source} 10%, var(--fl-color-surface))",
      soft_border:
        "color-mix(in oklab, #{source} var(--fl-border-strength-soft), var(--fl-color-surface))"
    }
  end

  defp on_fill(color, opts) do
    white = Contrast.ratio(color.css, Color.white()) || 0.0
    black = Contrast.ratio(color.css, Color.black()) || 0.0

    case Keyword.get(opts, :on_fill, :best) do
      :prefer_white ->
        if white >= @prefer_white_min_contrast, do: Color.white(), else: Color.black()

      _ ->
        if white >= black, do: Color.white(), else: Color.black()
    end
  end

  # Keep the requested color when it clears the target. Otherwise mix it toward
  # black (on a light surface) or white (on a dark one) just enough to pass.
  defp readable(source, color, background, target) do
    endpoint =
      if (Contrast.luminance(background) || 0.0) >= 0.5, do: Color.black(), else: Color.white()

    case Contrast.mix_to_target(color.css, [background], target, endpoint) do
      {_value, 0} -> source
      {_value, percent} -> "color-mix(in oklab, #{color.css}, #{endpoint} #{percent}%)"
    end
  end

  # The text carries the color over both the page and tinted surfaces, so score
  # it against the tint the tinted variants paint, the stricter background.
  defp tint(color, background), do: Contrast.mix(color.css, background, 0.15)

  defp format({same, same}), do: same
  defp format({light, dark}), do: "light-dark(#{light}, #{dark})"
  defp format(value), do: value

  defp put_assign(assigns, key, value) do
    assigns = Phoenix.Component.assign(assigns, key, value)

    case Map.get(assigns, :__changed__) do
      # The initial render has no change map; everything is rendered.
      nil -> assigns
      changed -> Map.put(assigns, :__changed__, Map.put(changed, key, true))
    end
  end

  defp merge_style(rest, derived) when is_map(rest) do
    user = Map.get(rest, :style) || Map.get(rest, "style")
    rest = Map.drop(rest, [:style, "style"])

    case user do
      value when value in [nil, ""] -> Map.put(rest, :style, derived)
      value -> Map.put(rest, :style, "#{derived}; #{value}")
    end
  end

  defp merge_style(_rest, derived), do: %{style: derived}

  defp invalid_message(prop, value, roles) do
    """
    invalid color #{inspect(value)} for the `#{prop}` prop.

    Use a semantic role (#{Enum.join(roles, ", ")}), an absolute tone
    (#{Enum.join(@absolute, ", ")}), a palette hue
    (#{Enum.join(Palette.known_hue_names(), ", ")}), or a raw color:

      * cyan, pink, gray (the active palette's core shade)
      * #rgb or #rrggbb
      * rgb(29 114 254)
      * oklch(58% 0.2 264)

    Alpha is not supported because the effective fill depends on the surface.
    """
  end
end
