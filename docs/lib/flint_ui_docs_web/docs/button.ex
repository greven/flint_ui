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
      %{tab: :styled, section: :usage, id: :wide, title: "Wide"},
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
      %{tab: :styled, section: :usage, id: :inset, title: "Inset"},
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
    <.preview id={@id} code={&code_icon/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button icon="lucide-save">Save</Components.button>
        <Components.button variant="soft">
          <:trailing>
            <.icon name="lucide-arrow-right" />
          </:trailing>
          Next
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
    <.preview id={@id} code={~S(<.button size="sm">Size<.button>)}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button :for={{label, size} <- sizes()} size={size}>{label}</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :square} = assigns) do
    ~H"""
    <.prose content="Set `square` for an icon-only button. The box stays square at every `size`,
      and inline padding is dropped so the icon fills it. The button still needs an accessible name,
      so pass `aria-label` or `aria-labelledby` (the icon is not a label)." />

    <.preview id={@id}>
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

  def render_section(%{section: :usage, id: :wide} = assigns) do
    ~H"""
    <.prose content="Set `wide` to fill the width of the surrounding container." />
    <.preview id={@id} code={&code_wide/1}>
      <div class="w-full max-w-lg">
        <Components.button variant="solid" wide>Full Width</Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :inset} = assigns) do
    ~H"""
    <.prose content="Set `inset` to pull the control over the padding it keeps for its hit area, so its
      content lines up with surrounding content." />
    <.prose content="It is most useful on `ghost` and `link` buttons, whose box is otherwise invisible." />
    <.preview id={@id} code={&code_inset/1}>
      <div class="flex items-center justify-between gap-4 rounded-lg border border-default px-4 py-3">
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

  def render_section(%{section: :usage, id: :loading} = assigns) do
    ~H"""
    <.prose content="Set `loading` to mark the button as pending." />
    <.prose content="It stays focusable and keeps its accessible name, but activation is ignored, so add your own indicator." />
    <.preview id={@id} code={&code_loading/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button loading>
          <.icon name="lucide-loader-circle" class="animate-spin" />Save
        </Components.button>

        <Components.button variant="solid" loading>
          <.loading variant="ring-dash" /> <.loading_text text="Loading" />
        </Components.button>

        <Components.button variant="solid" color="primary" square loading>
          <.loading variant="dots-bounce" />
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="Set `disabled` to prevent the button from being activated." />
    <.preview id={@id} code={~S(<.button disabled>Button<.button>)}>
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

  def render_section(%{section: :usage, id: :radius} = assigns) do
    ~H"""
    <.prose content="Use the `radius` attr to change the corner radius, from `none` to `xl`, or `full` for a pill shape. Default radius is md." />
    <.preview :let={props} id={@id} {assigns} code={&code_radius/1}>
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

    <.prose content="Another way you can change the color of the button is using the exposed CSS variables, either through your stylesheets or
      using inline styles." />

    <.preview id={"#{@id}-css-vars"} code={&code_css_vars/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.button
          variant="subtle"
          style="--fl-button-soft: linear-gradient(0.25turn, var(--color-green-100), var(--color-amber-100));
            --fl-button-soft-border: var(--color-green-600); --fl-button-text: var(--color-green-800);
            box-shadow: var(--shadow-md);"
        >
          <.icon name="lucide-rabbit" class="text-green-700 animate-bounce" /> Bunny
        </Components.button>

        <Components.button
          variant="solid"
          style="--fl-button-color: var(--color-red-800); --fl-button-color-content: white;
            --fl-focus-ring-color: var(--color-rose-500); --fl-focus-border-color: var(--color-rose-700);
            background: linear-gradient(0.25turn, var(--color-red-500), var(--color-rose-500));"
          loading
        >
          <.icon name="lucide-heart" class="text-rose-50" />
          <Components.loading_text variant="shimmer" text="Likes" />
        </Components.button>

        <Components.button
          variant="solid"
          style="--fl-button-color: var(--color-cyan-700); --fl-button-color-content: white;
          background: linear-gradient(0.25turn, var(--color-cyan-500), var(--color-blue-500));"
        >
          <.icon name="lucide-panda" class="text-cyan-100 animate-pulse" /> Panda
        </Components.button>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :destructive_confirmation} = assigns) do
    ~H"""
    <.prose content="Delete actions are worth a look. A `data-confirm` attribute makes the browser prompt before the button's `phx-click` event is sent,
      and `phx-value-id` passes the targeted record along to your handler." />

    <.preview id={@id} code={&code_destructive_confirm/1}>
      <Components.button
        variant="solid"
        color="error"
        phx-click="delete_item"
        phx-value-id="67"
        data-confirm="Delete item?"
      >
        <Components.icon name="lucide-trash" /> Delete Item
      </Components.button>
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

  defp code_css_vars(_) do
    """
    <.button
      variant="subtle"
      style="--fl-button-soft: linear-gradient(0.25turn, var(--color-green-100), var(--color-amber-100));
        --fl-button-soft-border: var(--color-green-600); --fl-button-text: var(--color-green-800);
        box-shadow: var(--shadow-md);">
      <.icon name="lucide-rabbit" class="text-green-700 animate-bounce" /> Bunny
    </.button>

    <.button
      variant="solid"
      loading
      style="--fl-button-color: var(--color-red-800); --fl-button-color-content: white;
        --fl-focus-ring-color: var(--color-rose-500); --fl-focus-border-color: var(--color-rose-700);
        background: linear-gradient(0.25turn, var(--color-red-500), var(--color-rose-500));">
      <.icon name="lucide-heart" class="text-rose-50" />
      <.loading_text variant="shimmer" text="Likes" />
    </.button>

    <.button
      variant="solid"
      style="--fl-button-color: var(--color-cyan-700); --fl-button-color-content: white;
      background: linear-gradient(0.25turn, var(--color-cyan-500), var(--color-blue-500));">
      <.icon name="lucide-panda" class="text-cyan-100 animate-pulse" /> Panda
    </.button>
    """
  end

  defp code_variant(props) do
    Snippet.tag(
      ".button",
      [Snippet.attr("variant", props.variant, "outline")],
      "Button"
    )
  end

  defp code_wide(_) do
    """
    <div class="w-full max-w-lg">
      <.button variant="solid" wide>Full Width</.button>
    </div>
    """
  end

  defp code_inset(_) do
    """
    <div class="flex items-center justify-between gap-4 rounded-lg border border-default px-4 py-3">
      <span class="text-sm font-medium">Post successfully created.</span>
      <div class="flex items-center gap-4">
        <.button variant="ghost" size="sm" square inset aria-label="Dismiss">
          <.icon name="lucide-x" />
        </.button>
      </div>
    </div>
    """
  end

  defp code_icon(_) do
    """
    <.button icon="lucide-save">Save</.button>
    <.button variant="soft">
      <:trailing>
        <.icon name="lucide-arrow-right" />
      </:trailing>
      Next
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

    <.button variant="solid" color="primary" square loading>
      <.loading variant="dots-bounce" />
    </.button>
    """
  end

  defp code_radius(props) do
    Snippet.tag(".button", [Snippet.attr("radius", props.radius, "md")], "Button")
  end

  defp code_destructive_confirm(_) do
    """
    <.button
      variant="solid"
      color="error"
      phx-click="delete_item"
      phx-value-id="67"
      data-confirm="Delete item?"
    >
      <.icon name="lucide-trash" /> Delete Item
    </.button>
    Code
    """
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
