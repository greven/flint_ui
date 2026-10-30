defmodule FlintUIDocsWeb.Docs.Toggle do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :toggle

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

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
    <FlintUI.toggle>Bold</FlintUI.toggle>

    <FlintUI.toggle pressed>
      <FlintUI.icon name="lucide-bold" class="size-4" /> Bold
    </FlintUI.toggle>

    <FlintUI.toggle on_click={JS.push("toggle-italic")}>
      <FlintUI.icon name="lucide-italic" class="size-4" /> Italic
    </FlintUI.toggle>
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
        covers: [:pressed],
        body: """
        The `pressed` attribute is the server-side source of truth. On click the
        button optimistically toggles its own `aria-pressed` and `data-state`, so
        the change is reflected immediately and reconciles with `pressed` on the
        next render.
        """,
        code: """
        <FlintUI.toggle pressed>Bold</FlintUI.toggle>
        """
      },
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
        covers: [:disabled],
        body: """
        Set `disabled` to prevent interaction. The native button is disabled and
        the root is marked with `data-disabled` for styling.
        """,
        code: """
        <FlintUI.toggle disabled>Bold</FlintUI.toggle>
        """
      },
      %{
        id: :type,
        title: "Button type",
        layer: :base,
        covers: [:type],
        body: """
        `type` sets the native button type. Use `submit` when the toggle is part
        of a form submission; the default is `button`.
        """,
        code: """
        <FlintUI.toggle type="submit" pressed>Bold</FlintUI.toggle>
        """
      },
      %{
        id: :on_click,
        title: "Reacting to clicks",
        layer: :base,
        covers: [:on_click],
        body: """
        Pass `on_click` a `Phoenix.LiveView.JS` command or a server event name.
        The client still flips `aria-pressed` and `data-state` immediately, then
        the server reconciles on the next render.
        """,
        code: """
        <FlintUI.toggle on_click={JS.push("toggle-bold")}>Bold</FlintUI.toggle>
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
        covers: [:color],
        body: """
        The generated component adds a `color` attribute mapped onto the
        `data-color` hook the theme targets. `color` and `variant` compose
        freely: the same palette drives every variant. It also accepts a raw CSS
        color such as `#1D72FE`; the fill is exact and the label is derived for
        contrast. Raw colors are a per-instance escape hatch, not a theme
        contract.
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
          "Pair an icon with a text label. The toggle sizes and tints the `.icon` it wraps."
      },
      %{
        id: :icon_only,
        title: "Icon only",
        description: "An icon-only toggle needs an accessible name."
      },
      %{
        id: :group,
        title: "Formatting group",
        description: "Several toggles arranged as a formatting group."
      },
      %{
        id: :base_icon_only,
        title: "Icon-only toggle",
        layer: :base,
        description: "An icon-only toggle needs an accessible name.",
        code: """
        <FlintUI.toggle aria-label="Bold">
          <FlintUI.icon name="lucide-bold" class="size-4" />
        </FlintUI.toggle>
        """
      },
      %{
        id: :base_preference,
        title: "Preference toggle",
        layer: :base,
        description: "The pressed state is the server-side source of truth.",
        code: """
        <FlintUI.toggle pressed>Email notifications</FlintUI.toggle>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The toggle renders a native `<button>` with `aria-pressed` and a
      `data-state` hook. The inner block is the button's content and its
      accessible name.
      """,
      nodes: [
        %{
          tag: "button",
          selector: ~s([data-element="toggle"][data-part="root"]),
          hooks: ["type", "aria-pressed", "data-state", "data-disabled", "disabled", "phx-click"],
          attributes: ["class"],
          children: []
        }
      ]
    }
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
            color: var(--fl-color-primary-content);
          }
          """
        },
        %{
          title: "Disabled",
          code: """
          [data-element="toggle"][data-disabled] {
            opacity: var(--fl-disabled-opacity, 0.5);
            pointer-events: none;
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
      name={:toggle}
      state={@state}
      controls={[:pressed, :disabled, :variant, :color, :size]}
      code={&main_code/1}
    >
      <Components.toggle
        variant={props.variant}
        color={props.color}
        size={props.size}
        pressed={props.pressed}
        disabled={props.disabled}
      >
        <.icon name="lucide-bold" /> Bold
      </Components.toggle>
    </.preview>
    """
  end

  defp main_code(props) do
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

  @impl true
  def render_section(%{kind: :usage, block: :variant} = assigns) do
    ~H"""
    <.preview id={@id} name={:toggle} state={@state} code={code(:variant)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.toggle
          :for={variant <- ~w(solid subtle outline ghost dashed)}
          variant={variant}
          pressed
        >
          {variant}
        </Components.toggle>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :color} = assigns) do
    ~H"""
    <.preview id={@id} name={:toggle} state={@state} code={code(:color)}>
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
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :size} = assigns) do
    ~H"""
    <.preview id={@id} name={:toggle} state={@state} code={code(:size)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.toggle :for={size <- ~w(xs sm md lg xl)} size={size} pressed>
          {size}
        </Components.toggle>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :icon} = assigns) do
    ~H"""
    <.preview id={@id} name={:toggle} state={@state} code={code(:icon)}>
      <Components.toggle variant="solid">
        <Components.icon name="lucide-bold" /> Bold
      </Components.toggle>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :icon_only} = assigns) do
    ~H"""
    <.preview id={@id} name={:toggle} state={@state} code={code(:icon_only)}>
      <Components.toggle variant="solid" aria-label="Bold">
        <Components.icon name="lucide-bold" />
      </Components.toggle>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :group} = assigns) do
    ~H"""
    <.preview id={@id} name={:toggle} state={@state} code={code(:group)}>
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
    </.preview>
    """
  end

  defp code(:variant) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.toggle :for={variant <- ~w(solid subtle outline ghost dashed)} variant={variant} pressed>
        {variant}
      </.toggle>
    </div>
    """
  end

  defp code(:color) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.toggle
        :for={color <- ~w(primary secondary success info warning error neutral)}
        color={color}
        pressed
      >
        {color}
      </.toggle>
    </div>
    """
  end

  defp code(:size) do
    ~S"""
    <div class="flex flex-wrap items-center gap-3">
      <.toggle :for={size <- ~w(xs sm md lg xl)} size={size} pressed>{size}</.toggle>
    </div>
    """
  end

  defp code(:icon) do
    ~S"""
    <.toggle variant="solid">
      <.icon name="lucide-bold" /> Bold
    </.toggle>
    """
  end

  defp code(:icon_only) do
    ~S"""
    <.toggle variant="solid" aria-label="Bold">
      <.icon name="lucide-bold" />
    </.toggle>
    """
  end

  defp code(:group) do
    ~S"""
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
  end

  @impl true
  def css do
    %{
      body: """
      The styled toggle maps `variant`, `color`, and `size` onto data hooks and
      leaves the pressed state to `data-state`. The public inputs are
      `--fl-toggle-color`, `--fl-toggle-color-content`, and
      `--fl-toggle-text`; surfaces, borders, and focus derive from them.
      `--fl-toggle-text` resolves to the role's `-text` token, so tinted and
      outlined colored toggles read consistently in both schemes; solid uses
      `--fl-toggle-color-content`.
      """,
      snippets: [
        %{
          title: "Retint one toggle",
          body: "Override the public color inputs on the instance.",
          code: """
          .danger-toggle {
            --fl-toggle-color: var(--fl-color-error);
            --fl-toggle-color-content: var(--fl-color-error-content);
            --fl-toggle-text: var(--fl-color-error-text);
          }
          """
        }
      ]
    }
  end
end
