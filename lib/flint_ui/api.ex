defmodule FlintUI.API do
  @moduledoc """
  Provides macros and utility functions for and to build FlintUI components.
  """

  use Phoenix.Component

  @doc """
  Generates a new FlintUI component with the given name.
  The component's implementation is expected to be defined in a separate
  module  under the `FlintUI` namespace (e.g., `FlintUI.Button` for `:button`).

  By default it will generate one component function with the same name as the component,
  but additional functions can be defined in the component module and will be imported as well.

  The component module must implement the `FlintUI.Component` behaviour, which requires defining
  the `meta/0` and `attrs/1` functions.
  """
  defmacro component(name, opts \\ []) do
    other = Keyword.get(opts, :other, [])
    prefix = Keyword.get(opts, :prefix)

    prefix = if prefix && prefix != "", do: "#{prefix}", else: nil

    component_module = component_module(name)
    expanded_module = Macro.expand(component_module, __CALLER__)

    Code.ensure_compiled!(expanded_module)
    component_def = expanded_module.__components__()[:render]

    %{attrs: attrs, slots: slots} = component_def

    attr_ast = component_attrs(attrs)
    slots_ast = component_slots(slots)
    module_doc = fetch_moduledoc(expanded_module)
    changed_var = Macro.var(:changed, __MODULE__)

    inputs =
      attrs
      |> Enum.map(& &1.name)
      |> Kernel.++([:rest])
      |> Enum.reject(&(&1 == :flint_parts))
      |> Enum.uniq()

    inputs_ast = Macro.escape(inputs)

    marked_ast =
      Enum.reduce(slots, quote(do: Map.put(unquote(changed_var), :flint_parts, true)), fn
        %{name: name}, acc ->
          quote do: Map.put(unquote(acc), unquote(name), true)
      end)

    changed_ast =
      quote do
        if Enum.any?(unquote(inputs_ast), &Map.has_key?(unquote(changed_var), &1)) do
          unquote(marked_ast)
        else
          unquote(changed_var)
        end
      end

    public_name =
      if prefix,
        do: String.to_atom("#{prefix}_#{name}"),
        else: name

    main =
      quote do
        @doc unquote(module_doc)
        unquote_splicing(attr_ast)
        unquote_splicing(slots_ast)

        def unquote(public_name)(assigns) do
          parts = unquote(expanded_module).build_attrs(assigns)

          changed =
            case assigns[:__changed__] do
              unquote(changed_var) when is_map(unquote(changed_var)) -> unquote(changed_ast)
              other -> other
            end

          assigns =
            assigns
            |> Map.put(:flint_parts, parts)
            |> Map.put(:__changed__, changed)

          unquote(expanded_module).render(assigns)
        end
      end

    # Generate delegations
    exports = expanded_module.__info__(:functions)

    delegations =
      for fun <- other, {^fun, arity} <- exports do
        args = Macro.generate_arguments(arity, __MODULE__)
        prefixed_fun = if prefix, do: String.to_atom("#{prefix}_#{fun}"), else: fun

        quote do
          defdelegate unquote(prefixed_fun)(unquote_splicing(args)),
            to: unquote(expanded_module),
            as: unquote(fun)
        end
      end

    quote do
      unquote(main)
      unquote_splicing(delegations)
    end
  end

  # Resolves the component name atom to its corresponding module name
  def component_module(name) when is_atom(name) do
    module_name = Atom.to_string(name) |> String.downcase() |> Macro.camelize()
    Module.concat(FlintUI, module_name)
  end

  # Converts a list of attribute definitions into quoted code
  defp component_attrs(attrs) do
    for %{name: name, type: type, required: required, opts: opts, doc: doc} <- attrs do
      opts = if required, do: [{:required, true} | opts], else: opts
      opts = if doc, do: [{:doc, doc} | opts], else: opts
      opts = Macro.escape(opts)
      quote do: attr(unquote(name), unquote(type), unquote(opts))
    end
  end

  # Converts a list of slot definitions into quoted code
  defp component_slots(slots) do
    for %{name: name, required: required, attrs: slot_attrs, opts: opts, doc: doc} <- slots do
      opts = if required, do: [{:required, true} | opts], else: opts
      opts = if doc, do: [{:doc, doc} | opts], else: opts

      inner =
        for %{name: sname, type: stype, required: srequired, opts: sopts, doc: sdoc} <- slot_attrs do
          sopts = if srequired, do: [{:required, true} | sopts], else: sopts
          sopts = if sdoc, do: [{:doc, sdoc} | sopts], else: sopts
          sopts = Macro.escape(sopts)
          quote do: attr(unquote(sname), unquote(stype), unquote(sopts))
        end

      quote do
        slot unquote(name), unquote(opts) do
          (unquote_splicing(inner))
        end
      end
    end
  end

  # Fetches the moduledoc string from a module
  defp fetch_moduledoc(module) do
    case Code.fetch_docs(module) do
      {:docs_v1, _, _, _, %{"en" => doc}, _, _} -> doc
      _ -> false
    end
  end

  ## Helpers

  @doc """
  Generates a unique id for a DOM element with an optional prefix.
  """
  def use_id(prefix \\ "fl") do
    "#{prefix}-"
    |> Kernel.<>(random_encoded_bytes())
    |> String.replace(["/", "+"], "-")
    |> String.trim()
  end

  # Taken from Phoenix LiveView
  defp random_encoded_bytes do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2({node(), self()})::16,
      :erlang.unique_integer()::16
    >>

    Base.url_encode64(binary)
  end
end
