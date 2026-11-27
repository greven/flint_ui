defmodule FlintUIDocsWeb.Docs.Header do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :header

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage"
      },
      %{
        tab: :styled,
        section: :usage,
        id: :surface,
        title: "Surface",
        controls: [
          %{key: :surface, type: :select, default: "solid", label: "Surface"},
          %{key: :blur, type: :boolean, default: false, label: "Blur"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :mobile,
        title: "Mobile menu",
        controls: [
          %{key: :toggle_position, type: :select, default: "end", label: "Toggle"},
          %{key: :collapse, type: :select, default: "always", label: "Collapse"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :regions,
        title: "Responsive regions"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={
      ~s|A header is a page-level bar with brand, navigation, and action zones. The navigation collapses into a toggle panel below the breakpoint;
      put a `.navbar` in `:nav` and the header handles the rest.|
    } />

    <.preview {assigns} code={usage_code()} canvas_class="min-h-82" flush>
      <div class="fl-w-full">
        <Components.header>
          <:brand>
            <.link navigate="/" class="fl-cluster fl-items-center fl-gap-sm">
              <Components.icon name="lucide-box" class="text-toned" /> Box Inc.
            </.link>
          </:brand>

          <:nav>
            <Components.navbar label="Primary">
              <Components.navbar_item navigate="/">Home</Components.navbar_item>
              <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
              <Components.navbar_item navigate="/docs">Docs</Components.navbar_item>
            </Components.navbar>
          </:nav>

          <:actions>
            <Components.button variant="ghost">Sign in</Components.button>
            <Components.button>Get started</Components.button>
          </:actions>
        </Components.header>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :mobile} = assigns) do
    ~H"""
    <.prose content={
      ~s|Below the breakpoint the navigation expands into a full-width sheet under the bar. The sheet stays in the header flow, so it pushes the page down instead of floating over it and cannot be clipped by a scrolling ancestor. Put the mobile content in `:mobile` and keep `:nav` for the desktop navigation; the panel then follows the toggle in reading order.|
    } />
    <.prose content={
      ~s|`toggle_position` chooses the toggle edge. The preview uses `collapse="always"` so the mobile layout stays visible at any width; open the toggle to see the sheet. The toggle swaps its icon on open through `data-toggle-icon`; set `toggle_icon` and `toggle_icon_open` to use your own icon set.|
    } />

    <.preview :let={props} {assigns} code={&mobile_code/1} canvas_class="min-h-48" flush>
      <div class="fl-w-full">
        <Components.header
          id={"#{@preview_id}-mobile-header"}
          collapse={props.collapse}
          toggle_position={props.toggle_position}
          sticky={false}
        >
          <:brand>
            <.link navigate="/" class="fl-cluster fl-items-center fl-gap-sm">
              <Components.icon name="lucide-box" class="text-toned" /> Box Inc.
            </.link>
          </:brand>

          <:nav>
            <Components.navbar label="Primary">
              <Components.navbar_item navigate="/">Home</Components.navbar_item>
              <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
              <Components.navbar_item navigate="/docs">Docs</Components.navbar_item>
            </Components.navbar>
          </:nav>

          <:actions>
            <Components.button variant="ghost" size="sm">Sign in</Components.button>
            <Components.button size="sm">Get started</Components.button>
          </:actions>

          <:mobile>
            <Components.navbar label="Mobile">
              <Components.navbar_item navigate="/">Home</Components.navbar_item>
              <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
              <Components.navbar_item navigate="/docs">Docs</Components.navbar_item>
            </Components.navbar>

            <div class="fl-border-t fl-border-default fl-pt-md fl-stack fl-gap-sm">
              <div class="fl-cluster fl-items-center fl-gap-sm">
                <Components.avatar alt="Tom Cook" color="initials" size="md" />
                <div class="fl-stack fl-gap-xs">
                  <span class="fl-text-sm fl-font-semibold">Tom Cook</span>
                  <span class="fl-text-xs fl-text-muted">tom@example.com</span>
                </div>
              </div>
              <Components.button variant="ghost" size="sm" class="fl-w-full fl-justify-start">
                Your profile
              </Components.button>
              <Components.button variant="ghost" size="sm" class="fl-w-full fl-justify-start">
                Settings
              </Components.button>
              <Components.button variant="ghost" size="sm" class="fl-w-full fl-justify-start">
                Sign out
              </Components.button>
            </div>
          </:mobile>
        </Components.header>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :regions} = assigns) do
    ~H"""
    <.prose content={
      ~s|The regions are grid items with named areas, so hiding one at a breakpoint leaves the rest in place. There is no styling API for this; target the documented `data-part` hook from your app CSS (or hide the slot's content with the responsive `fl-*` display utilities).|
    } />

    <.preview {assigns} code={responsive_css()} code_lang={:css} code_only />
    """
  end

  def render_section(%{section: :usage, id: :surface} = assigns) do
    ~H"""
    <.prose content={
      ~s|A header paints a neutral surface. `solid` is the page surface, `soft` and `strong` step up the tint, and `transparent` drops the fill while keeping the bottom border. Set `--fl-header-border: transparent` to remove the border as well.|
    } />
    <.prose content={
      ~s|Add `blur` to frost the selected surface: the fill becomes translucent and content scrolling behind the sticky bar softens. `surface="solid" blur` is the common glass header, while `surface="transparent" blur` is a clear overlay. When backdrop blur is unavailable or the user prefers reduced transparency, the header falls back to the opaque surface. The mobile sheet inherits the header surface, so it stays readable while it expands the header. Scroll the preview to see the effect.|
    } />

    <.preview :let={props} {assigns} code={&surface_code/1} canvas_class="h-80" flush>
      <div class="fl-h-full fl-overflow-y-auto">
        <Components.header
          id={"#{@preview_id}-surface-header"}
          surface={props.surface}
          blur={props.blur}
          collapse="never"
        >
          <:brand>
            <.link navigate="/" class="fl-cluster fl-items-center fl-gap-sm">
              <Components.icon name="lucide-box" class="text-toned" /> Box Inc.
            </.link>
          </:brand>

          <:nav>
            <Components.navbar label="Primary" size="sm">
              <Components.navbar_item navigate="/">Home</Components.navbar_item>
              <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
              <Components.navbar_item navigate="/docs">Docs</Components.navbar_item>
            </Components.navbar>
          </:nav>

          <:actions>
            <Components.button variant="ghost" size="sm">Sign in</Components.button>
            <Components.button size="sm">Get started</Components.button>
          </:actions>
        </Components.header>

        <div
          class="h-96 fl-stack fl-gap-md fl-p-lg"
          style="background-image: repeating-linear-gradient(135deg, color-mix(in oklab, var(--fl-color-primary) 16%, transparent) 0 18px, transparent 18px 36px), repeating-linear-gradient(45deg, color-mix(in oklab, var(--fl-color-info) 12%, transparent) 0 18px, transparent 18px 36px)"
        >
          <p class="fl-m-0 fl-text-lg fl-font-semibold">Scroll behind the header</p>
          <p class="fl-m-0 fl-text-sm fl-text-toned">
            The selected surface frosts the content as it passes under the sticky bar.
          </p>
          <p class="fl-m-0 fl-text-sm fl-text-muted">
            Use the controls to compare the neutral steps, transparency, and blur.
          </p>
        </div>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full">
      <Components.header
        id={"#{@parts_id}-header"}
        collapse="never"
        sticky={false}
        class="fl-rounded-lg"
      >
        <:brand>
          <span class="fl-font-semibold">Acme</span>
        </:brand>

        <:nav>
          <Components.navbar label="Primary">
            <Components.navbar_item navigate="/">Home</Components.navbar_item>
            <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
          </Components.navbar>
        </:nav>

        <:actions>
          <Components.button size="sm">Sign in</Components.button>
        </:actions>

        <:secondary>
          <p class="fl-py-sm fl-text-sm fl-text-toned">Secondary row</p>
        </:secondary>
      </Components.header>
    </div>
    """
  end

  defp usage_code do
    Snippet.tag(".header", [], header_body_code())
  end

  defp surface_code(props) do
    Snippet.tag(
      ".header",
      [
        Snippet.attr("surface", props.surface, "solid"),
        Snippet.flag("blur", props.blur)
      ],
      header_body_code()
    )
  end

  defp mobile_code(props) do
    Snippet.tag(
      ".header",
      [
        Snippet.attr("collapse", props.collapse, "always"),
        Snippet.attr("toggle_position", props.toggle_position, "end")
      ],
      mobile_body_code()
    )
  end

  defp mobile_body_code do
    (header_body_code() <>
       """

       <:mobile>
         <.navbar label="Mobile">
           <.navbar_item navigate="/">Home</.navbar_item>
           <.navbar_item navigate="/pricing">Pricing</.navbar_item>
           <.navbar_item navigate="/docs">Docs</.navbar_item>
         </.navbar>

         <div class="fl-border-t fl-border-default fl-pt-md fl-stack fl-gap-sm">
           <div class="fl-cluster fl-items-center fl-gap-sm">
             <.avatar alt="Tom Cook" color="initials" size="md" />
             <div class="fl-stack fl-gap-xs">
               <span class="fl-text-sm fl-font-semibold">Tom Cook</span>
               <span class="fl-text-xs fl-text-muted">tom@example.com</span>
             </div>
           </div>
           <.button variant="ghost" size="sm" class="fl-w-full fl-justify-start">Your profile</.button>
           <.button variant="ghost" size="sm" class="fl-w-full fl-justify-start">Settings</.button>
           <.button variant="ghost" size="sm" class="fl-w-full fl-justify-start">Sign out</.button>
         </div>
       </:mobile>
       """)
    |> String.trim()
  end

  defp responsive_css do
    """
    /* Hide the actions below md without moving the brand or navigation. */
    @media (max-width: 47.999rem) {
      [data-element="header"] [data-part="actions"] {
        display: none;
      }
    }
    """
    |> String.trim()
  end

  defp header_body_code do
    """
    <:brand>
      <.link navigate="/" class="fl-cluster fl-items-center fl-gap-sm">
        <.icon name="lucide-box" class="text-toned" /> Box Inc.
      </.link>
    </:brand>

    <:nav>
      <.navbar label="Primary">
        <.navbar_item navigate="/">Home</.navbar_item>
        <.navbar_item navigate="/pricing">Pricing</.navbar_item>
        <.navbar_item navigate="/docs">Docs</.navbar_item>
      </.navbar>
    </:nav>

    <:actions>
      <.button variant="ghost">Sign in</.button>
      <.button>Get started</.button>
    </:actions>
    """
    |> String.trim()
  end
end
