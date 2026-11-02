defmodule FlintUIDocsWeb.Docs.Page do
  @moduledoc """
  Behaviour for a single component's docs page content.

  A page module owns the title, subtitle, base-docs selection, and the authored
  sections for its component. The framework generates the API reference, the
  setup section, and the CSS tab's tables from the component and styled entry.

  ## Page shape

  Every page has three tabs:

    * **Styled**: authored `tab: :styled` sections, then the generated API
      reference and setup.
    * **Base**: the moduledoc sections selected by `base_docs/0`, plus any
      authored `tab: :base` sections, then the generated API reference.
    * **CSS**: authored `tab: :css` sections around the generated CSS variables,
      selectors, and theme-token tables.

  ## Sections

  Sections are plain maps returned by `sections/0`. A section has a `:section`
  key (the top-level group, e.g. `:main`, `:usage`, `:examples`), an optional
  `:id` (the subsection within the group), and optional content keys:

      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage",
        description: "A short line under the heading.",
        body: "Markdown prose above the example.",
        code: "the teaching snippet",
        codes: [%{label: "Tailwind", code: "..."}],
        controls: [%{key: :variant, type: :select, default: "outline", label: "Variant"}],
        features: ["A feature bullet"],
        snippets: [%{title: "Retint", body: "...", code: "..."}],
        preview_only: false
      }

  Sections with the same `{tab, section}` stack in declaration order. The first
  section's `:title` (or `:group_title`) becomes the top-level `h2`; the
  remaining sections render as `h3` subsections with their own `:title`. A
  section without a `:title` renders no heading. The section key itself is never
  used as a title. Set `:group_title` on the first section only when the `h2`
  should differ from that section's own `:title`.

  ## Rendering a section

  `render_section/1` is a plain function clause. Match on the `:section` and
  `:id` you declared:

      def render_section(%{section: :usage, id: :variant} = assigns) do
        ~H\"\"\"
        <.preview {assigns}>
          <Components.button variant="solid">Save</Components.button>
        </.preview>
        \"\"\"
      end

  `assigns` already carries the section metadata plus `:name`, `:tab`,
  `:preview_id`, and `:state`. Pass the whole map to `<.preview {assigns}>` and
  the preview inherits its id, component name, controls, code, source, and
  state. Explicit props still override it.

  Keep the `render_section/1` clauses together; Elixir warns when clauses of the
  same function are separated by other definitions.

  When a section has no `render_section/1` clause, the framework renders its
  `body`, `features`, and `code`/`codes`/`snippets` automatically. That covers
  prose-only and code-only sections without a render callback.

  ## Base docs

  `base_docs/0` selects what the Base tab renders:

    * `:all` - the moduledoc intro, every `##` section, `:anatomy` when the page
      defines `anatomy/0`, and `:api`.
    * a list - the listed keys, in order. Keys are moduledoc section slugs,
      `:intro`, `:api`, `:anatomy`, or `:keyboard`. `{key, "Title"}` overrides
      the heading. `:api` is appended when the list omits it.

  Authored `tab: :base` sections merge into the matching moduledoc section, or
  become their own section when no matching key exists.

  Authored `tab: :css` sections render above the generated CSS tables by
  default. Set `position: :after` to render below them.

  ## Previews

  Every preview is a `<.preview>` call. The demo is the inner block; the
  teaching snippet comes from the section's `code` (or `codes`) and stays in one
  place with the section. `code` also accepts a 1-arity function of the current
  props, which keeps the playground snippet in step with its controls.
  """

  @type section :: %{
          required(:section) => atom(),
          optional(:tab) => :styled | :base | :css,
          optional(:id) => atom() | nil,
          optional(:title) => String.t() | nil,
          optional(:description) => String.t() | nil,
          optional(:body) => String.t() | nil,
          optional(:code) => String.t() | (map() -> String.t()) | nil,
          optional(:codes) => [map()] | nil,
          optional(:controls) => [map()] | nil,
          optional(:features) => [String.t() | map()] | nil,
          optional(:snippets) => [map()] | nil,
          optional(:preview_only) => boolean(),
          optional(:group_title) => String.t() | nil,
          optional(:position) => :before | :after,
          optional(:preview_id) => String.t()
        }

  @callback component() :: atom()
  @callback title() :: String.t()
  @callback subtitle() :: String.t()
  @callback meta() :: FlintUI.Meta.t()
  @callback base_docs() :: :all | [atom() | {atom(), String.t()}]
  @callback sections() :: [section()]
  @callback render_section(assigns :: map()) :: Phoenix.LiveView.Rendered.t() | nil
  @callback anatomy() :: map() | nil
  @callback styling() :: map() | nil

  defmacro __using__(opts) do
    component = Keyword.fetch!(opts, :component)

    quote do
      @behaviour FlintUIDocsWeb.Docs.Page

      use FlintUI
      import FlintUIDocsWeb.Preview

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

      @doc "Authored sections. See `FlintUIDocsWeb.Docs.Page`."
      def sections, do: []

      @doc "Renders one authored section. Match on `:section` and `:id`."
      def render_section(_assigns), do: nil

      @doc "Structured anatomy for the Base tab, or `nil`."
      def anatomy, do: nil

      @doc "Plain-CSS recipes for the Styling guide, or `nil`."
      def styling, do: nil

      defoverridable component: 0,
                     title: 0,
                     subtitle: 0,
                     meta: 0,
                     sections: 0,
                     render_section: 1,
                     anatomy: 0,
                     styling: 0
    end
  end
end
