defmodule FlintUI.StyledCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  require Phoenix.LiveViewTest

  using do
    quote do
      import FlintUI.StyledCase
    end
  end

  @doc false
  # Compiles the generated wrapper for `name` together with the example
  # functions a test file provides. The examples are source so the test keeps
  # exercising the wrapper the generator actually produces.
  def compile_wrapper!(name, examples) do
    module = Module.concat([FlintUITest, Styled, Macro.camelize(to_string(name))])

    Code.compile_string(~s'''
    defmodule #{inspect(module)} do
      use Phoenix.Component

      #{FlintUI.Generator.component_source(name)}

      #{examples}
    end
    ''')

    module
  end

  @doc false
  def render(module, function, assigns \\ %{}) do
    Phoenix.LiveViewTest.render_component(
      fn component_assigns -> apply(module, function, [component_assigns]) end,
      assigns
    )
    |> LazyHTML.from_fragment()
  end

  @doc false
  def root(document, component) do
    LazyHTML.query(document, ~s([data-element="#{component}"]))
  end

  @doc false
  def attr(document, component, name) do
    document |> root(component) |> LazyHTML.attribute(name)
  end

  @doc false
  def part(document, name) do
    LazyHTML.query(document, ~s([data-part="#{name}"]))
  end

  @doc false
  def part_attr(document, name, attribute) do
    document |> part(name) |> LazyHTML.attribute(attribute)
  end

  @doc false
  def count_part(document, name) do
    pattern = ~r/data-part="#{Regex.escape(name)}"/

    document
    |> LazyHTML.to_html()
    |> then(&length(Regex.scan(pattern, &1)))
  end
end
