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
  - `icon`
  - `loading`
  - `toggle`

  """

  use Phoenix.Component
  require FlintUI.API

  @components [
    {:button, []},
    {:collapsible, [:open_collapsible, :close_collapsible, :toggle_collapsible]},
    {:icon, []},
    {:loading, []},
    {:toggle, []}
  ]

  defmacro __using__(opts) do
    only = Keyword.get(opts, :only, :all)
    except = Keyword.get(opts, :except, [])
    prefix = Keyword.get(opts, :prefix)

    components =
      Enum.filter(@components, fn {name, _aux} ->
        if is_list(only), do: name in only, else: name not in except
      end)

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

  @doc """
  Returns the names of the components registered by the library.
  """
  def components, do: Enum.map(@components, fn {name, _aux} -> name end)

  # Define this library's own components through the same code path consumers use.
  for {name, aux} <- @components do
    Code.eval_quoted(
      quote do
        require FlintUI.API
        FlintUI.API.component(unquote(name), other: unquote(aux))
      end,
      [],
      __ENV__
    )
  end
end
