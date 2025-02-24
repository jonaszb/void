defmodule VoidWeb.GithubAuth do
  @moduledoc """
  GitHub authentication controller
  """

  import Plug.Conn

  alias Assent.{Config, Strategy.Github}
  alias Void.Accounts.User

  # http://localhost:4000/auth/github
  def request(conn, params) do
    Application.get_env(:assent, :github)
    |> Github.authorize_url()
    |> case do
      {:ok, %{url: url, session_params: session_params}} ->
        # Session params (used for OAuth 2.0 and OIDC strategies) will be
        # retrieved when user returns for the callback phase
        conn =
          conn
          |> put_session(:session_params, session_params)
          |> put_session(:user_return_to, Map.get(params, "redirect_to", "/"))

        # Redirect end-user to Github to authorize access to their account
        conn
        |> put_resp_header("location", url)
        |> send_resp(302, "")

      {:error, error} ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(
          500,
          "Something went wrong generating the request authorization url: #{inspect(error)}"
        )
    end
  end

  # http://localhost:4000/auth/github/callback
  def callback(conn) do
    # End-user will return to the callback URL with params attached to the
    # request. These must be passed on to the strategy. In this example we only
    # expect GET query params, but the provider could also return the user with
    # a POST request where the params is in the POST body.
    %{params: params} = fetch_query_params(conn)
    # The session params (used for OAuth 2.0 and OIDC strategies) stored in the
    # request phase will be used in the callback phase
    session_params = get_session(conn, :session_params)

    Application.get_env(:assent, :github)
    # Session params should be added to the config so the strategy can use them
    |> Config.put(:session_params, session_params)
    |> Github.callback(params)
    |> case do
      {:ok, %{user: user, token: token}} ->
        # Authorization succesful
        # IO.inspect({user, token}, label: "user and token")

        user_record = Void.Accounts.get_user_by_email_or_register(user)

        conn
        |> VoidWeb.UserAuth.log_in_user(user_record)
        |> put_session(:github_user, user)
        |> put_session(:github_user_token, token)

      # |> Phoenix.Controller.redirect(to: "/")

      {:error, error} ->
        # Authorizaiton failed
        # IO.inspect(error, label: "error")

        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(500, inspect(error, pretty: true))
    end
  end

  def fetch_github_user(conn, _opts) do
    case get_session(conn, :github_user) do
      user when is_map(user) ->
        assign(conn, :current_user, %User{email: user["email"]})

      _ ->
        conn
    end
  end

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user = session["github_user"] do
        %User{email: user["email"]}
      end
    end)
  end
end
