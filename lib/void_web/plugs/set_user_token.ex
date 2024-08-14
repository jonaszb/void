defmodule VoidWeb.Plugs.SetUserToken do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _opts) do
    user_token = get_session(conn, :user_token)

    if user_token do
      conn
    else
      token = Void.Tokens.generate_token()
      conn |> put_session(:user_token, token) |> assign(:user_token, token)
    end
  end
end
