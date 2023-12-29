defmodule FlintUI.Accordion do
  @moduledoc false

  use FlintUI.Component

  def accordion(assigns) do
    ~H"""
    <div id={use_id()} phx-hook="Accordion">
      Accordion
    </div>
    """
  end
end
