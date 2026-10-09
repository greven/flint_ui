defmodule FlintUIDocsWeb.Router do
  use FlintUIDocsWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {FlintUIDocsWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FlintUIDocsWeb do
    pipe_through(:browser)

    live("/", OverviewLive, :index)
    live("/components/:name", ComponentLive, :show)
  end

  # Other scopes may use custom stacks.
  # scope "/api", FlintUIDocsWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:flint_ui_docs, :dev_routes) do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
