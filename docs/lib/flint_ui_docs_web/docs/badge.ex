defmodule FlintUIDocsWeb.Docs.Badge do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :badge

  alias FlintUIDocsWeb.Components

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{tab: :styled, section: :usage, id: :dot, title: "Dot"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the `inner_block` to set the content of the badge." />
    <.preview {assigns} code="<.badge>Badge</.badge>">
      <Components.badge>Badge</Components.badge>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :dot} = assigns) do
    ~H"""
    <.prose content="Use the `dot` variant for a status badge. The `color` fills the dot, while the border and text stay neutral. The dot is decorative, so keep the label meaningful and do not rely on color alone." />
    <.preview {assigns} code={dot_code()}>
      <div class="flex flex-wrap items-center gap-2">
        <Components.badge variant="dot" color="success" radius="xl">Online</Components.badge>
        <Components.badge variant="dot" color="warning" radius="xl">Pending</Components.badge>
        <Components.badge variant="dot" color="error" radius="xl">Offline</Components.badge>
      </div>
    </.preview>
    """
  end

  defp dot_code do
    """
    <.badge variant="dot" color="success" radius="xl">Online</.badge>
    <.badge variant="dot" color="warning" radius="xl">Pending</.badge>
    <.badge variant="dot" color="error" radius="xl">Offline</.badge>
    """
    |> String.trim()
  end
end
