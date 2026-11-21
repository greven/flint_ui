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
    live("/themes", ThemesLive, :index)

    get("/getting-started", RedirectController, :getting_started)
    live("/getting-started/introduction", IntroductionLive, :index)
    live("/getting-started/installation", GettingStartedLive, :index)
    live("/getting-started/styling", StylingLive, :index)

    get("/guides", RedirectController, :guides)

    live("/guides/theming", Theme.OverviewLive, :index)
    live("/guides/theming/color", Theme.ColorLive, :index)
    live("/guides/theming/themes", Theme.ThemesLive, :index)
    live("/guides/theming/tokens", Theme.TokensLive, :index)
    live("/guides/theming/tokens/colors", Theme.TokenLive, :colors)
    live("/guides/theming/tokens/typography", Theme.TokenLive, :typography)
    live("/guides/theming/tokens/spacing", Theme.TokenLive, :spacing)
    live("/guides/theming/tokens/radius", Theme.TokenLive, :radius)
    live("/guides/theming/tokens/borders", Theme.TokenLive, :borders)
    live("/guides/theming/tokens/surfaces", Theme.TokenLive, :surfaces)
    live("/guides/theming/tokens/shadows", Theme.TokenLive, :shadows)
    live("/guides/theming/tokens/focus", Theme.TokenLive, :focus)
    live("/guides/theming/tokens/transitions", Theme.TokenLive, :transitions)
    live("/guides/theming/customizing", Theme.CustomizingLive, :index)
    live("/guides/theming/css-utilities", Theme.CssUtilitiesLive, :index)

    live("/guides/sound", SoundLive, :index)
    live("/guides/icons", IconsLive, :index)
    live("/guides/flags", FlagsLive, :index)

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
