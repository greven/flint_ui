defmodule FlintUIDocsWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use FlintUIDocsWeb, :controller
      use FlintUIDocsWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  @doc """
  Returns a static asset path with a dev-only cache-busting query.

  Production relies on the digested asset URLs from the cache manifest. In
  development there is no manifest, so browsers (and some proxies) can keep
  serving an older `app.css` even after a hard reload. Hashing the built file
  makes each rebuilt asset a new URL, so the browser has to fetch
  it.
  """
  def asset_path(path) when is_binary(path) do
    if Application.get_env(:flint_ui_docs, :asset_version, false) do
      path <> "?v=" <> asset_version(path)
    else
      path
    end
  end

  defp asset_version(path) do
    file =
      Path.join([
        to_string(:code.priv_dir(:flint_ui_docs)),
        "static",
        String.trim_leading(path, "/")
      ])

    case File.read(file) do
      {:ok, contents} ->
        contents
        |> then(&:crypto.hash(:sha256, &1))
        |> Base.encode16(case: :lower)
        |> binary_part(0, 12)

      _ ->
        "0"
    end
  end

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      use Gettext, backend: FlintUIDocsWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: FlintUIDocsWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      import FlintUIDocsWeb.CoreComponents

      # FlintUI components (button, collapsible, ...)
      import FlintUIDocsWeb.FlintComponents

      # Dev-only cache-busting for built assets.
      import FlintUIDocsWeb, only: [asset_path: 1]

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias FlintUIDocsWeb.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: FlintUIDocsWeb.Endpoint,
        router: FlintUIDocsWeb.Router,
        statics: FlintUIDocsWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
