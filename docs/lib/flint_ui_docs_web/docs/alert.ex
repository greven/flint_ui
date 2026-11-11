defmodule FlintUIDocsWeb.Docs.Alert do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :alert

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @roles ~w(neutral info success warning error primary secondary)

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage",
        controls: [
          %{key: :variant, type: :select, default: "outline", label: "Variant"},
          %{
            key: :intent,
            type: :select,
            default: "info",
            label: "Intent",
            values: ~w(neutral info success warning error)
          },
          %{
            key: :color,
            type: :select,
            default: "inherit",
            label: "Color",
            values: ["inherit" | @roles]
          },
          %{key: :spacing, type: :select, default: "md", label: "Spacing"},
          %{key: :border, type: :select, default: "solid", label: "Border"},
          %{key: :background, type: :boolean, default: true, label: "Background"},
          %{key: :show_icon, type: :boolean, default: true, label: "Show icon"},
          %{key: :with_close, type: :boolean, default: false, label: "Close button"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :variant,
        title: "Variant"
      },
      %{
        tab: :styled,
        section: :usage,
        id: :intent,
        title: "Intent",
        controls: [%{key: :show_icon, type: :boolean, default: true, label: "Show icon"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :color,
        title: "Color",
        controls: [%{key: :color, type: :select, default: "info", label: "Color", values: @roles}]
      },
      %{tab: :styled, section: :usage, id: :title, title: "Title"},
      %{tab: :styled, section: :usage, id: :actions, title: "Actions"},
      %{
        tab: :styled,
        section: :usage,
        id: :orientation,
        title: "Orientation",
        controls: [
          %{key: :orientation, type: :select, default: "vertical", label: "Orientation"}
        ]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :spacing,
        title: "Spacing",
        controls: [%{key: :spacing, type: :select, default: "md", label: "Spacing"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :border,
        title: "Border"
      },
      %{
        tab: :styled,
        section: :usage,
        id: :background,
        title: "Background",
        controls: [%{key: :background, type: :boolean, default: true, label: "Background"}]
      },
      %{
        tab: :styled,
        section: :usage,
        id: :closing,
        title: "Closing",
        controls: [%{key: :with_close, type: :boolean, default: true, label: "Close button"}]
      },
      %{
        tab: :styled,
        section: :examples,
        id: :server_close,
        title: "Server Close",
        group_title: "Examples"
      },
      %{tab: :styled, section: :examples, id: :custom_color, title: "Custom Color"},
      %{tab: :styled, section: :examples, id: :icon_override, title: "Icon Override"},
      %{
        tab: :css,
        section: :styling,
        id: :tokens,
        title: "Styling",
        position: :before
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Use `title` for the message and the default slot for its body. `intent` selects the theme color and a default icon; `color` overrides only the color.
      The default variant is `outline`." />
    <.preview :let={props} {assigns} code={&basic_code/1}>
      <Components.alert
        variant={props.variant}
        intent={props.intent}
        color={effective_color(props)}
        spacing={props.spacing}
        border={props.border}
        background={props.background}
        show_icon={props.show_icon}
        with_close={props.with_close}
        title="Heads up"
      >
        Your trial ends in three days.
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :variant} = assigns) do
    ~H"""
    <.prose content="`variant` sets the visual emphasis. `outline` is the default tinted surface with the role's full-strength edge; `soft` keeps the tint with the faint matching edge;
      `solid` fills the alert with the role color." />
    <.preview :let={_props} {assigns} code={&variant_code/1}>
      <div class="grid w-full max-w-xl gap-3">
        <Components.alert
          :for={variant <- ~w(solid outline soft)}
          variant={variant}
          color="info"
          title={String.capitalize(variant)}
        >
          Lorem ipsum dolor sit amet.
        </Components.alert>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :intent} = assigns) do
    ~H"""
    <.prose content="`intent` gives the message a semantic meaning. It selects the default icon and is the fallback color. The five intents are `neutral`, `info`, `success`, `warning`, and `error`." />
    <.prose content={"`warning` and `error` default to `role=\"alert\"`, so they interrupt. The other intents default to the polite `role=\"status\"`.
      Set `role` yourself when the surrounding flow needs a different announcement."} />
    <.preview :let={props} {assigns} code={intent_code()}>
      <div class="grid w-full max-w-xl gap-3">
        <Components.alert
          :for={intent <- ~w(neutral info success warning error)}
          intent={intent}
          show_icon={props.show_icon}
          title={String.capitalize(intent)}
        >
          An alert with the {intent} intent.
        </Components.alert>
      </div>
    </.preview>
    <.prose content="Set `show_icon={false}` to keep the intent color without its default icon. An explicit `:icon` slot always renders." />
    """
  end

  def render_section(%{section: :usage, id: :color} = assigns) do
    ~H"""
    <.prose content="`color` overrides the intent color without changing the intent icon. It accepts the semantic roles and a raw CSS color for one-off accents." />
    <.preview :let={props} {assigns} code={&color_code/1}>
      <Components.alert
        variant="solid"
        color={props.color}
        title={String.capitalize(props.color)}
        class="w-full max-w-xl"
      >
        A solid {props.color} alert.
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :title} = assigns) do
    ~H"""
    <.prose content="`title` is a styled line above the default slot. Both render when both are set, so you can use a title with a body, a body alone, or a title alone." />
    <.preview {assigns} code={title_code()} collapsed>
      <div class="grid w-full max-w-xl gap-3">
        <Components.alert intent="info" title="Title and body">
          The default slot holds the description.
        </Components.alert>
        <Components.alert intent="success">
          A body without a title.
        </Components.alert>
        <Components.alert intent="neutral" title="A title without a body" />
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :actions} = assigns) do
    ~H"""
    <.prose content="The `:actions` slot renders below the body and spaces its children. It usually holds buttons, but any inline content works.
      Give an action the alert's `color` with a `subtle` or `soft` variant so it gains the alert's elevated tint; `ghost` stays borderless,
      while `surface` is the page-surface chip that contrasts instead of blending. Actions are regular controls; keep their labels distinct and meaningful." />
    <.preview {assigns} code={actions_code()}>
      <Components.alert
        intent="warning"
        title="Storage almost full"
        class="w-full max-w-xl"
      >
        You have used 90% of your plan.
        <:actions>
          <Components.button size="sm" variant="subtle" color="warning">Upgrade</Components.button>
          <Components.button size="sm" variant="ghost" color="warning">Not now</Components.button>
        </:actions>
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :orientation} = assigns) do
    ~H"""
    <.prose content={"`orientation=\"horizontal\"` moves the actions beside the content instead of below it. The title and body keep their column, so long copy still wraps."} />
    <.preview :let={props} {assigns} code={&orientation_code/1}>
      <Components.alert
        intent="info"
        orientation={props.orientation}
        title="New release"
        class="w-full max-w-xl"
      >
        Version 1.4 is ready.
        <:actions>
          <Components.button size="sm" variant="subtle" color="info"><:trailing>
            <.icon name="lucide-arrow-right" />
          </:trailing>
          View</Components.button>
        </:actions>
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :spacing} = assigns) do
    ~H"""
    <.prose content="`spacing` sets the root inset, the gap between the parts, and the icon sizes. It follows the shared spacing scale." />
    <.preview :let={props} {assigns} code={&spacing_code/1}>
      <Components.alert
        intent="info"
        spacing={props.spacing}
        title="Spacing"
        class="w-full max-w-xl"
      >
        The inset and gaps follow the selected step.
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :border} = assigns) do
    ~H"""
    <.prose content="`border` sets the edge treatment. `solid` is the default; `dashed` keeps the variant's edge color with a dashed stroke; `none` removes the edge while keeping the surface." />
    <.preview :let={_props} {assigns} code={border_code()}>
      <div class="grid w-full max-w-xl gap-3">
        <Components.alert
          :for={border <- ~w(solid dashed none)}
          intent="info"
          variant="outline"
          border={border}
          title={String.capitalize(border)}
        >
          The edge is independent of the surface.
        </Components.alert>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :background} = assigns) do
    ~H"""
    <.prose content={"`background={false}` removes the surface but keeps the border and elevation, so the alert can sit directly on the page. The label falls back to the role text so it stays readable. Set `border=\"none\"` or `shadow={false}` to drop those too."} />
    <.preview :let={props} {assigns} code={&background_code/1}>
      <Components.alert
        intent="info"
        variant="outline"
        background={props.background}
        title="No background"
        class="w-full max-w-xl"
      >
        The surface is optional; the edge is not.
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :closing} = assigns) do
    ~H"""
    <.prose content="Set `with_close` to render a close button. It hides the alert in the browser and pushes `close_event` when set, so the server can remove it from state." />
    <.prose content="Give the alert an `id` and use `close_alert/2` to close it from a server-rendered control. The helper dispatches `fl:alert:close` and hides the alert." />
    <.preview :let={props} {assigns} code={&closing_code/1}>
      <div class="grid w-full max-w-xl gap-3">
        <Components.alert
          id="docs-close-alert"
          intent="success"
          with_close={props.with_close}
          title="Dismissible"
        >
          Close this alert with its button.
        </Components.alert>
        <div>
          <Components.button size="sm" variant="surface" phx-click={close_alert("docs-close-alert")}>
            Close from the server
          </Components.button>
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :server_close} = assigns) do
    ~H"""
    <.prose content="The close button can push a server event with the alert `id`. Remove the alert from your assigns in that handler so the next render keeps it gone." />
    <.preview {assigns} code={server_close_code()} code_only />
    """
  end

  def render_section(%{section: :examples, id: :custom_color} = assigns) do
    ~H"""
    <.prose content="Pass a raw CSS color or a bundled Tailwind palette color to `color` for a one-off accent. The fill is used exactly and the label is derived for contrast.
      Prefer a semantic role or a theme override for anything app-wide." />
    <.preview {assigns} code={custom_color_code()} collapsed>
      <div class="grid w-full max-w-xl gap-3">
        <%!-- <Components.alert variant="solid" color="#B45309"> --%>
        <%!-- A raw color keeps its exact fill. --%>
        <%!-- </Components.alert> --%>
        <Components.alert variant="soft" color="tw:zinc">Zinc</Components.alert>
        <Components.alert variant="soft" color="tw:red">Red</Components.alert>
        <Components.alert variant="soft" color="tw:orange">Orange</Components.alert>
        <Components.alert variant="soft" color="tw:amber">Amber</Components.alert>
        <Components.alert variant="soft" color="tw:yellow">Yellow</Components.alert>
        <Components.alert variant="soft" color="tw:lime">Lime</Components.alert>
        <Components.alert variant="soft" color="tw:green">Green</Components.alert>
        <Components.alert variant="soft" color="tw:emerald">Emerald</Components.alert>
        <Components.alert variant="soft" color="tw:teal">Teal</Components.alert>
        <Components.alert variant="soft" color="tw:cyan">Cyan</Components.alert>
        <Components.alert variant="soft" color="tw:sky">Sky</Components.alert>
        <Components.alert variant="soft" color="tw:blue">Blue</Components.alert>
        <Components.alert variant="soft" color="tw:indigo">Indigo</Components.alert>
        <Components.alert variant="soft" color="tw:violet">Violet</Components.alert>
        <Components.alert variant="soft" color="tw:purple">Purple</Components.alert>
        <Components.alert variant="soft" color="tw:fuchsia">Fuchsia</Components.alert>
        <Components.alert variant="soft" color="tw:pink">Pink</Components.alert>
        <Components.alert variant="soft" color="tw:rose">Rose</Components.alert>
      </div>
    </.preview>
    """
  end

  def render_section(%{section: :examples, id: :icon_override} = assigns) do
    ~H"""
    <.prose content="The `:icon` slot replaces the intent default. Keep the icon decorative unless it has its own accessible name, and keep the title and body meaningful without it." />
    <.preview {assigns} code={icon_override_code()} collapsed>
      <Components.alert intent="info" title="Custom icon" class="w-full max-w-xl">
        <:icon><Components.icon name="lucide-sparkles" /></:icon>
        The icon comes from the slot instead of the intent.
      </Components.alert>
    </.preview>
    """
  end

  def render_section(%{section: :styling, id: :tokens} = assigns) do
    ~H"""
    <.prose content="The alert reads five public color inputs: `--fl-alert-color`, `--fl-alert-color-content`, `--fl-alert-text`, `--fl-alert-soft`, and `--fl-alert-soft-border`.
      Each role maps them to its fill, label, text, soft, and soft-border tokens." />
    <.preview {assigns} code={styling_code()} code_only />
    """
  end

  defp effective_color(props), do: if(props.color == "inherit", do: nil, else: props.color)

  defp basic_code(props) do
    Snippet.tag(
      ".alert",
      [
        Snippet.attr("variant", props.variant, "outline"),
        Snippet.attr("intent", props.intent),
        Snippet.attr("color", effective_color(props)),
        Snippet.attr("spacing", props.spacing, "md"),
        Snippet.attr("border", props.border, "solid"),
        Snippet.attr("show_icon", props.show_icon, true),
        Snippet.flag("with_close", props.with_close),
        Snippet.attr("title", "Heads up")
      ],
      "Your trial ends in three days."
    )
  end

  defp variant_code(_props) do
    """
    <.alert :for={variant <- ~w(solid outline soft)} variant={variant}
      color="info" title={String.capitalize(variant)}>
      Lorem ipsum dolor sit amet.
    </.alert>
    """
    |> String.trim()
  end

  defp intent_code do
    """
    <.alert intent="info" title="Info">An alert with the info intent.</.alert>
    <.alert intent="success" title="Success">An alert with the success intent.</.alert>
    <.alert intent="warning" title="Warning">An alert with the warning intent.</.alert>
    <.alert intent="error" title="Error">An alert with the error intent.</.alert>
    <.alert intent="neutral" title="Neutral">An alert with the neutral intent.</.alert>
    """
    |> String.trim()
  end

  defp color_code(props) do
    Snippet.tag(
      ".alert",
      [
        Snippet.attr("variant", "solid"),
        Snippet.attr("color", props.color),
        Snippet.attr("title", String.capitalize(props.color))
      ],
      "A solid #{props.color} alert."
    )
  end

  defp title_code do
    """
    <.alert intent="info" title="Title and body">The default slot holds the description.</.alert>
    <.alert intent="success">A body without a title.</.alert>
    <.alert intent="neutral" title="A title without a body" />
    """
    |> String.trim()
  end

  defp actions_code do
    """
    <.alert intent="warning" title="Storage almost full">
      You have used 90% of your plan.
      <:actions>
        <.button size="sm" variant="subtle" color="warning">Upgrade</.button>
        <.button size="sm" variant="ghost" color="warning">Not now</.button>
      </:actions>
    </.alert>
    """
    |> String.trim()
  end

  defp orientation_code(props) do
    Snippet.tag(
      ".alert",
      [
        Snippet.attr("intent", "info"),
        Snippet.attr("orientation", props.orientation, "vertical"),
        Snippet.attr("title", "New release")
      ],
      """
      Version 1.4 is ready.
      <:actions>
        <.button size="sm" variant="subtle" color="info">View</.button>
      </:actions>
      """
    )
  end

  defp spacing_code(props) do
    Snippet.tag(
      ".alert",
      [
        Snippet.attr("intent", "info"),
        Snippet.attr("spacing", props.spacing, "md"),
        Snippet.attr("title", "Spacing")
      ],
      "The inset and gaps follow the selected step."
    )
  end

  defp border_code do
    """
    <.alert :for={border <- ~w(solid dashed none)} border={border}
      intent="info" variant="outline" title={String.capitalize(border)}>
      The edge is independent of the surface.
    </.alert>
    """
    |> String.trim()
  end

  defp background_code(props) do
    Snippet.tag(
      ".alert",
      [
        Snippet.attr("intent", "info"),
        Snippet.attr("variant", "outline"),
        Snippet.attr("background", props.background, true),
        Snippet.attr("title", "No background")
      ],
      "The surface is optional; the edge is not."
    )
  end

  defp closing_code(props) do
    alert =
      Snippet.tag(
        ".alert",
        [
          Snippet.attr("id", "docs-close-alert"),
          Snippet.attr("intent", "success"),
          Snippet.flag("with_close", props.with_close),
          Snippet.attr("close_event", if(props.with_close, do: "dismiss_alert")),
          Snippet.attr("title", "Dismissible")
        ],
        "Close this alert with its button."
      )

    """
    #{alert}

    <.button phx-click={close_alert("docs-close-alert")}>Close from the server</.button>

    def handle_event("dismiss_alert", %{"id" => id}, socket) do
      {:noreply, assign(socket, :alert, nil)}
    end
    """
    |> String.trim()
  end

  defp server_close_code do
    """
    <.alert id="billing-alert" intent="success" with_close close_event="dismiss_alert" title="Dismissible">
      Close this alert with its button.
    </.alert>

    def handle_event("dismiss_alert", %{"id" => id}, socket) do
      {:noreply, assign(socket, :alert, nil)}
    end
    """
    |> String.trim()
  end

  defp custom_color_code do
    """
    <.alert variant="solid" color="#B45309" title="Amber">A raw color keeps its exact fill.</.alert>
    <.alert variant="soft" color="tw:indigo-600" title="Indigo">A `tw:` color comes from the bundled palette.</.alert>
    """
    |> String.trim()
  end

  defp icon_override_code do
    """
    <.alert intent="info" title="Custom icon">
      <:icon><.icon name="lucide-sparkles" /></:icon>
      The icon comes from the slot instead of the intent.
    </.alert>
    """
    |> String.trim()
  end

  defp styling_code do
    """
    [data-element="alert"] {
      --fl-alert-color: #B45309;
      --fl-alert-color-content: #FFFBEB;
      --fl-alert-text: #92400E;
      --fl-alert-soft: #FEF3C7;
      --fl-alert-soft-border: #FCD34D;
    }
    """
    |> String.trim()
  end
end
