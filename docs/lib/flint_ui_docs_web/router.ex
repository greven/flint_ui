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

    live("/", HomeLive, :index)

    get("/getting-started", RedirectController, :getting_started)
    live("/getting-started/introduction", IntroductionLive, :index)
    live("/getting-started/installation", GettingStartedLive, :index)
    live("/getting-started/styling", StylingLive, :index)

    get("/guides", RedirectController, :guides)
    live("/guides/theming", ThemeLive, :index)

    live("/components", ComponentsLive, :index)
    live("/components/:name", ComponentLive, :show)
  end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:flint_ui_docs, :dev_routes) do
    scope "/dev" do
      pipe_through(:browser)

      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
