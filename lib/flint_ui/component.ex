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
  Returns a list of events that the component can emit, along with their metadata.
  """
  @callback events :: list(FlintUI.Meta.Event.t())

  @doc """
  Returns a map of the component's parts, where each key is a part name (atom) and the value is a map
  of attributes to be spread onto that part's root element. The minimum required parts is the `:root`,
  but additional parts can be defined as needed.
  """
  @callback build_attrs(assigns :: map()) :: map()

  @doc """
  Renders the component's HTML structure.
  """
  @callback render(assigns :: map()) :: Phoenix.LiveView.Rendered.t()

  @doc """
  Returns a map where each key is a part name (atom) and the value is a list of
  `FlintUI.Meta.PartAttr` structs describing the HTML/data attributes applied to
  that part's DOM element.
  """
  @callback parts_attrs :: %{atom() => [FlintUI.Meta.PartAttr.t()]}

  @doc """
  Returns a list of `FlintUI.Meta.CSSVar` structs describing CSS custom properties
  emitted by the component, typically set by the JS hook for animation or layout
  calculations.
  """
  @callback css_vars :: [FlintUI.Meta.CSSVar.t()]

  @optional_callbacks events: 0, parts_attrs: 0, css_vars: 0

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      alias Phoenix.LiveView.JS

      import FlintUI.API
      import FlintUI.Component

      alias FlintUI.Meta

      @behaviour FlintUI.Component
    end
  end

  @doc """
  The attrs macro is used to inject the part attributes into the component's template.
  It takes a part name and returns the corresponding attributes for that part. It expects
  the module to define a `build_attrs/1` function that generates the attributes map based
  on the component's assigns.
  """
  defmacro attrs(part) do
    quote do
      build_attrs(var!(assigns))[unquote(part)]
    end
  end
end
