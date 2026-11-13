defmodule FlintUIDocsWeb.Docs.Page do
  @moduledoc """
  Behaviour for a single component's docs page content.

  A page module owns the title, subtitle, base-docs selection, the section
  outline, and the rendered content for its component. The framework generates
  the API reference, the setup section, and the CSS tab's tables from the
  component and styled entry.

  ## Page shape

  Every page has three tabs:

    * **Styled**: authored `tab: :styled` sections, then the generated API
      reference and setup.
    * **Base**: the moduledoc sections selected by `base_docs/0`, plus any
      authored `tab: :base` sections, then the generated API reference.
    * **CSS**: authored `tab: :css` sections around the generated CSS parts,
      CSS variables, selector, and state-selector tables. The CSS parts table is
      interactive: hovering a part in the preview highlights its row and vice
      versa, using the demo returned by `parts_demo/1`. State selectors are
      rendered only when the component declares `states/0`.

  ## Section outline

  `sections/0` is the outline: it defines the order, tabs, group keys, anchors,
  headings, and preview controls. It does not contain content. A section has a
  `:section` key (the top-level group, e.g. `:usage`, `:examples`), an optional
  `:id` (the subsection within the group), and optional metadata:

      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage",
        group_title: nil,
        controls: [%{key: :color, type: :select, default: "neutral", label: "Color"}]
      }

  Sections with the same `{tab, section}` stack in declaration order. The first
  section's `:title` becomes the top-level `h2`, and every later section renders
  as an `h3` subsection with its own `:title`. Set `:group_title` on the first
  section when the group needs a heading of its own: the `h2` uses
  `:group_title` and every section, including the first, renders as an `h3`. A
  section without a `:title` renders no heading. The section key itself is never
  used as a title.

  `:controls` stays in the outline because the LiveView needs the control schema
  before it renders a preview and when it coerces change events. Everything else
  belongs in `render_section/1`.

  ## Rendering a section

  `render_section/1` is a plain function clause and owns all content: prose,
  previews, code, feature lists, and snippets. Match on the `:section` and `:id`
  you declared:

      def render_section(%{section: :usage, id: :variant} = assigns) do
        ~H\"\"\"
        <Markdown.prose content="Use the `variant` attr to change the emphasis." />
        <.preview {assigns} code={~s(<.button variant="solid">Save</.button>)}>
          <Components.button variant="solid">Save</Components.button>
        </.preview>
        \"\"\"
      end

  `assigns` carries the outline metadata plus `:name`, `:tab`, `:preview_id`, and
  `:state`. Pass the whole map to `<.preview {assigns}>` and the preview inherits
  its id, component name, controls, source, and state. Explicit attributes
  override it; pass `code`, `codes`, `collapsed`, `resizable`, `canvas_class`,
  `preview_only`, and `code_only` on the preview call. Use
  `<DocsComponents.features>` and `<DocsComponents.snippets>` for structured
  blocks that used to live in the section map.

  Keep the `render_section/1` clauses together; Elixir warns when clauses of the
  same function are separated by other definitions. A section without a clause
  renders an empty section, so heading-only sections need no no-op clause.

  ## Prose

  `<Markdown.prose content="..." />` renders CommonMark/GFM prose with links,
  emphasis, lists, tables, autolinks, and highlighted code. Raw HTML is not
  passed through. When prose needs live components or route-checked `~p` links,
  use the component's inner block; it is rendered as HEEx, not Markdown.

  ## Base docs

  `base_docs/0` selects what the Base tab renders:

    * `:all` - the moduledoc intro, every `##` section, `:anatomy` when the page
      defines `anatomy/0`, and `:api`.
    * a list - the listed keys, in order. Keys are moduledoc section slugs,
      `:intro`, `:api`, `:anatomy`, or `:keyboard`. `{key, "Title"}` overrides
      the heading. `:api` is appended when the list omits it.

  `:keyboard` renders the table built from the component's `keyboard/0`, and
  only falls back to the `## Keyboard` moduledoc body when the component
  declares no keyboard metadata. Keep the moduledoc list as the source of truth
  for the component; the docs page will not render it twice.

  Authored `tab: :base` sections merge into the matching moduledoc section, or
  become their own section when no matching key exists.

  Authored `tab: :css` sections render above the generated CSS tables by
  default. Set `position: :after` to render below them.

  ## Previews

  Every preview is a `<.preview>` call. The demo is the inner block; the
  teaching snippet comes from the preview's `code` (or `codes`). Pass `code` as
  a string or as a 1-arity function of the current props, which keeps the
  playground snippet in step with its controls.

  Use `codes` when a preview needs several snippets. Each flavor becomes a tab:

      codes={[
        heex: "<.button color=\\"#009966\\">Common</.button>",
        css: "[data-element=\\"button\\"] { --fl-button-color: #009966; }"
      ]}

  A flavor map can override the auto-generated label with `label`, and set
  `lang` for highlighting. The code panel is expandable by default; pass
  `collapsed` to start it closed. Pass `resizable` to add the resize handle, or
  `canvas_class` to give the demo a surface other than the page background.

  When a section only needs to show a snippet, pass `code_only` to drop the demo
  canvas and controls while keeping the header, flavors, source toggle, copy
  button, and collapse. A code-only preview still needs `code` or `codes` and
  cannot also set `preview_only`.
  """

  @type section :: %{
          required(:section) => atom(),
          optional(:tab) => :styled | :base | :css,
          optional(:id) => atom() | nil,
          optional(:title) => String.t() | nil,
          optional(:group_title) => String.t() | nil,
          optional(:controls) => [map()] | nil,
          optional(:preview_id) => String.t() | nil,
          optional(:position) => :before | :after
        }

  @callback component() :: atom()
  @callback title() :: String.t()
  @callback subtitle() :: String.t()
  @callback meta() :: FlintUI.Meta.t()
  @callback base_docs() :: :all | [atom() | {atom(), String.t()}]
  @callback sections() :: [section()]
  @callback render_section(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil
  @callback anatomy() :: map() | nil
  @callback parts_demo(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil
  @callback styling() :: map() | nil
  @callback api_only?() :: boolean()

  defmacro __using__(opts) do
    component = Keyword.fetch!(opts, :component)

    quote do
      @behaviour FlintUIDocsWeb.Docs.Page

      use FlintUI
      import FlintUIDocsWeb.Preview
      import FlintUIDocsWeb.Markdown, only: [prose: 1]

      @component unquote(component)

      @doc "The component this page documents."
      def component, do: @component

      @doc "The page title. Override when the component name is not enough."
      def title do
        @component
        |> Atom.to_string()
        |> String.split("_")
        |> Enum.map_join(" ", &String.capitalize/1)
      end

      @doc "A short description shown under the title."
      def subtitle, do: FlintUI.Docs.description(@component)

      @doc "The component metadata shown in the page header."
      def meta, do: FlintUI.Docs.meta(@component)

      @doc "The section outline. See `FlintUIDocsWeb.Docs.Page`."
      def sections, do: []

      @doc "Renders one authored section. Match on `:section` and `:id`."
      def render_section(_assigns), do: nil

      @doc "Structured anatomy for the Base tab, or `nil`."
      def anatomy, do: nil

      @doc """
      The demo rendered above the CSS parts table.

      Return the component markup with the parts this page documents. The
      generated CSS tab wraps it in the interactive parts canvas, so the demo
      needs no preview card or controls. `assigns` carries `:name` and
      `:parts_id`, a unique DOM id prefix for the rendered component.
      """
      def parts_demo(_assigns), do: nil

      @doc "Plain-CSS recipes for the Styling guide, or `nil`."
      def styling, do: nil

      @doc """
      Whether the page is an API-only companion page.

      An API-only page keeps the Styled Usage callout, the generated API and
      setup sections, and the CSS contract tables, but it renders no preview and
      may select `base_docs: [:api]`.
      """
      def api_only?, do: false

      defoverridable component: 0,
                     title: 0,
                     subtitle: 0,
                     meta: 0,
                     sections: 0,
                     render_section: 1,
                     anatomy: 0,
                     parts_demo: 1,
                     styling: 0,
                     api_only?: 0
    end
  end
end
