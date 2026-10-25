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
  - `card`
  - `collapsible`
  - `group`
  - `icon`
  - `loading`
  - `toggle`

  ## Sounds

  `FlintUI.sound_provider/1` mounts the opt-in sound engine. Render it once per
  document, in the shared layout. Cues are off by default and attach to elements
  with `data-sound*` attributes; see the Sounds guide in the docs.

  """

  use Phoenix.Component
  require FlintUI.API

  @components [
    {:button, []},
    {:card, []},
    {:collapsible, [:open_collapsible, :close_collapsible, :toggle_collapsible]},
    {:group, []},
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
      import FlintUI, only: [sound_provider: 1]
      unquote_splicing(calls)
    end
  end

  @doc """
  Returns the names of the components registered by the library.
  """
  def components, do: Enum.map(@components, fn {name, _aux} -> name end)

  @doc """
  Mounts the interface-sounds provider.

  This renders a hidden element that the `FlintUI.Sound` hook attaches to.
  Mount it **once per document**, in the shared layout — not per page and not
  per component. The hook delegates from `document`, so one provider covers
  every page, every live navigation, and markup rendered later.

  Sounds ship as an optional bundle, so the core `flint.js` does not register
  this hook. Run `mix flint.setup --sound` (or import `flint_ui/sound` and merge
  its `hooks` yourself); without it the provider has nothing attached.

  Sounds are off by default. A cue plays only when an element opts in with a
  `data-sound*` attribute, and only while the provider is enabled.

  ## Examples

      # In lib/my_app_web/components/layouts.ex (Layouts.app/1), once:
      <FlintUI.sound_provider enabled={@sound_enabled} theme="default" />

      # Anywhere below it:
      <.button data-sound="tap">Save</.button>
      <.button data-sound-press="press" data-sound-release="release">Hold</.button>
      <.toggle data-sound-toggle>Dark mode</.toggle>
      <.toast data-sound-enter="bubble" data-sound-exit="whoosh">Saved</.toast>
  """
  attr :id, :string, default: "flint-sound"

  attr :enabled, :boolean,
    default: false,
    doc: "Whether cues may play. A stored user preference takes precedence."

  attr :theme, :string,
    values: ~w(default soft mechanical glass),
    default: "default",
    doc: "The sound palette that reshapes every cue."

  attr :volume, :float, default: 0.7, doc: "Master level, from 0.0 to 1.0."

  attr :reduced_motion, :string,
    values: ~w(mute allow),
    default: "mute",
    doc:
      "`mute` starts silent when the OS asks for reduced motion; `allow` ignores that preference."

  attr :rest, :global

  def sound_provider(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="FlintUI.Sound"
      data-sound-enabled={to_string(@enabled)}
      data-sound-theme={@theme}
      data-sound-volume={@volume}
      data-sound-reduced-motion={@reduced_motion}
      hidden
      {@rest}
    >
    </div>
    """
  end

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
