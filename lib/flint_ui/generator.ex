defmodule FlintUI.Generator do
  @moduledoc """
  Renders styled component wrapper source from the registry.

  The generated wrappers are thin: they declare the extra presentational attributes,
  map them onto the `data-*` hooks the theme targets, and delegate behavior to
  the headless base component. No styling is baked in; that lives in `flint.css`.
  """

  alias FlintUI.Styled

  @doc """
  Returns the wrapper function source for a component.

  Raises when the component is not registered.
  """
  def component_source(name) when is_atom(name) do
    entry =
      Styled.get(name) || raise ArgumentError, "unknown FlintUI component: #{inspect(name)}"

    EEx.eval_file(template_path("#{entry.name}.ex.eex"),
      assigns: [
        name: to_string(entry.name),
        attrs: attr_block(entry),
        slots: slot_block(entry)
      ]
    )
  end

  @tokens_part "tokens.css"
  @base_part "base.css"
  @aggregate "priv/static/flint.css"

  @doc "Absolute path to a theme part, relative to `priv/templates`."
  def part_path(relative) do
    Path.join([:code.priv_dir(:flint_ui), "templates", relative])
  end

  @doc """
  Absolute paths to every theme part, in assembly order.

  Tokens come first (they are unlayered), then the shared base rules, then each
  registered component's stylesheet in registry order.
  """
  def part_paths do
    [@tokens_part, @base_part | Enum.map(Styled.entries(), & &1.css)]
    |> Enum.map(&part_path/1)
  end

  @doc "The default theme stylesheet, assembled from its parts."
  def theme_source do
    part_paths()
    |> Enum.map(&File.read!/1)
    |> Enum.join("\n")
  end

  @doc """
  Path of the assembled stylesheet in the library source tree.

  It lives in the source tree (not `_build`) so the docs site can `@import` it.
  """
  def aggregate_path do
    Path.join(Path.dirname(Mix.Project.project_file()), @aggregate)
  end

  @doc """
  Writes `theme_source/0` to `aggregate_path/0` when any part is newer than it.

  Returns `:ok` when it (re)writes and `:noop` when the aggregate is fresh.
  """
  def write_aggregate! do
    output = aggregate_path()

    if fresh?(output, part_paths()) do
      :noop
    else
      File.mkdir_p!(Path.dirname(output))
      File.write!(output, theme_source())
      :ok
    end
  end

  defp fresh?(output, sources) do
    with {:ok, %File.Stat{mtime: out_mtime}} <- File.stat(output, time: :posix) do
      Enum.all?(sources, fn src ->
        match?({:ok, %File.Stat{mtime: m}} when m <= out_mtime, File.stat(src, time: :posix))
      end)
    else
      _ -> false
    end
  end

  @doc "The `@theme` mapping that exposes FlintUI tokens as Tailwind utilities."
  def tailwind_bridge_source do
    """
    @theme inline {
      --color-background: var(--fl-color-background);
      --color-foreground: var(--fl-color-foreground);
      --color-card: var(--fl-color-card);
      --color-card-foreground: var(--fl-color-card-foreground);
      --color-primary: var(--fl-color-primary);
      --color-primary-foreground: var(--fl-color-primary-foreground);
      --color-secondary: var(--fl-color-secondary);
      --color-secondary-foreground: var(--fl-color-secondary-foreground);
      --color-neutral: var(--fl-color-neutral);
      --color-neutral-foreground: var(--fl-color-neutral-foreground);
      --color-success: var(--fl-color-success);
      --color-success-foreground: var(--fl-color-success-foreground);
      --color-info: var(--fl-color-info);
      --color-info-foreground: var(--fl-color-info-foreground);
      --color-warning: var(--fl-color-warning);
      --color-warning-foreground: var(--fl-color-warning-foreground);
      --color-error: var(--fl-color-error);
      --color-error-foreground: var(--fl-color-error-foreground);
      --color-muted: var(--fl-color-muted);
      --color-muted-foreground: var(--fl-color-muted-foreground);
      --color-accent: var(--fl-color-accent);
      --color-accent-foreground: var(--fl-color-accent-foreground);
      --color-destructive: var(--fl-color-destructive);
      --color-border: var(--fl-color-border);
      --color-input: var(--fl-color-input);
      --color-ring: var(--fl-color-ring);

      --radius-sm: var(--fl-radius-sm);
      --radius-md: var(--fl-radius-md);
      --radius-lg: var(--fl-radius-lg);
      --radius-xl: var(--fl-radius-xl);

      --font-sans: var(--fl-font-sans);
    }
    """
  end

  defp template_path(file) do
    Path.join([:code.priv_dir(:flint_ui), "templates", "styled", file])
  end

  defp attr_block(entry) do
    prop_lines = Enum.map(entry.props, &prop_attr/1)
    include = base_attr_names(entry)

    common = [
      ~s{attr(:class, :any, default: nil, doc: "Additional classes appended to the generated component.")},
      "attr(:rest, :global, include: ~w(#{Enum.join(include, " ")}), doc: \"Additional HTML attributes, forwarded to the headless component.\")"
    ]

    Enum.join(prop_lines ++ common, "\n")
  end

  defp base_attr_names(entry) do
    entry.name
    |> FlintUI.Docs.attrs()
    |> Enum.map(&Atom.to_string(&1.name))
    |> Enum.reject(&(&1 in ["rest", "class"]))
    |> Enum.uniq()
  end

  defp prop_attr(prop) do
    values = "~w(#{Enum.join(prop.values, " ")})"

    "attr(:#{prop.name}, :string, values: #{values}, " <>
      "default: #{inspect(prop.default)}, doc: #{inspect(prop.doc)})"
  end

  defp slot_block(entry) do
    base = FlintUI.Docs.slots(entry.name)

    base
    |> Kernel.++(entry.slots)
    |> Enum.uniq_by(& &1.name)
    |> Enum.map_join("\n", &slot_decl/1)
  end

  defp slot_decl(slot) do
    opts = []
    opts = if slot.required, do: opts ++ [required: true], else: opts
    opts = if slot.doc, do: opts ++ [doc: slot.doc], else: opts

    case opts do
      [] -> "slot(:#{slot.name})"
      opts -> "slot(:#{slot.name}, #{Enum.map_join(opts, ", ", &opt/1)})"
    end
  end

  defp opt({key, value}), do: "#{key}: #{inspect(value)}"
end
