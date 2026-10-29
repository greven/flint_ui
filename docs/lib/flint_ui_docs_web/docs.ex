defmodule FlintUIDocsWeb.Docs do
  @moduledoc """
  Facade over the per-component docs page modules.

  Each component has a module under `FlintUIDocsWeb.Docs`
  (e.g. `FlintUIDocsWeb.Docs.Button`) that implements
  `FlintUIDocsWeb.Docs.Page`.

  Register it in `@modules` below; anything not registered falls back to
  `FlintUIDocsWeb.Docs.Default`.

  Components declare (`Docs.Page` for the full contract):

    * `title/0`, `subtitle/0`, `links/0` - the page header
    * `controls/0` - interactive properties available to previews
    * `styled_overview/0`, `base_overview/0` - optional prose
    * `styled_features/0`, `base_features/0` - optional feature lists
    * `usage/0`, `examples/0` - section metadata
    * `anatomy/0`, `architecture/0`, `structure/0` - the Base tab
    * `styling/0`, `css/0` - the CSS layer
    * `render_main/1`, `render_section/1` - the live previews
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Docs.{
    Button,
    Card,
    Collapsible,
    Default,
    Group,
    Icon,
    Loading,
    LoadingText,
    Source,
    Tabs,
    Toggle
  }

  @modules %{
    button: Button,
    card: Card,
    collapsible: Collapsible,
    group: Group,
    icon: Icon,
    loading: Loading,
    loading_text: LoadingText,
    tabs: Tabs,
    toggle: Toggle
  }

  attr :name, :atom, required: true
  attr :id, :string, required: true
  attr :state, :map, default: %{}

  def render_main(assigns) do
    module(assigns.name).render_main(assigns)
  end

  attr :name, :atom, required: true
  attr :id, :string, required: true
  attr :kind, :atom, required: true
  attr :block, :atom, required: true
  attr :section, :map, required: true
  attr :state, :map, default: %{}

  def render_section(assigns) do
    module(assigns.name).render_section(assigns)
  end

  @doc """
  The dev-only source of a preview's render callback, or `nil`.

  `callback` is `:main` or `:section`. See `FlintUIDocsWeb.Docs.Source` for the
  `:kind`, `:block`, and `:layer` options.
  """
  def source(name, callback, opts \\ []) do
    Source.get(module(name), callback, opts)
  end

  @doc """
  Returns the registered `{name, module}` page modules.
  """
  def modules, do: @modules

  def title(name) do
    case module(name) do
      Default -> humanize(name)
      module -> module.title()
    end
  end

  def subtitle(name) do
    case module(name) do
      Default -> FlintUI.Docs.description(name)
      module -> module.subtitle()
    end
  end

  def links(name) do
    case module(name) do
      Default -> default_links(name)
      module -> module.links()
    end
  end

  def controls(name), do: module(name).controls()

  def defaults(name) do
    Map.new(controls(name), fn control -> {control.key, control.default} end)
  end

  def styled_overview(name), do: module(name).styled_overview()
  def base_overview(name), do: module(name).base_overview()
  def styled_features(name), do: module(name).styled_features()
  def base_features(name), do: module(name).base_features()
  def usage(name), do: module(name).usage()
  def base_usage(name), do: Enum.filter(usage(name), &(&1.layer == :base))
  def styled_usage(name), do: Enum.filter(usage(name), &(&1.layer == :styled))
  def examples(name), do: module(name).examples()
  def base_examples(name), do: Enum.filter(examples(name), &(&1[:layer] == :base))
  def styled_examples(name), do: Enum.reject(examples(name), &(&1[:layer] == :base))
  def styling(name), do: module(name).styling()
  def css(name), do: module(name).css()
  def anatomy(name), do: module(name).anatomy()
  def architecture(name), do: module(name).architecture()
  def accessibility(name), do: module(name).accessibility()
  def structure(name), do: module(name).structure()

  @doc """
  The repository URL for a component's source file.
  """
  def source_url(name) do
    base =
      Application.get_env(
        :flint_ui_docs,
        :source_url,
        "https://github.com/greven/flint_ui/blob/main"
      )

    case component_source(name) do
      nil -> base
      path -> base <> "/" <> path
    end
  end

  defp component_source(name) do
    module = FlintUI.API.component_module(name)

    if Code.ensure_loaded?(module) do
      case module.module_info(:compile)[:source] do
        nil -> nil
        source -> relative_source(to_string(source))
      end
    end
  rescue
    _ -> nil
  end

  defp relative_source(path) do
    case String.split(path, "/lib/flint_ui/", parts: 2) do
      [_, rest] -> "lib/flint_ui/" <> rest
      _ -> path
    end
  end

  defp default_links(name) do
    [
      %{
        label: "Source",
        href: source_url(name),
        icon: "lucide-github"
      }
    ]
  end

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end

  defp module(name), do: Map.get(@modules, name, Default)
end
