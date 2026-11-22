defmodule FlintUIDocsWeb.Docs.CopyButton do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :copy_button

  alias FlintUIDocsWeb.Components

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{tab: :styled, section: :usage, id: :basic, title: "Usage"},
      %{tab: :styled, section: :usage, id: :sources, title: "Sources"},
      %{tab: :styled, section: :usage, id: :variant, title: "Variant"},
      %{tab: :styled, section: :usage, id: :color, title: "Color"},
      %{tab: :styled, section: :usage, id: :feedback, title: "Feedback"},
      %{tab: :styled, section: :usage, id: :success, title: "Success state"},
      %{tab: :styled, section: :usage, id: :icons, title: "Icons"},
      %{tab: :styled, section: :usage, id: :tooltip, title: "Tooltip"},
      %{tab: :styled, section: :usage, id: :sizing, title: "Sizing"},
      %{tab: :styled, section: :usage, id: :disabled, title: "Disabled"},
      %{
        tab: :styled,
        section: :examples,
        id: :group,
        title: "In a Group",
        group_title: "Examples"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="A copy button writes text to the clipboard and briefly confirms the result.
      It is a native button, so it works with the keyboard and assistive technology like any other action." />
    <.prose content="Copying needs the bundled `flint.js` and, for the Clipboard API, a secure context
      (HTTPS or `localhost`). Without the bundle the control is inert; there is no server equivalent." />

    <.preview
      {assigns}
      code={~s|<.copy_button from="install-command" label="Copy install command" />|}
    >
      <div class="fl-cluster">
        <code id="install-command" class="docs-code font-mono">mix flint.add copy_button</code>
        <Components.copy_button from="install-command" label="Copy install command" />
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :sources} = assigns) do
    ~H"""
    <.prose content="`value` copies a literal string. `from` names an element and takes precedence over
      `value`; by default the element's text content is copied. Add `attribute` to copy one of its
      attributes, or `property` to copy a JavaScript property such as an input's `value`." />
    <.prose content="An empty source is an error. When you use the `text` attribute and omit
      `label`, the visible text becomes the accessible name. For visible text rendered in the
      default slot, keep `label` equal to that text so the name matches what the user sees." />

    <.preview {assigns} code={code_sources()} collapsed>
      <div class="fl-stack fl-items-start fl-gap-lg">
        <div class="fl-cluster">
          <code id="copy-button-version" class="docs-code font-mono">FlintUI 0.1.0</code>
          <Components.copy_button value="FlintUI 0.1.0" label="Copy version" />
        </div>

        <div class="fl-cluster">
          <a id="copy-button-profile-link" href="/components/copy_button" class="docs-link">
            Profile page
          </a>
          <Components.copy_button
            from="copy-button-profile-link"
            attribute="href"
            label="Copy profile link"
          />
        </div>

        <div class="flex flex-wrap items-end gap-3">
          <Components.input
            id="copy-button-email"
            name="email"
            label="Email"
            value="hello@example.com"
            class="w-64"
          />
          <Components.copy_button
            from="copy-button-email"
            property="value"
            label="Copy email"
          />
        </div>
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="The copy button uses the shared control primitive, so it supports every button
      variant. The default is the quiet `ghost` treatment; set `variant` to match the surrounding
      controls. See the [button docs](/components/button) for the full control contract." />

    <.preview {assigns} code={code_variants()} collapsed>
      <div class="fl-cluster">
        <Components.copy_button
          :for={variant <- variants()}
          from="copy-button-variant-target"
          variant={variant}
          size="sm"
          label={"Copy, #{variant}"}
        >
          {variant}
        </Components.copy_button>
      </div>
      <p id="copy-button-variant-target" class="mt-4 text-sm text-muted">
        Shared control variants
      </p>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="Every semantic color role is available. Roles follow the theme and color
      scheme; `dark` and `light` stay absolute. A raw color is a per-instance escape hatch." />

    <.preview {assigns} code={code_colors()} collapsed>
      <div class="fl-cluster">
        <Components.copy_button
          :for={color <- colors()}
          from="copy-button-color-target"
          variant="soft"
          color={color}
          size="sm"
          label={"Copy, #{color}"}
        >
          {color}
        </Components.copy_button>
      </div>
      <p id="copy-button-color-target" class="mt-4 text-sm text-muted">
        Shared control colors
      </p>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :feedback} = assigns) do
    ~H"""
    <.prose content="The button sets `data-state` to `success` or `error` and clears it after
      `feedback_duration` milliseconds. The styled layer swaps the icon; non-solid variants tint it
      with the matching role, while solid variants keep the label color. A failed copy is announced
      with the same live region, so the button never changes its name." />
    <.prose content="The second button below points at a target that does not exist. Activate it to
      see and hear the error state." />

    <.preview {assigns} code={code_feedback()} collapsed>
      <div class="fl-cluster">
        <code id="copy-button-feedback-target" class="docs-code font-mono">
          npm install flint_ui
        </code>
        <Components.copy_button
          from="copy-button-feedback-target"
          label="Copy install command"
          feedback_duration={4000}
        />
        <Components.copy_button
          from="copy-button-missing-target"
          label="Copy from a missing target"
          success_label="Copied"
          error_label="Nothing to copy"
        />
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :success} = assigns) do
    ~H"""
    <.prose content="Set `success_color` to recolor the whole control while the success state is
      visible. `inherit` (the default) keeps the base `color`; a semantic role switches the fill,
      border, and label to that role, and the control's transitions ease back when the feedback
      ends. The `:success` slot swaps the visible content, so `Copy` becomes `Copied`." />

    <.preview {assigns} code={code_success()} collapsed>
      <div class="fl-cluster">
        <code id="copy-button-success-target" class="docs-code font-mono">
          mix flint.add copy_button
        </code>
        <Components.copy_button
          from="copy-button-success-target"
          text="Copy"
          variant="solid"
          success_color="success"
          feedback_duration={2500}
        >
          <:success>Copied</:success>
        </Components.copy_button>
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :icons} = assigns) do
    ~H"""
    <.prose content="`icon`, `success_icon`, and `error_icon` are icon CSS classes, like the rest of
      FlintUI. The `:success` and `:error` slots add content beside the state icon; set an icon to an
      empty string to omit it." />

    <.preview {assigns} code={code_icons()} collapsed>
      <div class="fl-cluster">
        <code id="copy-button-token" class="docs-code font-mono">fl_live_4f8c2a</code>
        <Components.copy_button
          from="copy-button-token"
          label="Copy token"
          icon="lucide-clipboard"
          success_icon="lucide-thumbs-up"
          error_icon="lucide-thumbs-down"
        >
          Copy token
        </Components.copy_button>
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :tooltip} = assigns) do
    ~H"""
    <.prose content="Set `tooltip` on an icon-only copy button to name it on hover and focus. The
      tooltip follows the copy state: it shows `label` (default `Copy`) while idle, `success_label`
      (default `Copied`) while the success state is visible, and `error_label` on failure. The
      default placement is `top`; pass a side such as `tooltip='right'` to prefer one, and the
      content flips when it would leave the viewport." />
    <.prose content="The button already has an accessible name from `label`. The tooltip is a
      pointer-device convenience and never replaces that name." />

    <.preview {assigns} code={code_tooltip()} collapsed>
      <div class="fl-cluster">
        <code id="copy-button-tooltip-target" class="docs-code font-mono">fl_live_4f8c2a</code>
        <Components.copy_button from="copy-button-tooltip-target" tooltip />
        <Components.copy_button
          from="copy-button-tooltip-target"
          label="Copy token"
          tooltip="right"
        />
      </div>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :sizing} = assigns) do
    ~H"""
    <.prose content="`size` uses the shared control scale, so a copy button lines up with a button or
      toggle of the same size. An icon-only button is square; add visible text to give it inline padding." />

    <.preview {assigns} code={code_sizing()} collapsed>
      <div class="fl-stack fl-gap-lg">
        <div class="fl-cluster">
          <Components.copy_button
            :for={size <- ~w(xs sm md lg xl)}
            from="copy-button-size-target"
            size={size}
            label={"Copy at #{size}"}
          />
        </div>
        <div class="fl-cluster">
          <Components.copy_button
            :for={size <- ~w(xs sm md lg xl)}
            from="copy-button-size-target"
            size={size}
            label={"Copy at #{size}"}
          >
            {String.upcase(size)}
          </Components.copy_button>
        </div>
      </div>
      <p id="copy-button-size-target" class="mt-4 text-sm text-muted">
        Shared control scale
      </p>
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :usage, id: :disabled} = assigns) do
    ~H"""
    <.prose content="A disabled copy button uses the native `disabled` attribute, leaves the tab
      order, and ignores the copy behavior." />

    <.preview {assigns} code={~s|<.copy_button value="Cannot copy this" label="Copy" disabled />|}>
      <Components.copy_button value="Cannot copy this" label="Copy" disabled />
    </.preview>
    """
  end

  @impl true
  def render_section(%{section: :examples, id: :group} = assigns) do
    ~H"""
    <.prose content="A copy button joins a group like any other control. The default is `ghost`,
      so pass the surrounding `variant` when the group uses a filled treatment. The group's size
      cascade handles the height and seam." />

    <.preview {assigns} code={code_group()} collapsed>
      <Components.group attached size="sm">
        <Components.copy_button
          from="copy-button-group-target"
          label="Copy example"
          variant="surface"
          size="sm"
        >
          Copy
        </Components.copy_button>
        <Components.button variant="surface" size="sm" icon="lucide-clipboard-paste">
          Paste
        </Components.button>
      </Components.group>
      <p id="copy-button-group-target" class="mt-4 text-sm text-muted">
        Copy example
      </p>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-cluster">
      <code id={"#{@parts_id}-target"} class="docs-code font-mono">
        mix flint.add copy_button
      </code>
      <Components.copy_button
        from={"#{@parts_id}-target"}
        label="Copy install command"
      />
    </div>
    """
  end

  defp variants, do: ~w(solid soft subtle surface outline ghost link)
  defp colors, do: ~w(neutral info success warning danger primary secondary)

  defp code_variants do
    """
    <.copy_button
      :for={variant <- ~w(solid soft subtle surface outline ghost link)}
      variant={variant}
      size="sm"
      from="value"
    >
      {variant}
    </.copy_button>
    """
  end

  defp code_colors do
    """
    <.copy_button
      :for={color <- ~w(neutral info success warning danger primary secondary)}
      variant="soft"
      color={color}
      size="sm"
      from="value"
    >
      {color}
    </.copy_button>
    """
  end

  defp code_sources do
    """
    <.copy_button value="FlintUI 0.1.0" label="Copy version" />
    <.copy_button from="profile-link" attribute="href" label="Copy profile link" />
    <.copy_button from="email-input" property="value" label="Copy email" />
    """
  end

  defp code_feedback do
    """
    <.copy_button
      from="install-command"
      label="Copy install command"
      feedback_duration={4000}
    />
    <.copy_button
      from="missing-target"
      label="Copy from a missing target"
      error_label="Nothing to copy"
    />
    """
  end

  defp code_success do
    """
    <.copy_button
      from="install-command"
      text="Copy"
      variant="solid"
      success_color="success"
      feedback_duration={2500}
    >
      <:success>Copied</:success>
    </.copy_button>
    """
  end

  defp code_icons do
    """
    <.copy_button
      from="api-token"
      label="Copy token"
      icon="lucide-clipboard"
      success_icon="lucide-thumbs-up"
      error_icon="lucide-thumbs-down"
    >
      Copy token
    </.copy_button>
    """
  end

  defp code_sizing do
    """
    <.copy_button :for={size <- ~w(xs sm md lg xl)} from="value" size={size} />
    <.copy_button :for={size <- ~w(xs sm md lg xl)} from="value" size={size}>Copy</.copy_button>
    """
  end

  defp code_tooltip do
    """
    <.copy_button from="api-token" tooltip />
    <.copy_button from="api-token" label="Copy token" tooltip="right" />
    """
  end

  defp code_group do
    """
    <.group attached size="sm">
      <.copy_button from="value" variant="surface" size="sm">Copy</.copy_button>
      <.button variant="surface" size="sm" icon="lucide-clipboard-paste">Paste</.button>
    </.group>
    """
  end
end
