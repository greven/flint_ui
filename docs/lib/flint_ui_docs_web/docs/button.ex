defmodule FlintUIDocsWeb.Docs.Button do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :button

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, default: "outline", label: "Variant"},
      %{key: :color, type: :select, default: "neutral", label: "Color"},
      %{key: :size, type: :select, default: "md", label: "Size"},
      %{key: :depth, type: :boolean, default: true, label: "Depth"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :loading, type: :boolean, default: false, label: "Loading"}
    ]
  end

  @impl true
  def styled_overview do
    """
    Buttons are the primary action control. The generated component adds the
    themed variants and sizes while keeping the headless behavior: native
    buttons and links, loading state, and disabled semantics.
    """
  end

  @impl true
  def styled_features do
    [
      "Every variant composes with every semantic color role, or a raw color for a one-off accent.",
      "Sizes, depth, square icon buttons, and full-width layouts are all props.",
      "The leading and trailing slots place icons without extra markup."
    ]
  end

  @impl true
  def base_features do
    [
      "Renders a native button, or an anchor when href, navigate, or patch is set.",
      "The loading state is pending: aria-busy and aria-disabled without the native disabled attribute.",
      "Disabled links stay in the tab order and expose aria-disabled."
    ]
  end

  @impl true
  def usage do
    [
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
        covers: [:disabled],
        body: """
        Set `disabled` to prevent interaction. A disabled action button is removed
        from the tab order and ignores pointer and keyboard input.
        """,
        code: """
        <FlintUI.button disabled>Delete</FlintUI.button>
        """
      },
      %{
        id: :loading,
        title: "Loading",
        layer: :base,
        covers: [:loading],
        body: """
        Set `loading` while an action is in progress. The button becomes pending:
        it keeps `aria-busy="true"`, `aria-disabled="true"`, and `data-loading`,
        stays focusable, and keeps its accessible name. The bundled `flint.js`
        ignores activation while pending; always guard the handler too. The styled
        layer shows a progress cursor, suppresses hover feedback, and hides
        `[data-loading-indicator]` children such as `.loading` and `.loading_text`
        until the button is loading. For a form submit, LiveView already locks the
        form's buttons while the event is in flight; keep `loading` set for work
        that continues after the reply. Do not combine `loading` with
        `phx-disable-with`: during the request LiveView uses the native `disabled`
        attribute and replaces the button's content, so focus and the pending
        indicator are lost until the reply. Announce progress in a status region
        outside the button, because `aria-busy` can defer announcements inside it.
        Use `role="status"` (polite), not an assertive live region. A disabled
        button is a different state: it uses the native `disabled` attribute,
        leaves the focus order, and is dimmed by the styled layer.
        """,
        code: """
        <div class="flex items-center gap-3">
          <FlintUI.button loading>
            <FlintUI.loading class="hidden size-4 in-data-loading:inline-block" />
            Save
          </FlintUI.button>
          <span role="status" class="sr-only">Saving…</span>
        </div>
        """
      },
      %{
        id: :links,
        title: "Links",
        layer: :base,
        covers: [],
        body: """
        Pass `href`, `navigate`, or `patch` to render an anchor instead of a
        button. A disabled link keeps its place in the tab order and is marked
        with `aria-disabled`, so its state can still be discovered.
        """,
        code: """
        <div class="flex flex-col items-start gap-3">
          <FlintUI.button navigate="/settings">Settings</FlintUI.button>
          <FlintUI.button href="https://example.com" target="_blank" rel="noopener" disabled>Visit</FlintUI.button>
        </div>
        """
      },
      %{
        id: :type,
        title: "Button type",
        layer: :base,
        covers: [:type],
        body: """
        `type` sets the native button type. Use `submit` for a form's primary
        action, or `reset` to clear a form. A link ignores `type`.
        """,
        code: """
        <FlintUI.button type="submit">Save changes</FlintUI.button>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        covers: [:variant],
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets.
        """
      },
      %{
        id: :color,
        title: "Color",
        layer: :styled,
        preview_only: true,
        covers: [:color],
        body: """
        The generated component adds a `color` attribute mapped onto the
        `data-color` hook the theme targets. `color` and `variant` compose
        freely: every variant is available in every role. Each row below is a
        color role, each column a variant.
        """
      },
      %{
        id: :raw_color,
        title: "Raw colors",
        layer: :styled,
        covers: [],
        body: """
        `color` also accepts a raw CSS color for a one-off accent or a value
        that comes from data. The fill is used exactly; the label on a solid
        fill and the text-carrying variants derive readable colors from it. The
        best available contrast is used, so a mid-tone fill can still fall below
        AA when neither black nor white clears it. Raw colors are an escape
        hatch: they do not follow `data-theme` presets or the semantic role
        contract, and they emit inline custom properties. Prefer a role for
        app-wide theming, and pass `style` to override the derived values.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.button color="#1D72FE" variant="solid">Deploy</.button>
          <.button color="#1D72FE" variant="outline">Preview</.button>
          <.button color="#1D72FE" variant="ghost">Details</.button>
          <.button color="#FFE066">Warm</.button>
        </div>
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        covers: [:size],
        body: """
        The generated component adds a `size` attribute mapped onto the
        `data-size` hook the theme targets.
        """
      },
      %{
        id: :square,
        title: "Square",
        layer: :styled,
        covers: [:square],
        body: """
        Set `square` for an icon-only button. The box stays square at every
        `size`, and inline padding is dropped so the icon fills it. The button
        still needs an accessible name, so pass `aria-label` or
        `aria-labelledby` (the icon is not a label). Because the icon is the
        whole label there, it keeps the full-strength color instead of the
        muted tint an icon beside text gets. `square` has no effect on the
        `link` variant, which has no box of its own.
        """
      },
      %{
        id: :square_sizes,
        title: "Square sizes",
        layer: :styled,
        covers: [],
        body: """
        `size` scales the square box and the icon inside it, so an icon-only
        button lines up with a text button of the same size.
        """
      },
      %{
        id: :wide,
        title: "Full width",
        layer: :styled,
        covers: [:wide],
        body: """
        Set `wide` to fill the width of the surrounding container, which is
        useful for a form's primary action or a mobile call to action. It is
        layout, not emphasis: combine it with any `variant` and `size`. Avoid it
        inside a `<.group>`, whose children share the row.
        """
      },
      %{
        id: :inset,
        title: "Inset",
        layer: :styled,
        covers: [:inset],
        body: """
        Set `inset` to pull the control over the padding it keeps for its hit
        area, so its content lines up with surrounding content. It is most
        useful on `ghost` and `link` buttons, whose box is otherwise invisible;
        the hit area itself keeps its size. Square icon buttons inset by the
        leftover space around the icon. Since this is an outer margin, avoid
        combining it with `wide` or using it inside a `<.group>`.
        """
      },
      %{
        id: :depth,
        title: "Depth",
        layer: :styled,
        covers: [:depth],
        body: """
        `depth` is a boolean that controls the surface highlight: `solid` wears
        a top rim light that fades as it runs down the sides, `outline` a bottom
        inner line. The other variants have no depth treatment. Set
        `depth={false}` to remove the rim or inner line. Depth does not control
        shadows: solid, subtle, and outline always sit on
        `--fl-control-shadow`; set that variable to `0 0 #0000` to remove them.
        Pressing a button sinks it, fading the highlight as it nudges down.
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :icon,
        title: "With an icon",
        description:
          "Use the `:leading` slot to place an icon before the content. A button sizes the `.icon` it wraps (following its own `size`) and mutes it to 70%, brightening on hover. A `square` button has no label beside the icon, so its icon stays at full strength."
      },
      %{
        id: :destructive_confirm,
        title: "Destructive with confirmation",
        description:
          "Delete actions are worth a second look. A data-confirm attribute makes the browser prompt before the button's phx-click event is sent, and phx-value-id passes the targeted record along to your handler."
      },
      %{
        id: :loading,
        title: "Loading states",
        description:
          "Loading composes with every variant. A spinner and label work on any button; the dots variant of `.loading_text` lets the label itself carry the progress.
          Indicators marked `data-loading-indicator` are hidden until the button is loading, so no reveal classes are needed. A loading button is pending: it stays focusable, announces `aria-busy` and `aria-disabled`, and ignores activation.
          Announce the change outside the button with `role=\"status\"`."
      },
      %{
        id: :link,
        title: "Link button",
        description:
          "Pass `href`, `navigate`, or `patch` to render an anchor. The `:trailing` slot places an icon after the content."
      },
      %{
        id: :sound,
        title: "Interface sounds",
        description:
          "Add `data-sound` to play a synthesized cue on activation. The palette and the provider are covered in the Sounds guide; a button can also own a press and a release with `data-sound-press` / `data-sound-release`."
      },
      %{
        id: :base_form,
        title: "Form submit",
        layer: :base,
        description: "A native submit button inside a form.",
        code: """
        <form phx-submit="save">
          <FlintUI.button type="submit">Save changes</FlintUI.button>
        </form>
        """
      },
      %{
        id: :base_link,
        title: "Navigation link",
        layer: :base,
        description:
          "Use `navigate` or `patch` for LiveView navigation, or `href` for an external URL.",
        code: """
        <FlintUI.button navigate="/settings">Settings</FlintUI.button>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      A button renders a single `<button>` (or `<a>` when `href`, `navigate`, or
      `patch` is set). Its content is the `:inner_block` slot — normally the label,
      and the accessible name. Interaction state is exposed as `data-*` attributes
      so you can style it without extra classes.

      The generated component adds `:leading` and `:trailing` slots around the
      content; those are listed in the Styled tab's API reference, not here.
      """,
      nodes: [
        %{
          tag: "button",
          selector: ~s([data-element="button"]),
          hooks: ["data-disabled", "data-loading"],
          attributes: ["type", "aria-busy", "aria-disabled"],
          children: [
            %{
              tag: ":inner_block",
              note: "the button's content (label, icon, or both)",
              children: []
            }
          ]
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The button ships behavior, not appearance. Style it with `class` and target
      the data attributes it exposes for state.
      """,
      snippets: [
        %{
          title: "Disabled",
          code: """
          [data-element="button"][data-disabled] {
            opacity: var(--fl-disabled-opacity, 0.5);
            pointer-events: none;
          }
          """
        },
        %{
          title: "Loading",
          code: """
          /* Pending is not disabled: keep the control legible and focusable. */
          [data-element="button"][data-loading]:not([data-disabled]) {
            cursor: progress;
          }
          [data-element="button"][data-loading] .my-spinner {
            display: inline-block;
          }
          """
        },
        %{
          title: "Focus",
          code: """
          /* The base layer gives every component a focus ring:
           * outline: var(--fl-focus-ring-width) solid var(--fl-focus-ring-color);
           * outline-offset: var(--fl-focus-ring-offset);
           * Retint it per component by overriding the color token. */
          [data-element="button"] {
            --fl-focus-ring-color: var(--fl-color-primary);
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_main(assigns) do
    ~H"""
    <.preview
      :let={props}
      id={@id}
      name={:button}
      state={@state}
      controls={[:variant, :color, :size, :loading]}
      code={&main_code/1}
    >
      <Components.button
        variant={props.variant}
        color={props.color}
        size={props.size}
        depth={props.depth}
        disabled={props.disabled}
        loading={props.loading}
      >
        <Components.loading /> Unbound
      </Components.button>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".button",
      [
        Snippet.attr("variant", props.variant, "outline"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("depth", props.depth, true),
        Snippet.flag("disabled", props.disabled),
        Snippet.flag("loading", props.loading)
      ],
      "Button"
    )
  end

  @impl true
  def render_section(%{kind: :usage, block: :variant} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:variant)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button
          :for={variant <- ~w(solid soft subtle outline dashed ghost link)}
          variant={variant}
        >
          {variant}
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :color} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} preview_only>
      <div class="overflow-x-auto py-1">
        <div class="grid grid-cols-8 items-center gap-x-3 gap-y-6">
          <div></div>
          <span
            :for={variant <- ~w(solid soft subtle outline dashed ghost link)}
            class="text-center text-xs font-medium text-zinc-500"
          >
            {variant}
          </span>
          <div
            :for={color <- ~w(primary secondary neutral info success warning error)}
            class="contents"
          >
            <span class="text-xs font-medium text-zinc-500">{color}</span>
            <Components.button
              :for={variant <- ~w(solid soft subtle outline dashed ghost link)}
              variant={variant}
              color={color}
            >
              {String.capitalize(variant)}
            </Components.button>
          </div>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :raw_color} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:raw_color)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button color="#1D72FE" variant="solid">Deploy</Components.button>
        <Components.button color="#1D72FE" variant="outline">Preview</Components.button>
        <Components.button color="#1D72FE" variant="ghost">Details</Components.button>
        <Components.button color="#FFE066">Warm</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :size} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:size)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button :for={{label, size} <- sizes()} size={size}>{label}</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :square} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:square)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button square variant="ghost" aria-label="More options">
          <Components.icon name="lucide-ellipsis" />
        </Components.button>
        <Components.button square variant="dashed" aria-label="Add item">
          <Components.icon name="lucide-plus" />
        </Components.button>
        <Components.button square variant="outline" aria-label="Edit">
          <Components.icon name="lucide-pencil" />
        </Components.button>
        <Components.button square variant="solid" aria-label="Delete">
          <Components.icon name="lucide-trash" />
        </Components.button>
        <Components.button square variant="solid" color="info" aria-label="Download">
          <Components.icon name="lucide-download" />
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :square_sizes} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:square_sizes)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button
          :for={{label, size} <- sizes()}
          square
          size={size}
          aria-label={"Add item (#{label})"}
        >
          <Components.icon name="lucide-plus" />
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :wide} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:wide)}>
      <Components.button wide variant="solid">Continue</Components.button>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :inset} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:inset)}>
      <div class="flex items-center justify-between gap-4 rounded-lg border border-zinc-200 px-4 py-3 dark:border-zinc-700">
        <span class="text-sm font-medium">Post successfully created.</span>
        <div class="flex items-center gap-4">
          <Components.button variant="ghost" size="sm" square inset aria-label="Dismiss">
            <Components.icon name="lucide-x" />
          </Components.button>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :depth} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:depth)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button variant="solid" color="info">With highlight</Components.button>
        <Components.button variant="outline">With line</Components.button>
        <Components.button variant="solid" color="info" depth={false}>
          No highlight
        </Components.button>
        <Components.button variant="outline" depth={false}>No line</Components.button>
        <Components.button variant="subtle">Shadow only</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :icon} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:icon)}>
      <Components.button variant="solid">
        <:leading><Components.icon name="lucide-plus" /></:leading>
        New project
      </Components.button>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :destructive_confirm} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:destructive_confirm)}>
      <Components.button
        variant="solid"
        color="error"
        phx-click="delete_item"
        phx-value-id="67"
        data-confirm="Delete item?"
      >
        <Components.icon name="lucide-trash" /> Delete project
      </Components.button>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :loading} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:loading)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button variant="solid" color="info" loading square>
          <Components.loading />
        </Components.button>
        <Components.button variant="solid" loading>
          <Components.loading variant="ring-dash" /> Save
        </Components.button>
        <Components.button variant="outline" loading>
          <Components.loading_text text="Loading" variant="dots" />
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :sound} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:sound)}>
      <div class="flex flex-wrap gap-2">
        <Components.button variant="outline" data-sound="tap">Tap</Components.button>
        <Components.button variant="outline" data-sound="success">Success</Components.button>
        <Components.button variant="outline" data-sound="error">Error</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :link} = assigns) do
    ~H"""
    <.preview id={@id} name={:button} state={@state} code={code(:link)}>
      <Components.button
        variant="outline"
        href={docs_url()}
        target="_blank"
        rel="noopener"
      >
        View docs
        <:trailing><Components.icon name="lucide-arrow-up-right" /></:trailing>
      </Components.button>
    </.preview>
    """
  end

  defp code(:raw_color) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button color="#1D72FE" variant="solid">Deploy</.button>
      <.button color="#1D72FE" variant="outline">Preview</.button>
      <.button color="#1D72FE" variant="ghost">Details</.button>
      <.button color="#FFE066">Warm</.button>
    </div>
    """
  end

  defp code(:variant) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button :for={variant <- ~w(solid soft subtle outline dashed ghost link)} variant={variant}>
        {variant}
      </.button>
    </div>
    """
  end

  defp code(:size) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button size="xs">Extra Small</.button>
      <.button size="sm">Small</.button>
      <.button size="md">Medium</.button>
      <.button size="lg">Large</.button>
      <.button size="xl">Extra Large</.button>
    </div>
    """
  end

  defp code(:square) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button square variant="ghost" aria-label="More options">
        <.icon name="lucide-ellipsis" />
      </.button>
      <.button square variant="dashed" aria-label="Add item">
        <.icon name="lucide-plus" />
      </.button>
      <.button square variant="outline" aria-label="Edit">
        <.icon name="lucide-pencil" />
      </.button>
      <.button square variant="solid" aria-label="Delete">
        <.icon name="lucide-trash" />
      </.button>
      <.button square variant="solid" color="info" aria-label="Download">
        <.icon name="lucide-download" />
      </.button>
    </div>
    """
  end

  defp code(:square_sizes) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button square size="xs" aria-label="Add item (Extra Small)"><.icon name="lucide-plus" /></.button>
      <.button square size="sm" aria-label="Add item (Small)"><.icon name="lucide-plus" /></.button>
      <.button square size="md" aria-label="Add item (Medium)"><.icon name="lucide-plus" /></.button>
      <.button square size="lg" aria-label="Add item (Large)"><.icon name="lucide-plus" /></.button>
      <.button square size="xl" aria-label="Add item (Extra Large)"><.icon name="lucide-plus" /></.button>
    </div>
    """
  end

  defp code(:wide) do
    ~S"""
    <.button wide variant="solid">Continue</.button>
    """
  end

  defp code(:inset) do
    ~S"""
    <div class="flex items-center justify-between gap-4 rounded-lg border border-zinc-200 px-4 py-3 dark:border-zinc-700">
      <span class="text-sm font-medium">Post successfully created.</span>
      <div class="flex items-center gap-4">
        <.button variant="ghost" size="sm" square inset aria-label="Dismiss">
          <.icon name="lucide-x" />
        </.button>
      </div>
    </div>
    """
  end

  defp code(:depth) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button variant="solid" color="info">With highlight</.button>
      <.button variant="outline">With line</.button>
      <.button variant="solid" color="info" depth={false}>No highlight</.button>
      <.button variant="outline" depth={false}>No line</.button>
      <.button variant="subtle">Shadow only</.button>
    </div>
    """
  end

  defp code(:icon) do
    ~S"""
    <.button variant="solid">
      <:leading><.icon name="lucide-plus" /></:leading>
      New project
    </.button>
    """
  end

  defp code(:destructive_confirm) do
    ~S"""
    <.button
      variant="solid"
      color="error"
      phx-click="delete_item"
      phx-value-id="67"
      data-confirm="Delete item?"
    >
      <.icon name="lucide-trash" /> Delete project
    </.button>
    """
  end

  defp code(:loading) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.button variant="solid" color="info" loading square>
        <.loading />
      </.button>
      <.button variant="solid" loading>
        <.loading variant="ring-dash" /> Save
      </.button>
      <.button variant="outline" loading>
        <.loading_text text="Loading" variant="dots" />
      </.button>
    </div>
    """
  end

  defp code(:sound) do
    ~S"""
    <div class="flex flex-wrap gap-2">
      <.button variant="outline" data-sound="tap">Tap</.button>
      <.button variant="outline" data-sound="success">Success</.button>
      <.button variant="outline" data-sound="error">Error</.button>
    </div>
    """
  end

  defp code(:link) do
    ~S"""
    <.button
      variant="outline"
      href="https://hexdocs.pm/phoenix_live_view"
      target="_blank"
      rel="noopener"
    >
      View docs
      <:trailing><.icon name="lucide-arrow-up-right" /></:trailing>
    </.button>
    """
  end

  @impl true
  def css do
    %{
      body: """
      The generated button maps its props onto data hooks and lets the theme do
      the rest. The public inputs are `--fl-button-color`,
      `--fl-button-color-foreground`, `--fl-button-text`, and
      `--fl-button-soft-text`; borders, tinted surfaces, and focus all derive
      from them and the theme tokens. Solid buttons mix the fill with black by
      `--fl-border-strength-solid` (12% by default) for the border, so retinting
      the fill retints the edge too. Ghost and link read
      `--fl-button-text`, the role's regular `-text` token. Tinted and bordered
      variants read `--fl-button-soft-text`, the role's `-soft-foreground`
      label, so they read lighter in dark; solid uses
      `--fl-button-color-foreground`. A raw `color` value sets all four inputs
      inline from that one color, so an explicit `style` override still wins.
      """,
      snippets: [
        %{
          title: "Retint one button",
          body: "Override the public color inputs on the instance.",
          code: """
          .danger-action {
            --fl-button-color: var(--fl-color-error);
            --fl-button-color-foreground: var(--fl-color-error-foreground);
            --fl-button-text: var(--fl-color-error-text);
            --fl-button-soft-text: var(--fl-color-error-soft-foreground);
          }
          """
        },
        %{
          title: "Flatten depth",
          body: "Disable every control's rim, inner line, and press nudge. Shadows stay on.",
          code: """
          [data-theme="flat"] {
            --fl-control-depth: 0;
            --fl-control-press: none;
          }
          """
        },
        %{
          title: "Remove shadows",
          body: "Solid, subtle, and outline buttons share one control shadow.",
          code: """
          [data-theme="flat"] {
            --fl-control-shadow: 0 0 #0000;
          }
          """
        }
      ]
    }
  end

  defp sizes,
    do: [
      {"Extra Small", "xs"},
      {"Small", "sm"},
      {"Medium", "md"},
      {"Large", "lg"},
      {"Extra Large", "xl"}
    ]

  defp docs_url, do: "https://hexdocs.pm/phoenix_live_view"
end
