defmodule FlintUIDocsWeb.Docs.Default do
  @moduledoc """
  Fallback page for a library component that does not have an authored one yet.
  """

  use FlintUIDocsWeb.Docs.Page, component: :default

  @impl true
  def controls, do: []

  @impl true
  def accessibility, do: nil

  @impl true
  def render_playground(assigns) do
    assigns = assign(assigns, :name_label, to_string(assigns.name))

    ~H"""
    <p class="text-sm text-zinc-500">No example yet for <code>{@name_label}</code>.</p>
    """
  end
end
