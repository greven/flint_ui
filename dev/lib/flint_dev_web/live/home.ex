defmodule FlintDevWeb.HomeLive do
  @moduledoc false

  use FlintDevWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
      <.accordion />

      <.visually_hidden class="poo" data-foo="bar">
        <div>Hello World!</div>
      </.visually_hidden>
    """
  end
end
