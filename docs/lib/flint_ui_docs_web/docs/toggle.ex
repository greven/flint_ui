defmodule FlintUIDocsWeb.Docs.Toggle do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :toggle

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
        title: "Usage",
        controls: [
          %{key: :pressed, type: :boolean, default: false, label: "Pressed"},
          %{key: :variant, type: :select, default: "solid", label: "Variant"},
          %{key: :color, type: :select, default: "neutral", label: "Color"},
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :radius, type: :select, default: "md", label: "Radius"},
          %{key: :disabled, type: :boolean, default: false, label: "Disabled"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <Components.toggle
        variant={props.variant}
        color={props.color}
        size={props.size}
        radius={props.radius}
        pressed={props.pressed}
        disabled={props.disabled}
      >
        <.icon name="lucide-bold" /> Bold
      </Components.toggle>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".toggle",
      [
        Snippet.attr("variant", props.variant, "solid"),
        Snippet.attr("color", props.color, "neutral"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("radius", props.radius, "md"),
        Snippet.flag("pressed", props.pressed),
        Snippet.flag("disabled", props.disabled)
      ],
      ~s(<.icon name="lucide-bold" /> Bold)
    )
  end
end
