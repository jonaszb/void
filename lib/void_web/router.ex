defmodule VoidWeb.Router do
  use VoidWeb, :router

  import VoidWeb.UserAuth
  import Config, only: [config_env: 0]

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

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Mix.env() == :test or Application.compile_env(:void, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live "/log_in", VoidWeb.UserLoginLive, :new
      live_dashboard "/telemetry-dashboard", metrics: VoidWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
      post "/log_in", VoidWeb.UserSessionController, :create
    end
  end

  ## Authentication routes

  # scope "/", VoidWeb do
  #   pipe_through [:browser, :redirect_if_user_is_authenticated]

  #   # live_session :redirect_if_user_is_authenticated,
  #   #   on_mount: [{VoidWeb.UserAuth, :redirect_if_user_is_authenticated}] do
  #   #   live "/users/register", UserRegistrationLive, :new
  #   #   live "/users/log_in", UserLoginLive, :new
  #   #   live "/users/reset_password", UserForgotPasswordLive, :new
  #   #   live "/users/reset_password/:token", UserResetPasswordLive, :edit
  #   # end

  #   # post "/users/log_in", UserSessionController, :create
  # end

  scope "/", VoidWeb do
    pipe_through [:browser, :require_authenticated_user]

    # live_session :require_authenticated_user,
    #   on_mount: [{VoidWeb.UserAuth, :ensure_authenticated}] do
    #   live "/users/settings", UserSettingsLive, :edit
    #   live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    # end

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
      # live "/users/confirm/:token", UserConfirmationLive, :edit
      # live "/users/confirm", UserConfirmationInstructionsLive, :new
      live "/rooms/:room", RoomLive
      live "/rooms/:room/lobby", LobbyLive
    end
  end
end
