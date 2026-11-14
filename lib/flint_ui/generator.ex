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

  @doc """
  Returns the slots the generated wrapper exposes.

  The base slots and the entry's extra slots are merged by name. The wrapper
  always renders its own body into the base's `inner_block`, so that slot is
  optional when the entry also offers content attributes (such as `text` or
  `icon`). Otherwise the base contract is kept as-is.
  """
  def wrapper_slots(name) when is_atom(name) do
    case Styled.get(name) do
      nil ->
        FlintUI.Docs.slots(name)

      entry ->
        FlintUI.Docs.slots(name)
        |> Kernel.++(entry.slots)
        |> Enum.uniq_by(& &1.name)
        |> Enum.map(&optional_inner_block(&1, entry))
    end
  end

  @tokens_part "tokens.css"
  @base_part "base.css"
  @focus_part "focus.css"
  @aggregate "priv/static/flint.css"

  @doc "Absolute path to a theme part, relative to `priv/templates`."
  def part_path(relative) do
    Path.join([:code.priv_dir(:flint_ui), "templates", relative])
  end

  @doc """
  Absolute paths to every theme part, in assembly order.

  Tokens come first (they are unlayered), then the shared base rules, then each
  registered theme preset, then each registered component's stylesheet in
  registry order, and finally the shared focus layer.
  """
  def part_paths do
    theme_parts = Enum.map(Theme.themes(), & &1.css)
    component_parts = Enum.map(Styled.entries(), & &1.css)

    [@tokens_part, @base_part | theme_parts ++ component_parts ++ [@focus_part]]
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

  Colors are mapped per utility family, so `text-muted`, `bg-subtle`, and
  `border-subtle` resolve to the ink, surface, and border ladders respectively
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
      --text-color-highlighted: var(--fl-color-text-highlighted);
      --text-color-default: var(--fl-color-text);
      --text-color-toned: var(--fl-color-text-toned);
      --text-color-muted: var(--fl-color-text-muted);
      --text-color-dimmed: var(--fl-color-text-dimmed);
      --text-color-inverted: var(--fl-color-text-inverted);

      /* Chrome surfaces */
      --background-color-default: var(--fl-color-background);
      --background-color-surface: var(--fl-color-surface);
      --background-color-subtle: var(--fl-color-surface-subtle);
      --background-color-strong: var(--fl-color-surface-strong);
      --background-color-inverted: var(--fl-color-inverted);
      --background-color-foreground: var(--fl-color-text);
      --color-inverted: var(--fl-color-inverted);

      /* Chrome borders and focus */
      --border-color-default: var(--fl-color-border);
      --border-color-subtle: var(--fl-color-border-subtle);
      --border-color-strong: var(--fl-color-border-strong);
      --border-color-inverted: var(--fl-color-inverted);
      --divide-color-default: var(--fl-color-border);
      --divide-color-subtle: var(--fl-color-border-subtle);
      --divide-color-strong: var(--fl-color-border-strong);
      --ring-color-default: var(--fl-color-ring);
      --ring-color-subtle: var(--fl-color-border-subtle);
      --ring-color-strong: var(--fl-color-border-strong);
      --ring-color-inverted: var(--fl-color-inverted);
      --outline-color-default: var(--fl-color-border);
      --outline-color-subtle: var(--fl-color-border-subtle);
      --outline-color-strong: var(--fl-color-border-strong);
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
      --radius-full: var(--fl-radius-full);

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
    content_lines = Enum.map(entry.content_attrs, &content_attr/1)
    sentinels = color_sentinels(entry)
    prop_lines = Enum.map(entry.props, &prop_attr(&1, sentinels))

    common = [
      ~s{attr(:class, :any, default: nil, doc: "Additional classes appended to the generated component.")},
      rest_attr(attrs)
    ]

    Enum.join(content_lines ++ prop_lines ++ common, "\n")
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

    doc = "Additional HTML attributes, forwarded to the headless component."

    case include do
      [] ->
        "attr(:rest, :global, doc: #{inspect(doc)})"

      include ->
        "attr(:rest, :global, include: ~w(#{Enum.join(include, " ")}), doc: #{inspect(doc)})"
    end
  end

  defp rest_include(attrs) do
    case Enum.find(attrs, &(&1.name == :rest)) do
      nil -> nil
      attr -> Keyword.get(attr.opts, :include)
    end
  end

  defp content_attr(attr) do
    opts = [default: attr.default, doc: attr.doc]
    "attr(:#{attr.name}, #{inspect(attr.type)}, #{Enum.map_join(opts, ", ", &opt/1)})"
  end

  defp prop_attr(prop, sentinels) do
    cond do
      FlintUI.Styled.Prop.boolean?(prop) ->
        "attr(:#{prop.name}, :boolean, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(prop.doc)})"

      FlintUI.Styled.Prop.multi?(prop) ->
        "attr(:#{prop.name}, :any, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(prop.doc)})"

      prop.allow_custom ->
        roles = custom_roles(prop, sentinels)

        doc =
          if roles, do: "#{prop.doc} Semantic roles: #{Enum.join(roles, ", ")}.", else: prop.doc

        type = prop.type || :string

        "attr(:#{prop.name}, #{inspect(type)}, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(doc)})"

      true ->
        values = "~w(#{Enum.join(prop.values, " ")})"

        "attr(:#{prop.name}, :string, values: #{values}, " <>
          "default: #{inspect(prop.default)}, doc: #{inspect(prop.doc)})"
    end
  end

  # A free-form color prop documents its semantic roles in the wrapper's attr
  # doc; other free-form props, such as a numeric `size`, keep the author's doc.
  # A component that gives a color prop a sentinel value (the toggle's `inherit`)
  # filters that value out: it is not a role and never reaches the theme as a
  # `data-*` hook.
  defp custom_roles(prop, sentinels) do
    if prop.name == :color or Map.has_key?(sentinels, prop.name) do
      case reject_sentinel(prop.values, Map.get(sentinels, prop.name)) do
        [] -> nil
        roles -> roles
      end
    end
  end

  defp color_sentinels(%{active_color: %{prop: prop, inherit: inherit}}) when not is_nil(inherit),
    do: %{prop => inherit}

  defp color_sentinels(_entry), do: %{}

  defp reject_sentinel(values, nil), do: values
  defp reject_sentinel(values, sentinel), do: Enum.reject(values, &(&1 == sentinel))

  # A free-form `color` prop needs the wrapper to resolve roles vs raw values
  # before rendering. The call is emitted literally so the generated wrapper
  # keeps no dependency on the registry at runtime.
  defp color_block(entry) do
    [color_call(entry, :color, entry.color_vars, :data_color, nil), active_color_call(entry)]
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
  end

  defp active_color_call(%{active_color: %{prop: prop_name, vars: vars} = spec} = entry) do
    color_call(entry, prop_name, vars, :data_active_color, Map.get(spec, :inherit))
  end

  defp active_color_call(_entry), do: nil

  defp color_call(entry, prop_name, vars, data, inherit) do
    with %{} = prop <- FlintUI.Styled.Entry.prop(entry, prop_name),
         true <- prop.allow_custom,
         [_ | _] <- vars do
      roles = reject_sentinel(prop.values, inherit)

      # The default prop and hook need no options, so the common case keeps the
      # same call shape it always had.
      args =
        ["assigns", "~w(#{Enum.join(roles, " ")})", inspect(vars)] ++
          if prop_name == :color and data == :data_color do
            []
          else
            ["prop: #{inspect(prop_name)}", "data: #{inspect(data)}"]
          end

      last = length(args) - 1

      arguments =
        args
        |> Enum.with_index()
        |> Enum.map(fn {arg, index} -> "  " <> arg <> if(index == last, do: "", else: ",") end)

      call = ["FlintUI.Styled.Color.apply("] ++ arguments ++ [")"]

      body =
        case inherit do
          nil ->
            ["assigns ="] ++ indent(call, 1)

          sentinel ->
            [
              "assigns =",
              "  if assigns.#{prop_name} == #{inspect(sentinel)} do",
              "    FlintUI.Styled.Color.clear(assigns, #{inspect(data)})",
              "  else"
            ] ++
              indent(call, 2) ++
              [
                "  end"
              ]
        end

      body
      |> indent(1)
      |> Enum.join("\n")
    else
      _ -> nil
    end
  end

  defp indent(lines, levels) do
    prefix = String.duplicate("  ", levels)
    Enum.map(lines, &(prefix <> &1))
  end

  defp slot_block(entry) do
    entry.name
    |> wrapper_slots()
    |> Enum.map_join("\n", &slot_decl/1)
  end

  # A wrapper that renders content shortcuts (text/icon) supplies the base's
  # inner block itself, so the caller must be able to omit it. Other wrapper
  # inputs, such as an indicator offset, leave the slot required.
  defp optional_inner_block(%{name: :inner_block} = slot, %{content_attrs: content_attrs}) do
    if Enum.any?(content_attrs, & &1.fills_content) do
      Map.put(slot, :required, false)
    else
      slot
    end
  end

  defp optional_inner_block(slot, _entry), do: slot

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

    opts =
      if Map.get(slot, :validate_attrs) == false,
        do: opts ++ [validate_attrs: false],
        else: opts

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
