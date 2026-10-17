defmodule FlintUIDocsWeb.ComponentDocs.Toggle do
  @moduledoc false

  use FlintUIDocsWeb.ComponentDocs.Page, component: :toggle

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.ComponentDocs.Snippet

  @impl true
  def controls do
    [
      %{key: :pressed, type: :boolean, default: false, label: "Pressed"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :variant, type: :select, default: "solid", label: "Variant"},
      %{key: :color, type: :select, default: "neutral", label: "Color"},
      %{key: :size, type: :select, default: "md", label: "Size"}
    ]
  end

  @impl true
  def structure do
    """
    <.toggle>Bold</.toggle>

    <.toggle pressed>
      <.icon name="lucide-bold" class="size-4" /> Bold
    </.toggle>

    <.toggle on_click={JS.push("toggle-italic")}>
      <.icon name="lucide-italic" class="size-4" /> Italic
    </.toggle>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :pressed,
        title: "Pressed state",
        layer: :base,
        body: """
        The `pressed` attribute is the server-side source of truth. On click the
        button optimistically toggles its own `aria-pressed` and `data-state`, so
        the change is reflected immediately and reconciles with `pressed` on the
        next render.
        """,
        code: """
        <.toggle pressed>Bold</.toggle>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.toggle :for={variant <- ~w(solid subtle outline ghost dashed)} variant={variant} pressed>
            {variant}
          </.toggle>
        </div>
        """
      },
      %{
        id: :color,
        title: "Color",
        layer: :styled,
        body: """
        The generated component adds a `color` attribute mapped onto the
        `data-color` hook the theme targets. `color` and `variant` compose
        freely: the same palette drives every variant.
        """,
        code: """
        <div class="flex flex-col gap-3">
          <div class="flex flex-wrap items-center gap-3">
            <.toggle
              :for={color <- ~w(primary secondary success info warning error neutral)}
              color={color}
              pressed
            >
              {color}
            </.toggle>
          </div>
          <div class="flex flex-wrap items-center gap-3">
            <.toggle
              :for={color <- ~w(primary secondary success info warning error neutral)}
              variant="outline"
              color={color}
              pressed
            >
              {color}
            </.toggle>
          </div>
        </div>
        """
      },
      %{
        id: :size,
        title: "Size",
        layer: :styled,
        body: """
        The generated component adds a `size` attribute mapped onto the
        `data-size` hook the theme targets.
        """,
        code: """
        <div class="flex flex-wrap items-center gap-3">
          <.toggle :for={size <- ~w(xs sm md lg xl)} size={size} pressed>{size}</.toggle>
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
        title: "Icon and label",
        description:
          "Pair an icon with a text label. The toggle sizes and tints the `.icon` it wraps.",
        code: """
        <.toggle variant="solid">
          <.icon name="lucide-bold" /> Bold
        </.toggle>
        """
      },
      %{
        id: :icon_only,
        title: "Icon only",
        description: "An icon-only toggle needs an accessible name.",
        code: """
        <.toggle variant="solid" aria-label="Bold">
          <.icon name="lucide-bold" />
        </.toggle>
        """
      },
      %{
        id: :group,
        title: "Toolbar group",
        description: "Several toggles arranged as a formatting toolbar with a group.",
        code: """
        <.group variant="framed">
          <.toggle variant="solid" aria-label="Bold" pressed>
            <.icon name="lucide-bold" />
          </.toggle>
          <.toggle variant="solid" aria-label="Italic">
            <.icon name="lucide-italic" />
          </.toggle>
          <.toggle variant="solid" aria-label="Underline">
            <.icon name="lucide-underline" />
          </.toggle>
        </.group>
        """
      },
      %{
        id: :on_click,
        title: "Reacting to clicks",
        description:
          "Pass `on_click` a `Phoenix.LiveView.JS` command or a server event name to run when the button is clicked. The state flip still happens regardless.",
        preview: false,
        code: """
        <.toggle variant="solid" on_click={JS.push("toggle-bold")}>
          <.icon name="lucide-bold" /> Bold
        </.toggle>
        """
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The toggle ships behavior, not appearance. Style it with `class` and target
      its state through `data-state` (`"on"` / `"off"`).
      """,
      snippets: [
        %{
          title: "Pressed",
          code: """
          [data-element="toggle"][data-state="on"] {
            background: var(--fl-color-primary);
            color: var(--fl-color-primary-foreground);
          }
          """
        },
        %{
          title: "Disabled",
          code: """
          [data-element="toggle"][data-disabled] {
            opacity: 0.5;
            pointer-events: none;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.toggle
      variant={@props.variant}
      color={@props.color}
      size={@props.size}
      pressed={@props.pressed}
      disabled={@props.disabled}
    >
      <.icon name="lucide-bold" /> Bold
    </Components.toggle>
    """
  end

  def render_playground(assigns) do
    ~H"""
    <.toggle pressed={@props.pressed} disabled={@props.disabled}>
      <.icon name="lucide-bold" class="size-4" /> Bold
    </.toggle>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(
      ".toggle",
      [
        Snippet.attr("variant", props.variant, "solid"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.flag("pressed", props.pressed),
        Snippet.flag("disabled", props.disabled)
      ],
      ~s(<.icon name="lucide-bold" /> Bold)
    )
  end

  def render_code(%{props: props}) do
    Snippet.tag(
      ".toggle",
      [Snippet.flag("pressed", props.pressed), Snippet.flag("disabled", props.disabled)],
      ~s(<.icon name="lucide-bold" class="size-4" /> Bold)
    )
  end

  @impl true
  def render_usage(%{block: :pressed} = assigns) do
    ~H"""
    <.toggle pressed>Bold</.toggle>
    """
  end

  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.toggle
        :for={variant <- ~w(solid subtle outline ghost dashed)}
        variant={variant}
        pressed
      >
        {variant}
      </Components.toggle>
    </div>
    """
  end

  def render_usage(%{block: :color} = assigns) do
    ~H"""
    <div class="flex flex-col gap-3">
      <div class="flex flex-wrap items-center gap-3">
        <Components.toggle
          :for={color <- ~w(primary secondary success info warning error neutral)}
          color={color}
          pressed
        >
          {color}
        </Components.toggle>
      </div>
      <div class="flex flex-wrap items-center gap-3">
        <Components.toggle
          :for={color <- ~w(primary secondary success info warning error neutral)}
          variant="outline"
          color={color}
          pressed
        >
          {color}
        </Components.toggle>
      </div>
    </div>
    """
  end

  def render_usage(%{block: :size} = assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.toggle :for={size <- ~w(xs sm md lg xl)} size={size} pressed>
        {size}
      </Components.toggle>
    </div>
    """
  end

  @impl true
  def render_block(%{block: :icon} = assigns) do
    ~H"""
    <Components.toggle variant="solid">
      <Components.icon name="lucide-bold" /> Bold
    </Components.toggle>
    """
  end

  def render_block(%{block: :icon_only} = assigns) do
    ~H"""
    <Components.toggle variant="solid" aria-label="Bold">
      <Components.icon name="lucide-bold" />
    </Components.toggle>
    """
  end

  def render_block(%{block: :group} = assigns) do
    ~H"""
    <Components.group variant="framed">
      <Components.toggle variant="solid" aria-label="Bold" pressed>
        <Components.icon name="lucide-bold" />
      </Components.toggle>
      <Components.toggle variant="solid" aria-label="Italic">
        <Components.icon name="lucide-italic" />
      </Components.toggle>
      <Components.toggle variant="solid" aria-label="Underline">
        <Components.icon name="lucide-underline" />
      </Components.toggle>
    </Components.group>
    """
  end

  def render_block(%{block: :on_click}), do: nil
end
