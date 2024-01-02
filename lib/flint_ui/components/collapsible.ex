defmodule FlintUI.Collapsible do
  @moduledoc false

  use FlintUI.API
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  @toggle_event "fl:collapsible:toggle"

  def use_collapsible(assigns) do
    assigns
    |> assign_new(:id, &use_id/0)
    |> create_elements()
  end

  defp create_elements(assigns) do
    %{id: id, open: open, disabled: disabled} = assigns

    root = %{
      "id" => id,
      "phx-hook" => "Collapsible",
      "data-collapsible-root" => true,
      "data-state" => if(open, do: "open", else: "closed"),
      "data-disabled" => if(disabled, do: true, else: false)
    }

    trigger = %{
      "id" => "#{id}-trigger",
      "data-collapsible-trigger" => true,
      "data-state" => if(open, do: "open", else: "closed"),
      "data-disabled" => if(disabled, do: true, else: false),
      "role" => "button",
      "aria-expanded" => if(open, do: "true", else: "false"),
      "aria-controls" => "#{id}-content",
      "phx-click" => JS.dispatch(@toggle_event)
    }

    content =
      %{
        "id" => "#{id}-content",
        "hidden" => !open,
        "data-collapsible-content" => true,
        "aria-hidden" => if(open, do: "false", else: "true")
      }

    %{
      root: root,
      trigger: trigger,
      content: content
    }
  end
end
