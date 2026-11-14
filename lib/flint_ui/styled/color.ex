defmodule FlintUI.Styled.Color do
  @moduledoc """
  Resolves the `color` prop of a generated wrapper.

  Known semantic roles and the absolute tones (`dark` and `light`) stay on
  `data-color`, so the theme's value rules apply unchanged. Any other value is
  parsed as a raw color and expanded into the component's public color inputs.
  The fill is used exactly; labels and text are derived for WCAG contrast,
  preferring the requested color and moving only its lightness when it would be
  unreadable.

  A raw value can name a color from the bundled Tailwind palette with a `tw:`
  prefix: `tw:rose` is rose-500 and `tw:rose-700` is rose-700. The palette is
  vendored as data, so it works without Tailwind. It is a static snapshot, not
  the host app's Tailwind theme, and the names are not semantic roles: they do
  not follow presets or change with the color scheme.

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
  alias FlintUI.Palette.{Color, Contrast, Tailwind}

  @roles ~w(primary secondary success info warning error neutral inherit)
  @absolute ~w(dark light)
  @tailwind_default_shade 500
  # White is kept for image-like labels until it misses the 3:1 large-text floor.
  @prefer_white_min_contrast 3.0

  # Saturated hues used for deterministic initials. Neutrals are deliberately
  # omitted so every name lands on a readable, recognisable fill.
  @initials_colors ~w(red orange amber lime green emerald teal cyan sky blue indigo violet purple fuchsia pink rose)
  @initials_shade 600

  @doc """
  Whether `value` is a known role, an absolute tone, a `tw:` palette color, or a
  parseable raw color.

  This is the union of the documented roles (including `inherit`), the absolute
  tones, and the accepted raw forms, and is meant for sanitizing values before
  they reach a component. A wrapper validates against its own role list.
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
    {data_color, color_style} =
      case resolve(assigns.color, roles) do
        {:hook, hook} ->
          {hook, nil}

        {:raw, source, color} ->
          {nil, style(source, color, vars, opts)}

        :error ->
          raise ArgumentError, invalid_message(:color, assigns.color, roles)
      end

    assigns
    |> put_assign(:data_color, data_color)
    |> put_assign(:color_style, color_style)
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

        "tw:#{Enum.at(@initials_colors, index)}-#{@initials_shade}"
    end
  end

  def initials_color(_name), do: "neutral"

  # Resolves a free-form color once, so `valid?/1` and `apply/3` agree on what
  # is accepted. A role or absolute tone is a presence hook; everything else is
  # a raw color, with the CSS string used as the fill.
  defp resolve(value, roles) when is_binary(value) do
    if value in roles or value in @absolute do
      {:hook, value}
    else
      raw(value)
    end
  end

  defp resolve(_value, _roles), do: :error

  defp raw(value) do
    case tailwind(value) do
      {:ok, css} ->
        case Color.parse(css) do
          {:ok, color} -> {:raw, color.css, color}
          :error -> :error
        end

      :error ->
        case Color.parse(value) do
          {:ok, color} -> {:raw, value, color}
          :error -> :error
        end
    end
  end

  # `tw:<name>` selects the 500 shade; `tw:<name>-<shade>` selects an explicit
  # one. Names and shades are validated against the vendored palette, so a typo
  # is an error rather than a silently unstyled control.
  defp tailwind(value) do
    with "tw:" <> rest <- String.downcase(String.trim(value)) do
      case String.split(rest, "-", parts: 2) do
        [name] ->
          palette_color(name, @tailwind_default_shade)

        [name, shade] ->
          case Integer.parse(shade) do
            {shade, ""} -> palette_color(name, shade)
            _ -> :error
          end
      end
    else
      _ -> :error
    end
  end

  defp palette_color(name, shade) do
    with color when not is_nil(color) <-
           Enum.find(Tailwind.colors(), &(Atom.to_string(&1) == name)),
         true <- shade in Palette.shade_keys() do
      {:ok, Map.fetch!(Tailwind.shades(color), shade)}
    else
      _ -> :error
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
    if at_least?(color.css, background, target) do
      source
    else
      endpoint =
        if (Contrast.luminance(background) || 0.0) >= 0.5, do: Color.black(), else: Color.white()

      percent = minimal_percent(color.css, endpoint, background, target)
      "color-mix(in oklab, #{color.css}, #{endpoint} #{percent}%)"
    end
  end

  # The text carries the color over both the page and tinted surfaces, so score
  # it against the tint the tinted variants paint, the stricter background.
  defp tint(color, background), do: Contrast.mix(color.css, background, 0.15)

  defp minimal_percent(fill, endpoint, background, target) do
    if at_least?(Contrast.mix(endpoint, fill, 1.0), background, target) do
      search(0, 100, fill, endpoint, background, target)
    else
      100
    end
  end

  defp search(lo, hi, _fill, _endpoint, _background, _target) when hi - lo <= 1, do: hi

  defp search(lo, hi, fill, endpoint, background, target) do
    mid = div(lo + hi, 2)
    mixed = Contrast.mix(endpoint, fill, mid / 100)

    if at_least?(mixed, background, target) do
      search(lo, mid, fill, endpoint, background, target)
    else
      search(mid, hi, fill, endpoint, background, target)
    end
  end

  defp at_least?(candidate, background, target) do
    case Contrast.ratio(candidate, background) do
      ratio when is_float(ratio) -> ratio >= target
      _ -> false
    end
  end

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
    (#{Enum.join(@absolute, ", ")}), a Tailwind palette color, or a raw color:

      * tw:rose (rose-500) or tw:rose-700 (shades 50..950)
      * #rgb or #rrggbb
      * rgb(29 114 254)
      * oklch(58% 0.2 264)

    Alpha is not supported because the effective fill depends on the surface.
    """
  end
end
