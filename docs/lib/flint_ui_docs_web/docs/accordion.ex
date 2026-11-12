defmodule FlintUIDocsWeb.Docs.Accordion do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :accordion

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
          %{key: :variant, type: :select, default: "simple", label: "Variant"},
          %{key: :surface, type: :select, default: "solid", label: "Surface"},
          %{key: :multiple, type: :boolean, default: false, label: "Multiple"}
        ]
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.preview :let={props} {assigns} code={&main_code/1}>
      <div class="w-full max-w-md">
        <Components.accordion
          id={"#{@preview_id}-accordion"}
          variant={props.variant}
          surface={props.surface}
          multiple={props.multiple}
          class="w-full"
        >
          <Components.accordion_item
            id={"#{@preview_id}-shipping"}
            label="Shipping"
            expanded
          >
            <:panel>Orders leave the warehouse in one business day.</:panel>
          </Components.accordion_item>
          <Components.accordion_item id={"#{@preview_id}-returns"} label="Returns">
            <:panel>Return any item within 30 days for a full refund.</:panel>
          </Components.accordion_item>
          <Components.accordion_item id={"#{@preview_id}-support"} label="Support">
            <:panel>Email support is included with every plan.</:panel>
          </Components.accordion_item>
        </Components.accordion>
      </div>
    </.preview>
    """
  end

  defp main_code(props) do
    Snippet.tag(
      ".accordion",
      [
        Snippet.attr("id", "faq"),
        Snippet.attr("variant", props.variant, "simple"),
        Snippet.attr("surface", props.surface, "solid")
      ],
      body_code()
    )
  end

  defp body_code do
    """
    <.accordion_item id="shipping" label="Shipping" expanded>
      <:panel>Orders leave the warehouse in one business day.</:panel>
    </.accordion_item>
    <.accordion_item id="returns" label="Returns">
      <:panel>Return any item within 30 days for a full refund.</:panel>
    </.accordion_item>
    <.accordion_item id="support" label="Support">
      <:panel>Email support is included with every plan.</:panel>
    </.accordion_item>
    """
    |> String.trim()
  end
end
