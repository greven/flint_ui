if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flint.Add do
    @shortdoc "Generates styled FlintUI components into your app"

    @moduledoc """
    Generates one or more styled FlintUI components into `MyAppWeb.Components`.

        mix flint.add button
        mix flint.add button toggle
        mix flint.add --all

    The generated wrapper is thin: it declares the extra attributes, maps them onto
    the `data-*` hooks the theme targets, and delegates behavior to the headless
    component. Styling lives in the theme stylesheet (see `mix flint.setup`).

    ## Replacing the core input

    `mix flint.add input` also removes `input/1` from `MyAppWeb.CoreComponents`
    when it is there. Both modules would otherwise be imported into your HTML
    helpers, and two `input/1` functions make `<.input>` ambiguous. The private
    `error/1` helper is removed too when nothing else uses it. Existing templates
    keep working; pass `field`, `type`, `options`, and the rest exactly as before.
    """

    use Igniter.Mix.Task

    alias FlintUI.{Generator, Styled}
    alias Sourceror.Zipper

    @impl Igniter.Mix.Task
    def info(_argv, _composing) do
      %Igniter.Mix.Task.Info{
        positional: [{:components, [optional: true, rest: true]}],
        schema: [all: :boolean],
        aliases: [a: :all]
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      positional = igniter.args.positional[:components] || []
      {names, unknown} = resolve(positional, igniter.args.options)

      cond do
        unknown != [] ->
          Igniter.add_issue(igniter, """
          Unknown component(s): #{Enum.join(unknown, ", ")}.
          Available: #{available()}.
          """)

        names == [] ->
          Igniter.add_issue(
            igniter,
            "No components given. Try `mix flint.add button` or `mix flint.add --all`."
          )

        true ->
          Enum.reduce(names, igniter, &add_component(&2, &1))
      end
    end

    defp resolve(positional, options) do
      if options[:all] do
        {Styled.names(), []}
      else
        resolve_names(positional)
      end
    end

    defp resolve_names(positional) do
      Enum.reduce(positional, {[], []}, fn input, {names, unknown} ->
        case Enum.find(Styled.names(), &(Atom.to_string(&1) == input)) do
          nil -> {names, unknown ++ [input]}
          name -> {names ++ [name], unknown}
        end
      end)
    end

    defp available, do: Enum.map_join(Styled.names(), ", ", &to_string/1)

    defp add_component(igniter, name) do
      module = Igniter.Libs.Phoenix.web_module_name(igniter, "Components")
      source = Generator.component_source(name)

      igniter
      |> replace_core_component(name)
      |> Igniter.Project.Module.find_and_update_or_create_module(
        module,
        "use Phoenix.Component\n\n#{source}",
        fn zipper ->
          case Igniter.Code.Function.move_to_def(zipper, name, 1) do
            {:ok, _} -> {:ok, zipper}
            :error -> {:ok, Igniter.Code.Common.add_code(zipper, source, placement: :after)}
          end
        end
      )
    end

    # Phoenix's generated `<.input>` and FlintUI's generated `<.input>` would be
    # imported from two modules at once, which makes every call ambiguous. Only
    # the input is a parity target that already exists in a new Phoenix app.
    defp replace_core_component(igniter, :input) do
      core = Igniter.Libs.Phoenix.web_module_name(igniter, "CoreComponents")
      components = Igniter.Libs.Phoenix.web_module_name(igniter, "Components")

      case Igniter.Project.Module.find_module(igniter, core) do
        {:ok, {igniter, source, _zipper}} ->
          if source |> Rewrite.Source.get(:content) |> String.match?(input_definition()) do
            igniter
            |> Igniter.Project.Module.find_and_update_module(core, &remove_core_input/1)
            |> case do
              {:ok, igniter} ->
                Igniter.add_notice(igniter, """
                Removed `input/1` from #{inspect(core)}. `<.input>` now comes from \
                #{inspect(components)}.\
                """)

              {:error, igniter} ->
                igniter
            end
          else
            igniter
          end

        {:error, igniter} ->
          igniter
      end
    end

    defp replace_core_component(igniter, _name), do: igniter

    defp input_definition, do: ~r/def input\(/

    defp remove_core_input(zipper) do
      case Zipper.node(zipper) do
        {:__block__, meta, statements} ->
          {:ok, Zipper.replace(zipper, {:__block__, meta, remove_input(statements)})}

        _ ->
          {:ok, zipper}
      end
    end

    defp remove_input(statements) do
      indices =
        for {statement, index} <- Enum.with_index(statements),
            input_definition?(statement),
            do: index

      case indices do
        [] ->
          statements

        _ ->
          first = List.first(indices)
          last = List.last(indices)
          start = declaration_start(statements, first)

          statements
          |> Enum.with_index()
          |> Enum.reject(fn {_statement, index} -> index >= start and index <= last end)
          |> Enum.map(fn {statement, _index} -> statement end)
          |> remove_unused_error()
      end
    end

    # The input's `@doc`, `@spec`, `@impl`, and `attr` declarations sit directly
    # above its first clause. Remove them together so they do not attach to the
    # next function.
    defp declaration_start(statements, index) when index > 0 do
      if declaration?(Enum.at(statements, index - 1)) do
        declaration_start(statements, index - 1)
      else
        index
      end
    end

    defp declaration_start(_statements, 0), do: 0

    defp declaration?({:@, _, _}), do: true
    defp declaration?({:attr, _, args}) when is_list(args), do: true
    defp declaration?(_statement), do: false

    # The private error helper only existed for the core input. Keep it when a
    # customized module still calls it somewhere else.
    defp remove_unused_error(statements) do
      case Enum.split_with(statements, &function_definition?(&1, :error, 1)) do
        {[_ | _], rest} ->
          if Enum.any?(rest, &calls_function?(&1, :error, 1)), do: statements, else: rest

        _ ->
          statements
      end
    end

    defp calls_function?(ast, name, arity) do
      {_ast, found} =
        Macro.prewalk(ast, false, fn
          {^name, _, args} = node, _found when is_list(args) -> {node, length(args) == arity}
          node, found -> {node, found}
        end)

      found
    end

    defp input_definition?(statement), do: function_definition?(statement, :input, 1)

    defp function_definition?({kind, _, [head, _body]}, name, arity) when kind in [:def, :defp],
      do: function_head?(head, name, arity)

    defp function_definition?(_statement, _name, _arity), do: false

    defp function_head?({name, _, args}, name, arity) when is_list(args),
      do: length(args) == arity

    defp function_head?({name, _, nil}, name, 0), do: true

    defp function_head?({:when, _, [head, _guard]}, name, arity),
      do: function_head?(head, name, arity)

    defp function_head?(_head, _name, _arity), do: false
  end
end
