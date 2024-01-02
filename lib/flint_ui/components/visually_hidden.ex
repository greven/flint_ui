defmodule FlintUI.VisuallyHidden do
  @moduledoc false

  use Phoenix.Component

  attr(:class, :string, default: nil)
  attr(:rest, :global)
  slot(:inner_block)

  def visually_hidden(assigns) do
    ~H"""
    <div class={["fl-visually-hidden", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
