defmodule FlintUIDocsWeb.Examples.Default do
  @moduledoc """
  Fallback example for a library component that does not have an authored one yet.
  """

  use FlintUIDocsWeb.Examples.Example

  @impl true
  def controls, do: []

  @impl true
  def variants, do: []

  @impl true
  def structure, do: nil

  @impl true
  def render_example(assigns) do
    assigns = assign(assigns, :name_label, to_string(assigns.name))

    ~H"""
    <p class="text-sm text-zinc-500">No example yet for <code>{@name_label}</code>.</p>
    """
  end
end
