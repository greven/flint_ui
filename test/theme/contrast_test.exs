defmodule FlintUI.Theme.ContrastTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.Contrast

  @roles ~w(primary secondary neutral success info warning error)
  @shades ~w(50 100 200 300 400 500 600 700 800 900 950)

  # Fills use 600 when it supports a light label, stepping to 700 when it does
  # not. Warning keeps a light fill with a dark label so amber stays yellow,
  # and neutral is the inverted surface.
  @expected_fill_shades %{
    "neutral" => {"900", "200"},
    "success" => {"700", "700"},
    "warning" => {"500", "500"}
  }

  @light_label_roles ~w(primary secondary success info error)

  setup_all do
    css = File.read!(FlintUI.Generator.part_path("tokens.css"))
    %{css: css, scales: parse_scales(css)}
  end

  test "every shipped role label clears AA on its fill", %{css: css, scales: scales} do
    for role <- @roles do
      {fill_light, fill_dark} = resolve(css, scales, role)
      {content_light, content_dark} = resolve(css, scales, "#{role}-content")

      for {scheme, fill, content} <- [
            {:light, fill_light, content_light},
            {:dark, fill_dark, content_dark}
          ] do
        ratio = Contrast.ratio(fill, content) || 0.0

        assert ratio >= Contrast.aa(),
               "#{role}/#{scheme} content #{content} on #{fill} is #{ratio}:1, below AA"
      end
    end
  end

  test "solid labels stay light for the roles that prefer white", %{
    css: css,
    scales: scales
  } do
    for role <- @light_label_roles do
      {content_light, content_dark} = resolve(css, scales, "#{role}-content")

      for {scheme, content} <- [{:light, content_light}, {:dark, content_dark}] do
        luminance = Contrast.luminance(content) || 0.0

        assert luminance >= 0.8,
               "#{role}/#{scheme} content #{content} is not a light solid label"
      end
    end
  end

  test "every shipped role text clears AA on its soft surface", %{
    css: css,
    scales: scales
  } do
    for role <- @roles do
      {soft_light, soft_dark} = resolve(css, scales, "#{role}-soft")
      {text_light, text_dark} = resolve(css, scales, "#{role}-text")

      for {scheme, soft, text} <- [
            {:light, soft_light, text_light},
            {:dark, soft_dark, text_dark}
          ] do
        ratio = Contrast.ratio(text, soft) || 0.0

        assert ratio >= Contrast.aa(),
               "#{role}/#{scheme} text #{text} on #{soft} is #{ratio}:1, below AA"
      end
    end
  end

  test "soft surfaces stay visible and their border reads against them", %{
    css: css,
    scales: scales
  } do
    for role <- @roles do
      {soft_light, soft_dark} = resolve(css, scales, "#{role}-soft")
      {border_light, border_dark} = resolve(css, scales, "#{role}-soft-border")

      for {scheme, soft, border} <- [
            {:light, soft_light, border_light},
            {:dark, soft_dark, border_dark}
          ] do
        surface = surface_color(scales, scheme)
        soft_ratio = Contrast.ratio(soft, surface) || 0.0
        border_ratio = Contrast.ratio(border, soft) || 0.0

        assert soft_ratio >= 1.1,
               "#{role}/#{scheme} soft #{soft} is too close to #{surface}"

        assert border_ratio >= 1.1,
               "#{role}/#{scheme} border #{border} is too close to #{soft}"
      end
    end
  end

  test "role fills use their accessibility step, and neutral stays inverted", %{
    css: css,
    scales: scales
  } do
    for role <- @roles do
      {fill_light, fill_dark} = resolve(css, scales, role)
      {light, dark} = Map.get(@expected_fill_shades, role, {"600", "600"})

      expected = {
        eval_color("var(--fl-color-#{role}-#{light})", scales, :light),
        eval_color("var(--fl-color-#{role}-#{dark})", scales, :dark)
      }

      assert {fill_light, fill_dark} == expected,
             "#{role} should resolve its fill to #{inspect({light, dark})}, got " <>
               inspect({fill_light, fill_dark})
    end
  end

  test "the contrast reference matches the shipped surface", %{scales: scales} do
    for scheme <- [:light, :dark] do
      assert_in_delta Contrast.luminance(surface_color(scales, scheme)),
                      Contrast.luminance(background_reference(scheme)),
                      1.0e-6
    end
  end

  # The surface role text sits on: white in light, and neutral-900 in dark.
  defp surface_color(_scales, :light), do: "oklch(100% 0 none)"

  defp surface_color(scales, :dark) do
    Map.fetch!(scales["neutral"], "900")
  end

  defp background_color(_scales, :light), do: "oklch(100% 0 none)"
  defp background_color(scales, :dark), do: Map.fetch!(scales["neutral"], "950")

  defp background_reference(:light), do: Contrast.light_background()
  defp background_reference(:dark), do: Contrast.dark_background()

  defp parse_scales(css) do
    Map.new(@roles, fn role ->
      values =
        Map.new(@shades, fn shade ->
          [_, value] = Regex.run(~r/--fl-color-#{role}-#{shade}:\s*([^;]+);/, css)
          {shade, String.trim(value)}
        end)

      {role, values}
    end)
  end

  defp resolve(css, scales, token) do
    [_, value] = Regex.run(~r/--fl-color-#{Regex.escape(token)}:\s*([^;]+);/, css)
    value = String.trim(value)

    case Regex.run(~r/^light-dark\((.*)\)$/s, value) do
      [_, inner] ->
        [light, dark] = split_top_level(inner)
        {eval_color(light, scales, :light), eval_color(dark, scales, :dark)}

      nil ->
        resolved = eval_color(value, scales, :light)
        {resolved, resolved}
    end
  end

  # Splits on commas that are not nested inside a function call. `light-dark()`
  # branches contain `color-mix()` arguments, so a plain split is not enough.
  defp split_top_level(value) do
    value
    |> String.graphemes()
    |> Enum.reduce({[], [], 0}, fn
      "(", {parts, current, depth} -> {parts, ["(" | current], depth + 1}
      ")", {parts, current, depth} -> {parts, [")" | current], depth - 1}
      ",", {parts, current, 0} -> {[Enum.reverse(current) | parts], [], 0}
      char, {parts, current, depth} -> {parts, [char | current], depth}
    end)
    |> then(fn {parts, current, _depth} -> Enum.reverse([Enum.reverse(current) | parts]) end)
    |> Enum.map(&(&1 |> Enum.join() |> String.trim()))
  end

  # Evaluates the small color expression subset the tokens use: scale vars,
  # oklch literals, the surface, and a two-stop color-mix.
  defp eval_color(value, scales, scheme) do
    value = String.trim(value)

    cond do
      value == "var(--fl-color-surface)" ->
        surface_color(scales, scheme)

      value == "var(--fl-color-background)" ->
        background_color(scales, scheme)

      String.starts_with?(value, "var(--fl-color-") ->
        inner =
          value
          |> String.replace_prefix("var(--fl-color-", "")
          |> String.trim_trailing(")")

        case String.split(inner, "-", parts: 2) do
          [role, shade] ->
            Map.fetch!(Map.fetch!(scales, role), shade)

          [role] ->
            {light, dark} = Map.get(@expected_fill_shades, role, {"600", "600"})
            shade = if scheme == :light, do: light, else: dark
            Map.fetch!(Map.fetch!(scales, role), shade)
        end

      String.starts_with?(value, "color-mix(") ->
        [_, first, percent, second] =
          Regex.run(~r/^color-mix\(in oklab,\s*(.+)\s+(\d+)%,\s*(.+)\)$/s, value)

        weight = String.to_integer(percent) / 100

        Contrast.mix(
          eval_color(first, scales, scheme),
          eval_color(second, scales, scheme),
          weight
        )

      String.starts_with?(value, "oklch(") ->
        value

      true ->
        flunk("unexpected token value in tokens.css: #{inspect(value)}")
    end
  end
end
