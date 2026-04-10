defmodule FlintUI.Component do
  @moduledoc """
  FlintUI component behaviour module.
  """

  @doc """
  Returns the component's metadata struct with information about the component,
  such as its name, type, and the version it was introduced in.
  """
  @callback meta :: FlintUI.Meta.t()

  @doc """
  Returns a map of the component's parts, where each key is a part name (atom) and the value is a map
  of attributes to be spread onto that part's root element. The minimum required parts is the `:root`,
  but additional parts can be defined as needed.
  """
  @callback attrs(assigns :: map()) :: map()

  @doc """
  Renders the component's HTML structure.
  """
  @callback render(assigns :: map()) :: Phoenix.LiveView.Rendered.t()

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      import FlintUI.API

      @behaviour FlintUI.Component
    end
  end
end
