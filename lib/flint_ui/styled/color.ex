defmodule FlintUI.Styled.Color do
  @moduledoc """
  Resolves the `color` prop of a generated wrapper.

  Known role values stay on `data-color`, so the theme's role rules apply
  unchanged. Any other value is parsed as a raw color and expanded into the
  component's public color inputs. The fill is used exactly; labels and text are
  derived for WCAG contrast, preferring the requested color and moving only its
  lightness when it would be unreadable.

  The derived values are inline custom properties, so an explicit `style` on the
  instance wins over them.
  """

  alias FlintUI.Palette.{Color, Contrast}

  @roles ~w(primary secondary success info warning error neutral inherit)

  @doc """
  Whether `value` is a known role or a parseable raw color.

  This is the union of the documented roles, including `inherit`, and is meant
  for sanitizing values before they reach a component. A wrapper validates
  against its own role list.
  """
  def valid?(value) when is_binary(value) do
    value in @roles or match?({:ok, _}, Color.parse(value))
  end

  def valid?(_value), do: false

  @doc false
  # Expands a raw `color` into the wrapper's assigns. Role values only set the
  # presence hook; raw values also merge the derived style into `rest`.
  def apply(assigns, roles, vars) do
    value = assigns.color

    {data_color, rest} =
      if value in roles do
        {value, Map.get(assigns, :rest)}
      else
        case Color.parse(value) do
          {:ok, color} ->
            {nil, merge_style(Map.get(assigns, :rest), style(value, color, vars))}

          :error ->
            raise ArgumentError, invalid_message(value, roles)
        end
      end

    # Both assigns are derived from `color`, and a previous raw value may have
    # added a style to `rest`. Mark them changed so switching between a role and
    # a raw color always updates the rendered attributes.
    assigns
    |> put_assign(:data_color, data_color)
    |> put_assign(:rest, rest)
  end

  @doc false
  # The inline style for a parsed raw color, keyed by the wrapper's color vars.
  def style(source, color, vars) do
    values = derive(source, color)

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
  # the label on a fill is a single scheme-independent color.
  def derive(source, color) do
    target = Contrast.aa()
    light = Contrast.light_background()
    dark = Contrast.dark_background()

    %{
      fill: source,
      on_fill: on_fill(color),
      on_page: {
        readable(source, color, light, target),
        readable(source, color, dark, target)
      },
      on_tint: {
        readable(source, color, tint(color, light), target),
        readable(source, color, tint(color, dark), target)
      }
    }
  end

  defp on_fill(color) do
    white = Contrast.ratio(color.css, Color.white()) || 0.0
    black = Contrast.ratio(color.css, Color.black()) || 0.0

    if white >= black, do: Color.white(), else: Color.black()
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

  # The text carries the color over the page, so score it against the tint the
  # tinted variants paint, not the page itself.
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

  defp invalid_message(value, roles) do
    """
    invalid color #{inspect(value)} for the `color` prop.

    Use a semantic role (#{Enum.join(roles, ", ")}) or a raw color:

      * #rgb or #rrggbb
      * rgb(29 114 254)
      * oklch(58% 0.2 264)

    Alpha is not supported because the effective fill depends on the surface.
    """
  end
end
