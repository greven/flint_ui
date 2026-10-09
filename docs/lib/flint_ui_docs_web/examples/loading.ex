defmodule FlintUIDocsWeb.Examples.Loading do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example

  @variants ~w(ring ring-bg dots-fade dots-bounce)

  @impl true
  def controls do
    [
      %{key: :variant, type: :string, default: "ring", label: "Variant (ring, ring-bg, …)"},
      %{key: :duration, type: :string, default: "600", label: "Duration (ms)"}
    ]
  end

  @impl true
  def variants do
    base = defaults()

    [
      {"Ring", Map.put(base, :variant, "ring")},
      {"Ring with background", Map.put(base, :variant, "ring-bg")},
      {"Dots fade", Map.put(base, :variant, "dots-fade")},
      {"Dots bounce", Map.put(base, :variant, "dots-bounce")}
    ]
  end

  @impl true
  def structure do
    """
    <.loading />

    <.loading variant="ring-bg" class="size-6 text-zinc-500" />

    <.loading variant="dots-fade" duration={300} class="size-4" />

    <.loading variant="dots-bounce" class="size-4" />

    <%!-- Reveal inside a FlintUI button via its [data-loading] attribute --%>
    <.button loading>
      <.loading class="hidden size-4 [[data-loading]_&]:inline-block" />
      Saving
    </.button>
    """
    |> String.trim()
  end

  @impl true
  def render_example(assigns) do
    ~H"""
    <.loading
      variant={variant(@props)}
      duration={duration(@props)}
      class={@props[:class] || "size-6 text-zinc-900 dark:text-zinc-100"}
    />
    """
  end

  defp variant(%{variant: value}) when value in @variants, do: value
  defp variant(_), do: "ring"

  defp duration(%{duration: value}) when is_integer(value) and value > 0, do: value

  defp duration(%{duration: value}) when is_binary(value) do
    case Integer.parse(value) do
      {parsed, _} when parsed > 0 -> parsed
      _ -> 600
    end
  end

  defp duration(_), do: 600
end
