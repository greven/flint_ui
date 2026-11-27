defmodule FlintUI.TestDOM do
  @moduledoc false

  # Semantic DOM helpers shared by the component tests.
  #
  # The testing contract prefers hooks (`data-element`, `data-part`, `data-*`,
  # ARIA) over raw markup. Inline styles are parsed into a map so assertions do
  # not depend on declaration order, and class strings are split so assertions
  # check membership instead of exact whitespace.

  @doc "Parses a rendered fragment into a `LazyHTML` document."
  def parse(html) when is_binary(html), do: LazyHTML.from_fragment(html)

  @doc "Runs a CSS selector against a document."
  def query(document, selector), do: LazyHTML.query(document, selector)

  @doc "Returns the number of nodes matching `selector`."
  def count(document, selector), do: document |> query(selector) |> Enum.count()

  @doc "Returns true when no node matches `selector`."
  def empty?(document, selector), do: document |> query(selector) |> Enum.empty?()

  @doc "Returns the trimmed text of the first matching node."
  def text(document, selector) do
    document
    |> query(selector)
    |> LazyHTML.text()
    |> String.trim()
  end

  @doc "Returns every attribute value for `selector` and `name`."
  def attrs(document, selector, name) do
    document
    |> query(selector)
    |> LazyHTML.attribute(name)
  end

  @doc "Returns the first attribute value for `selector` and `name`, or nil."
  def attr(document, selector, name) do
    document
    |> attrs(selector, name)
    |> List.first()
  end

  @doc "Returns the first matching part (`data-part`)."
  def part(document, name), do: query(document, ~s([data-part="#{name}"]))

  @doc "Returns every attribute value for a part."
  def part_attr(document, name, attribute),
    do: attrs(document, ~s([data-part="#{name}"]), attribute)

  @doc "Returns the first matching element (`data-element`)."
  def element(document, name), do: query(document, ~s([data-element="#{name}"]))

  @doc "Returns every attribute value for an element."
  def element_attr(document, name, attribute) do
    attrs(document, ~s([data-element="#{name}"]), attribute)
  end

  @doc """
  Parses an inline `style` attribute into a map.

  Later declarations win, which mirrors the cascade while dropping the
  formatting and declaration order from the assertion.
  """
  def style_vars(style) when is_binary(style) do
    style
    |> String.split(";", trim: true)
    |> Enum.reduce(%{}, fn declaration, acc ->
      case String.split(declaration, ":", parts: 2) do
        [name, value] -> Map.put(acc, String.trim(name), String.trim(value))
        _other -> acc
      end
    end)
  end

  def style_vars(nil), do: %{}

  def style_vars(%LazyHTML{} = nodes) do
    nodes
    |> LazyHTML.attribute("style")
    |> List.first("")
    |> style_vars()
  end

  @doc "Parses the `style` attribute of the first node matching `selector`."
  def style_vars(document, selector) do
    document
    |> attr(selector, "style")
    |> style_vars()
  end

  @doc "Returns one custom property from the parsed inline style."
  def style_var(document, selector, name) do
    document
    |> style_vars(selector)
    |> Map.fetch!(name)
  end

  @doc "Splits a class attribute into class names."
  def class_list(nil), do: []

  def class_list(value) when is_binary(value) do
    String.split(value, ~r/\s+/, trim: true)
  end

  def class_list(values) when is_list(values), do: Enum.flat_map(values, &class_list/1)

  @doc "Returns the class list of the first node matching `selector`."
  def classes(document, selector) do
    document
    |> attr(selector, "class")
    |> class_list()
  end
end
