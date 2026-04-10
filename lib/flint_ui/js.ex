defmodule FlintUI.JS do
  alias Phoenix.LiveView.JS

  def open_collapsible(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:open", to: "##{id}")
  end

  def close_collapsible(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:close", to: "##{id}")
  end

  def toggle_collapsible(js \\ %JS{}, id) do
    JS.dispatch(js, "fl:collapsible:toggle", to: "##{id}")
  end
end
