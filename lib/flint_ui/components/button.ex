defmodule FlintUI.Button do
  @moduledoc """
  Renders a button that performs an action, or a link styled as a button.

  ## Examples

      <.button>Save</.button>
      <.button type="submit">Save</.button>
      <.button phx-click="delete" disabled>Delete</.button>
      <.button loading aria-label="Saving">Save</.button>

  While `loading`, the button sets `aria-busy`, disables interaction, and is
  marked with `data-loading`. FlintUI is unstyled, so add an indicator yourself
  when you want one:

      <.button loading>
        <.icon :if={@loading} name="lucide-loader-circle" class="size-4 animate-spin" />
        Save
      </.button>

  Pass `href`, `navigate`, or `patch` to render a link instead of a button:

      <.button navigate={~p"/settings"}>Settings</.button>
      <.button patch={~p"/settings?tab=profile"}>Profile</.button>
      <.button href="https://example.com" target="_blank" rel="noopener">
        Visit
      </.button>

  ## Accessibility

  Always provide an accessible name. The content is the name in most cases, so
  prefix an icon-only button with `aria-label` or `aria-labelledby`.

  Action buttons render a native `<button>`, which browsers expose with an
  implicit `button` role and activate with both `Enter` and `Space`. Links
  render a native `<a>`, are exposed with an implicit `link` role, and are
  activated with `Enter` only.

  When `disabled` is set on a link, the `href`, `navigate`, or `patch`
  destination is removed, the link is marked with `aria-disabled="true"`, and it
  stays in the tab order so its state can be discovered. It cannot be activated.

  While `loading` is set the button is disabled and marked with `aria-busy="true"`
  and `data-loading`.

  ## Keyboard

  - `Enter` - activates a button or a link.
  - `Space` - activates a button. Has no effect on a link.
  """

  use FlintUI.Component

  @impl true
  def meta do
    %Meta{
      name: :button,
      type: :element,
      since: "0.1.0",
      status: :stable
    }
  end

  @impl true
  def parts_attrs do
    %{
      root: [
        %Meta.PartAttr{
          name: "[data-element]",
          value: "button",
          description: "Identifies the component type. Shared by the button and link forms."
        },
        %Meta.PartAttr{
          name: "[data-part]",
          value: "root",
          description: "Identifies the root element."
        },
        %Meta.PartAttr{
          name: "[data-disabled]",
          value: "boolean",
          description:
            "Present when the button cannot be interacted with, either because `disabled` or `loading` is set."
        },
        %Meta.PartAttr{
          name: "[data-loading]",
          value: "boolean",
          description: "Present when `loading` is set."
        },
        %Meta.PartAttr{
          name: "aria-busy",
          value: ~s("true"),
          description: "Set to `\"true\"` while `loading` is set."
        },
        %Meta.PartAttr{
          name: "type",
          value: ~s("button" | "submit" | "reset"),
          description: "The button type. Rendered only for an action button."
        },
        %Meta.PartAttr{
          name: "disabled",
          value: "boolean",
          description: "Disables the action button. Rendered only for an action button."
        }
      ]
    }
  end

  @impl true
  def keyboard do
    [
      %Meta.Keyboard{keys: "Enter", description: "Activates an action button or a link."},
      %Meta.Keyboard{
        keys: "Space",
        description: "Activates an action button. Has no effect on a link."
      }
    ]
  end

  @impl true
  def build_attrs(assigns) do
    %{
      root: %{
        "data-element" => "button",
        "data-part" => "root",
        "data-disabled" => disabled?(assigns),
        "data-loading" => assigns.loading,
        "aria-busy" => assigns.loading && "true"
      }
    }
  end

  @doc false

  attr(:flint_parts, :map, default: nil)

  attr(:type, :string,
    default: "button",
    values: ~w(button submit reset),
    doc: "The button type, defaults to `button`. Rendered only for an action button."
  )

  attr(:disabled, :boolean,
    default: false,
    doc: "Whether the button should ignore user interaction."
  )

  attr(:loading, :boolean,
    default: false,
    doc:
      "Whether the button is in a loading state. Sets `aria-busy` and `data-loading`, and suppresses interaction."
  )

  attr(:rest, :global,
    include: ~w(href navigate patch replace method csrf_token target rel download
                hreflang referrerpolicy name value form formaction formenctype
                formmethod formnovalidate formtarget popovertarget autofocus
                command commandfor),
    doc:
      "Additional HTML attributes. Pass `href`, `navigate`, or `patch` to render a link instead of a button."
  )

  slot(:inner_block, required: true, doc: "The content of the button.")

  @impl true
  def render(assigns) do
    cond do
      link?(assigns) && disabled?(assigns) ->
        assigns = assign(assigns, :rest, drop_navigation(assigns.rest))

        ~H"""
        <a role="link" aria-disabled="true" tabindex="0" {@flint_parts[:root]} {@rest}>
          {render_slot(@inner_block)}
        </a>
        """

      link?(assigns) ->
        ~H"""
        <.link {@flint_parts[:root]} {@rest}>{render_slot(@inner_block)}</.link>
        """

      true ->
        ~H"""
        <button type={@type} disabled={@disabled || @loading} {@flint_parts[:root]} {@rest}>
          {render_slot(@inner_block)}
        </button>
        """
    end
  end

  defp link?(assigns) do
    rest = Map.get(assigns, :rest, %{})
    rest[:href] || rest[:navigate] || rest[:patch]
  end

  defp disabled?(assigns), do: assigns.disabled || assigns.loading

  defp drop_navigation(rest) do
    Map.drop(rest, [:href, :navigate, :patch, :replace, :method, :csrf_token])
  end
end
