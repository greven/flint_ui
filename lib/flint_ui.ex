defmodule FlintUI do
  @moduledoc """
  TODO: !!!!!!!!!
  """

  use Phoenix.Component

  import FlintUI.Collapsible

  alias Phoenix.LiveView.JS

  attr(:id, :string)
  attr(:open, :boolean, default: false)
  attr(:disabled, :boolean, default: false)
  attr(:on_open, JS, default: %JS{})
  attr(:on_close, JS, default: %JS{})

  slot(:inner_block, required: true)

  def fl_collapsible(assigns) do
    ~H"""
    <%= render_slot(@inner_block, use_collapsible(assigns)) %>
    """
  end
end
