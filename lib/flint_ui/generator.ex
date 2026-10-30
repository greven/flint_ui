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

  @doc """
  The `@theme` mapping that exposes FlintUI tokens as Tailwind utilities.

  Colors are mapped per utility family, so `text-muted`, `bg-muted`, and
  `border-muted` resolve to the text, surface, and border tokens respectively
  instead of sharing one value. This needs Tailwind 4.1 or newer.
  """
  def tailwind_bridge_source do
    roles =
      Enum.map_join(@color_roles, "\n", fn role ->
        """
            --color-#{role}: var(--fl-color-#{role});
            --text-color-#{role}: var(--fl-color-#{role}-text);
            --text-color-#{role}-content: var(--fl-color-#{role}-content);
            --background-color-#{role}: var(--fl-color-#{role});
            --border-color-#{role}: var(--fl-color-#{role});
            --ring-color-#{role}: var(--fl-color-#{role});\
        """
      end)

    scales =
      Enum.map_join(@color_roles, "\n", fn role ->
        Enum.map_join(@color_shades, "\n", fn shade ->
          "    --color-#{role}-#{shade}: var(--fl-color-#{role}-#{shade});"
        end)
      end)

    """
    @theme inline {
      /* Chrome text */
      --text-color-default: var(--fl-color-text);
      --text-color-soft: var(--fl-color-text-soft);
      --text-color-muted: var(--fl-color-text-muted);
      --text-color-dimmed: var(--fl-color-text-dimmed);
      --text-color-inverted: var(--fl-color-text-inverted);

      /* Chrome surfaces */
      --background-color-default: var(--fl-color-background);
      --background-color-surface: var(--fl-color-surface);
      --background-color-surface-soft: var(--fl-color-surface-soft);
      --background-color-control: var(--fl-color-control);
      --background-color-muted: var(--fl-color-muted);
      --background-color-inverted: var(--fl-color-inverted);
      --background-color-foreground: var(--fl-color-text);
      --color-inverted: var(--fl-color-inverted);

      /* Chrome borders and focus */
      --border-color-default: var(--fl-color-border);
      --border-color-muted: var(--fl-color-border-muted);
      --border-color-accented: var(--fl-color-border-accented);
      --border-color-inverted: var(--fl-color-inverted);
      --divide-color-default: var(--fl-color-border);
      --divide-color-muted: var(--fl-color-border-muted);
      --divide-color-accented: var(--fl-color-border-accented);
      --ring-color-default: var(--fl-color-ring);
      --ring-color-muted: var(--fl-color-border-muted);
      --ring-color-accented: var(--fl-color-border-accented);
      --ring-color-inverted: var(--fl-color-inverted);
      --outline-color-default: var(--fl-color-border);
      --outline-color-muted: var(--fl-color-border-muted);
      --outline-color-accented: var(--fl-color-border-accented);
      --outline-color-inverted: var(--fl-color-inverted);

      /* Semantic roles: fill, role text, and the label on the fill */
    #{roles}

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
