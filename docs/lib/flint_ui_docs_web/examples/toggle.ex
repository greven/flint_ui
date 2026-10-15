defmodule FlintUIDocsWeb.Examples.Toggle do
  @moduledoc false

  use FlintUIDocsWeb.Examples.Example, component: :toggle

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Examples.Snippet

  @base "inline-flex items-center justify-center gap-2 rounded-md px-3 py-2 text-sm font-medium transition-colors disabled:pointer-events-none disabled:opacity-50"

  @impl true
  def controls do
    [
      %{key: :pressed, type: :boolean, default: false, label: "Pressed"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"}
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
        id: :on_click,
        title: "Reacting to clicks",
        body: """
        Pass `on_click` a `Phoenix.LiveView.JS` command or a server event name to
        run when the button is clicked. The state flip still happens regardless.
        """,
        code: """
        <.toggle on_click={JS.push("toggle-bold")}>Bold</.toggle>
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
        description: "Pair an icon with a text label.",
        code: """
        <.toggle class="#{class(:solid)}">
          <.icon name="lucide-bold" class="size-4" /> Bold
        </.toggle>
        """
      },
      %{
        id: :icon_only,
        title: "Icon only",
        description: "An icon-only toggle needs an accessible name.",
        code: """
        <.toggle aria-label="Bold" class="#{class(:solid)}">
          <.icon name="lucide-bold" class="size-4" />
        </.toggle>
        """
      },
      %{
        id: :group,
        title: "Toolbar group",
        description: "Several toggles arranged as a formatting toolbar.",
        code: """
        <div class="inline-flex items-center gap-1 rounded-md border border-zinc-200 p-1">
          <.toggle aria-label="Bold" pressed class="#{class(:solid)}">
            <.icon name="lucide-bold" class="size-4" />
          </.toggle>
          <.toggle aria-label="Italic" class="#{class(:solid)}">
            <.icon name="lucide-italic" class="size-4" />
          </.toggle>
          <.toggle aria-label="Underline" class="#{class(:solid)}">
            <.icon name="lucide-underline" class="size-4" />
          </.toggle>
        </div>
        """
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The toggle ships behavior, not appearance. Style it with `class` and target
      its state through `data-state` (`"on"` / `"off"`). The generated component
      on the **Styled** tab adds an opinionated theme.
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
  def render_example(assigns) do
    ~H"""
    <.toggle pressed={@props.pressed} disabled={@props.disabled} class={toggle_class(:solid)}>
      <.icon name="lucide-bold" class="size-4" /> Bold
    </.toggle>
    """
  end

  @impl true
  def render_code(%{props: props}) do
    Snippet.tag(
      ".toggle",
      [Snippet.flag("pressed", props.pressed), Snippet.flag("disabled", props.disabled)],
      ~s(<.icon name="lucide-bold" class="size-4" /> Bold)
    )
  end

  @impl true
  def render_block(%{block: :icon} = assigns) do
    ~H"""
    <.toggle class={toggle_class(:solid)}>
      <.icon name="lucide-bold" class="size-4" /> Bold
    </.toggle>
    """
  end

  def render_block(%{block: :icon_only} = assigns) do
    ~H"""
    <.toggle aria-label="Bold" class={toggle_class(:solid)}>
      <.icon name="lucide-bold" class="size-4" />
    </.toggle>
    """
  end

  def render_block(%{block: :group} = assigns) do
    ~H"""
    <div class="inline-flex items-center gap-1 rounded-md border border-zinc-200 p-1 dark:border-zinc-800">
      <.toggle aria-label="Bold" pressed class={toggle_class(:solid)}>
        <.icon name="lucide-bold" class="size-4" />
      </.toggle>
      <.toggle aria-label="Italic" class={toggle_class(:solid)}>
        <.icon name="lucide-italic" class="size-4" />
      </.toggle>
      <.toggle aria-label="Underline" class={toggle_class(:solid)}>
        <.icon name="lucide-underline" class="size-4" />
      </.toggle>
    </div>
    """
  end

  @impl true
  def styled do
    %{
      description:
        "The generated wrapper adds `variant` and `size` props; the theme styles `data-state` for the on/off look.",
      code: """
      <.toggle variant="solid" pressed>Bold</.toggle>
      <.toggle variant="outline" pressed>Italic</.toggle>
      <.toggle variant="ghost">Underline</.toggle>
      """
    }
  end

  @impl true
  def render_styled(assigns) do
    ~H"""
    <div class="flex flex-wrap items-center gap-3">
      <Components.toggle variant="solid" size="md" pressed>Solid</Components.toggle>
      <Components.toggle variant="outline" size="md" pressed>Outline</Components.toggle>
      <Components.toggle variant="ghost" size="md" pressed>Ghost</Components.toggle>
      <Components.toggle variant="solid" size="md" disabled>Disabled</Components.toggle>
    </div>
    <div class="mt-4 flex flex-wrap items-center gap-3">
      <Components.toggle variant="solid" size="sm" pressed>Small</Components.toggle>
      <Components.toggle variant="solid" size="md" pressed>Medium</Components.toggle>
      <Components.toggle variant="solid" size="lg" pressed>Large</Components.toggle>
    </div>
    """
  end

  defp toggle_class(:solid) do
    [
      @base,
      "text-zinc-600 hover:bg-zinc-100 data-[state=on]:bg-zinc-900 data-[state=on]:text-white",
      "dark:text-zinc-400 dark:hover:bg-zinc-800 dark:data-[state=on]:bg-white dark:data-[state=on]:text-zinc-900"
    ]
  end

  defp class(variant), do: Enum.join(toggle_class(variant), " ")
end
