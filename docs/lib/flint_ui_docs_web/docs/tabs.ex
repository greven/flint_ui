defmodule FlintUIDocsWeb.Docs.Tabs do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :tabs

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, default: "outlined", label: "Variant"},
      %{key: :color, type: :select, default: "neutral", label: "Color"},
      %{key: :size, type: :select, default: "md", label: "Size"},
      %{key: :disabled, type: :boolean, default: false, label: "Disabled"},
      %{key: :grow, type: :boolean, default: false, label: "Grow"},
      %{key: :align, type: :select, default: "start", label: "Align"},
      %{key: :gap, type: :select, default: "auto", label: "Gap"}
    ]
  end

  @impl true
  def styled_features do
    [
      "Three treatments: outlined, segmented, and minimal.",
      "Grow tabs to fill the row, or align them start, center, end, or spaced.",
      "Adjust the distance between triggers, which composed buttons usually need wider.",
      "Horizontal scrolling with an optional edge fade.",
      "Find-in-page can reveal an inactive panel and select its tab.",
      "Custom triggers: compose any focusable button or link."
    ]
  end

  @impl true
  def base_features do
    [
      "Roving tabindex with arrow, Home, and End navigation.",
      "Link triggers defer to navigation and LiveView's phx:before-navigate.",
      "Findable inactive panels use hidden until found."
    ]
  end

  @impl true
  def structure do
    """
    <FlintUI.tabs id="account" value="profile" label="Account sections">
      <:tab value="profile">Profile</:tab>
      <:tab value="billing">Billing</:tab>

      <:panel value="profile">Profile content</:panel>
      <:panel value="billing">Billing content</:panel>
    </FlintUI.tabs>
    """
    |> String.trim()
  end

  @impl true
  def usage do
    [
      %{
        id: :id_value,
        title: "Id and value",
        layer: :base,
        covers: [:id, :value],
        body: """
        `id` derives every tab and panel id, so it must be unique on the page.
        `value` selects the active tab; when it is missing or does not match a
        tab, the first enabled tab is active.
        """,
        code: """
        <FlintUI.tabs id="account" value="profile" label="Account sections">
          <:tab value="profile">Profile</:tab>
          <:tab value="billing">Billing</:tab>
          <:panel value="profile">Profile content</:panel>
          <:panel value="billing">Billing content</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :label,
        title: "Accessible name",
        layer: :base,
        covers: [:label],
        body: """
        `label` names the tab list. Set it whenever the page has more than one
        tab list, so screen readers can tell them apart.
        """,
        code: """
        <FlintUI.tabs id="settings" value="general" label="Settings sections">
          <:tab value="general">General</:tab>
          <:tab value="advanced">Advanced</:tab>
          <:panel value="general">General settings</:panel>
          <:panel value="advanced">Advanced settings</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :orientation,
        title: "Orientation",
        layer: :base,
        covers: [:orientation],
        body: """
        `orientation` changes the tab list layout and the arrow-key axis. A
        vertical list uses `ArrowUp` and `ArrowDown`.
        """,
        code: """
        <FlintUI.tabs id="settings" value="general" label="Settings" orientation="vertical">
          <:tab value="general">General</:tab>
          <:tab value="advanced">Advanced</:tab>
          <:panel value="general">General settings</:panel>
          <:panel value="advanced">Advanced settings</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :activation,
        title: "Activation and looping",
        layer: :base,
        covers: [:activation_mode, :loop],
        body: """
        `automatic` selects a tab as soon as it receives focus. Use `manual` when
        the arrow keys should only move focus, or when guarding a change.
        `loop={false}` stops arrow navigation at the ends.
        """,
        code: """
        <FlintUI.tabs
          id="steps"
          value="one"
          label="Steps"
          activation_mode="manual"
          loop={false}
        >
          <:tab value="one">One</:tab>
          <:tab value="two">Two</:tab>
          <:panel value="one">First step</:panel>
          <:panel value="two">Second step</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :disabled,
        title: "Disabled",
        layer: :base,
        covers: [:disabled],
        body: """
        `disabled` disables the whole tab list. Set `disabled` on one tab to skip
        only that tab in click and arrow-key navigation.
        """,
        code: """
        <FlintUI.tabs id="plan" value="free" label="Plan" disabled>
          <:tab value="free">Free</:tab>
          <:tab value="pro">Pro</:tab>
          <:panel value="free">Free plan</:panel>
          <:panel value="pro">Pro plan</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :change_event,
        title: "Server event",
        layer: :base,
        covers: [:change_event],
        body: """
        `change_event` pushes the new value after a button tab changes. The
        payload contains the component's `id` and the new `value`.
        """,
        code: """
        <FlintUI.tabs id="account" value={@tab} change_event="account_tab_changed">
          <:tab value="profile">Profile</:tab>
          <:tab value="billing">Billing</:tab>
          <:panel value="profile">Profile content</:panel>
          <:panel value="billing">Billing content</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :findable,
        title: "Find in page",
        layer: :base,
        covers: [:findable],
        body: """
        `findable` marks inactive panels with `hidden="until-found"`. Browsers
        that support it can find text in a hidden panel, reveal it, and the hook
        selects the matching tab. Browsers without support keep the panel hidden
        and skip it in find-in-page.
        """,
        code: """
        <FlintUI.tabs id="docs" value="guide" label="Docs" findable>
          <:tab value="guide">Guide</:tab>
          <:tab value="faq">FAQ</:tab>
          <:panel value="guide">Guide content</:panel>
          <:panel value="faq">FAQ content</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :overflow,
        title: "Overflowing tabs",
        layer: :base,
        covers: [:scrollable, :fadable],
        body: """
        `scrollable` makes the tab list scroll horizontally instead of
        overflowing. `fadable` adds a fade at the edge that has more tabs and
        also makes the list scrollable. The hook scrolls the active tab into
        view when the selection changes. The styled layer applies the overflow
        and fade; with the base, style `[data-part="tablist"]` with
        `overflow-x: auto`.
        """,
        code: """
        <FlintUI.tabs id="months" value="may" label="Months" scrollable fadable>
          <:tab :for={month <- ~w(January February March April May June)} value={String.downcase(month)}>
            {month}
          </:tab>
          <:panel :for={month <- ~w(January February March April May June)} value={String.downcase(month)}>
            {month} view
          </:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :custom_triggers,
        title: "Custom triggers",
        layer: :base,
        covers: [],
        body: """
        Set `custom` to render the trigger yourself. The slot receives the
        trigger attributes through `:let`; spread them onto a focusable element.
        Every trigger carries `data-tabs-trigger`, so the hook finds a composed
        component regardless of the element it renders. Default triggers are
        also marked with `data-tabs-tab`, so the styled layer only styles them
        and a composed component keeps its own styles. A raw custom `<button>`
        should set `type="button"`; a composed button component usually sets it
        already.
        """,
        code: """
        <FlintUI.tabs id="billing" value="monthly" label="Billing period">
          <:tab value="monthly" custom :let={attrs}>
            <FlintUI.button {attrs} class="my-button">Monthly</FlintUI.button>
          </:tab>
          <:tab value="yearly" custom :let={attrs}>
            <FlintUI.button {attrs} class="my-button">Yearly</FlintUI.button>
          </:tab>
          <:panel value="monthly">Monthly billing</:panel>
          <:panel value="yearly">Yearly billing</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :links,
        title: "Link triggers",
        layer: :base,
        covers: [],
        body: """
        A custom trigger may be a link, including a button component given
        `patch` or `navigate`, which renders an anchor. The link owns the
        navigation: the hook does not change the local state or push
        `change_event`. Use `patch` to keep the current LiveView mounted. Link
        triggers are manual, so arrow keys move focus and `Enter` follows the
        link.
        """,
        code: """
        <FlintUI.tabs id="settings" value={@tab} label="Settings sections">
          <:tab value="profile" custom :let={attrs}>
            <.link {attrs} patch={~p"/settings?tab=profile"}>Profile</.link>
          </:tab>
          <:tab value="billing" custom :let={attrs}>
            <.link {attrs} patch={~p"/settings?tab=billing"}>Billing</.link>
          </:tab>
          <:panel value="profile">Profile content</:panel>
          <:panel value="billing">Billing content</:panel>
        </FlintUI.tabs>
        """
      },
      %{
        id: :guarding,
        title: "Guarding a change",
        layer: :base,
        covers: [],
        body: """
        A button change dispatches a cancelable `fl:tabs:before-change` event on
        the trigger. Call `preventDefault()` to stop the local change and the
        server push. Continue with `FlintUI.select_tab/3` after an asynchronous
        confirmation; the select command bypasses the guard. Find-in-page
        selection bypasses it too, so a hidden panel can always be revealed.

        ```js
        window.addEventListener("fl:tabs:before-change", (event) => {
          if (hasUnsavedChanges() && !confirm("Discard changes?")) {
            event.preventDefault()
          }
        })
        ```

        Link triggers use LiveView's cancelable `phx:before-navigate` event
        instead. It fires before live navigation and back/forward, but not for
        server-side pushes, redirects, regular links, or page unloads.
        """
      },
      %{
        id: :appearance,
        title: "Variants, colors, and sizes",
        layer: :styled,
        covers: [:variant, :color, :size],
        body: """
        `variant` chooses the container treatment, `color` tints the active
        state, and `size` sets the default trigger metrics. On `outlined`, only
        the indicator (and focus ring) carries the color; the active label stays
        on the default text color. On `segmented` and `minimal`, the active
        label is tinted too. `color` also accepts a raw CSS color such as
        `#1D72FE`; the indicator uses it exactly and the active label derives a
        readable shade. Raw colors are a per-instance escape hatch, not a theme
        contract.
        """
      },
      %{
        id: :layout,
        title: "Growth and alignment",
        layer: :styled,
        covers: [:grow, :align],
        body: """
        `grow` makes every tab share the available width. `align` places the
        tab group at the start, center, or end, or distributes it with
        `spaced` (space-between). Alignment has no effect once `grow` fills the
        row. Both apply to horizontal tab lists; `scrollable` and `fadable`
        keep intrinsic tab widths and ignore `grow`.
        """
      },
      %{
        id: :gap,
        title: "Trigger spacing",
        layer: :styled,
        covers: [:gap],
        body: """
        `gap` sets the distance between triggers. The default, `auto`, follows
        the variant. Composed triggers such as buttons bring their own padding
        and border, so they usually need a wider gap than bare labels; set
        `gap` to `sm`, `md`, `lg`, or `xl` to open it up.
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :buttons,
        title: "Buttons as tabs",
        description:
          "Compose an existing button component as a trigger while the tab list keeps the segmented container."
      },
      %{
        id: :scrollable,
        title: "Scrollable tabs",
        description:
          "A narrow strip that scrolls instead of overflowing, with a fade at the edge that has more tabs."
      },
      %{
        id: :base_switcher,
        title: "Headless view switcher",
        layer: :base,
        description:
          "Tabs without panels act as a view switcher; style the state with the data hooks.",
        code: """
        <FlintUI.tabs id="view" value="list" label="View">
          <:tab value="list">List</:tab>
          <:tab value="grid">Grid</:tab>
          <:tab value="table">Table</:tab>
        </FlintUI.tabs>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The root owns the id and the hook. The tab list is a direct child; the
      panels are its siblings. Every trigger carries `data-tabs-trigger`, so the
      hook finds it even when it is a composed component. Default triggers are
      native buttons also marked with `data-tabs-tab`. A composed component keeps
      its own `data-element` (it stays a button), while the trigger keeps
      `data-part="tab"`.
      """,
      nodes: [
        %{
          tag: "div",
          selector: ~s([data-element="tabs"][data-part="root"]),
          hooks: [
            "id",
            "phx-hook",
            "data-value",
            "data-orientation",
            "data-activation",
            "data-loop",
            "data-disabled",
            "data-change-event",
            "data-findable",
            "data-scrollable",
            "data-fadable"
          ],
          attributes: ["class"],
          children: [
            %{
              tag: "div",
              selector: ~s([data-part="tablist"]),
              hooks: [
                "role",
                "aria-orientation",
                "aria-label",
                "data-orientation",
                "data-fade-start",
                "data-fade-end"
              ],
              children: [
                %{
                  tag: "button",
                  selector: ~s([data-part="tab"]),
                  hooks: [
                    "type",
                    "role",
                    "id",
                    "aria-selected",
                    "aria-controls",
                    "aria-label",
                    "tabindex",
                    "disabled",
                    "aria-disabled",
                    "data-value",
                    "data-state",
                    "data-disabled",
                    "data-tabs-trigger",
                    "data-tabs-tab"
                  ],
                  children: []
                }
              ]
            },
            %{
              tag: "div",
              selector: ~s([data-part="panel"]),
              hooks: [
                "role",
                "id",
                "aria-labelledby",
                "tabindex",
                "hidden",
                "data-value",
                "data-state"
              ],
              children: []
            }
          ]
        }
      ]
    }
  end

  @impl true
  def architecture do
    [
      %{
        name: "root",
        description: "The tabs root. Owns the id, the active value, and the hook."
      },
      %{
        name: "tablist",
        description: "The tab list. Owns the accessible name and orientation."
      },
      %{
        name: "tab",
        description:
          "A tab trigger. Default triggers are buttons; a custom trigger renders the element you provide with the tab attributes."
      },
      %{
        name: "panel",
        description: "A tab panel, linked to its tab and hidden while inactive."
      }
    ]
  end

  @impl true
  def styling do
    %{
      body: """
      The base tabs component is behavior and ARIA only. Style the tab list,
      triggers, and panels through the `data-part` hooks and the `data-state`
      on each part.
      """,
      snippets: [
        %{
          title: "Active tab",
          code: """
          [data-element="tabs"] [data-part="tab"][data-state="active"] {
            color: var(--fl-color-text);
          }
          """
        },
        %{
          title: "Segmented container",
          code: """
          [data-element="tabs"] [data-part="tablist"] {
            display: flex;
            gap: 0.25rem;
            padding: 0.25rem;
            border-radius: var(--fl-radius-md);
            background: var(--fl-color-muted);
          }

          [data-element="tabs"] [data-part="tab"][data-state="active"] {
            border-radius: var(--fl-radius-sm);
            background: var(--fl-color-surface);
            box-shadow: var(--fl-shadow-xs);
          }
          """
        },
        %{
          title: "Scrollable tab list",
          code: """
          [data-element="tabs"][data-scrollable] [data-part="tablist"] {
            display: flex;
            overflow-x: auto;
            scrollbar-width: thin;
          }

          [data-element="tabs"][data-scrollable] [data-part="tab"] {
            flex: 0 0 auto;
          }
          """
        }
      ]
    }
  end

  @impl true
  def css do
    %{
      body: """
      The styled layer maps `variant`, `color`, and `size` onto data hooks. Its
      trigger visuals are scoped to `[data-tabs-tab]`, so a custom trigger is
      never restyled by the tabs theme. The public inputs are
      `--fl-tabs-color`, `--fl-tabs-text`, and `--fl-tabs-surface`; the tablist
      container and layout are styled through `[data-part="tablist"]` and
      `[data-part="tab"]`. `--fl-tabs-color` drives the outlined indicator and
      focus ring; the outlined label always uses the default text color, so
      `--fl-tabs-text` only affects segmented and minimal. The outlined
      indicator grows in while the outgoing one fades, and the segmented and
      minimal surfaces cross-fade. A `scrollable` or
      `fadable` list scrolls horizontally; `fadable` masks the edge with more
      tabs. Growth and alignment are set with `data-grow` and `data-align`;
      overflow keeps intrinsic tab widths and wins over growth. `gap` sets
      `data-gap`, which overrides the variant's trigger spacing; composed
      triggers usually want a wider value than bare labels.
      """,
      snippets: [
        %{
          title: "Container look",
          body: "Scope the container and the active surface with the part and state hooks.",
          code: """
          .trip-tabs {
            padding: var(--fl-spacing-md);
            border: 1px solid var(--fl-color-border);
            border-radius: var(--fl-radius-lg);
            background: var(--fl-color-surface);
          }

          .trip-tabs [data-part="tablist"] {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: var(--fl-spacing-xs);
            padding: var(--fl-spacing-xs);
            border: 0;
            border-radius: var(--fl-radius-md);
            background: var(--fl-color-muted);
          }

          .trip-tabs [data-part="tab"][data-state="active"] {
            border-radius: var(--fl-radius-sm);
            background: var(--fl-color-surface);
            box-shadow: var(--fl-shadow-xs);
          }
          """
        },
        %{
          title: "Retint one instance",
          body: "Override the public color inputs on the instance.",
          code: """
          .brand-tabs {
            --fl-tabs-color: var(--fl-color-primary);
            --fl-tabs-text: var(--fl-color-primary-text);
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
      name={:tabs}
      state={@state}
      controls={[:variant, :color, :size, :grow, :align, :disabled, :gap]}
      code={&main_code/1}
    >
      <div class="w-full max-w-md">
        <Components.tabs
          id={"#{@id}-tabs"}
          value="overview"
          label="Workspace sections"
          variant={props.variant}
          color={props.color}
          size={props.size}
          grow={props.grow}
          align={props.align}
          gap={props.gap}
          disabled={props.disabled}
        >
          <:tab value="overview">Overview</:tab>
          <:tab value="activity">Activity</:tab>
          <:tab value="members">Members</:tab>
          <:panel value="overview">
            <p class="text-sm text-toned">
              Snapshot of the workspace with health, ownership, and recent updates.
            </p>
          </:panel>
          <:panel value="activity">
            <p class="text-sm text-toned">
              Timeline of edits, comments, and merges across the team.
            </p>
          </:panel>
          <:panel value="members">
            <p class="text-sm text-toned">
              Roster of teammates, roles, and pending invitations.
            </p>
          </:panel>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".tabs",
      [
        ~s(id="workspace"),
        ~s(value="overview"),
        ~s(label="Workspace sections"),
        Snippet.attr("variant", props.variant, "outlined"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.flag("grow", props.grow),
        Snippet.attr("align", props.align, "start"),
        Snippet.attr("gap", props.gap, "auto"),
        Snippet.flag("disabled", props.disabled)
      ],
      """
      <:tab value="overview">Overview</:tab>
      <:tab value="activity">Activity</:tab>
      <:tab value="members">Members</:tab>

      <:panel value="overview">Overview content</:panel>
      <:panel value="activity">Activity content</:panel>
      <:panel value="members">Members content</:panel>
      """
    )
  end

  defp gap_tabs(assigns) do
    ~H"""
    <Components.tabs
      id={@id}
      value="monthly"
      label={@label}
      variant="minimal"
      gap={@gap}
    >
      <:tab :let={attrs} :for={period <- ~w(monthly yearly)} value={period} custom>
        <Components.button
          {attrs}
          variant="ghost"
          size="sm"
          class="aria-selected:bg-surface aria-selected:text-default aria-selected:shadow-xs"
        >
          {String.capitalize(period)}
        </Components.button>
      </:tab>
    </Components.tabs>
    """
  end

  @impl true
  def render_section(%{kind: :usage, block: :appearance} = assigns) do
    ~H"""
    <.preview id={@id} name={:tabs} state={@state} code={code(:appearance)}>
      <div class="flex w-full max-w-md flex-col gap-6">
        <Components.tabs
          :for={variant <- ~w(outlined segmented minimal)}
          id={"#{@id}-#{variant}"}
          value="day"
          label={"#{variant} range"}
          variant={variant}
          grow={variant == "segmented"}
        >
          <:tab value="day">Day</:tab>
          <:tab value="week">Week</:tab>
          <:tab value="month">Month</:tab>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :layout} = assigns) do
    ~H"""
    <.preview id={@id} name={:tabs} state={@state} code={code(:layout)}>
      <div class="flex w-full max-w-md flex-col gap-6">
        <Components.tabs id={"#{@id}-grow"} value="one" label="Grow" grow>
          <:tab value="one">One</:tab>
          <:tab value="two">Two</:tab>
          <:tab value="three">Three</:tab>
        </Components.tabs>

        <Components.tabs id={"#{@id}-spaced"} value="one" label="Spaced" align="spaced">
          <:tab value="one">One</:tab>
          <:tab value="two">Two</:tab>
          <:tab value="three">Three</:tab>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :usage, block: :gap} = assigns) do
    ~H"""
    <.preview id={@id} name={:tabs} state={@state} code={code(:gap)}>
      <div class="flex w-full max-w-md flex-col gap-6">
        <div class="flex flex-col gap-2">
          <p class="text-xs font-medium text-muted">Auto spacing</p>
          <.gap_tabs id={"#{@id}-gap-auto"} label="Billing period" gap="auto" />
        </div>
        <div class="flex flex-col gap-2">
          <p class="text-xs font-medium text-muted">
            <code>gap="md"</code>
          </p>
          <.gap_tabs id={"#{@id}-gap-md"} label="Billing period, spaced" gap="md" />
        </div>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :buttons} = assigns) do
    ~H"""
    <.preview id={@id} name={:tabs} state={@state} code={code(:buttons)}>
      <div class="w-full max-w-md">
        <Components.tabs
          id={"#{@id}-tabs"}
          value="monthly"
          label="Billing period"
          variant="segmented"
          size="sm"
          gap="sm"
          grow
        >
          <:tab :let={attrs} value="monthly" custom>
            <Components.button
              {attrs}
              variant="ghost"
              size="sm"
              class="aria-selected:bg-surface aria-selected:text-default aria-selected:shadow-xs"
            >
              Monthly
            </Components.button>
          </:tab>
          <:tab :let={attrs} value="yearly" custom>
            <Components.button
              {attrs}
              variant="ghost"
              size="sm"
              class="aria-selected:bg-surface aria-selected:text-default aria-selected:shadow-xs"
            >
              Yearly
            </Components.button>
          </:tab>
          <:tab value="lifetime">Lifetime</:tab>
          <:panel value="monthly">
            <p class="text-sm text-toned">Billed every month.</p>
          </:panel>
          <:panel value="yearly">
            <p class="text-sm text-toned">Billed once a year.</p>
          </:panel>
          <:panel value="lifetime">
            <p class="text-sm text-toned">Billed once.</p>
          </:panel>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  def render_section(%{kind: :example, block: :scrollable} = assigns) do
    ~H"""
    <.preview id={@id} name={:tabs} state={@state} code={code(:scrollable)}>
      <div class="w-full max-w-xs">
        <Components.tabs
          id={"#{@id}-tabs"}
          value="may"
          label="Months"
          scrollable
          fadable
        >
          <:tab
            :for={month <- ~w(January February March April May June)}
            value={String.downcase(month)}
          >
            {month}
          </:tab>
          <:panel
            :for={month <- ~w(January February March April May June)}
            value={String.downcase(month)}
          >
            <p class="text-sm text-toned">{month} view</p>
          </:panel>
        </Components.tabs>
      </div>
    </.preview>
    """
  end

  defp code(:gap) do
    ~S"""
    <.tabs
      id="billing"
      value="monthly"
      label="Billing period"
      variant="minimal"
      gap="md"
    >
      <:tab :for={period <- ~w(monthly yearly)} :let={attrs} value={period} custom>
        <.button
          {attrs}
          variant="ghost"
          size="sm"
          class="aria-selected:bg-surface aria-selected:text-default aria-selected:shadow-xs"
        >
          {String.capitalize(period)}
        </.button>
      </:tab>
    </.tabs>
    """
  end

  defp code(:layout) do
    ~S"""
    <div class="flex flex-col gap-6">
      <.tabs id="grow" value="one" label="Grow" grow>
        <:tab value="one">One</:tab>
        <:tab value="two">Two</:tab>
        <:tab value="three">Three</:tab>
      </.tabs>

      <.tabs id="spaced" value="one" label="Spaced" align="spaced">
        <:tab value="one">One</:tab>
        <:tab value="two">Two</:tab>
        <:tab value="three">Three</:tab>
      </.tabs>
    </div>
    """
  end

  defp code(:appearance) do
    ~S"""
    <div class="flex flex-col gap-6">
      <.tabs
        :for={variant <- ~w(outlined segmented minimal)}
        id={variant}
        value="day"
        label={variant}
        variant={variant}
        grow={variant == "segmented"}
      >
        <:tab value="day">Day</:tab>
        <:tab value="week">Week</:tab>
        <:tab value="month">Month</:tab>
      </.tabs>
    </div>
    """
  end

  defp code(:scrollable) do
    ~S"""
    <div class="max-w-xs">
      <.tabs id="months" value="may" label="Months" scrollable fadable>
        <:tab :for={month <- ~w(January February March April May June)} value={String.downcase(month)}>
          {month}
        </:tab>
        <:panel :for={month <- ~w(January February March April May June)} value={String.downcase(month)}>
          {month} view
        </:panel>
      </.tabs>
    </div>
    """
  end

  defp code(:buttons) do
    ~S"""
    <.tabs
      id="billing"
      value="monthly"
      label="Billing period"
      variant="segmented"
      size="sm"
      grow
    >
      <:tab value="monthly" custom :let={attrs}>
        <.button
          {attrs}
          variant="ghost"
          size="sm"
          class="aria-selected:bg-surface aria-selected:text-default aria-selected:shadow-xs"
        >
          Monthly
        </.button>
      </:tab>
      <:tab value="yearly" custom :let={attrs}>
        <.button
          {attrs}
          variant="ghost"
          size="sm"
          class="aria-selected:bg-surface aria-selected:text-default aria-selected:shadow-xs"
        >
          Yearly
        </.button>
      </:tab>
      <:tab value="lifetime">Lifetime</:tab>
      <:panel value="monthly">Billed every month.</:panel>
      <:panel value="yearly">Billed once a year.</:panel>
      <:panel value="lifetime">Billed once.</:panel>
    </.tabs>
    """
  end
end
