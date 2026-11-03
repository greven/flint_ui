defmodule FlintUI.ThemeContrastTest do
  use ExUnit.Case, async: true

  alias FlintUI.Palette.Contrast

  @roles ~w(primary secondary neutral success info warning error)
  @shades ~w(50 100 200 300 400 500 600 700 800 900 950)

  # Fills use 600 when it supports a light label, stepping to 700 when it does
  # not. Warning keeps 600 with a dark label so amber stays yellow instead of
  # turning brown, and neutral is the inverted surface.
  @expected_fill_shades %{
    "neutral" => {"900", "200"},
    "success" => {"700", "700"}
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

  test "every shipped role text clears AA on the tinted control surface", %{
    css: css,
    scales: scales
  } do
    for role <- @roles do
      {fill_light, fill_dark} = resolve(css, scales, role)
      {text_light, text_dark} = resolve(css, scales, "#{role}-text")

      for {scheme, fill, text} <- [
            {:light, fill_light, text_light},
            {:dark, fill_dark, text_dark}
          ] do
        background = Contrast.mix(fill, control_surface(scales, scheme), 0.15)
        ratio = Contrast.ratio(text, background) || 0.0

        assert ratio >= Contrast.aa(),
               "#{role}/#{scheme} text #{text} on #{background} is #{ratio}:1, below AA"
      end
    end
  end

  test "non-neutral fills use 600 or step to 700, and neutral stays inverted", %{
    css: css,
    scales: scales
  } do
    for role <- @roles do
      {fill_light, fill_dark} = resolve(css, scales, role)
      {light, dark} = Map.get(@expected_fill_shades, role, {"600", "600"})

      expected = {
        resolve_value("var(--fl-color-#{role}-#{light})", scales),
        resolve_value("var(--fl-color-#{role}-#{dark})", scales)
      }

      assert {fill_light, fill_dark} == expected,
             "#{role} should resolve its fill to #{inspect({light, dark})}, got " <>
               inspect({fill_light, fill_dark})
    end
  end

  test "the contrast reference matches the shipped control surface", %{scales: scales} do
    for scheme <- [:light, :dark] do
      assert_in_delta Contrast.luminance(control_surface(scales, scheme)),
                      Contrast.luminance(background_reference(scheme)),
                      1.0e-6
    end
  end

  # The surface role text sits on: white in light, and the neutral-900/950
  # control mix in dark.
  defp control_surface(_scales, :light), do: "oklch(100% 0 none)"

  defp control_surface(scales, :dark) do
    Contrast.mix(
      Map.fetch!(scales["neutral"], "950"),
      Map.fetch!(scales["neutral"], "900"),
      0.5
    )
  end

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
        [light, dark] = String.split(inner, ",", parts: 2)
        {resolve_value(light, scales), resolve_value(dark, scales)}

      nil ->
        resolved = resolve_value(value, scales)
        {resolved, resolved}
    end
  end

  defp resolve_value(value, scales) do
    value = String.trim(value)

    cond do
      String.starts_with?(value, "var(--fl-color-") ->
        inner =
          value
          |> String.replace_prefix("var(--fl-color-", "")
          |> String.trim_trailing(")")

        [role, shade] = String.split(inner, "-", parts: 2)
        Map.fetch!(Map.fetch!(scales, role), shade)

      String.starts_with?(value, "oklch(") ->
        value

      true ->
        flunk("unexpected token value in tokens.css: #{inspect(value)}")
    end
  end
end
