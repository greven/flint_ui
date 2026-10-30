defmodule FlintUI.Generator do
  @moduledoc """
  Renders styled component wrapper source from the registry.

  The generated wrappers are thin: they declare the extra presentational attributes,
  map them onto the `data-*` hooks the theme targets, and delegate behavior to
  the headless base component. No styling is baked in; that lives in `flint.css`.
  """

  alias FlintUI.Styled
  alias FlintUI.Theme

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
        slots: slot_block(entry),
        color: color_block(entry)
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
  registered theme preset, then each registered component's stylesheet in
  registry order.
  """
  def part_paths do
    theme_parts = Enum.map(Theme.themes(), & &1.css)
    component_parts = Enum.map(Styled.entries(), & &1.css)

    [@tokens_part, @base_part | theme_parts ++ component_parts]
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

  @color_roles ~w(primary secondary neutral success info warning error)
  @color_shades ~w(50 100 200 300 400 500 600 700 800 900 950)

  @doc "The `@theme` mapping that exposes FlintUI tokens as Tailwind utilities."
  def tailwind_bridge_source do
    scales =
      Enum.map_join(@color_roles, "\n", fn role ->
        Enum.map_join(@color_shades, "\n", fn shade ->
          "    --color-#{role}-#{shade}: var(--fl-color-#{role}-#{shade});"
        end)
      end)

    """
    @theme inline {
      --color-background: var(--fl-color-background);
      --color-foreground: var(--fl-color-foreground);
      --color-foreground-soft: var(--fl-color-foreground-soft);
      --color-surface: var(--fl-color-surface);
      --color-surface-soft: var(--fl-color-surface-soft);
      --color-surface-muted: var(--fl-color-surface-muted);
      --color-surface-foreground: var(--fl-color-surface-foreground);
      --color-control: var(--fl-color-control);
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
      --color-elevated: var(--fl-color-elevated);
      --color-dimmed: var(--fl-color-dimmed);
      --color-disabled: var(--fl-color-disabled);
      --color-disabled-foreground: var(--fl-color-disabled-foreground);
      --color-disabled-border: var(--fl-color-disabled-border);
      --color-inverted: var(--fl-color-inverted);
      --color-inverted-foreground: var(--fl-color-inverted-foreground);
      --color-border: var(--fl-color-border);
      --color-border-muted: var(--fl-color-border-muted);
      --color-border-accented: var(--fl-color-border-accented);
      --color-input: var(--fl-color-input);
      --color-ring: var(--fl-color-ring);

      /* Semantic color scales */
    #{scales}

      --radius: var(--fl-radius);
      --radius-xs: var(--fl-radius-xs);
      --radius-sm: var(--fl-radius-sm);
      --radius-md: var(--fl-radius-md);
      --radius-lg: var(--fl-radius-lg);
      --radius-xl: var(--fl-radius-xl);
      --radius-2xl: var(--fl-radius-2xl);

      --font-sans: var(--fl-font-sans);
      --font-mono: var(--fl-font-mono);

      --spacing: var(--fl-spacing);
      --spacing-xs: var(--fl-spacing-xs);
      --spacing-sm: var(--fl-spacing-sm);
      --spacing-md: var(--fl-spacing-md);
      --spacing-lg: var(--fl-spacing-lg);
      --spacing-xl: var(--fl-spacing-xl);
      --spacing-2xl: var(--fl-spacing-2xl);
      --spacing-3xl: var(--fl-spacing-3xl);

      --text-xs: var(--fl-font-size-xs);
      --text-xs--line-height: var(--fl-line-height-xs);
      --text-sm: var(--fl-font-size-sm);
      --text-sm--line-height: var(--fl-line-height-sm);
      --text-base: var(--fl-font-size-md);
      --text-base--line-height: var(--fl-line-height-md);
      --text-lg: var(--fl-font-size-lg);
      --text-lg--line-height: var(--fl-line-height-lg);
      --text-xl: var(--fl-font-size-xl);
      --text-xl--line-height: var(--fl-line-height-xl);

      --font-weight-normal: var(--fl-font-weight-normal);
      --font-weight-medium: var(--fl-font-weight-medium);
      --font-weight-semibold: var(--fl-font-weight-semibold);
      --font-weight-bold: var(--fl-font-weight-bold);

      --shadow-base: var(--fl-shadow-base);
      --shadow-2xs: var(--fl-shadow-2xs);
      --shadow-xs: var(--fl-shadow-xs);
      --shadow-sm: var(--fl-shadow-sm);
      --shadow-md: var(--fl-shadow-md);
      --shadow-lg: var(--fl-shadow-lg);
      --shadow-xl: var(--fl-shadow-xl);

      --ease-out: var(--fl-ease-out);
      --ease-in-out: var(--fl-ease-in-out);
    }
    """
  end

  defp template_path(file) do
    Path.join([:code.priv_dir(:flint_ui), "templates", "styled", file])
  end

  defp attr_block(entry) do
    attrs = FlintUI.Docs.attrs(entry.name)
    prop_lines = Enum.map(entry.props, &prop_attr/1)

    common = [
      ~s{attr(:class, :any, default: nil, doc: "Additional classes appended to the generated component.")},
      rest_attr(attrs)
    ]

    Enum.join(prop_lines ++ common, "\n")
  end

  # Whitelist the base's declared attributes, plus any attributes the base
  # itself whitelists on its own `rest` (e.g. the button's link attributes), so
  # the wrapper forwards the same contract to the headless component.
  defp rest_attr(attrs) do
    include =
      attrs
      |> Enum.map(&Atom.to_string(&1.name))
      |> Enum.reject(&(&1 in ["rest", "class"]))
      |> Kernel.++(rest_include(attrs) || [])
      |> Enum.uniq()

    "attr(:rest, :global, include: ~w(#{Enum.join(include, " ")}), doc: \"Additional HTML attributes, forwarded to the headless component.\")"
  end

  defp rest_include(attrs) do
    case Enum.find(attrs, &(&1.name == :rest)) do
      nil -> nil
      attr -> Keyword.get(attr.opts, :include)
    end
  end

  defp prop_attr(prop) do
    cond do
      FlintUI.Styled.Prop.boolean?(prop) ->
        "attr(:#{prop.name}, :boolean, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(prop.doc)})"

      prop.allow_custom ->
        doc = "#{prop.doc} Semantic roles: #{Enum.join(prop.values, ", ")}."

        "attr(:#{prop.name}, :string, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(doc)})"

      true ->
        values = "~w(#{Enum.join(prop.values, " ")})"

        "attr(:#{prop.name}, :string, values: #{values}, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(prop.doc)})"
    end
  end

  # A free-form `color` prop needs the wrapper to resolve roles vs raw values
  # before rendering. The call is emitted literally so the generated wrapper
  # keeps no dependency on the registry at runtime.
  defp color_block(entry) do
    with %{allow_custom: true} = prop <- FlintUI.Styled.Entry.prop(entry, :color),
         [_ | _] = vars <- entry.color_vars do
      """
        assigns =
          FlintUI.Styled.Color.apply(
            assigns,
            ~w(#{Enum.join(prop.values, " ")}),
            #{inspect(vars)}
          )
      """
    else
      _ -> ""
    end
  end

  defp slot_block(entry) do
    base = FlintUI.Docs.slots(entry.name)

    base
    |> Kernel.++(entry.slots)
    |> Enum.uniq_by(& &1.name)
    |> Enum.map_join("\n", &slot_decl/1)
  end

  defp slot_decl(slot) do
    head = slot_head(slot)
    attrs = Map.get(slot, :attrs, [])

    case attrs do
      [] ->
        head

      attrs ->
        nested = Enum.map_join(attrs, "\n", &("  " <> attr_decl(&1)))
        head <> " do\n" <> nested <> "\nend"
    end
  end

  defp slot_head(slot) do
    opts = []
    opts = if slot.required, do: opts ++ [required: true], else: opts
    opts = if slot.doc, do: opts ++ [doc: slot.doc], else: opts

    case opts do
      [] -> "slot(:#{slot.name})"
      opts -> "slot(:#{slot.name}, #{Enum.map_join(opts, ", ", &opt/1)})"
    end
  end

  defp attr_decl(attr) do
    opts = Map.get(attr, :opts) || []
    opts = if attr.required, do: opts ++ [required: true], else: opts
    opts = if attr.doc, do: opts ++ [doc: attr.doc], else: opts

    case opts do
      [] -> "attr(:#{attr.name}, #{inspect(attr.type)})"
      opts -> "attr(:#{attr.name}, #{inspect(attr.type)}, #{Enum.map_join(opts, ", ", &opt/1)})"
    end
  end

  defp opt({key, value}), do: "#{key}: #{inspect(value)}"
end
