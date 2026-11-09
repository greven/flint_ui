defmodule Mix.Tasks.Compile.FlintIcons do
  @moduledoc """
  Regenerates the scanned icon CSS during compilation.

  Add the compiler when you install icons with plain CSS and `--scan`:

      def project do
        [
          compilers: Mix.compilers() ++ [:flint_icons]
        ]
      end

  The compiler scans the configured source globs and rewrites the
  `assets/css/flint-<set>.css` files for the sets imported from
  `assets/css/app.css`, or for the generated files that already exist. It is a
  no-op when neither is present (for example, in Tailwind mode).

  Configure the scanner with:

      config :flint_ui,
        icon_source_globs: ["lib/**/*.{ex,heex,eex,leex}"],
        icon_safelist: ["lucide-wifi"]

  The defaults are `FlintUI.Icons.Scanner.default_globs/0` and `[]`.
  """

  use Mix.Task.Compiler

  alias FlintUI.Icons
  alias FlintUI.Icons.Scanner

  @recursive true

  @impl Mix.Task.Compiler
  def run(_args) do
    sets =
      case Icons.css_sets() do
        [] ->
          Enum.filter(Icons.installed_sets(), fn set ->
            File.exists?(Path.join("assets/css", Icons.css_file(set)))
          end)

        css_sets ->
          Enum.filter(css_sets, &File.dir?(Icons.deps_path(&1)))
      end

    if sets == [] do
      {:ok, []}
    else
      globs = Application.get_env(:flint_ui, :icon_source_globs, Scanner.default_globs())
      safelist = Application.get_env(:flint_ui, :icon_safelist, [])
      classes = Scanner.scan(globs, safelist: safelist)

      if MapSet.size(classes) == 0 do
        Mix.shell().info(
          "FlintUI icon scan found no icon classes; leaving generated CSS untouched."
        )

        {:ok, []}
      else
        write_changed(sets, classes)
        {:ok, []}
      end
    end
  end

  defp write_changed(sets, classes) do
    for set <- sets do
      path = Path.join("assets/css", Icons.css_file(set))
      css = Icons.generate_css(set, classes: classes)

      if File.read(path) != {:ok, css} do
        File.write!(path, css)
        Mix.shell().info("Generated #{path}")
      end
    end
  end
end
