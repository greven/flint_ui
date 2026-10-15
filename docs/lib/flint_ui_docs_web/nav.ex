defmodule FlintUIDocsWeb.Nav do
  @moduledoc """
  The single source of truth for the docs navigation.
  """

  @type page :: %{
          required(:id) => atom(),
          required(:label) => String.t(),
          required(:path) => String.t(),
          optional(:name) => atom()
        }

  @type group :: %{required(:label) => String.t(), required(:pages) => [page()]}

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
        pages: [
          %{id: :introduction, label: "Introduction", path: "/getting-started/introduction"},
          %{id: :installation, label: "Installation", path: "/getting-started/installation"}
        ]
      }
    ]
  end

  defp guide_groups do
    [
      %{
        label: "Theming",
        pages: [%{id: :theming, label: "Theming", path: "/guides/theming"}]
      }
    ]
  end

  defp component_groups do
    FlintUI.Docs.grouped_components()
    |> Enum.map(fn {type, names} ->
      %{
        label: type_label(type),
        pages:
          Enum.map(names, fn name ->
            %{id: name, name: name, label: to_string(name), path: "/components/#{name}"}
          end)
      }
    end)
  end

  @doc """
  Fetches a section by id.
  """
  def get!(id) when is_atom(id) do
    Enum.find(sections(), &(&1.id == id)) ||
      raise ArgumentError, "unknown docs section #{inspect(id)}"
  end

  @doc """
  Returns the path of a section's first page, used for the section bar links.
  """
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

  defp group_crumbs(%{id: :components}, _page_id), do: []

  defp group_crumbs(section, page_id) do
    Enum.find_value(section.groups, [], fn group ->
      if Enum.any?(group.pages, &(&1.id == page_id)) do
        [%{label: group.label, path: group.pages |> List.first() |> Map.fetch!(:path)}]
      end
    end)
  end

  defp type_label(type) do
    type
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
