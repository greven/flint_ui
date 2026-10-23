defmodule FlintUIDocsWeb.Docs.Button do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :button

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @sizes [
    {"Extra Small", "xs"},
    {"Small", "sm"},
    {"Medium", "md"},
    {"Large", "lg"},
    {"Extra Large", "xl"}
  ]

  defp sizes, do: @sizes

  @impl true
  def controls do
    [
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :loading, type: :boolean, default: false, label: "Loading"},
      %{key: :variant, type: :select, default: "outline", label: "Variant"},
      %{key: :color, type: :select, default: "neutral", label: "Color"},
      %{key: :size, type: :select, default: "md", label: "Size"},
      %{key: :depth, type: :boolean, default: true, label: "Depth"}
    ]
  end

  @impl true
  def playground_controls, do: [:variant, :color, :size]

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
        Set `loading` while an action is in progress. The button is disabled and
        marked with `aria-busy="true"` and `data-loading` instead of a visual
        change, so you are free to render your own indicator.
        """,
        code: """
        <FlintUI.button loading>
          <FlintUI.loading class="hidden size-4 in-data-loading:inline-block" />
          Save
        </FlintUI.button>
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
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.button :for={variant <- ~w(solid soft subtle outline dashed ghost link)} variant={variant}>
            {variant}
          </.button>
        </div>
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
        id: :size,
        title: "Size",
        layer: :styled,
        covers: [:size],
        body: """
        The generated component adds a `size` attribute mapped onto the
        `data-size` hook the theme targets.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.button size="xs">Extra Small</.button>
          <.button size="sm">Small</.button>
          <.button size="md">Medium</.button>
          <.button size="lg">Large</.button>
          <.button size="xl">Extra Large</.button>
        </div>
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
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.button variant="solid" color="info">With highlight</.button>
          <.button variant="outline">With line</.button>
          <.button variant="solid" color="info" depth={false}>No highlight</.button>
          <.button variant="outline" depth={false}>No line</.button>
          <.button variant="subtle">Shadow only</.button>
        </div>
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
          "Use the `:leading` slot to place an icon before the content. A button sizes the `.icon` it wraps (following its own `size`) and mutes it to 70%, brightening on hover.",
        code: """
        <.button variant="solid">
          <:leading><.icon name="lucide-plus" /></:leading>
          New project
        </.button>
        """
      },
      %{
        id: :destructive_confirm,
        title: "Destructive with confirmation",
        description:
          "Delete actions are worth a second look. A data-confirm attribute makes the browser prompt before the button's phx-click event is sent, and phx-value-id passes the targeted record along to your handler.",
        code: """
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
      },
      %{
        id: :loading,
        title: "Loading with a spinner",
        description: "Reveal a FlintUI loading indicator via the button's data-loading state.",
        code: """
        <.button variant="solid" loading>
          <.loading class="hidden in-data-loading:inline-block" /> Save
        </.button>
        """
      },
      %{
        id: :link,
        title: "Link button",
        description:
          "Pass `href`, `navigate`, or `patch` to render an anchor. The `:trailing` slot places an icon after the content.",
        code: """
        <.button variant="outline" href="https://hexdocs.pm/phoenix_live_view" target="_blank" rel="noopener">
          View docs
          <:trailing><.icon name="lucide-arrow-up-right" /></:trailing>
        </.button>
        """
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
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.button
      variant={@props.variant}
      color={@props.color}
      size={@props.size}
      depth={@props.depth}
      disabled={@props.disabled}
      loading={@props.loading}
    >
      <.loading class="hidden in-data-loading:inline-block" /> Unbound
    </Components.button>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(
      ".button",
      [
        Snippet.attr("variant", props.variant, "subtle"),
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
  def render_usage(%{block: :disabled, layer: :styled} = assigns) do
    ~H"""
    <Components.button disabled>Delete</Components.button>
    """
  end

  def render_usage(%{block: :loading, layer: :styled} = assigns) do
    ~H"""
    <Components.button loading>
      <Components.loading class="hidden in-data-loading:inline-block" /> Save
    </Components.button>
    """
  end

  def render_usage(%{block: :links, layer: :styled} = assigns) do
    ~H"""
    <div class="flex flex-col items-start gap-3">
      <Components.button navigate="/settings">Settings</Components.button>
      <Components.button href="https://example.com" target="_blank" rel="noopener" disabled>
        Visit
      </Components.button>
    </div>
    """
  end

  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.button
        :for={variant <- ~w(solid soft subtle outline dashed ghost link)}
        variant={variant}
      >
        {variant}
      </Components.button>
    </div>
    """
  end

  def render_usage(%{block: :color} = assigns) do
    ~H"""
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
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.button :for={{label, size} <- sizes()} size={size}>{label}</Components.button>
    </div>
    """
  end

  def render_usage(%{block: :depth} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.button variant="solid" color="info">With highlight</Components.button>
      <Components.button variant="outline">With line</Components.button>
      <Components.button variant="solid" color="info" depth={false}>No highlight</Components.button>
      <Components.button variant="outline" depth={false}>No line</Components.button>
      <Components.button variant="subtle">Shadow only</Components.button>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :icon} = assigns) do
    ~H"""
    <Components.button variant="solid">
      <:leading><Components.icon name="lucide-plus" /></:leading>
      New project
    </Components.button>
    """
  end

  def render_block(%{block: :destructive_confirm} = assigns) do
    ~H"""
    <Components.button
      variant="solid"
      color="error"
      phx-click="delete_item"
      phx-value-id="67"
      data-confirm="Delete item?"
    >
      <Components.icon name="lucide-trash" /> Delete project
    </Components.button>
    """
  end

  def render_block(%{block: :loading} = assigns) do
    ~H"""
    <Components.button variant="solid" loading>
      <Components.loading class="hidden in-data-loading:inline-block" /> Save
    </Components.button>
    """
  end

  def render_block(%{block: :link} = assigns) do
    ~H"""
    <Components.button
      variant="outline"
      href={docs_url()}
      target="_blank"
      rel="noopener"
    >
      View docs
      <:trailing><Components.icon name="lucide-arrow-up-right" /></:trailing>
    </Components.button>
    """
  end

  @impl true
  def css do
    %{
      body: """
      The generated button maps its props onto data hooks and lets the theme do
      the rest. The public inputs are `--fl-button-color`,
      `--fl-button-color-foreground`, and `--fl-button-text`; borders, tinted
      surfaces, and focus all derive from them and the theme tokens.
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

  defp docs_url, do: "https://hexdocs.pm/phoenix_live_view"
end
