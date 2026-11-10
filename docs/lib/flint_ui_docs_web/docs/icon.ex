defmodule FlintUIDocsWeb.Docs.Icon do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :icon

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  # Tailwind's Lucide plugin is JIT: it only emits the CSS for classes it finds
  # as literal text in a scanned source file. Keep these names as literals so
  # the playground can offer only icons the docs bundle actually generated.
  @icons ~w(
    lucide-house lucide-wifi lucide-mail lucide-bell lucide-search lucide-user
    lucide-users lucide-settings lucide-heart lucide-star lucide-check lucide-x
    lucide-plus lucide-minus lucide-arrow-left lucide-arrow-right
    lucide-chevron-down lucide-circle-alert lucide-circle-check lucide-info
    lucide-triangle-alert lucide-calendar-days lucide-clock lucide-download
    lucide-upload lucide-trash lucide-pencil lucide-copy lucide-link lucide-lock
    lucide-eye lucide-sun lucide-moon lucide-volume-2 lucide-play lucide-pause
    lucide-refresh-cw lucide-loader-circle lucide-palette lucide-code-xml
    lucide-image lucide-file lucide-folder lucide-shopping-cart
    lucide-credit-card lucide-map-pin lucide-phone
  )

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
          %{key: :name, type: :select, values: @icons, default: "lucide-house", label: "Icon"},
          %{key: :size, type: :select, default: "md", label: "Size"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="FlintUI does not ship icon assets. See the [Icons guide](/guides/icons) to install Lucide, Heroicons, or Simple Icons with Tailwind or plain CSS." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.icon name={props.name} size={props.size} />
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.component(
      ".icon",
      [
        Snippet.attr("name", props.name),
        Snippet.attr("size", props.size, "md")
      ]
    )
  end
end
