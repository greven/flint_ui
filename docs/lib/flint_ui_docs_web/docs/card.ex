defmodule FlintUIDocsWeb.Docs.Card do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :card

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @impl true
  def controls do
    [
      %{key: :variant, type: :select, default: "solid", label: "Variant"},
      %{key: :body, type: :select, default: "seamless", label: "Body"},
      %{key: :orientation, type: :select, default: "vertical", label: "Orientation"},
      %{key: :spacing, type: :select, default: "md", label: "Spacing"},
      %{key: :outline, type: :boolean, default: true, label: "Outline"},
      %{key: :shadow, type: :boolean, default: true, label: "Shadow"},
      %{key: :inverted, type: :boolean, default: false, label: "Inverted"}
    ]
  end

  @impl true
  def usage do
    [
      %{
        id: :as,
        title: "Root element",
        layer: :base,
        covers: [:as],
        body: """
        Choose the root element with `as`. Use `section`, `article`, or `li`
        when the card carries that semantics; the default is a plain `div`.
        """,
        code: """
        <FlintUI.card as="section" aria-labelledby="deployments-title" title_id="deployments-title">
          <:title>Deployments</:title>
          <p>Your latest deployment is live.</p>
        </FlintUI.card>
        """
      },
      %{
        id: :title_id,
        title: "Title id",
        layer: :base,
        covers: [:title_id],
        body: """
        Set `title_id` to give the title element an id, then point the root's
        `aria-labelledby` at it. This gives a section or article card an
        accessible name without wrapping the title yourself.
        """,
        code: """
        <FlintUI.card as="section" aria-labelledby="deployments-title" title_id="deployments-title">
          <:title>Deployments</:title>
          <p>Your latest deployment is live.</p>
        </FlintUI.card>
        """
      },
      %{
        id: :orientation,
        title: "Orientation",
        layer: :base,
        covers: [:orientation],
        body: """
        `orientation` lays the header, sections and footer out in a column or a
        row through the `data-orientation` hook. It is a styling hook: the card
        still has no implicit role, so add `aria-orientation` yourself only if
        you give the root a role that expects it.
        """,
        code: """
        <div class="flex flex-col gap-4">
          <FlintUI.card orientation="vertical">
            <:section>Vertical</:section>
            <:section>Second section</:section>
          </FlintUI.card>
          <FlintUI.card orientation="horizontal">
            <:section>Horizontal</:section>
            <:section>Second section</:section>
          </FlintUI.card>
        </div>
        """
      },
      %{
        id: :root,
        title: "Sections and slots",
        layer: :base,
        covers: [],
        body: """
        The card renders a root element with `data-part` hooks for each region.
        The default slot is shorthand for the first section; additional sections
        use `:section`. `title`, `description`, `header_actions`, `header`,
        `footer`, and `footer_actions` are flat slots: Phoenix requires every
        slot entry to be a direct child of the component, so actions get their
        own region-prefixed slot instead of nesting under `header` or `footer`.
        """,
        code: """
        <FlintUI.card as="section">
          <:title>Deployments</:title>
          <:description>Updated 2 minutes ago</:description>
          <:header_actions>
            <FlintUI.button>Edit</FlintUI.button>
          </:header_actions>
          <p>Your latest deployment is live.</p>
          <:section>More detail</:section>
          <:footer>3 repositories</:footer>
          <:footer_actions>
            <FlintUI.button variant="outline">View logs</FlintUI.button>
          </:footer_actions>
        </FlintUI.card>
        """
      },
      %{
        id: :actions,
        title: "Header and footer actions",
        layer: :base,
        covers: [],
        body: """
        `header_actions` renders at the end of the header, beside the title and
        description. `footer_actions` renders at the end of the footer, after the
        footer content. Both slots may be repeated or contain multiple controls.
        """,
        code: """
        <FlintUI.card>
          <:title>Starred repositories</:title>
          <:header_actions>
            <FlintUI.button variant="ghost">Edit</FlintUI.button>
            <FlintUI.button variant="ghost">Remove</FlintUI.button>
          </:header_actions>
          <p>Reorder or remove the repositories you follow.</p>
          <:footer>3 repositories</:footer>
          <:footer_actions>
            <FlintUI.button variant="outline">View logs</FlintUI.button>
          </:footer_actions>
        </FlintUI.card>
        """
      },
      %{
        id: :section,
        title: "Sections",
        layer: :base,
        covers: [],
        body: """
        Each `:section` adds another body block after the default slot. Sections
        stack in the card's orientation.
        """,
        code: """
        <FlintUI.card>
          <:section>First section</:section>
          <:section>Second section</:section>
          <:section>Third section</:section>
        </FlintUI.card>
        """
      },
      %{
        id: :padded,
        title: "Body padding",
        layer: :base,
        covers: [:padded],
        body: """
        `padded={false}` on the card removes the inline inset from every body
        section, so content can run to the card or body-panel edges.
        """,
        code: """
        <FlintUI.card padded={false}>
          <:section>Full-bleed body</:section>
        </FlintUI.card>
        """
      },
      %{
        id: :variant,
        title: "Variant",
        layer: :styled,
        covers: [:variant],
        body: """
        The generated component adds a `variant` attribute mapped onto the
        `data-variant` hook the theme targets. Variants are neutral surface
        treatments with no color: `solid` (the default) uses the base surface,
        `soft` is a half-step off it, and `muted` is the full de-emphasized
        step. In light the steps darken; in dark they lighten, following the
        surface scale. All variants draw an outline and shadow by default.
        """,
        code: """
        <div class="grid w-full max-w-3xl grid-cols-1 gap-4 sm:grid-cols-3">
          <.card :for={variant <- ~w(solid soft muted)} variant={variant}>
            <:title>{variant}</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :body,
        title: "Body treatment",
        layer: :styled,
        covers: [:body],
        body: """
        The body region is the card's main content: the default slot plus any
        `:section` slots. There is no separate `:body` slot. `body="seamless"`
        is the default and keeps one surface. `separated` uses darker header and
        footer bands; `separated-header` and `separated-footer` band only one
        edge while the other stays on the card surface. The body and unbanded
        edge both use the selected variant's surface, so soft and muted cards
        carry through. `divided` draws lines at the body boundaries, and `inset`
        or `flush` mount the body in a bordered panel. In light, a solid card's
        panel is a subtle well while soft and muted cards use a raised panel; in
        dark the panel is a raised surface above the card. Inverted cards keep a
        well. `flush` drops the horizontal inset but keeps the border and
        radius. Divided bodies inherit the card surface so the lines are the
        only treatment. Bands stay a darker shade of the card surface in both
        schemes. The root `padded` setting still controls the section inset.
        """,
        code: """
        <.card body="separated" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Product updates, weekly digests and security alerts.
          </p>
          <:footer>3 repositories</:footer>
        </.card>
        """
      },
      %{
        id: :outline,
        title: "Outline",
        layer: :styled,
        covers: [:outline],
        body: """
        `outline` is on by default for every variant. Set `outline={false}` to
        remove the border while keeping the surface, shadow and spacing.
        """,
        code: """
        <div class="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
          <.card>
            <:title>Outlined</:title>
            <p>Body</p>
          </.card>
          <.card outline={false}>
            <:title>No outline</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :shadow,
        title: "Shadow",
        layer: :styled,
        covers: [:shadow],
        body: """
        Shadows are on by default for every variant. Set `shadow={false}` to
        remove one, or override the elevation itself with `--fl-card-shadow`.
        """,
        code: """
        <div class="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
          <.card>
            <:title>With a shadow</:title>
            <p>Body</p>
          </.card>
          <.card shadow={false}>
            <:title>Without a shadow</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :inverted,
        title: "Inverted",
        layer: :styled,
        covers: [:inverted],
        body: """
        Set `inverted` to swap the neutral surface, text, border and divider
        colors. It composes with every variant; soft and muted remain opaque
        steps over the inverted surface.
        """,
        code: """
        <div class="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
          <.card inverted>
            <:title>Inverted solid</:title>
            <p>Body</p>
          </.card>
          <.card variant="muted" inverted>
            <:title>Inverted muted</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :spacing,
        title: "Spacing",
        layer: :styled,
        covers: [:spacing],
        body: """
        `spacing` sets the internal spacing through `--fl-card-spacing`.
        """,
        code: """
        <div class="flex w-full max-w-md flex-col gap-4">
          <.card :for={spacing <- ~w(xs sm md lg xl)} spacing={spacing}>
            <:title>{spacing}</:title>
            <p>Body</p>
          </.card>
        </div>
        """
      },
      %{
        id: :footer_actions,
        title: "Footer with actions",
        layer: :styled,
        covers: [],
        body: """
        `footer` holds the content at the start of the footer; `footer_actions`
        aligns the controls at the end. Both slots can be used independently.
        """,
        code: """
        <.card class="w-full max-w-md">
          <:title>Deployments</:title>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Your latest deployment is live.
          </p>
          <:footer>3 repositories</:footer>
          <:footer_actions>
            <.button size="sm">View logs</.button>
            <.button variant="ghost" size="sm">Settings</.button>
          </:footer_actions>
        </.card>
        """
      }
    ]
  end

  @impl true
  def examples do
    [
      %{
        id: :sectioned,
        title: "Header, sections and footer",
        description:
          "A divided card with a header, an implicit first section, an explicit section and a footer.",
        code: """
        <.card body="divided" class="w-full max-w-md">
          <:title>Deployments</:title>
          <:description>Manage your project's deployments.</:description>
          <:header_actions>
            <.button variant="ghost" size="sm">Edit</.button>
          </:header_actions>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Your latest deployment is live.
          </p>
          <:section>
            <p class="text-sm text-zinc-600 dark:text-zinc-400">Last deployed 2 minutes ago.</p>
          </:section>
          <:footer>3 repositories</:footer>
          <:footer_actions>
            <.button variant="outline" size="sm">View logs</.button>
          </:footer_actions>
        </.card>
        """
      },
      %{
        id: :horizontal,
        title: "Horizontal sections",
        description: "A divided row layout with content-sized header and sections.",
        code: """
        <.card body="divided" orientation="horizontal" class="w-full max-w-2xl">
          <:title>Project tasks</:title>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">1887 completed</p>
          <:section>
            <p class="text-sm text-zinc-600 dark:text-zinc-400">447 remaining</p>
          </:section>
          <:section>
            <p class="text-sm text-zinc-600 dark:text-zinc-400">76 in progress</p>
          </:section>
        </.card>
        """
      },
      %{
        id: :collapsible,
        title: "Expanding card",
        description: "A full-bleed body section wrapping a collapsible.",
        code: """
        <.card padded={false} class="w-full max-w-md">
          <:section>
            <.collapsible id="repos">
              <:trigger :let={attrs}>
                <button {attrs} class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium">
                  Starred repositories
                  <.icon name="lucide-chevron-down" class="size-4 transition-transform group-aria-expanded:rotate-180" />
                </button>
              </:trigger>
              <:content :let={attrs}>
                <div {attrs}>
                  <ul class="flex flex-col gap-2 border-t border-zinc-200 px-4 py-3 dark:border-zinc-800">
                    <li>flint_ui</li>
                    <li>phoenix_live_view</li>
                  </ul>
                </div>
              </:content>
            </.collapsible>
          </:section>
        </.card>
        """
      },
      %{
        id: :body_separated,
        title: "Separated bands",
        description: "Darker header and footer bands around the body.",
        code: """
        <.card body="separated" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <:header_actions>
            <.button variant="ghost" size="sm">Edit</.button>
          </:header_actions>
          <div class="space-y-2 text-sm">
            <p>Product updates</p>
            <p>Weekly digest</p>
            <p>Security alerts</p>
          </div>
          <:footer>3 repositories</:footer>
          <:footer_actions>
            <.button variant="solid" size="sm">View logs</.button>
          </:footer_actions>
        </.card>
        """
      },
      %{
        id: :body_separated_muted,
        title: "Muted bands",
        description:
          "The muted variant uses the full muted surface; bands stay a darker shade of it.",
        code: """
        <.card body="separated" variant="muted" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Product updates, weekly digests and security alerts.
          </p>
          <:footer>3 repositories</:footer>
        </.card>
        """
      },
      %{
        id: :body_separated_footer,
        title: "Footer-only band",
        description: "Band the footer while the header stays on the card surface.",
        code: """
        <.card body="separated-footer" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Product updates, weekly digests and security alerts.
          </p>
          <:footer>3 repositories</:footer>
          <:footer_actions>
            <.button variant="solid" size="sm">View logs</.button>
          </:footer_actions>
        </.card>
        """
      },
      %{
        id: :body_divided,
        title: "Divided regions",
        description: "Hairlines separate the header, body and footer without a tint.",
        code: """
        <.card body="divided" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <p class="text-sm text-zinc-600 dark:text-zinc-400">
            Product updates, weekly digests and security alerts.
          </p>
          <:footer>Last saved 2 minutes ago</:footer>
          <:footer_actions>
            <.button variant="ghost" size="sm">Settings</.button>
          </:footer_actions>
        </.card>
        """
      },
      %{
        id: :body_inset,
        title: "Raised inset body",
        description: "On a soft or muted card the inset body panel is raised above the shell.",
        code: """
        <.card body="inset" variant="soft" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <div class="space-y-2 text-sm">
            <p>Product updates</p>
            <p>Weekly digest</p>
            <p>Security alerts</p>
          </div>
        </.card>
        """
      },
      %{
        id: :body_inset_well,
        title: "Inset body",
        description: "A subtle well on a light solid card; raised on a dark card.",
        code: """
        <.card body="inset" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <div class="space-y-2 text-sm">
            <p>Product updates</p>
            <p>Weekly digest</p>
            <p>Security alerts</p>
          </div>
        </.card>
        """
      },
      %{
        id: :body_flush,
        title: "Flush body",
        description:
          "The body panel reaches the card's outer edges while keeping its border and radius.",
        code: """
        <.card body="flush" variant="soft" class="w-full max-w-md">
          <:title>Notifications</:title>
          <:description>Choose what you hear about</:description>
          <div class="divide-y divide-zinc-200 text-sm dark:divide-zinc-800">
            <p class="py-2">Product updates</p>
            <p class="py-2">Weekly digest</p>
            <p class="py-2">Security alerts</p>
          </div>
        </.card>
        """
      },
      %{
        id: :base_section,
        title: "Accessible section",
        layer: :base,
        description: "A card exposed as a labelled section through its own root and title id.",
        code: """
        <FlintUI.card as="section" aria-labelledby="deployments-title" title_id="deployments-title">
          <:title>Deployments</:title>
          <p>Your latest deployment is live.</p>
        </FlintUI.card>
        """
      },
      %{
        id: :base_plain,
        title: "Plain panel",
        layer: :base,
        description: "The default slot is shorthand for the first section.",
        code: """
        <FlintUI.card>
          <p>Your latest deployment is live.</p>
        </FlintUI.card>
        """
      }
    ]
  end

  @impl true
  def anatomy do
    %{
      body: """
      The card renders a root element containing an optional header, an optional
      body region, and an optional footer. The body wraps the implicit first
      section (the default slot) and any additional `:section` slots. The header
      appears when a `title`, `description`, `header_actions` or `header` slot
      is given; the footer appears when a `footer` or `footer_actions` slot is
      given. Body treatments style this region without adding a body slot.
      """,
      nodes: [
        %{
          tag: "div",
          selector: ~s([data-element="card"][data-part="root"]),
          hooks: [
            "data-variant",
            "data-body",
            "data-spacing",
            "data-outline",
            "data-shadow",
            "data-inverted",
            "data-orientation"
          ],
          attributes: ["class", "as"],
          children: [
            %{
              tag: "div",
              selector: ~s([data-part="header"]),
              children: [
                %{tag: "div", selector: ~s([data-part="title"]), children: []},
                %{tag: "div", selector: ~s([data-part="description"]), children: []},
                %{tag: "div", selector: ~s([data-part="header-actions"]), children: []},
                %{tag: "div", selector: ~s([data-part="header-content"]), children: []}
              ]
            },
            %{
              tag: "div",
              selector: ~s([data-part="body"]),
              children: [
                %{
                  tag: "div",
                  selector: ~s([data-part="section"]),
                  hooks: ["data-padded"],
                  children: []
                }
              ]
            },
            %{
              tag: "div",
              selector: ~s([data-part="footer"]),
              children: [
                %{tag: "div", selector: ~s([data-part="footer-content"]), children: []},
                %{tag: "div", selector: ~s([data-part="footer-actions"]), children: []}
              ]
            }
          ]
        }
      ]
    }
  end

  @impl true
  def styling do
    %{
      body: """
      The base card is structural. It renders a root element and `data-part`
      hooks for each region; the body wraps the default slot and any sections.
      Surface, body treatment, spacing, orientation and dividers are decisions
      for your own CSS. The generated styled component and its public variables
      are documented on the CSS tab.
      """,
      snippets: [
        %{
          title: "Root and orientation",
          code: """
          [data-element="card"] {
            display: flex;
            flex-direction: column;
          }

          [data-element="card"][data-orientation="horizontal"] {
            flex-direction: row;
          }
          """
        },
        %{
          title: "Body region",
          code: """
          [data-part="body"] {
            display: flex;
            flex-direction: column;
            gap: 1rem;
          }

          [data-element="card"][data-orientation="horizontal"] [data-part="body"] {
            flex-direction: row;
          }
          """
        },
        %{
          title: "Regions and sections",
          code: """
          [data-element="card"] [data-part="header"] {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
          }

          [data-element="card"] [data-part="footer"] {
            display: flex;
            align-items: center;
            gap: 0.75rem;
          }

          [data-part="header-actions"],
          [data-part="footer-actions"] {
            display: flex;
            align-items: center;
            gap: 0.5rem;
          }

          [data-part="footer-actions"] {
            margin-inline-start: auto;
          }

          [data-part="section"][data-padded="false"] {
            padding-inline: 0;
          }
          """
        }
      ]
    }
  end

  @impl true
  def render_playground(%{layer: :styled} = assigns) do
    ~H"""
    <Components.card
      variant={@props.variant}
      body={@props.body}
      orientation={@props.orientation}
      spacing={@props.spacing}
      outline={@props.outline}
      shadow={@props.shadow}
      inverted={@props.inverted}
    >
      <:title>Starred repositories</:title>
      <:description>Updated just now</:description>
      <:header_actions>
        <Components.button variant="ghost" size="sm">Edit</Components.button>
      </:header_actions>
      <p>Reorder or remove the repositories you follow.</p>
      <:footer>3 repositories</:footer>
      <:footer_actions>
        <Components.button variant="outline" size="sm">View logs</Components.button>
      </:footer_actions>
    </Components.card>
    """
  end

  @impl true
  def render_code(%{layer: :styled, props: props}) do
    Snippet.tag(
      ".card",
      [
        Snippet.attr("variant", props.variant, "solid"),
        Snippet.attr("body", props.body, "seamless"),
        Snippet.attr("orientation", props.orientation, "vertical"),
        Snippet.attr("spacing", props.spacing, "md"),
        Snippet.attr("outline", props.outline, true),
        Snippet.attr("shadow", props.shadow, true),
        Snippet.flag("inverted", props.inverted)
      ],
      body_code()
    )
  end

  defp body_code do
    """
    <:title>Starred repositories</:title>
    <:description>Updated just now</:description>
    <:header_actions>
      <.button variant="ghost" size="sm">Edit</.button>
    </:header_actions>
    <p>Reorder or remove the repositories you follow.</p>
    <:footer>3 repositories</:footer>
    <:footer_actions>
      <.button variant="outline" size="sm">View logs</.button>
    </:footer_actions>
    """
    |> String.trim()
  end

  @impl true
  def render_usage(%{block: :variant} = assigns) do
    ~H"""
    <div class="grid w-full max-w-3xl grid-cols-1 gap-4 sm:grid-cols-3">
      <Components.card :for={variant <- ~w(solid soft muted)} variant={variant}>
        <:title>{variant}</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :body} = assigns) do
    ~H"""
    <Components.card body="separated" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Product updates, weekly digests and security alerts.
      </p>
      <:footer>3 repositories</:footer>
    </Components.card>
    """
  end

  def render_usage(%{block: :outline} = assigns) do
    ~H"""
    <div class="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Components.card>
        <:title>Outlined</:title>
        <p>Body</p>
      </Components.card>
      <Components.card outline={false}>
        <:title>No outline</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :shadow} = assigns) do
    ~H"""
    <div class="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Components.card>
        <:title>With a shadow</:title>
        <p>Body</p>
      </Components.card>
      <Components.card shadow={false}>
        <:title>Without a shadow</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :inverted} = assigns) do
    ~H"""
    <div class="grid w-full max-w-2xl grid-cols-1 gap-4 sm:grid-cols-2">
      <Components.card inverted>
        <:title>Inverted solid</:title>
        <p>Body</p>
      </Components.card>
      <Components.card variant="muted" inverted>
        <:title>Inverted muted</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :spacing} = assigns) do
    ~H"""
    <div class="flex w-full max-w-md flex-col gap-4">
      <Components.card :for={spacing <- ~w(xs sm md lg xl)} spacing={spacing}>
        <:title>{spacing}</:title>
        <p>Body</p>
      </Components.card>
    </div>
    """
  end

  def render_usage(%{block: :footer_actions} = assigns) do
    ~H"""
    <Components.card class="w-full max-w-md">
      <:title>Deployments</:title>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Your latest deployment is live.
      </p>
      <:footer>3 repositories</:footer>
      <:footer_actions>
        <Components.button size="sm">View logs</Components.button>
        <Components.button variant="ghost" size="sm">Settings</Components.button>
      </:footer_actions>
    </Components.card>
    """
  end

  @impl true
  def render_block(%{block: :sectioned} = assigns) do
    ~H"""
    <Components.card body="divided" class="w-full max-w-md">
      <:title>Deployments</:title>
      <:description>Manage your project's deployments.</:description>
      <:header_actions>
        <Components.button variant="ghost" size="sm">Edit</Components.button>
      </:header_actions>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Your latest deployment is live.
      </p>
      <:section>
        <p class="text-sm text-zinc-600 dark:text-zinc-400">Last deployed 2 minutes ago.</p>
      </:section>
      <:footer>3 repositories</:footer>
      <:footer_actions>
        <Components.button variant="outline" size="sm">View logs</Components.button>
      </:footer_actions>
    </Components.card>
    """
  end

  def render_block(%{block: :horizontal} = assigns) do
    ~H"""
    <Components.card body="divided" orientation="horizontal" class="w-full max-w-2xl">
      <:title>Project tasks</:title>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">1887 completed</p>
      <:section>
        <p class="text-sm text-zinc-600 dark:text-zinc-400">447 remaining</p>
      </:section>
      <:section>
        <p class="text-sm text-zinc-600 dark:text-zinc-400">76 in progress</p>
      </:section>
    </Components.card>
    """
  end

  def render_block(%{block: :collapsible} = assigns) do
    ~H"""
    <Components.card padded={false} class="w-full max-w-md">
      <:section>
        <Components.collapsible id={"#{@id}-collapsible"}>
          <:trigger :let={attrs}>
            <button
              {attrs}
              class="group flex w-full items-center justify-between gap-2 px-4 py-3 text-left text-sm font-medium"
            >
              Starred repositories
              <Components.icon
                name="lucide-chevron-down"
                class="size-4 transition-transform group-aria-expanded:rotate-180"
              />
            </button>
          </:trigger>
          <:content :let={attrs}>
            <div {attrs}>
              <ul class="flex flex-col gap-2 border-t border-zinc-200 px-4 py-3 dark:border-zinc-800">
                <li>flint_ui</li>
                <li>phoenix_live_view</li>
              </ul>
            </div>
          </:content>
        </Components.collapsible>
      </:section>
    </Components.card>
    """
  end

  def render_block(%{block: :body_separated} = assigns) do
    ~H"""
    <Components.card body="separated" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <:header_actions>
        <Components.button variant="ghost" size="sm">Edit</Components.button>
      </:header_actions>
      <div class="space-y-2 text-sm">
        <p>Product updates</p>
        <p>Weekly digest</p>
        <p>Security alerts</p>
      </div>
      <:footer>3 repositories</:footer>
      <:footer_actions>
        <Components.button variant="solid" size="sm">View logs</Components.button>
      </:footer_actions>
    </Components.card>
    """
  end

  def render_block(%{block: :body_separated_muted} = assigns) do
    ~H"""
    <Components.card body="separated" variant="muted" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Product updates, weekly digests and security alerts.
      </p>
      <:footer>3 repositories</:footer>
    </Components.card>
    """
  end

  def render_block(%{block: :body_separated_footer} = assigns) do
    ~H"""
    <Components.card body="separated-footer" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Product updates, weekly digests and security alerts.
      </p>
      <:footer>3 repositories</:footer>
      <:footer_actions>
        <Components.button variant="solid" size="sm">View logs</Components.button>
      </:footer_actions>
    </Components.card>
    """
  end

  def render_block(%{block: :body_divided} = assigns) do
    ~H"""
    <Components.card body="divided" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <p class="text-sm text-zinc-600 dark:text-zinc-400">
        Product updates, weekly digests and security alerts.
      </p>
      <:footer>Last saved 2 minutes ago</:footer>
      <:footer_actions>
        <Components.button variant="ghost" size="sm">Settings</Components.button>
      </:footer_actions>
    </Components.card>
    """
  end

  def render_block(%{block: :body_inset} = assigns) do
    ~H"""
    <Components.card body="inset" variant="soft" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <div class="space-y-2 text-sm">
        <p>Product updates</p>
        <p>Weekly digest</p>
        <p>Security alerts</p>
      </div>
    </Components.card>
    """
  end

  def render_block(%{block: :body_inset_well} = assigns) do
    ~H"""
    <Components.card body="inset" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <div class="space-y-2 text-sm">
        <p>Product updates</p>
        <p>Weekly digest</p>
        <p>Security alerts</p>
      </div>
    </Components.card>
    """
  end

  def render_block(%{block: :body_flush} = assigns) do
    ~H"""
    <Components.card body="flush" variant="soft" class="w-full max-w-md">
      <:title>Notifications</:title>
      <:description>Choose what you hear about</:description>
      <div class="divide-y divide-zinc-200 text-sm dark:divide-zinc-800">
        <p class="py-2">Product updates</p>
        <p class="py-2">Weekly digest</p>
        <p class="py-2">Security alerts</p>
      </div>
    </Components.card>
    """
  end

  @impl true
  def css do
    %{
      body: """
      The generated card adds a neutral surface, optional outline and shadow,
      orientation-aware sections and dividers, and shared spacing. Header and
      footer actions align at the end of their region. `body` controls how the
      header, body and footer are set apart: seamless, separated (or one-sided
      `separated-header`/`separated-footer`), divided, inset or flush. `variant`
      selects the surface, while `outline`, `shadow`, `inverted`, and `spacing`
      adjust it. Separated bodies use the card surface with darker bands; divided
      bodies inherit the card surface; inset and flush render a panel that is a
      subtle well on light solid cards and raised in dark or on soft and muted
      cards. Inverted cards keep a well. The public inputs are
      `--fl-card-spacing`, `--fl-card-surface`, `--fl-card-surface-foreground`,
      `--fl-card-border`, and `--fl-card-shadow`; dividers, bands, and panels
      derive from them and the theme tokens.
      """,
      snippets: [
        %{
          title: "Custom surface",
          body: "Override the resolved surface, border, or elevation on one card.",
          code: """
          .accent-card {
            --fl-card-surface: var(--fl-color-primary-50);
            --fl-card-surface-foreground: var(--fl-color-primary-950);
            --fl-card-border: var(--fl-color-primary-200);
            --fl-card-shadow: var(--fl-shadow-md);
          }
          """
        },
        %{
          title: "Tighter panel",
          body: "Override the spacing on one card without changing its spacing preset.",
          code: """
          .compact-card {
            --fl-card-spacing: 0.75rem;
          }
          """
        }
      ]
    }
  end
end
