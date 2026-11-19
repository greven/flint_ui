defmodule FlintUI.ProgressScale do
  @moduledoc false

  # Shared value-scale resolution for the progress components. `Base.Progress`
  # and `Base.ProgressRing` differ only in how they paint the resolved value, so
  # the clamping, numeric parsing, percentage, and step-label rules live here.

  @doc false
  def resolve(value, max) do
    {steps, max} = scale(max)
    indeterminate = value in [nil, ""]
    value = if indeterminate, do: nil, else: value |> number(0) |> clamp(0, max)
    percent = if indeterminate, do: nil, else: value / max * 100
    active_step = if indeterminate, do: nil, else: active_step(steps, value)

    %{
      max: max,
      value: value,
      indeterminate: indeterminate,
      percent: percent,
      steps: if(indeterminate, do: nil, else: steps),
      active_step: active_step && elem(active_step, 0),
      value_text: if(indeterminate, do: nil, else: value_text(active_step, percent)),
      percent_label: if(indeterminate, do: nil, else: percent_label(percent))
    }
  end

  @doc false
  def format_number(value) when is_integer(value), do: Integer.to_string(value)

  def format_number(value) when is_float(value) do
    value = Float.round(value, 6)

    if value == trunc(value) do
      Integer.to_string(trunc(value))
    else
      Float.to_string(value)
    end
  end

  # A list of labels is a step scale: the last label is the maximum so the
  # labels sit evenly from 0% to 100%. A single label still needs a positive
  # scale to divide by.
  defp scale(labels) when is_list(labels) do
    case Enum.map(labels, &step_label/1) do
      [] -> {nil, 100}
      steps -> {steps, max(length(steps) - 1, 1)}
    end
  end

  defp scale(value), do: {nil, max_value(value)}

  defp step_label(label) when is_binary(label), do: label
  defp step_label(label), do: to_string(label)

  defp active_step(nil, _value), do: nil

  defp active_step(steps, value) do
    index = value |> floor() |> clamp(0, length(steps) - 1)
    {index, Enum.at(steps, index)}
  end

  defp value_text(nil, percent), do: percent_label(percent)
  defp value_text({_index, label}, percent) when label in [nil, ""], do: percent_label(percent)
  defp value_text({_index, label}, _percent), do: label

  defp max_value(value) do
    case number(value, 100) do
      max when max > 0 -> max
      _ -> 100
    end
  end

  defp percent_label(percent), do: "#{round(percent)}%"

  defp clamp(_value, min, max) when max <= min, do: min
  defp clamp(value, min, max), do: value |> Kernel.max(min) |> Kernel.min(max)

  defp number(nil, default), do: default
  defp number(value, _default) when is_integer(value), do: value
  defp number(value, _default) when is_float(value), do: normalize_number(value)

  defp number(value, default) when is_binary(value) do
    case Float.parse(value) do
      {number, ""} -> normalize_number(number)
      _ -> default
    end
  end

  defp number(_value, default), do: default

  defp normalize_number(value) when is_float(value) do
    if value == trunc(value), do: trunc(value), else: value
  end

  defp normalize_number(value), do: value
end
