defmodule FlintUI.Palette.Color do
  @moduledoc """
  Parses the raw color formats accepted by styled `color` props and converts
  them to OKLCH for contrast derivation.

  Accepted forms are `#rgb`, `#rrggbb`, `rgb(...)`, and `oklch(...)`. Alpha is
  intentionally unsupported: a translucent fill's effective color depends on the
  surface it sits on, so its labels cannot be derived up front.
  """

  @type t :: %{l: float(), c: float(), h: float(), css: String.t()}

  @black "oklch(0% 0 0)"
  @white "oklch(100% 0 0)"

  @rgb ~r/^\s*(\d{1,3})\s*(?:,\s*|\s+)(\d{1,3})\s*(?:,\s*|\s+)(\d{1,3})\s*$/

  @doc "The OKLCH string for black, used as a contrast endpoint."
  def black, do: @black

  @doc "The OKLCH string for white, used as a contrast endpoint."
  def white, do: @white

  @doc """
  Parses a raw color into its OKLCH components plus a canonical `oklch()` string.
  """
  @spec parse(term()) :: {:ok, t()} | :error
  def parse(value) when is_binary(value) do
    value = String.trim(value)
    lower = String.downcase(value)

    cond do
      String.starts_with?(value, "#") -> parse_hex(value)
      String.starts_with?(lower, "rgb(") -> parse_rgb(value)
      String.starts_with?(lower, "oklch(") -> parse_oklch(value)
      true -> :error
    end
  end

  def parse(_), do: :error

  defp parse_hex("#" <> hex) do
    case String.graphemes(String.downcase(hex)) do
      [r, g, b] ->
        from_hex_pairs([r <> r, g <> g, b <> b])

      [r1, r2, g1, g2, b1, b2] ->
        from_hex_pairs([r1 <> r2, g1 <> g2, b1 <> b2])

      _ ->
        :error
    end
  end

  defp from_hex_pairs(pairs) do
    case Enum.map(pairs, &hex_byte/1) do
      [{:ok, r}, {:ok, g}, {:ok, b}] -> from_srgb(r / 255, g / 255, b / 255)
      _ -> :error
    end
  end

  defp hex_byte(pair) do
    case Integer.parse(pair, 16) do
      {value, ""} when value in 0..255 -> {:ok, value}
      _ -> :error
    end
  end

  defp parse_rgb(value) do
    args = value |> String.slice(4..-1//1) |> String.trim()

    with true <- String.ends_with?(args, ")"),
         false <- String.contains?(args, "/"),
         args = args |> String.slice(0..-2//1) |> String.trim(),
         [r, g, b] <- Regex.run(@rgb, args, capture: :all_but_first),
         {r, ""} when r in 0..255 <- parse_byte(r),
         {g, ""} when g in 0..255 <- parse_byte(g),
         {b, ""} when b in 0..255 <- parse_byte(b) do
      from_srgb(r / 255, g / 255, b / 255)
    else
      _ -> :error
    end
  end

  defp parse_byte(value) do
    case Integer.parse(value) do
      {value, ""} -> {value, ""}
      _ -> :error
    end
  end

  defp parse_oklch(value) do
    args = value |> String.slice(6..-1//1) |> String.trim()

    with true <- String.ends_with?(args, ")"),
         false <- String.contains?(args, "/"),
         args = args |> String.slice(0..-2//1) |> String.replace(",", " ") |> String.split(),
         [l, c, h] <- args,
         {:ok, l} <- parse_lightness(l),
         {:ok, c} <- parse_number(c),
         true <- c >= 0,
         {:ok, h} <- parse_hue(h) do
      {:ok, %{l: l, c: c, h: h, css: oklch(l, c, h)}}
    else
      _ -> :error
    end
  end

  defp parse_lightness(value) do
    case String.ends_with?(value, "%") do
      true ->
        case parse_number(String.trim_trailing(value, "%")) do
          {:ok, l} when l >= 0 and l <= 100 -> {:ok, l / 100}
          _ -> :error
        end

      false ->
        case parse_number(value) do
          {:ok, l} when l >= 0 and l <= 1 -> {:ok, l}
          _ -> :error
        end
    end
  end

  defp parse_hue("none"), do: {:ok, 0.0}
  defp parse_hue(value), do: value |> String.trim_trailing("deg") |> parse_number()

  defp parse_number("none"), do: {:ok, 0.0}

  defp parse_number(value) do
    case Float.parse(value) do
      {number, ""} -> {:ok, number * 1.0}
      _ -> :error
    end
  end

  # sRGB → OKLab → OKLCH (D65).
  defp from_srgb(r, g, b) do
    r = linearize(r)
    g = linearize(g)
    b = linearize(b)

    l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
    m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
    s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

    l_ = cube_root(l)
    m_ = cube_root(m)
    s_ = cube_root(s)

    ok_l = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
    ok_a = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
    ok_b = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_

    c = :math.sqrt(ok_a * ok_a + ok_b * ok_b)
    h = :math.atan2(ok_b, ok_a) * 180 / :math.pi()
    h = if h < 0, do: h + 360, else: h

    {:ok, %{l: ok_l, c: c, h: h, css: oklch(ok_l, c, h)}}
  end

  defp linearize(value) when value <= 0.04045, do: value / 12.92
  defp linearize(value), do: :math.pow((value + 0.055) / 1.055, 2.4)

  defp cube_root(value), do: :math.pow(value, 1.0 / 3.0)

  defp oklch(l, c, h) do
    "oklch(#{fmt(l * 100)}% #{fmt(c)} #{fmt(h)})"
  end

  defp fmt(value), do: value |> Float.round(4) |> Float.to_string()
end
