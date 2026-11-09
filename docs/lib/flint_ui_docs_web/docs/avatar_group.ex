defmodule FlintUIDocsWeb.Docs.AvatarGroup do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :avatar_group

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @avatars [
    %{src: "https://i.pravatar.cc/160?img=12", name: "John Smith"},
    %{src: "https://i.pravatar.cc/160?img=32", name: "Jane Doe"},
    %{src: "https://i.pravatar.cc/160?img=5", name: "Joan Wood"},
    %{name: "Chris McCord"}
  ]

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
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :overlap, type: :select, default: "md", label: "Overlap"},
          %{key: :ring, type: :boolean, default: false, label: "Ring"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    assigns = Map.put(assigns, :avatars, @avatars)

    ~H"""
    <.prose content="Pass [avatars](/components/avatar) directly as children. The group handles the overlap, size cascade, and optional surface ring.
      Overflow is caller-controlled, for example with a final avatar named `+3`." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.avatar_group
        label="Project members"
        size={props.size}
        overlap={props.overlap}
        ring={props.ring}
      >
        <Components.avatar :for={avatar <- @avatars} src={avatar[:src]} name={avatar[:name]} />
      </Components.avatar_group>
    </.preview>
    """
  end

  defp main_code(props) do
    attrs =
      [
        ~s(label="Project members"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("overlap", props.overlap, "md"),
        Snippet.flag("ring", props.ring)
      ]

    body =
      Enum.map_join(@avatars, "\n", fn avatar ->
        attrs =
          [
            avatar[:src] && ~s(src="#{avatar[:src]}"),
            ~s(name="#{avatar[:name]}")
          ]

        Snippet.component(".avatar", attrs)
      end)

    Snippet.tag(".avatar_group", attrs, body)
  end
end
