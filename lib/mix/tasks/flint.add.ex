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
    """

    use Igniter.Mix.Task

    alias FlintUI.{Generator, Styled}

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

      Igniter.Project.Module.find_and_update_or_create_module(
        igniter,
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
  end
end
