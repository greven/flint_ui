defmodule FlintUI do
  @moduledoc """
  FlintUI is a collection of accessible, unstyled UI components for Phoenix LiveView.
  It provides a set of building blocks that can be easily styled and customized to fit any
  design system. Each component is designed with accessibility in mind, ensuring that
  your applications are usable by everyone.

  ## Usage

  To use FlintUI, simply call `use FlintUI` in your module and then use the
  provided components in your templates.

  ## Available Components

  - `button`
  - `collapsible`

  """

  use Phoenix.Component
  import FlintUI.API

  defmacro __using__(_opts) do
    quote do
      import FlintUI
    end
  end

  ## Components

  defcomponent(:button)
  defcomponent(:collapsible)

  ## JS Helpers

  defdelegate open_collapsible(js \\ %Phoenix.LiveView.JS{}, id), to: FlintUI.JS
  defdelegate close_collapsible(js \\ %Phoenix.LiveView.JS{}, id), to: FlintUI.JS
  defdelegate toggle_collapsible(js \\ %Phoenix.LiveView.JS{}, id), to: FlintUI.JS
end
