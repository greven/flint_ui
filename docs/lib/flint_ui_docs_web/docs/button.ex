defmodule FlintUIDocsWeb.Docs.Button do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :button

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{
        tab: :styled,
        section: :usage,
        id: :variant,
        title: "Variant",
        controls: [%{key: :variant, type: :select, default: "subtle", label: "Variant"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        controls: [%{key: :color, type: :select, default: "neutral", label: "Color"}]
      },
      %{tab: :styled, section: :usage, id: :icon, title: "Icon"},
      %{tab: :styled, section: :usage, id: :size, title: "Size"},
      %{tab: :styled, section: :usage, id: :square, title: "Square"},
      %{
        tab: :styled,
        section: :usage,
        id: :disabled,
        title: "Disabled"
      },
      %{tab: :styled, section: :usage, id: :loading, title: "Loading"},
      %{
        tab: :styled,
        section: :usage,
        id: :radius,
        title: "Radius",
        controls: [%{key: :radius, type: :select, default: "md", label: "Radius"}]
      },
      %{tab: :styled, section: :usage, id: :type, title: "Type"},
      %{
        tab: :styled,
        section: :examples,
        id: :custom_color,
        title: "Custom Color",
        group_title: "Examples"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :destructive_confirmation,
        title: "Destructive Confirmation"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the `inner_block` to set the content of the button." />
    <.preview {assigns} code="<.button>Button</.button>">
      <Components.button>Button</Components.button>
    </.preview>
    <.prose content="If all you want is to render text you can also use the `text` attribute." />
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="Use the `variant` attr to change the visual style of the button. Default variant is outline." />
    <.preview :let={props} {assigns} code={&code_variant/1}>
      <Components.button variant={props.variant}>Button</Components.button>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color of the button." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.button variant="solid" color={props.color}>Button</Components.button>
    </.preview>

    <.prose content="Each `color` and `variant` compose freely: every variant is available in every role.
      Each row below is a color role, each column a variant." />

    <.preview id={"#{@id}-grid"}>
      <div class="overflow-x-auto py-1">
        <div class="grid grid-cols-8 items-center gap-x-3 gap-y-6">
          <div></div>
          <span
            :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
            class="text-center text-xs font-medium text-muted"
          >
            {variant}
          </span>
          <div
            :for={color <- ~w(neutral info success warning error)}
            class="contents"
          >
            <span class="text-xs font-medium text-muted">{color}</span>
            <Components.button
              :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
              variant={variant}
              color={color}
            >
              {String.capitalize(variant)}
            </Components.button>
          </div>
        </div>
      </div>
    </.preview>

    <.prose content="You can also override **Primary** and **Secondary** colors in your stylesheet." />

    <.preview id={"#{@id}-brand"}>
      <div class="overflow-x-auto py-1">
        <div class="grid grid-cols-8 items-center gap-x-3 gap-y-6">
          <div></div>
          <span
            :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
            class="text-center text-xs font-medium text-muted"
          >
            {variant}
          </span>
          <div
            :for={color <- ~w(primary secondary)}
            class="contents"
          >
            <span class="text-xs font-medium text-muted">{color}</span>
            <Components.button
              :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
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

  def render_section(%{section: :usage, id: :icon} = assigns) do
    ~H"""
    <.prose content="Use the `icon` attr to render a decorative icon before the label." />
    <.prose content="You can also use the `:leading` and `:trailing` slots to place an icon before or after the content." />
    <.prose content="For an icon-only button, combine `square` with an `aria-label` so it keeps an accessible name." />
    <.preview {assigns} code={&code_icon/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button icon="lucide-save">Save</Components.button>
        <Components.button variant="soft">
          <:trailing>
            <.icon name="lucide-archive" />
          </:trailing>
          Archive
        </Components.button>
        <Components.button variant="solid">
          <:leading>
            <.icon name="lucide-plus" />
          </:leading>
          New
        </Components.button>
        <Components.button variant="solid" color="error" icon="lucide-trash">Delete</Components.button>
        <Components.button icon="lucide-ellipsis" aria-label="More" square />
        <Components.button variant="ghost" aria-label="Close" icon="lucide-x" square />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="Use the `size` attr to change the control size, from `xs` to `xl`. Default size is md." />
    <.preview {assigns} code={~S(<.button size="sm">Size<.button>)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button :for={{label, size} <- sizes()} size={size}>{label}</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :square} = assigns) do
    ~H"""
    """
  end

  def render_section(%{section: :usage, id: :loading} = assigns) do
    ~H"""
    <.prose content="Set `loading` to mark the button as pending." />
    <.prose content="It stays focusable and keeps its accessible name, but activation is ignored, so add your own indicator." />
    <.preview code={&code_loading/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button loading>
          <.icon name="lucide-loader-circle" class="animate-spin" />Save
        </Components.button>

        <Components.button variant="solid" loading>
          <.loading variant="ring-dash" /> <.loading_text text="Loading" />
        </Components.button>

        <Components.button variant="solid" color="info" square loading>
          <.loading variant="dots-bounce" />
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="Set `disabled` to prevent the button from being activated." />
    <.preview code={~S(<.button disabled>Button<.button>)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button
          :for={variant <- ~w(outline solid subtle soft dashed ghost link)}
          class="capitalize"
          variant={variant}
          disabled
        >{variant}</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :type} = assigns) do
    ~H"""
    <.prose content="Use the `type` attr to set the native button type. Default is `button`; use `submit` or `reset` inside a form." />
    """
  end

  def render_section(%{section: :usage, id: :radius} = assigns) do
    ~H"""
    <.prose content="Use the `radius` attr to change the corner radius, from `xs` to `xl`, or `full` for a pill shape. Default radius is md." />
    <.preview :let={props} {assigns} code={&code_radius/1}>
      <Components.button radius={props.radius}>Button</Components.button>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :custom_color} = assigns) do
    ~H"""
    <.prose content="You can customize the `color` of a button using raw CSS color for a one-off accent or a value that comes from data. The
            best available contrast is used, so a mid-tone fill can still fall below AA when neither black nor white clears it. Raw colors are
            an escape hatch: they do not follow `data-theme` presets or the semantic role contract. Prefer a role for app-wide
            theming, and pass `style` to override the derived values." />

    <.preview id={"#{@id}-raw"} code={&code_raw/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button color="#009966" icon="lucide-coins">Common</Components.button>
        <Components.button color="#165DFC" icon="lucide-pickaxe">Rare</Components.button>
        <Components.button color="#7007E7" icon="lucide-shield">Epic</Components.button>
        <Components.button color="#FE9A00" icon="lucide-swords">Legendary</Components.button>
      </div>
    </.preview>
    """
  end

  defp code_color(props) do
    Snippet.tag(
      ".button",
      [Snippet.attr("color", props.color, "neutral"), Snippet.attr("variant", "solid")],
      "Button"
    )
  end

  defp code_raw(_) do
    """
    <.button color="#009966" icon="lucide-coins">Common</.button>
    <.button color="#165DFC" icon="lucide-pickaxe">Rare</.button>
    <.button color="#7007E7" icon="lucide-shield">Epic</.button>
    <.button color="#FE9A00" icon="lucide-swords">Legendary</.button>
    """
  end

  defp code_variant(props) do
    Snippet.tag(
      ".button",
      [Snippet.attr("variant", props.variant, "outline")],
      "Button"
    )
  end

  defp code_icon(_) do
    """
    <.button icon="lucide-save">Save</.button>
    <.button variant="soft">
      <:trailing>
        <.icon name="lucide-archive" />
      </:trailing>
      Archive
    </.button>
    <.button variant="solid">
      <:leading>
        <.icon name="lucide-plus" />
      </:leading>
      New
    </.button>
    <.button variant="solid" color="error" icon="lucide-trash">Delete</.button>
    <.button icon="lucide-ellipsis" aria-label="More" square />
    <.button variant="ghost" aria-label="Close" icon="lucide-x" square />
    """
    |> String.trim()
  end

  defp code_loading(_) do
    """
    <.button loading>
      <.icon name="lucide-loader-circle" class="animate-spin" />Save
    </.button>

    <.button variant="solid" loading>
      <.loading variant="ring-dash" /> <.loading_text text="Loading" />
    </.button>

    <.button variant="solid" color="info" square loading>
      <.loading variant="dots-bounce" />
    </.button>
    """
  end

  defp code_radius(props) do
    Snippet.tag(".button", [Snippet.attr("radius", props.radius, "md")], "Button")
  end

  defp sizes,
    do: [
      {"Extra Small", "xs"},
      {"Small", "sm"},
      {"Medium", "md"},
      {"Large", "lg"},
      {"Extra Large", "xl"}
    ]
end
