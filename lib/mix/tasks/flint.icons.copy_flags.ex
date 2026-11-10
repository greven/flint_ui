defmodule Mix.Tasks.Flint.Icons.CopyFlags do
  @shortdoc "Copies Flag Icons SVGs into priv/static/images/flags"

  @moduledoc """
  Copies the installed Flag Icons SVGs into `priv/static/images/flags`.

      mix flint.icons.copy_flags
      mix flint.icons.copy_flags --only pt,us,br

  The 4:3 files become `<code>.svg` and the 1:1 files become
  `<code>-square.svg`, matching the URL the Flag component builds from `code`
  and `shape`. `priv/static/images` is already in the default Phoenix
  `Plug.Static` allowlist. Pass `--dest` to copy elsewhere and set
  `config :flint_ui, flag_path: "/..."` to match.

  Run the task again after updating the `flag_icons` dependency. `mix
  flint.icons flags --assets` queues it automatically.
  """

  use Mix.Task

  alias FlintUI.Icons

  @impl Mix.Task
  def run(args) do
    {options, _positional, invalid} =
      OptionParser.parse(args,
        strict: [only: :keep, source: :string, dest: :string]
      )

    if invalid != [] do
      Mix.raise("Invalid option(s): #{Enum.map_join(invalid, ", ", &elem(&1, 0))}")
    end

    only =
      options
      |> Keyword.get_values(:only)
      |> Enum.flat_map(&String.split(&1, ",", trim: true))
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    try do
      paths =
        Icons.copy_flag_assets!(
          only: only,
          source: options[:source],
          dest: options[:dest]
        )

      dest = options[:dest] || Icons.flag_public_dir()
      Mix.shell().info("Copied #{length(paths)} flag SVGs to #{dest}")
    rescue
      error in ArgumentError -> Mix.raise(Exception.message(error))
    end
  end
end
