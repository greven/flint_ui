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
  Returns a map of the component's parts, where each key is a part name (atom) and the value
  is a map of attributes to be spread onto that part's root element. The minimum required
  parts is the `:root`, but additional parts can be defined as needed.

  The generated component wrapper calls this once per render and exposes the result to
  the template as the `@flint_parts` assign, so a part's attributes are spread with
  `{@flint_parts[:part_name]}`.

  Because components declare a `:global` attribute (usually `:rest`), Phoenix splits the
  assigns it receives into declared ones and caller globals. An undeclared `:flint_parts`
  would be swept into that global map and the part spread would raise, so every component
  must declare it immediately before `render/1`:

      attr :flint_parts, :map, default: nil, doc: false

  Compilation fails when a component declares a `:global` attribute without it.

  A caller attribute wins over the same attribute on the root part. That keeps a
  composed component (one FlintUI component used as a part of another) from
  rendering the attribute twice while it keeps its own `data-element`. A button
  used as a collapsible trigger keeps `data-element="button"` and takes the
  trigger's `data-part`:

      <.collapsible id="details">
        <:trigger :let={attrs}>
          <.button {attrs}>Toggle</.button>
        </:trigger>
        <:content>Content</:content>
      </.collapsible>
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

  @doc """
  Returns a list of `FlintUI.Meta.Keyboard` structs describing the keyboard
  interactions the component supports.
  """
  @callback keyboard :: [FlintUI.Meta.Keyboard.t()]

  @optional_callbacks events: 0, parts_attrs: 0, css_vars: 0, keyboard: 0

  defmacro __using__(_opts) do
    quote do
      use Phoenix.Component
      alias Phoenix.LiveView.JS

      import FlintUI.API

      alias FlintUI.Meta

      @behaviour FlintUI.Component

      @before_compile FlintUI.Component
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    components = Module.get_attribute(env.module, :__components__) || %{}

    case components[:render] do
      %{attrs: attrs, line: line} ->
        names = Enum.map(attrs, & &1.name)

        if Enum.any?(attrs, &(&1.type == :global)) and :flint_parts not in names do
          raise CompileError,
            file: env.file,
            line: line,
            description: """
            #{inspect(env.module)} declares a :global attribute but not `:flint_parts`.

            Phoenix splits the assigns a component receives, keeping only the attributes,
            slots and reserved assigns it declares and sweeping everything else into the
            global attribute. `FlintUI.API` sets the `:flint_parts` assign before calling
            `render/1`, so without the declaration it lands in the global map and the
            part spread in the template raises.

            Declare it immediately before `render/1`:

                attr :flint_parts, :map, default: nil, doc: false
            """
        end

      _ ->
        :ok
    end

    :ok
  end
end
