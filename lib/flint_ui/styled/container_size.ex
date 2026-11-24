defmodule FlintUI.Styled.ContainerSize do
  @moduledoc false

  @tokens ~w(xs sm md lg xl 2xl 3xl 4xl 5xl 6xl 7xl)
  @values @tokens ++ ["fluid"]
  @breakpoints ~w(sm md lg xl 2xl)
  @default "6xl"

  @doc "The container token names."
  def tokens, do: @tokens

  @doc "The public `size` values: the container tokens plus `fluid`."
  def values, do: @values

  @doc "The breakpoint keys a responsive `size` map accepts."
  def breakpoints, do: @breakpoints

  @doc "The default container token."
  def default, do: @default

  @doc """
  Resolves a container size into its `data-size` value and inline CSS.

  Tokens and `fluid` resolve to a `data-size` hook; numbers and arbitrary CSS
  lengths resolve to a `--fl-container-size` declaration. A map or keyword list
  adds `--fl-container-size-<breakpoint>` overrides.
  """
  def resolve(size) when is_map(size), do: resolve_pairs(Map.to_list(size))

  def resolve(size) when is_list(size) do
    if pairs?(size), do: resolve_pairs(size), else: scalar(size)
  end

  def resolve(size), do: scalar(size)

  defp resolve_pairs(pairs) do
    pairs = Map.new(pairs, fn {key, value} -> {to_string(key), value} end)
    validate_keys!(Map.keys(pairs))

    {data_size, base_style} =
      case Map.fetch(pairs, "base") do
        {:ok, value} -> base_part(value)
        :error -> {nil, nil}
      end

    overrides =
      Enum.flat_map(@breakpoints, fn breakpoint ->
        case Map.fetch(pairs, breakpoint) do
          {:ok, value} ->
            case css_value(value) do
              nil -> []
              css -> ["--fl-container-size-#{breakpoint}: #{css}"]
            end

          :error ->
            []
        end
      end)

    {data_size, join([base_style | overrides])}
  end

  defp scalar(size), do: base_part(size)

  defp base_part(value) do
    if preset?(value) do
      {preset_name(value), nil}
    else
      case css_value(value) do
        nil -> {nil, nil}
        css -> {nil, "--fl-container-size: #{css}"}
      end
    end
  end

  defp css_value(nil), do: nil

  defp css_value(value) when is_number(value), do: rem_length(value)

  defp css_value(value) when is_atom(value) do
    case Atom.to_string(value) do
      "fluid" -> "none"
      token when token in @tokens -> "var(--fl-container-#{token})"
      other -> raise ArgumentError, invalid_size_message(other)
    end
  end

  defp css_value(value) when is_binary(value) do
    value = String.trim(value)

    cond do
      value == "" -> nil
      value == "fluid" -> "none"
      value in @tokens -> "var(--fl-container-#{value})"
      true -> numeric_or_css(value)
    end
  end

  defp css_value(value), do: raise(ArgumentError, invalid_size_message(value))

  defp numeric_or_css(value) do
    case Float.parse(value) do
      {number, ""} -> rem_length(number)
      _ -> value
    end
  end

  defp rem_length(number) when is_number(number) do
    value = number / 16

    value =
      if value == trunc(value) do
        Integer.to_string(trunc(value))
      else
        Float.to_string(value)
      end

    "#{value}rem"
  end

  defp preset?(value) when is_atom(value), do: Atom.to_string(value) in @values
  defp preset?(value) when is_binary(value), do: String.trim(value) in @values
  defp preset?(_value), do: false

  defp preset_name(value) when is_atom(value), do: Atom.to_string(value)
  defp preset_name(value) when is_binary(value), do: String.trim(value)

  defp pairs?([]), do: true

  defp pairs?(list) do
    Enum.all?(list, fn
      {key, _value} when is_atom(key) or is_binary(key) -> true
      _ -> false
    end)
  end

  defp validate_keys!(keys) do
    unknown = keys -- ["base" | @breakpoints]

    if unknown != [] do
      raise ArgumentError,
            "unknown container size breakpoint(s) #{inspect(unknown)}; " <>
              "expected base, sm, md, lg, xl, or 2xl"
    end
  end

  defp join(declarations) do
    case Enum.reject(declarations, &is_nil/1) do
      [] -> nil
      declarations -> Enum.join(declarations, "; ")
    end
  end

  defp invalid_size_message(value) do
    "invalid container size #{inspect(value)}; expected xs..7xl, fluid, a number, " <>
      "an arbitrary CSS length, or a breakpoint map"
  end
end
