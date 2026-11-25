defmodule FlintUIDocsWeb.Docs.Modal do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :modal

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
          %{key: :size, type: :select, default: "md", label: "Size"},
          %{key: :placement, type: :select, default: "center", label: "Placement"},
          %{key: :backdrop, type: :select, default: "dim", label: "Backdrop"},
          %{key: :body, type: :select, default: "divided", label: "Body"},
          %{key: :spacing, type: :select, default: "md", label: "Spacing"}
        ]
      },
      %{tab: :styled, section: :usage, id: :sizes, title: "Sizes"},
      %{tab: :styled, section: :usage, id: :placement, title: "Placement"},
      %{tab: :styled, section: :usage, id: :backdrop, title: "Backdrop"},
      %{
        tab: :styled,
        section: :usage,
        id: :surface,
        title: "Surface",
        controls: [
          %{key: :body, type: :select, default: "separated-footer", label: "Body"},
          %{key: :spacing, type: :select, default: "md", label: "Spacing"}
        ]
      },
      %{tab: :styled, section: :usage, id: :confirmation, title: "Confirmation"},
      %{tab: :styled, section: :usage, id: :scrolling, title: "Scrolling"},
      %{tab: :styled, section: :usage, id: :controlled, title: "Controlled State"}
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content="Open the modal from a control anywhere on the page with `FlintUI.open_modal/2`, or let the server drive `opened`.
      The `:title` slot names the dialog and the `:description` slot describes it; the default slot is the scrollable body and `:footer` holds the actions.
      `size`, `placement`, and `backdrop` shape the dialog shell, and `body` and `spacing` shape the card surface behind it." />
    <.preview :let={props} {assigns} code={&basic_code/1}>
      <Components.button phx-click={FlintUI.open_modal("docs-modal-basic")}>
        Open modal
      </Components.button>

      <Components.modal
        id="docs-modal-basic"
        size={props.size}
        placement={props.placement}
        backdrop={props.backdrop}
        body={props.body}
        spacing={props.spacing}
      >
        <:title>Invite teammate</:title>
        <:description>Send an invitation to join the workspace.</:description>
        <Components.input name="email" type="email" label="Email address" />
        <:footer>
          <Components.button phx-click={FlintUI.close_modal("docs-modal-basic")}>
            Cancel
          </Components.button>
          <Components.button variant="solid" phx-click={FlintUI.close_modal("docs-modal-basic")}>
            Send invite
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :sizes} = assigns) do
    ~H"""
    <.prose content="`size` caps the dialog width. The edge gutter stays the same, so `full` fills the viewport without touching its edges." />
    <.preview {assigns} code={sizes_code()}>
      <div class="flex flex-wrap items-center justify-center gap-2">
        <Components.button
          :for={size <- ~w(sm md lg xl full)}
          phx-click={FlintUI.open_modal("docs-modal-size-#{size}")}
        >
          {size}
        </Components.button>
      </div>

      <Components.modal :for={size <- ~w(sm md lg xl full)} id={"docs-modal-size-#{size}"} size={size}>
        <:title>{String.capitalize(size)} modal</:title>
        <:description>The dialog stays inside the viewport gutter.</:description>
        <p>The width comes from the size preset.</p>
        <:footer>
          <Components.button phx-click={FlintUI.close_modal("docs-modal-size-#{size}")}>
            Close
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :placement} = assigns) do
    ~H"""
    <.prose content="`placement` anchors the dialog to an edge while keeping the other axis centered.
      Use it for a near-edge prompt, not for a full-height drawer." />
    <.preview {assigns} code={placement_code()}>
      <div class="flex flex-wrap items-center justify-center gap-2">
        <Components.button
          :for={placement <- ~w(center top bottom left right)}
          phx-click={FlintUI.open_modal("docs-modal-placement-#{placement}")}
        >
          {placement}
        </Components.button>
      </div>

      <Components.modal
        :for={placement <- ~w(center top bottom left right)}
        id={"docs-modal-placement-#{placement}"}
        placement={placement}
        size="sm"
      >
        <:title>{String.capitalize(placement)} placement</:title>
        <p>The dialog keeps the viewport gutter.</p>
        <:footer>
          <Components.button phx-click={FlintUI.close_modal("docs-modal-placement-#{placement}")}>
            Close
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :backdrop} = assigns) do
    ~H"""
    <.prose content="`backdrop` sets the treatment behind the dialog. The page stays inert in every variant; `none` only removes the visual dim." />
    <.preview {assigns} code={backdrop_code()}>
      <div class="flex flex-wrap items-center justify-center gap-2">
        <Components.button
          :for={backdrop <- ~w(dim blur none)}
          phx-click={FlintUI.open_modal("docs-modal-backdrop-#{backdrop}")}
        >
          {backdrop}
        </Components.button>
      </div>

      <Components.modal
        :for={backdrop <- ~w(dim blur none)}
        id={"docs-modal-backdrop-#{backdrop}"}
        backdrop={backdrop}
        size="sm"
      >
        <:title>{String.capitalize(backdrop)} backdrop</:title>
        <p>The page behind the dialog is inert.</p>
        <:footer>
          <Components.button phx-click={FlintUI.close_modal("docs-modal-backdrop-#{backdrop}")}>
            Close
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :surface} = assigns) do
    ~H"""
    <.prose content="The dialog is the positional shell; its surface is a `FlintUI.card`, so the region treatments come from the card.
      The card opts into the shared elevation at the top of the ladder, so its border, top highlight, ring, and depth follow `--fl-elevation-*`; retune the lift with `--fl-elevation-level`.
      `body` selects how the header, body, and footer are set apart: `divided` draws hairlines, and the `separated` values tint the bands.
      `separated-footer` gives the actions a tinted footer, and `spacing` sets the inset on every region." />
    <.preview :let={props} {assigns} code={&surface_code/1}>
      <Components.button phx-click={FlintUI.open_modal("docs-modal-surface")}>
        Open modal
      </Components.button>

      <Components.modal
        id="docs-modal-surface"
        body={props.body}
        spacing={props.spacing}
      >
        <:title>Team plan</:title>
        <:description>Update the plan for the whole workspace.</:description>
        <p>The footer band follows the same recipe as a card's.</p>
        <:footer>
          <Components.button phx-click={FlintUI.close_modal("docs-modal-surface")}>
            Cancel
          </Components.button>
          <Components.button
            variant="solid"
            phx-click={FlintUI.close_modal("docs-modal-surface")}
          >
            Save plan
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :confirmation} = assigns) do
    ~H"""
    <.prose content={
      ~s(A confirmation is a `role="alertdialog"` modal with no backdrop dismissal, an explicit close, and `autofocus` on the least destructive action.
      The description carries the consequence, so it is wired as the dialog's `aria-describedby`.)
    } />
    <.preview {assigns} code={confirmation_code()}>
      <Components.button
        color="danger"
        variant="solid"
        phx-click={FlintUI.open_modal("docs-modal-confirm")}
      >
        Archive project
      </Components.button>

      <Components.modal
        id="docs-modal-confirm"
        role="alertdialog"
        size="sm"
        show_close={false}
        close_on_backdrop={false}
      >
        <:title>Archive project?</:title>
        <:description>You can restore it from the trash within 30 days.</:description>
        <:footer>
          <Components.button
            autofocus
            phx-click={FlintUI.close_modal("docs-modal-confirm")}
          >
            Cancel
          </Components.button>
          <Components.button
            color="danger"
            variant="solid"
            phx-click={FlintUI.close_modal("docs-modal-confirm")}
          >
            Archive
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :scrolling} = assigns) do
    ~H"""
    <.prose content="The header and footer stay pinned while the body scrolls. The dialog never grows past the viewport gutter." />
    <.preview {assigns} code={scrolling_code()}>
      <Components.button phx-click={FlintUI.open_modal("docs-modal-scroll")}>
        Open long modal
      </Components.button>

      <Components.modal id="docs-modal-scroll" size="md">
        <:title>Recent activity</:title>
        <:description>Scroll the body without losing the actions.</:description>
        <p :for={index <- 1..24} class="py-2">
          Activity item {index}
        </p>
        <:footer>
          <Components.button phx-click={FlintUI.close_modal("docs-modal-scroll")}>
            Close
          </Components.button>
        </:footer>
      </Components.modal>
    </.preview>
    """
  end

  def render_section(%{section: :usage, id: :controlled} = assigns) do
    ~H"""
    <.prose content="`opened` is the server-driven state. Set `close_event` (and optionally `open_event` or `toggle_event`) to push user changes back to the server.
      Server-driven changes do not echo those events." />
    <.preview {assigns} code={controlled_code()} code_only />
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="flex fl-w-full justify-center py-6">
      <dialog
        id={"#{@parts_id}-dialog"}
        open
        data-element="modal"
        data-part="root"
        data-modal
        data-state="open"
        data-size="md"
        data-placement="center"
        data-backdrop="dim"
        class="m-0 fl-w-full fl-max-w-md"
        style="position: relative; inset: auto; max-height: none;"
      >
        <div data-part="content" tabindex="-1">
          <div
            data-element="card"
            data-card
            data-part="root"
            data-body="separated-footer"
            data-spacing="md"
          >
            <header data-part="header">
              <h2 data-part="title" id={"#{@parts_id}-title"}>Invite teammate</h2>
              <p data-part="description" id={"#{@parts_id}-description"}>
                Send an invitation to join the workspace.
              </p>
            </header>
            <div data-part="body">
              <div data-part="section" data-padded>
                <p>The body scrolls independently of the header and footer.</p>
              </div>
            </div>
            <div data-part="footer">
              <div data-part="footer-actions">
                <Components.button size="sm" variant="surface">Cancel</Components.button>
                <Components.button size="sm" variant="solid">Send invite</Components.button>
              </div>
            </div>
          </div>
          <button type="button" data-part="close" aria-label="Close">
            <Components.icon name="lucide-x" size="sm" />
          </button>
        </div>
      </dialog>
    </div>
    """
  end

  defp basic_code(props) do
    Snippet.tag(
      ".modal",
      [
        ~s(id="invite"),
        Snippet.attr("size", props.size, "md"),
        Snippet.attr("placement", props.placement, "center"),
        Snippet.attr("backdrop", props.backdrop, "dim"),
        Snippet.attr("body", props.body, "divided"),
        Snippet.attr("spacing", props.spacing, "md")
      ],
      """
      <:title>Invite teammate</:title>
      <:description>Send an invitation to join the workspace.</:description>
      <.input name="email" type="email" label="Email address" />
      <:footer>
        <.button phx-click={FlintUI.close_modal("invite")}>Cancel</.button>
        <.button variant="solid" phx-click={FlintUI.close_modal("invite")}>Send invite</.button>
      </:footer>
      """
    )
  end

  defp surface_code(props) do
    Snippet.tag(
      ".modal",
      [
        ~s(id="team-plan"),
        Snippet.attr("body", props.body, "divided"),
        Snippet.attr("spacing", props.spacing, "md")
      ],
      """
      <:title>Team plan</:title>
      <:description>Update the plan for the whole workspace.</:description>
      <p>The footer band follows the same recipe as a card's.</p>
      <:footer>
        <.button phx-click={FlintUI.close_modal("team-plan")}>Cancel</.button>
        <.button variant="solid" phx-click={FlintUI.close_modal("team-plan")}>Save plan</.button>
      </:footer>
      """
    )
  end

  defp sizes_code do
    """
    <.button phx-click={FlintUI.open_modal("invite")}>Open modal</.button>

    <.modal id="invite" size="lg">
      <:title>Invite teammate</:title>
      <:description>The dialog stays inside the viewport gutter.</:description>
      <p>The width comes from the size preset.</p>
      <:footer>
        <.button phx-click={FlintUI.close_modal("invite")}>Close</.button>
      </:footer>
    </.modal>
    """
    |> String.trim()
  end

  defp placement_code do
    """
    <.modal id="invite" placement="top" size="sm">
      <:title>Top placement</:title>
      <p>The dialog keeps the viewport gutter.</p>
    </.modal>
    """
    |> String.trim()
  end

  defp backdrop_code do
    """
    <.modal id="invite" backdrop="blur" size="sm">
      <:title>Frosted backdrop</:title>
      <p>The page behind the dialog is inert.</p>
    </.modal>
    """
    |> String.trim()
  end

  defp confirmation_code do
    """
    <.modal id="archive" role="alertdialog" show_close={false} close_on_backdrop={false}>
      <:title>Archive project?</:title>
      <:description>You can restore it from the trash within 30 days.</:description>
      <:footer>
        <.button autofocus phx-click={FlintUI.close_modal("archive")}>Cancel</.button>
        <.button color="danger" variant="solid" phx-click={FlintUI.close_modal("archive")}>
          Archive
        </.button>
      </:footer>
    </.modal>
    """
    |> String.trim()
  end

  defp scrolling_code do
    """
    <.modal id="activity" size="md">
      <:title>Recent activity</:title>
      <:description>Scroll the body without losing the actions.</:description>
      <p :for={item <- @items}>{item}</p>
      <:footer>
        <.button phx-click={FlintUI.close_modal("activity")}>Close</.button>
      </:footer>
    </.modal>
    """
    |> String.trim()
  end

  defp controlled_code do
    """
    <.modal id="payment" opened={@payment_open} close_event="close_payment">
      <:title>Confirm payment</:title>
      <p>The server owns the open state.</p>
    </.modal>

    def handle_event("close_payment", %{"id" => "payment"}, socket) do
      {:noreply, assign(socket, :payment_open, false)}
    end
    """
    |> String.trim()
  end
end
