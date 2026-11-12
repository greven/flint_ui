defmodule FlintUIDocsWeb.Docs do
  @moduledoc """
  Facade over the per-component docs page modules.

  Each component has a module under `FlintUIDocsWeb.Docs`
  (e.g. `FlintUIDocsWeb.Docs.Button`) that implements
  `FlintUIDocsWeb.Docs.Page`.

  Register it in `@modules` below; anything not registered falls back to
  `FlintUIDocsWeb.Docs.Default`.
  """

  use Phoenix.Component

  alias FlintUIDocsWeb.Docs.{
    Accordion,
    AccordionItem,
    Alert,
    Avatar,
    AvatarGroup,
    Badge,
    Button,
    Card,
    Collapsible,
    Default,
    Flag,
    Group,
    Icon,
    Indicator,
    Loading,
    LoadingText,
    Source,
    Tabs,
    Toggle
  }

  @modules %{
    accordion: Accordion,
    accordion_item: AccordionItem,
    alert: Alert,
    avatar: Avatar,
    avatar_group: AvatarGroup,
    badge: Badge,
    button: Button,
    card: Card,
    collapsible: Collapsible,
    flag: Flag,
    group: Group,
    icon: Icon,
    indicator: Indicator,
    loading: Loading,
    loading_text: LoadingText,
    tabs: Tabs,
    toggle: Toggle
  }

  @doc "Returns the registered `{name, module}` page modules."
  def modules, do: @modules

  @doc "The page module for a component."
  def page(name), do: Map.get(@modules, name, Default)

  def title(name) do
    case page(name) do
      Default -> humanize(name)
      module -> module.title()
    end
  end

  def subtitle(name) do
    case page(name) do
      Default -> FlintUI.Docs.description(name)
      module -> module.subtitle()
    end
  end

  def meta(name) do
    case page(name) do
      Default -> FlintUI.Docs.meta(name)
      module -> module.meta()
    end
  end

  def links(name), do: default_links(name)

  @doc "Every authored section for a page."
  def sections(name) do
    case page(name) do
      Default -> [%{tab: :styled, section: :usage}]
      module -> module.sections()
    end
  end

  @doc "Authored sections for one tab."
  def sections(name, tab), do: name |> sections() |> Enum.filter(&(section_tab(&1) == tab))

  @doc "Authored sections grouped by top-level `:section`."
  def groups(name, tab) do
    name
    |> sections(tab)
    |> group_sections(tab)
  end

  @doc false
  def group_sections(sections, tab) do
    {order, groups} =
      Enum.reduce(sections, {[], %{}}, fn section, {order, groups} ->
        key = section.section

        if Map.has_key?(groups, key) do
          {order, Map.update!(groups, key, &%{&1 | sections: &1.sections ++ [section]})}
        else
          {order ++ [key], Map.put(groups, key, new_group(tab, section))}
        end
      end)

    Enum.map(order, &finalize_group(Map.fetch!(groups, &1)))
  end

  @doc """
  Authored CSS sections split by their `:position`.

  `:before` sections render above the generated CSS tables; `:after` sections
  render below them.
  """
  def css_groups(name) do
    groups = groups(name, :css)
    Enum.split_with(groups, &(first_position(&1) == :before))
  end

  @doc "The controls declared by the first styled section."
  def controls(name) do
    case sections(name, :styled) do
      [first | _rest] -> Map.get(first, :controls, [])
      [] -> []
    end
  end

  @doc "A map of preview id to the controls that preview exposes."
  def preview_controls(name) do
    for tab <- [:styled, :base],
        section <- sections(name, tab),
        section[:controls] not in [nil, []],
        into: %{} do
      {preview_id(name, section), section.controls}
    end
  end

  @doc """
  Renders one authored section through its page module.

  A page may define only the clauses it needs. A missing clause returns `nil`,
  so the framework renders an empty section.
  """
  def render_section(name, assigns) do
    module = page(name)

    if Code.ensure_loaded?(module) and function_exported?(module, :render_section, 1) do
      module.render_section(assigns)
    end
  rescue
    error in FunctionClauseError ->
      if error.module == page(name) and error.function == :render_section and error.arity == 1 do
        nil
      else
        reraise error, __STACKTRACE__
      end
  end

  @doc "The dev-only source of a section's render clause, or `nil`."
  def source(name, section, id), do: Source.get(page(name), section, id)

  @doc "The stable DOM id of the preview a section renders."
  def preview_id(name, %{tab: :base} = section) do
    "base-" <> preview_id(name, Map.delete(section, :tab))
  end

  def preview_id(name, section) do
    case {section[:preview_id], section.section, Map.get(section, :id)} do
      {id, _section, _id} when is_binary(id) ->
        anchor_id(id)

      # Examples use the same slug as the section anchor, so suffix the preview
      # to keep the heading and preview DOM ids distinct.
      {_preview_id, :examples, id} when not is_nil(id) ->
        anchor_id("example-#{name}-#{id}-preview")

      {_preview_id, :usage, id} when not is_nil(id) ->
        anchor_id("usage-#{name}-#{id}")

      {_preview_id, section, nil} ->
        anchor_id("#{section}-#{name}")

      {_preview_id, section, id} ->
        anchor_id("#{section}-#{name}-#{id}")
    end
  end

  @doc "The stable anchor id of a section's subsection."
  def section_anchor(name, %{tab: :base} = section) do
    "base-" <> section_anchor(name, Map.delete(section, :tab))
  end

  def section_anchor(name, section) do
    case {section.section, Map.get(section, :id)} do
      {section, nil} -> to_string(section)
      {:usage, id} -> "usage-#{id}"
      {:examples, id} -> "example-#{name}-#{id}"
      {section, id} -> "#{section}-#{id}"
    end
    |> anchor_id()
  end

  @doc """
  The Base tab groups, resolved from the page's `base_docs/0`.

  Each group has a `:title`, an `:id`, an optional Markdown `:body`, an optional
  `:system` (`:api`, `:anatomy`, or `:keyboard`), and authored `:sections` that
  accumulate inside it.

  The `:keyboard` system group renders the table built from `keyboard/0` and
  drops the moduledoc body when that metadata exists, so the interactions are
  not listed twice. A component without `keyboard/0` renders its prose instead.
  """
  def base_groups(name) do
    module = page(name)
    doc = FlintUI.Docs.doc_sections(name)
    authored = sections(name, :base)

    keys =
      case apply(module, :base_docs, []) do
        :all -> [:intro | Enum.map(doc.sections, & &1.key)] ++ [:anatomy, :api]
        list when is_list(list) -> list
      end

    groups =
      keys
      |> Enum.map(&resolve_base_entry(name, doc, &1))
      |> Enum.reject(&is_nil/1)
      |> ensure_api()
      |> merge_authored_base(authored)
      |> Enum.map(&finalize_base_group/1)

    groups
  end

  @doc "Plain-CSS recipes for the Styling guide."
  def styling(name), do: page(name).styling()

  @doc "Whether a page is an API-only companion page."
  def api_only?(name), do: page(name).api_only?()

  @doc "Structured anatomy for the Base tab."
  def anatomy(name) do
    module = page(name)

    if Code.ensure_loaded?(module) and function_exported?(module, :anatomy, 0) do
      apply(module, :anatomy, [])
    end
  end

  @doc "The repository URL for a component's source file."
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

  defp new_group(tab, section) do
    %{tab: tab, section: section.section, sections: [section]}
  end

  defp finalize_group(group) do
    first = List.first(group.sections)

    Map.merge(group, %{
      title: first[:group_title] || first[:title],
      id: anchor_id(group.section)
    })
  end

  defp first_position(group) do
    group.sections |> List.first() |> Map.get(:position, :before)
  end

  defp section_tab(section), do: Map.get(section, :tab, :styled)

  defp resolve_base_entry(name, doc, entry) do
    {key, title} =
      case entry do
        {key, title} -> {key, title}
        key -> {key, nil}
      end

    cond do
      key == :api ->
        base_group(key, title || "API", nil, :api)

      key == :anatomy ->
        if anatomy(name) do
          base_group(key, title || "Anatomy", nil, :anatomy)
        end

      key == :keyboard ->
        body = keyboard_body(name, doc)
        base_group(key, title || "Keyboard", body, :keyboard)

      key == :intro ->
        if doc.intro do
          base_group(:intro, title || "Overview", doc.intro, nil)
        end

      true ->
        case Enum.find(doc.sections, &(&1.key == key)) do
          nil ->
            raise ArgumentError,
                  "unknown base doc #{inspect(key)} for #{inspect(name)}; " <>
                    "expected a ## heading, :intro, :anatomy, :keyboard, or :api"

          section ->
            base_group(key, title || section.title, section.body, nil)
        end
    end
  end

  defp base_group(key, title, body, system) do
    %{
      tab: :base,
      section: key,
      title: title,
      id: anchor_id(if(key == :intro, do: "overview", else: key)),
      body: body,
      system: system,
      sections: []
    }
  end

  # `keyboard/0` drives the generated table, and a component documents the same
  # interactions in its `## Keyboard` moduledoc. Rendering both repeats the
  # section, so the table replaces the moduledoc body. Components without
  # `keyboard/0` (e.g. Group) keep the prose-only section.
  defp keyboard_body(name, doc) do
    if FlintUI.Docs.keyboard(name) == [] do
      doc_section_body(doc, :keyboard)
    end
  end

  defp doc_section_body(doc, key) do
    case Enum.find(doc.sections, &(&1.key == key)) do
      nil -> nil
      section -> section.body
    end
  end

  defp ensure_api(groups) do
    if Enum.any?(groups, &(&1.section == :api)) do
      groups
    else
      groups ++ [base_group(:api, "API", nil, :api)]
    end
  end

  defp merge_authored_base(groups, authored) do
    Enum.reduce(authored, groups, fn section, groups ->
      case Enum.find_index(groups, &(&1.section == section.section)) do
        nil ->
          group = %{
            tab: :base,
            section: section.section,
            title: section[:group_title] || section[:title] || humanize(section.section),
            id: anchor_id(section.section),
            body: nil,
            system: nil,
            sections: [section]
          }

          insert_before_api(groups, group)

        index ->
          List.update_at(groups, index, fn group ->
            %{group | sections: group.sections ++ [section]}
          end)
      end
    end)
  end

  defp insert_before_api(groups, group) do
    case Enum.find_index(groups, &(&1.section == :api)) do
      nil -> groups ++ [group]
      index -> List.insert_at(groups, index, group)
    end
  end

  defp finalize_base_group(group) do
    Map.merge(group, %{
      main?: false,
      subsection?: group.sections != []
    })
  end

  # Fragment ids are URL-facing, so keep them to dashes: `:inside_button`
  # becomes `inside-button` instead of leaking the Elixir atom's underscore.
  defp anchor_id(value) do
    value
    |> to_string()
    |> String.replace("_", "-")
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
        icon: "lucide-code-xml"
      }
    ]
  end

  defp humanize(name) do
    name
    |> Atom.to_string()
    |> String.split("_")
    |> Enum.map_join(" ", &String.capitalize/1)
  end
end
