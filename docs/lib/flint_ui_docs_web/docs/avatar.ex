defmodule FlintUIDocsWeb.Docs.Avatar do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :avatar

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.Docs.Snippet

  @image "https://i.pravatar.cc/160?img=28"

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
          %{key: :shape, type: :select, default: "circle", label: "Shape"},
          %{key: :radius, type: :select, default: "none", label: "Radius"},
          %{key: :color, type: :select, default: "neutral", label: "Color"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    assigns = Map.put(assigns, :image, @image)

    ~H"""
    <.prose content="Use `src` to load an image. When it is missing or fails to load, the avatar falls back to initials from `alt`, to fixed `text`, or to a user icon when neither is set." />
    <.preview :let={props} {assigns} code={&main_code/1}>
      <div class="flex flex-wrap items-center gap-3">
        <Components.avatar
          src={@image}
          alt="Chris McCord"
          size={props.size}
          shape={props.shape}
          radius={props.radius}
          color={props.color}
        />
        <Components.avatar
          alt="Clark Kent"
          color="initials"
          size={props.size}
          shape={props.shape}
          radius={props.radius}
        />
        <Components.avatar
          alt="José Valim"
          size={props.size}
          shape={props.shape}
          radius={props.radius}
          color={props.color}
        />
        <Components.avatar
          alt="3 more members"
          text="+3"
          size={props.size}
          shape={props.shape}
          radius={props.radius}
          color={props.color}
        />
        <Components.avatar
          size={props.size}
          shape={props.shape}
          radius={props.radius}
          color={props.color}
        />
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    assigns = Map.put(assigns, :image, @image)

    ~H"""
    <div class="flex items-center gap-3">
      <Components.avatar src={@image} alt="Chris McCord" size="lg" />
      <Components.avatar alt="Jane Doe" size="lg" />
    </div>
    """
  end

  defp main_code(props) do
    attrs =
      [
        ~s(src="#{@image}"),
        ~s(alt="Jane Smith"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("shape", props.shape, "circle"),
        Snippet.attr("radius", props.radius, "none"),
        Snippet.attr("color", props.color, "neutral")
      ]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(" ")

    """
    <.avatar #{attrs} />

    <.avatar alt="Clark Kent" color="initials" />
    <.avatar alt="José Valim" />
    <.avatar alt="3 more members" text="+3" />
    <.avatar />
    """
    |> String.trim()
  end
end
