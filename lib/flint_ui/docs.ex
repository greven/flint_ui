defmodule FlintUI.Docs do
  @moduledoc """
  Provides macros to fetch the documentation for a given component.
  """

  import FlintUI.API, only: [component_module: 1]

  @doc """
  Fetches the metadata (`FlintUI.Meta`) for a component.
  """
  def meta(component) when is_atom(component) do
    component_module(component).meta()
  end

  @doc """
  Returns all registered components grouped by their `FlintUI.Meta` type.

  Groups are ordered by `FlintUI.Meta.types/0`, types without components are
  omitted, and components within each group are sorted by name. Returns a list
  of `{type, [component]}` tuples.
  """
  def grouped_components do
    types = FlintUI.Meta.types()

    FlintUI.components()
    |> Enum.group_by(&meta(&1).type)
    |> Enum.sort_by(fn {type, _} -> Enum.find_index(types, &(&1 == type)) || length(types) end)
    |> Enum.map(fn {type, components} -> {type, Enum.sort(components)} end)
  end

  @doc """
  Returns a short, single-line description for a component, taken from the first
  sentence of its moduledoc.

  The first paragraph is joined into a single line, so a description wrapped
  across source lines is not cut off. Anything after the first period is
  dropped.
  """
  def description(component) when is_atom(component) do
    case Code.fetch_docs(component_module(component)) do
      {:docs_v1, _, _, _, %{"en" => doc}, _, _} ->
        doc
        |> String.split("\n")
        |> Enum.map(&String.trim/1)
        |> Enum.drop_while(&(&1 == ""))
        |> Enum.take_while(&(&1 != ""))
        |> Enum.join(" ")
        |> first_sentence()

      _ ->
        nil
    end
  end

  defp first_sentence(""), do: nil

  defp first_sentence(text) do
    case String.split(text, ".", parts: 2) do
      [sentence, _rest] -> sentence <> "."
      [sentence] -> sentence
    end
  end

  @doc """
  Returns the intro and `##`-level sections of a component's moduledoc.

  The intro is the text before the first `##` heading; each section carries its
  title, a slug key (`"Link triggers"` becomes `:link_triggers`), and its
  Markdown body. `###` headings stay inside the section body, so a section can
  still use subheadings.

  Returns `%{intro: nil | String.t(), sections: [map()]}`.
  """
  def doc_sections(component) when is_atom(component) do
    case Code.fetch_docs(component_module(component)) do
      {:docs_v1, _, _, _, %{"en" => doc}, _, _} -> parse_doc(doc)
      _ -> %{intro: nil, sections: []}
    end
  end

  @doc """
  Returns the text before the first `##` heading of a component's moduledoc.
  """
  def intro(component) when is_atom(component), do: doc_sections(component).intro

  @doc """
  Returns the body of a `##`-level section from a component's moduledoc.

  The shared leading indentation is stripped so the result is ready to render
  as Markdown. Returns `nil` when the section is absent, which lets callers
  treat an undocumented section as optional.
  """
  def section(component, title) when is_atom(component) and is_binary(title) do
    case Code.fetch_docs(component_module(component)) do
      {:docs_v1, _, _, _, %{"en" => doc}, _, _} -> extract_section(doc, title)
      _ -> nil
    end
  end

  defp parse_doc(doc) do
    lines = String.split(doc, "\n")
    headings = headings_with_indices(lines)

    intro =
      case headings do
        [] -> dedent_and_trim(lines)
        [{index, _title} | _rest] -> lines |> Enum.take(index) |> dedent_and_trim()
      end

    sections =
      headings
      |> Enum.with_index()
      |> Enum.map(fn {{index, title}, position} ->
        next =
          case Enum.at(headings, position + 1) do
            nil -> length(lines)
            {next_index, _title} -> next_index
          end

        body =
          lines
          |> Enum.slice((index + 1)..(next - 1)//1)
          |> dedent_and_trim()
          |> blank_to_nil()

        %{key: slug(title), title: title, body: body}
      end)

    %{intro: blank_to_nil(intro), sections: sections}
  end

  defp headings_with_indices(lines) do
    lines
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, index} ->
      trimmed = String.trim_leading(line)

      if String.starts_with?(trimmed, "## ") and not String.starts_with?(trimmed, "### ") do
        [{index, trimmed |> String.replace_prefix("## ", "") |> String.trim()}]
      else
        []
      end
    end)
  end

  defp dedent_and_trim(lines) do
    lines
    |> dedent()
    |> trim_blank_lines()
  end

  defp slug(title) do
    title
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "_")
    |> String.trim("_")
    |> String.to_atom()
  end

  defp blank_to_nil(""), do: nil
  defp blank_to_nil(value), do: value

  defp extract_section(doc, title) do
    lines = String.split(doc, "\n")
    heading = "## " <> title

    case Enum.find_index(lines, &(String.trim(&1) == heading)) do
      nil ->
        nil

      index ->
        body =
          lines
          |> Enum.drop(index + 1)
          |> Enum.take_while(&(not section_heading?(&1)))
          |> dedent()
          |> trim_blank_lines()

        if body == "", do: nil, else: body
    end
  end

  defp section_heading?(line) do
    trimmed = String.trim_leading(line)
    String.starts_with?(trimmed, "## ") and not String.starts_with?(trimmed, "### ")
  end

  defp dedent(lines) do
    indent =
      lines
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(&(String.length(&1) - String.length(String.trim_leading(&1))))
      |> Enum.min(fn -> 0 end)

    Enum.map(lines, fn
      "" -> ""
      line -> String.slice(line, indent..-1//1)
    end)
  end

  defp trim_blank_lines(lines) do
    lines
    |> Enum.drop_while(&(String.trim(&1) == ""))
    |> Enum.reverse()
    |> Enum.drop_while(&(String.trim(&1) == ""))
    |> Enum.reverse()
    |> Enum.join("\n")
  end

  @doc """
  Fetches the documentation for a component's attributes (`:attrs`).
  """
  def attrs(component) when is_atom(component) do
    component_module(component).__components__()[:render][:attrs]
    # `doc: false` marks an internal connector, such as the part map or a
    # wrapper-supplied nested attribute map. It is never public API.
    |> Enum.reject(&(&1.name == :flint_parts or &1[:doc] == false))
    |> Enum.sort_by(&{not &1.required, &1.name})
  end

  @doc """
  Fetches the documentation for a component's slots (`:slots`).
  """
  def slots(component) when is_atom(component) do
    component_module(component).__components__()[:render][:slots]
    |> Enum.sort_by(&{not &1.required, &1.name})
  end

  @doc """
  Fetches the documentation for a component's part attributes (`:parts_attrs`).
  Returns the parts as an ordered list of `{part, attrs}` tuples, where `attrs`
  is a list of `FlintUI.Meta.PartAttr` structs. The order is the component's DOM
  order, as declared by the component.
  """
  def parts_attrs(component) when is_atom(component) do
    component_module = component_module(component)

    if exported?(component_module, :parts_attrs, 0) do
      component_module.parts_attrs()
    else
      []
    end
  end

  @doc """
  Fetches a component's styling parts as normalized CSS-part rows.

  Each row names the part (`:root`, `:panel`, …), the `data-part` hook it
  carries, a human description, and the selector that targets it in the styled
  layer. The description comes from the part's `[data-part]` attribute metadata,
  so a component only declares its parts once.

  The rows keep the component's declared part order, so the CSS-parts table and
  the data-attribute table list the parts the same way, in anatomy order.

  A part whose `[data-part]` metadata is absent still appears, using its name as
  the hook and a generic description.
  """
  def parts(component) when is_atom(component) do
    component
    |> parts_attrs()
    |> Enum.map(fn {name, attrs} ->
      hook = part_hook(name, attrs)

      %{
        name: name,
        hook: hook,
        description: part_description(name, attrs),
        selector: part_selector(component, hook)
      }
    end)
  end

  @doc """
  Fetches the CSS custom properties for a component (`:css_vars`).
  Returns a list of `FlintUI.Meta.CSSVar` structs.
  """
  def css_vars(component) when is_atom(component) do
    component_module = component_module(component)

    if exported?(component_module, :css_vars, 0) do
      component_module.css_vars()
    else
      []
    end
  end

  @doc """
  Fetches the events a component emits (`:events`).
  Returns a list of `FlintUI.Meta.Event` structs.
  """
  def events(component) when is_atom(component) do
    component_module = component_module(component)

    if exported?(component_module, :events, 0) do
      component_module.events()
    else
      []
    end
  end

  @doc """
  Fetches the keyboard interactions for a component (`:keyboard`).
  Returns a list of `FlintUI.Meta.Keyboard` structs.
  """
  def keyboard(component) when is_atom(component) do
    component_module = component_module(component)

    if exported?(component_module, :keyboard, 0) do
      component_module.keyboard()
    else
      []
    end
  end

  @doc """
  Fetches the state selectors a component exposes (`:states`).
  Returns a list of `FlintUI.Meta.State` structs.
  """
  def states(component) when is_atom(component) do
    component_module = component_module(component)

    if exported?(component_module, :states, 0) do
      component_module.states()
    else
      []
    end
  end

  # `function_exported?/3` does not load a module, and the docs compute their
  # metadata before the page renders any component. Without this the first page
  # load would treat every optional callback as missing.
  defp exported?(module, function, arity) do
    Code.ensure_loaded?(module) and function_exported?(module, function, arity)
  end

  defp part_hook(name, attrs) do
    case Enum.find(attrs, &(&1.name == "[data-part]")) do
      %{value: value} when is_binary(value) and value != "" -> value
      _ -> to_string(name)
    end
  end

  defp part_description(:root, attrs), do: root_description(attrs)
  defp part_description(_name, attrs), do: attr_part_description(attrs)

  # Most root parts carry the same "Identifies the root element" note, which is
  # useful in the data-attribute table but says nothing about a CSS part. Keep a
  # root description that adds information and replace the generic one.
  defp root_description(attrs) do
    description = attr_part_description(attrs)

    if generic_root_description?(description) do
      "The component's outer wrapper."
    else
      description
    end
  end

  defp generic_root_description?(description) do
    String.starts_with?(description, "Identifies the ") and
      (String.ends_with?(description, "root.") or
         String.ends_with?(description, "root element."))
  end

  defp attr_part_description(attrs) do
    case Enum.find(attrs, &(&1.name == "[data-part]")) do
      %{description: description} when is_binary(description) and description != "" -> description
      _ -> "The part element."
    end
  end

  defp part_selector(component, "root"), do: ~s([data-element="#{component}"])
  defp part_selector(component, hook), do: ~s([data-element="#{component}"] [data-part="#{hook}"])

  @doc """
  Returns the components closely related to a component, as declared by its
  styled entry.
  """
  def related(component) when is_atom(component) do
    entry_relations(component, &FlintUI.Styled.Entry.related/1)
  end

  @doc """
  Returns the related components nested under a component in the docs sidebar.
  """
  def nav_related(component) when is_atom(component) do
    entry_relations(component, &FlintUI.Styled.Entry.nav_related/1)
  end

  @doc """
  Returns the components a component is built on, as declared by its styled
  entry.
  """
  def dependencies(component) when is_atom(component) do
    entry_relations(component, &FlintUI.Styled.Entry.dependencies/1)
  end

  defp entry_relations(component, fun) do
    case FlintUI.Styled.get(component) do
      nil -> []
      entry -> fun.(entry)
    end
  end
end
