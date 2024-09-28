defmodule VoidWeb.Router do
  use VoidWeb, :router

  import VoidWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug VoidWeb.Plugs.SetUserToken
    plug :put_root_layout, html: {VoidWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", VoidWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :home
  end

  scope "/auth/github", VoidWeb do
    pipe_through [:browser]
    get "/", GithubAuthController, :request
    get "/callback", GithubAuthController, :callback
  end

  # Other scopes may use custom stacks.
  # scope "/api", VoidWeb do
  #   pipe_through :api
  # end

  # Enable email login, LiveDashboard and Swoosh mailbox preview in development
  if Mix.env() == :test or Application.compile_env(:void, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live "/log_in", VoidWeb.UserLoginLive, :new
      live_dashboard "/telemetry-dashboard", metrics: VoidWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
      post "/log_in", VoidWeb.UserSessionController, :create
    end
  end

  scope "/", VoidWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{VoidWeb.UserAuth, :ensure_authenticated}] do
      live "/dashboard", DashboardLive
    end
  end

  scope "/", VoidWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
    get "/rooms/404", PageController, :not_found
    get "/access_denied", PageController, :access_denied

    live_session :current_user,
      on_mount: [{VoidWeb.UserAuth, :mount_current_user}] do
      live "/rooms/:room", RoomLive
      live "/rooms/:room/lobby", LobbyLive
    end
  end
end
