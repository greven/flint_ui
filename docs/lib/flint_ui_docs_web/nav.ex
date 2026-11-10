defmodule FlintUIDocsWeb.Nav do
  @moduledoc """
  The single source of truth for the docs navigation.
  """

  @type page :: %{
          required(:id) => atom(),
          required(:label) => String.t(),
          required(:path) => String.t(),
          optional(:name) => atom(),
          optional(:children) => [page()]
        }

  @type group :: %{
          required(:label) => String.t(),
          required(:icon) => String.t(),
          required(:pages) => [page()]
        }

  @type section :: %{
          required(:id) => atom(),
          required(:label) => String.t(),
          required(:groups) => [group()]
        }

  @doc """
  Returns the top-level sections in display order.
  """
  def sections do
    [
      %{id: :getting_started, label: "Get Started", groups: getting_started_groups()},
      %{id: :guides, label: "Guides", groups: guide_groups()},
      %{id: :components, label: "Components", groups: component_groups()}
    ]
  end

  defp getting_started_groups do
    [
      %{
        label: "Overview",
        icon: "lucide-book-open",
        pages: [
          %{id: :introduction, label: "Introduction", path: "/getting-started/introduction"},
          %{id: :installation, label: "Installation", path: "/getting-started/installation"},
          %{id: :styling, label: "Styling", path: "/getting-started/styling"}
        ]
      }
    ]
  end

  defp guide_groups do
    [
      %{
        label: "Theming",
        icon: "lucide-palette",
        pages: [%{id: :theming, label: "Theming", path: "/guides/theming"}]
      },
      %{
        label: "Interaction",
        icon: "lucide-volume-2",
        pages: [%{id: :sound, label: "Sounds", path: "/guides/sound"}]
      },
      %{
        label: "Assets",
        icon: "lucide-shapes",
        pages: [
          %{id: :icons, label: "Icons", path: "/guides/icons"},
          %{id: :flags, label: "Flags", path: "/guides/flags"}
        ]
      }
    ]
  end

  defp component_groups do
    FlintUI.Docs.grouped_components()
    |> Enum.map(fn {type, names} ->
      %{
        label: type_label(type),
        icon: type_icon(type),
        pages: component_pages(names)
      }
    end)
  end

  # A related component opts into the sidebar grouping from the other side,
  # with `{name, nav: true}` in its styled entry. Nesting stays inside one type
  # group so every section keeps a single component category.
  defp component_pages(names) do
    names = Enum.sort(names)
    name_set = MapSet.new(names)

    children_by_parent =
      Map.new(names, fn name ->
        children =
          name
          |> FlintUI.Docs.nav_related()
          |> Enum.filter(&MapSet.member?(name_set, &1))

        {name, children}
      end)

    nested =
      children_by_parent
      |> Map.values()
      |> List.flatten()
      |> MapSet.new()

    for name <- names, not MapSet.member?(nested, name) do
      component_page(name, children_by_parent, [])
    end
  end

  defp component_page(name, children_by_parent, ancestors) do
    children =
      children_by_parent
      |> Map.get(name, [])
      |> Enum.reject(&(&1 == name or &1 in ancestors))
      |> Enum.map(&component_page(&1, children_by_parent, [name | ancestors]))

    %{
      id: name,
      name: name,
      label: humanize(name),
      path: "/components/#{name}",
      children: children
    }
  end

  @doc """
  Fetches a section by id.
  """
  def get!(id) when is_atom(id) do
    Enum.find(sections(), &(&1.id == id)) ||
      raise ArgumentError, "unknown docs section #{inspect(id)}"
  end

  @doc """
  Returns the path a section's bar link points at.

  Most sections link to their first page; the Components section links to its
  landing page so the section switcher does not jump straight into a component.
  """
  def first_page_path(%{id: :components} = section), do: section_path(section)

  def first_page_path(%{groups: [%{pages: [%{path: path} | _]} | _]}), do: path

  @doc """
  Returns the breadcrumb trail for a page as `[%{label: label, path: path}]`.
  """
  def breadcrumbs(section_id, page_id \\ nil) do
    section = get!(section_id)
    [%{label: section.label, path: section_path(section)} | group_crumbs(section, page_id)]
  end

  defp section_path(section) do
    "/" <> (section.id |> Atom.to_string() |> String.replace("_", "-"))
  end

  defp group_crumbs(%{id: :components} = section, page_id) when not is_nil(page_id) do
    Enum.find_value(section.groups, [], fn group ->
      if Enum.any?(group.pages, &page_match?(&1, page_id)) do
        [%{label: group.label, path: "/components"}]
      end
    end)
  end

  defp group_crumbs(section, page_id) do
    Enum.find_value(section.groups, [], fn group ->
      if Enum.any?(group.pages, &page_match?(&1, page_id)) do
        [%{label: group.label, path: group.pages |> List.first() |> Map.fetch!(:path)}]
      end
    end)
  end

  defp page_match?(page, page_id) do
    page.id == page_id or
      Enum.any?(Map.get(page, :children, []), &page_match?(&1, page_id))
  end

  @doc """
  Returns the human-readable label for a `FlintUI.Meta` component type.
  """
  def type_label(type) do
    type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end

  # Icons are keyed by component type, never by the display label: a type the
  # sidebar does not know about raises instead of silently sharing a default.
  @type_icons %{
    element: "lucide-blocks",
    layout: "lucide-panel-left",
    action: "lucide-mouse-pointer-click",
    form: "lucide-square-pen",
    feedback: "lucide-messages-square",
    navigation: "lucide-compass",
    overlay: "lucide-app-window"
  }

  @doc """
  Returns the Lucide icon for a `FlintUI.Meta` component type.

  Adding a type to `FlintUI.Meta` means adding its icon here; `NavTest` asserts
  every type is covered.
  """
  def type_icon(type), do: Map.fetch!(@type_icons, type)

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
