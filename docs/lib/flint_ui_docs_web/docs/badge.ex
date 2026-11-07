defmodule FlintUIDocsWeb.Docs.Badge do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :badge

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
      %{
        tab: :styled,
        section: :usage,
        id: :radius,
        title: "Radius",
        controls: [%{key: :radius, type: :select, default: "md", label: "Radius"}]
      },
      %{tab: :styled, section: :usage, id: :wide, title: "Wide"},
      %{tab: :styled, section: :usage, id: :uppercase, title: "Uppercase"},
      %{
        tab: :styled,
        section: :examples,
        id: :as_link,
        title: "As a Link",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :status_dot, title: "Status Dot"},
      %{
        tab: :styled,
        section: :examples,
        id: :custom_color,
        title: "Custom Color"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :removable_badge,
        title: "Removable Chip"
      },
      %{
        tab: :styled,
        section: :examples,
        id: :inside_button,
        title: "Inside a Button"
      },
      %{tab: :styled, section: :examples, id: :icon_only, title: "Icon Only"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use the `inner_block` to set the content of the badge." />
    <.preview {assigns} code="<.badge>Badge</.badge>">
      <Components.badge>Badge</Components.badge>
    </.preview>
    <.prose content="If all you want is to render text you can also use the `text` attribute." />
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="Use the `variant` attr to change the visual emphasis of the badge. The default variant is `subtle`." />
    <.preview :let={props} {assigns} code={&code_variant/1}>
      <div class="flex items-center flex-wrap gap-3">
        <Components.badge variant={props.variant}>The Best</Components.badge>
        <Components.badge variant={props.variant} color="info">Things</Components.badge>
        <Components.badge variant={props.variant} color="success">Come</Components.badge>
        <Components.badge variant={props.variant} color="warning">In Small</Components.badge>
        <Components.badge variant={props.variant} color="error">Packages</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Use the `color` attr to change the color the variant is built from. The default color is `neutral`." />
    <.preview :let={props} {assigns} code={&code_color/1}>
      <Components.badge variant="solid" color={props.color}>Badge</Components.badge>
    </.preview>

    <.prose content="Each `color` and `variant` compose freely: every variant is available in every role.
      Each row below is a color role, each column a variant. You can use any of the semantic theme colors: `neutral`, `info`,
      `success`, `warning`, `error`, `primary`, and `secondary`." />

    <.preview id={"#{@id}-grid"}>
      <div class="space-y-3">
        <div
          :for={color <- ~w(neutral info success warning error)}
          class="flex flex-wrap gap-3 justify-center"
        >
          <Components.badge
            :for={variant <- ~w(solid soft subtle outline dashed ghost)}
            variant={variant}
            color={color}
          >
            {String.capitalize(variant)}
          </Components.badge>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :icon} = assigns) do
    ~H"""
    <.prose content="Use the `icon` attr to render a decorative icon before the label. The icon scales with the badge size." />
    <.prose content="You can also use the `:leading` and `:trailing` slots to place an icon or other content before and after the label." />
    <.prose content="Icons are decorative. Keep the badge's text meaningful on its own instead of relying on the icon to carry the state." />
    <.preview id={@id} code={&code_icon/1} collapsed>
      <div class="grid grid-rows-2 gap-3">
        <div class="flex flex-wrap justify-center gap-3">
          <Components.badge color="neutral" icon="lucide-bookmark">Saved</Components.badge>
          <Components.badge color="success" icon="lucide-badge-check">Success</Components.badge>
          <Components.badge color="info" icon="lucide-info">Info</Components.badge>
          <Components.badge color="warning" icon="lucide-clock">Pending</Components.badge>
          <Components.badge color="error" icon="lucide-circle-x">Failure</Components.badge>
        </div>
        <div class="flex flex-wrap justify-center gap-3">
          <Components.badge variant="solid" color="neutral">
            <:leading><Components.icon name="lucide-tag-plus" /></:leading>
            New Version
          </Components.badge>
          <Components.badge variant="solid" color="primary">
            Synced
            <:trailing><Components.icon name="lucide-cloud-check" /></:trailing>
          </Components.badge>
          <Components.badge color="warning" variant="soft" icon="lucide-ticket-percent">
            50% off
          </Components.badge>
          <Components.badge variant="soft" color="neutral">
            Files
            <:trailing><Components.icon name="lucide-files" /></:trailing>
          </Components.badge>
          <Components.badge variant="ghost" icon="lucide-ghost">
            Removed
          </Components.badge>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :size} = assigns) do
    ~H"""
    <.prose content="Use the `size` attr to change the badge size, from `xs` to `xl`. The default size is `md`." />
    <.preview id={@id} code={&code_size/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge :for={{label, size} <- sizes()} size={size}>{label}</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :radius} = assigns) do
    ~H"""
    <.prose content="Use the `radius` attr to change the corner radius, from `none` to `xl`, or `full` for a pill shape. A `full` badge whose content is narrower than it is tall, such as a one-character count, renders as a circle instead of a squashed oval. The default radius is `md`." />
    <.preview :let={props} id={@id} {assigns} code={&code_radius/1}>
      <Components.badge radius={props.radius}>Badge</Components.badge>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :wide} = assigns) do
    ~H"""
    <.prose content="Set `wide` to fill the width of the surrounding container. The content stays centered." />
    <.preview id={@id} code={&code_wide/1}>
      <div class="w-full max-w-xs">
        <Components.badge variant="solid" icon="lucide-move-horizontal" wide>
          Full width
        </Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :uppercase} = assigns) do
    ~H"""
    <.prose content="Set `uppercase` to render the label in uppercase." />
    <.preview id={@id} code={&code_uppercase/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge size="xs" variant="solid" color="neutral" radius="sm" uppercase>
          Tiny
        </Components.badge>
        <Components.badge variant="solid" color="info" size="sm" radius="full" uppercase>
          Small
        </Components.badge>
        <Components.badge variant="dot" color="info" radius="full" uppercase>
          Huge
        </Components.badge>
        <Components.badge variant="subtle" color="warning" size="lg" uppercase>
          If True
        </Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :as_link} = assigns) do
    ~H"""
    <.prose content="Pass `href`, `navigate`, or `patch` to render the badge as a link. The badge keeps its styling and gains native link semantics: `Enter` activates it,
      and assistive technology announces it as a link." />
    <.prose content="Use the link form for navigation. Keep a plain badge for labels and statuses that only describe something." />
    <.preview {assigns} code={&code_as_link/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge variant="solid" color="info" navigate="/components/badge">
          Badge Docs
        </Components.badge>
        <Components.badge
          variant="subtle"
          color="info"
          patch="/components/badge#usage-color"
        >
          Color Options
        </Components.badge>
        <Components.badge variant="outline" color="info" href="/components">
          Browse Components
        </Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :status_dot} = assigns) do
    ~H"""
    <.prose content="Use the `dot` variant for a status badge. The `color` fills the dot, while the border and text stay neutral.
      The dot is decorative, so keep the label meaningful and do not rely on color alone. Using the `color` attr you can set any custom color." />
    <.preview {assigns} code={dot_code()}>
      <div class="flex flex-wrap items-center gap-2">
        <Components.badge variant="dot" color="success" radius="xl">Online</Components.badge>
        <Components.badge variant="dot" color="warning" radius="xl">Pending</Components.badge>
        <Components.badge variant="dot" color="error" radius="xl">Offline</Components.badge>
        <Components.badge variant="dot" color="#9810FA" radius="xl">Custom</Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :custom_color} = assigns) do
    ~H"""
    <.prose content="You can pass a raw CSS color to `color` for a one-off accent or a value that comes from data. FlintUI keeps the fill exactly and derives the label with
      the best contrast available, so a mid-tone fill can still fall below AA when neither black nor white clears it." />
    <.prose content="Styling the badge yourself with `style` or utility classes goes further: it overrides the derived label, border, and text colors, so contrast is up to you.
        Most of the examples below look vivid but do not meet WCAG AA. Prefer a semantic role or a theme override
        for anything app-wide, and treat raw colors as a deliberate exception." />

    <.preview {assigns} code={&code_raw/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge variant="solid" size="lg" color="#00B9DB" style="color: white;">
          Cyan
        </Components.badge>
        <Components.badge variant="solid" size="lg" color="#05A6F3" style="color: white;">
          Sky
        </Components.badge>
        <Components.badge variant="solid" size="lg" class="bg-lime-500 border-lime-600 text-lime-50">
          Lime
        </Components.badge>
        <Components.badge variant="solid" size="lg" class="bg-rose-500 border-rose-600 text-white">
          Rose
        </Components.badge>
      </div>
    </.preview>

    <.prose content="For a subtle gradient badge, paint the soft fill on the padding box and the gradient on the border box,
      then clip the same gradient to the label. A local custom property keeps the border and text in sync." />
    <.prose content="Wrap the label in its own element so the text clip does not catch an icon. In forced-colors mode the background
      image is dropped, so restore the text fill with a `@media (forced-colors: active)` rule." />

    <.preview {assigns} preview_id={"#{@preview_id}-gradient"} code={&code_gradient/1} collapsed>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge
          variant="subtle"
          color="primary"
          size="sm"
          style="--badge-gradient: linear-gradient(90deg, light-dark(#1D4ED8, #84b3ff), light-dark(#A21CAF, #df6cff));
            background: linear-gradient(var(--fl-badge-soft), var(--fl-badge-soft)) padding-box, var(--badge-gradient) border-box; border-color: transparent;"
        >
          <span style="background-image: var(--badge-gradient); -webkit-background-clip: text; background-clip: text;
              -webkit-text-fill-color: transparent; color: transparent;">
            Pink
          </span>
        </Components.badge>

        <Components.badge
          variant="subtle"
          color="warning"
          size="sm"
          style="--badge-gradient: linear-gradient(90deg, light-dark(#92400E, #fcd34d), light-dark(#BE123C, #fda4af));
            background: linear-gradient(var(--fl-badge-soft), var(--fl-badge-soft)) padding-box, var(--badge-gradient) border-box; border-color: transparent;"
        >
          <span style="background-image: var(--badge-gradient); -webkit-background-clip: text; background-clip: text;
              -webkit-text-fill-color: transparent; color: transparent;">
            Pony
          </span>
        </Components.badge>

        <Components.badge
          variant="subtle"
          color="success"
          size="sm"
          style="--badge-gradient: linear-gradient(90deg, light-dark(#047857, #6ee7b7), light-dark(#3F6212, #bef264));
            background: linear-gradient(var(--fl-badge-soft), var(--fl-badge-soft)) padding-box, var(--badge-gradient) border-box; border-color: transparent;"
        >
          <span style="background-image: var(--badge-gradient);
              -webkit-background-clip: text; background-clip: text; -webkit-text-fill-color: transparent; color: transparent;">
            Club
          </span>
        </Components.badge>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :removable_badge} = assigns) do
    ~H"""
    <.prose content="A Badge with a actionable inside, most commonly a close button is a commonly used pattern,
      sometimes known as a chip. Keep the badge as the label and give the remove action its own button." />
    <.prose content="Name the button after the value it removes so every chip has a distinct accessible name." />
    <.preview {assigns} code={&code_removable_badge/1} collapsed>
      <Components.badge variant="outline" size="lg" radius="full">
        Bananas
        <:trailing>
          <Components.button
            variant="ghost"
            size="xs"
            radius="full"
            class="-me-2.25"
            aria-label="Remove Bananas"
            phx-click="remove_filter"
            phx-value-tag="Bananas"
            square
          >
            <Components.icon name="lucide-x" />
          </Components.button>
        </:trailing>
      </Components.badge>

      <%!-- <div class="flex flex-wrap items-center gap-2">
        <Components.badge
          :for={tag <- ~w(Elixir Phoenix LiveView)}
          variant="dashed"
          color="primary"
          size="lg"
          radius="full"
        >
          {tag}
          <:trailing>
            <Components.button
              variant="ghost"
              size="xs"
              square
              radius="full"
              class="-me-1"
              aria-label={"Remove #{tag} filter"}
              phx-click="remove_filter"
              phx-value-tag={tag}
            >
              <Components.icon name="lucide-x" />
            </Components.button>
          </:trailing>
        </Components.badge>
      </div> --%>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :inside_button} = assigns) do
    ~H"""
    <.prose content="A badge can annotate a button's label, for example to show a count or a plan.
      The badge is part of the button's accessible name, so keep the combined text meaningful." />
    <.preview {assigns} code={&code_inside_button/1} collapsed>
      <div class="flex flex-wrap items-center gap-6">
        <Components.button variant="solid" color="neutral">
          Upgrade
          <Components.badge
            class="bg-neutral-50/20 text-neutral-50 dark:bg-neutral-900/75 dark:text-neutral-50"
            variant="soft"
            color="neutral"
            size="xs"
            radius="sm"
          >
            Pro+
          </Components.badge>
        </Components.button>

        <Components.tabs
          id="tabs-with-badges"
          label="Workspace sections"
          variant="minimal"
          value="rules"
        >
          <:tab :let={attrs} value="rules" custom>
            <Components.button variant="subtle" {attrs}>
              Rules
              <Components.badge variant="solid" color="neutral" size="xs" radius="sm">
                7
              </Components.badge>
            </Components.button>
          </:tab>
          <:tab :let={attrs} value="members" custom>
            <Components.button variant="subtle" {attrs}>
              Members
              <Components.badge variant="solid" color="info" size="xs" radius="sm">
                3
              </Components.badge>
            </Components.button>
          </:tab>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :icon_only} = assigns) do
    ~H"""
    <.prose content={"When a badge has no visible text, give it an accessible name with `aria-label`
      plus `role=\"img\"`. The same rule covers a bare count: include the context in the label, such as
      `3 unread notifications`. Use `role=\"status\"` instead of `role=\"img\"` when the count changes
      and should be announced."} />
    <.preview {assigns} code={&code_icon_only/1} collapsed>
      <div class="flex flex-wrap items-center gap-3">
        <Components.badge variant="solid" color="success" role="img" aria-label="Verified">
          <Components.icon name="lucide-circle-check" />
        </Components.badge>
        <Components.badge variant="solid" role="img" aria-label="Package">
          <Components.icon name="lucide-package" />
        </Components.badge>
        <Components.badge variant="subtle" color="neutral" role="img" aria-label="Saved">
          <Components.icon name="lucide-bookmark" />
        </Components.badge>
        <Components.badge
          variant="solid"
          color="error"
          radius="full"
          size="sm"
          role="status"
          aria-label="7 unread notifications"
        >
          7
        </Components.badge>
        <Components.badge variant="soft" size="xs" role="status" aria-label="3 emails">
          3
        </Components.badge>
      </div>
    </.preview>
    """
  end

  defp code_variant(props) do
    Snippet.tag(".badge", [Snippet.attr("variant", props.variant, "subtle")], "Badge")
  end

  defp code_color(props) do
    Snippet.tag(
      ".badge",
      [Snippet.attr("color", props.color, "neutral"), Snippet.attr("variant", "solid")],
      "Badge"
    )
  end

  defp code_radius(props) do
    Snippet.tag(".badge", [Snippet.attr("radius", props.radius, "md")], "Badge")
  end

  defp code_icon(_) do
    """
    <.badge color="neutral" icon="lucide-bookmark">Saved</.badge>
    <.badge color="success" icon="lucide-badge-check">Success</.badge>
    <.badge color="info" icon="lucide-info">Info</.badge>
    <.badge color="warning" icon="lucide-clock">Pending</.badge>
    <.badge color="error" icon="lucide-circle-x">Failure</.badge>
    <.badge variant="solid" color="neutral">
      <:leading><.icon name="lucide-tag-plus" /></:leading> New Version
    </.badge>
    <.badge variant="solid" color="primary">
      <:trailing><.icon name="lucide-cloud-check" /></:trailing> Synced
    </.badge>
    <.badge color="warning" variant="soft" icon="lucide-ticket-percent">50% off</.badge>
    <.badge variant="soft" color="neutral">
      <:trailing><.icon name="lucide-files" /></:trailing>
      Files
    </.badge>
    <.badge variant="ghost" icon="lucide-ghost">Removed</.badge>
    """
    |> String.trim()
  end

  defp code_size(_) do
    """
    <.badge size="xs">Extra Small</.badge>
    <.badge size="sm">Small</.badge>
    <.badge size="md">Medium</.badge>
    <.badge size="lg">Large</.badge>
    <.badge size="xl">Extra Large</.badge>
    """
    |> String.trim()
  end

  defp code_wide(_) do
    """
    <div class="w-full">
      <.badge variant="solid" icon="lucide-move-horizontal" wide>Full Width</.badge>
    </div>
    """
    |> String.trim()
  end

  defp code_uppercase(_) do
    """
    <.badge size="xs" variant="solid" color="neutral" radius="sm" uppercase>Tiny</.badge>
    <.badge variant="solid" color="info" size="sm" radius="full" uppercase>Small</.badge>
    <.badge variant="dot" color="info" radius="full" uppercase>Huge</.badge>
    <.badge variant="subtle" color="warning" size="lg" uppercase>If True</.badge>
    """
    |> String.trim()
  end

  defp code_as_link(_) do
    """
    <.badge variant="solid" color="info" navigate="/components/badge">Badge Docs</.badge>
    <.badge variant="subtle" color="info" patch="/components/badge#usage-color">Color Options</.badge>
    <.badge variant="outline" color="info" href="/components">Browse Components</.badge>
    """
    |> String.trim()
  end

  defp code_removable_badge(_) do
    ~S"""
    <.badge
      :for={tag <- @active_filters}
      variant="dashed"
      color="primary"
      size="lg"
      radius="full"
    >
      {tag}
      <:trailing>
        <.button
          variant="ghost"
          size="xs"
          square
          radius="full"
          class="-me-1"
          aria-label={"Remove #{tag} filter"}
          phx-click="remove_filter"
          phx-value-tag={tag}
        >
          <.icon name="lucide-x" />
        </.button>
      </:trailing>
    </.badge>
    """
    |> String.trim()
  end

  defp code_icon_only(_) do
    ~S"""
    <.badge variant="solid" color="success" role="img" aria-label="Verified">
      <.icon name="lucide-circle-check" />
    </.badge>
    <.badge variant="solid" role="img" aria-label="Package">
      <.icon name="lucide-package" />
    </.badge>
    <.badge variant="subtle" color="neutral" role="img" aria-label="Saved">
      <.icon name="lucide-bookmark" />
    </.badge>
    <.badge variant="solid" color="error" radius="full" size="sm"
      role="status" aria-label="7 unread notifications">
      7
    </.badge>
    <.badge variant="soft" size="xs" role="status" aria-label="3 emails">
      3
    </.badge>
    """
    |> String.trim()
  end

  defp code_inside_button(_) do
    """
    # Button with Badge
    <.button variant="solid" color="neutral">
      Upgrade
      <.badge variant="solid" color="neutral" size="xs" radius="sm"
        class="bg-neutral-50/20 text-neutral-50 dark:bg-neutral-900/75 dark:text-neutral-50">
        Pro+
      </.badge>
    </.button>

    # Tabs with custom buttons and badges
    <.tabs id="tabs-with-badges" value="rules" label="Settings" variant="minimal"
    >
      <:tab value="rules" custom>
        <.button variant="soft">
          Rules
          <.badge variant="solid" color="neutral" size="xs" radius="sm">7</.badge>
        </.button>
      </:tab>
      <:tab value="members" custom>
        <.button variant="soft">
          Members
          <.badge variant="solid" color="info" size="xs" radius="sm">3</.badge>
        </.button>
      </:tab>
    </.tabs>
    """
    |> String.trim()
  end

  defp code_raw(_) do
    """
    <.badge variant="solid" size="lg" color="#00B9DB" style="color: white;">Cyan</.badge>
    <.badge variant="solid" size="lg" color="#05A6F3" style="color: white;">Sky</.badge>
    <.badge variant="solid" size="lg" class="bg-lime-500 border-lime-600">Lime</.badge>
    <.badge variant="solid" size="lg" class="bg-rose-500 border-rose-600">Rose</.badge>
    """
    |> String.trim()
  end

  defp code_gradient(_) do
    """
    <.badge
      variant="subtle"
      color="primary"
      size="sm"
      style="--badge-gradient: linear-gradient(90deg,
        light-dark(#1D4ED8, #84b3ff), light-dark(#A21CAF, #df6cff));
        background: linear-gradient(var(--fl-badge-soft), var(--fl-badge-soft)) padding-box,
          var(--badge-gradient) border-box;
        border-color: transparent;"
    >
      <span style="background-image: var(--badge-gradient);
        -webkit-background-clip: text; background-clip: text;
        -webkit-text-fill-color: transparent; color: transparent;">
        Pink
      </span>
    </.badge>

    <.badge
      variant="subtle"
      color="warning"
      size="sm"
      style="--badge-gradient: linear-gradient(90deg,
        light-dark(#92400E, #fcd34d), light-dark(#BE123C, #fda4af));
        background: linear-gradient(var(--fl-badge-soft), var(--fl-badge-soft)) padding-box,
          var(--badge-gradient) border-box;
        border-color: transparent;"
    >
      <span style="background-image: var(--badge-gradient);
        -webkit-background-clip: text; background-clip: text;
        -webkit-text-fill-color: transparent; color: transparent;">
        Pony
      </span>
    </.badge>

    <.badge
      variant="subtle"
      color="success"
      size="sm"
      style="--badge-gradient: linear-gradient(90deg,
        light-dark(#047857, #6ee7b7), light-dark(#3F6212, #bef264));
        background: linear-gradient(var(--fl-badge-soft), var(--fl-badge-soft)) padding-box,
          var(--badge-gradient) border-box;
        border-color: transparent;"
    >
      <span style="background-image: var(--badge-gradient);
        -webkit-background-clip: text; background-clip: text;
        -webkit-text-fill-color: transparent; color: transparent;">
        Club
      </span>
    </.badge>
    """
    |> String.trim()
  end

  defp dot_code do
    """
    <.badge variant="dot" color="success" radius="xl">Online</.badge>
    <.badge variant="dot" color="warning" radius="xl">Pending</.badge>
    <.badge variant="dot" color="error" radius="xl">Offline</.badge>
    """
    |> String.trim()
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
