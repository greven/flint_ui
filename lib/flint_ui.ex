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

  @components [
    {:button, []},
    {:collapsible, [:open_collapsible, :close_collapsible, :toggle_collapsible]}
  ]

  require FlintUI.API
  import FlintUI.API

  defmacro __using__(opts) do
    only = Keyword.get(opts, :only, :all)
    except = Keyword.get(opts, :except, [])
    prefix = Keyword.get(opts, :prefix)

    components = Enum.filter(@components, fn {name, _aux} -> include?(name, only, except) end)

    calls =
      for {name, aux} <- components do
        quote do
          FlintUI.API.component(unquote(name), other: unquote(aux), prefix: unquote(prefix))
        end
      end

    quote do
      use Phoenix.Component
      require FlintUI.API
      unquote_splicing(calls)
    end
  end

  ## Componnts

  component(:button)
  component(:collapsible, other: [:open_collapsible, :close_collapsible, :toggle_collapsible])

  ## Internal

  defp include?(_name, :all, []), do: true
  defp include?(name, :all, except), do: name not in except
  defp include?(name, only, _except) when is_list(only), do: name in only
end
