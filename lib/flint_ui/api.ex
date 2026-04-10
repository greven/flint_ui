defmodule FlintUI.API do
  @moduledoc """
  Provides macros and utility functions for and to build FlintUI components.
  """

  use Phoenix.Component

  defmacro defcomponent(name) do
    component_module = component_module(name)
    expanded_module = Macro.expand(component_module, __CALLER__)

    if not Module.has_attribute?(__CALLER__.module, :__flint_components__) do
      Module.register_attribute(__CALLER__.module, :__flint_components__, accumulate: true)
    end

    Code.ensure_compiled!(expanded_module)

    %{attrs: attrs, slots: slots} = expanded_module.__components__()[:render]

    attr_ast = component_attrs(attrs)
    slots_ast = component_slots(slots)
    module_doc = fetch_moduledoc(expanded_module)

    quote do
      @__flint_components__ unquote(expanded_module)

      @doc unquote(module_doc)
      unquote_splicing(attr_ast)
      unquote_splicing(slots_ast)
      def unquote(name)(assigns), do: unquote(expanded_module).render(assigns)
    end
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

  # Resolves the component name atom to its corresponding module name
  defp component_module(name) when is_atom(name) do
    module_name = Atom.to_string(name) |> String.downcase() |> Macro.camelize()
    Module.concat(FlintUI, module_name)
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
