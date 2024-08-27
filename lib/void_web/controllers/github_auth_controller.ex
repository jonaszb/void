defmodule VoidWeb.GithubAuthController do
  use VoidWeb, :controller
  alias VoidWeb.GithubAuth

  def request(conn, params) do
    GithubAuth.request(conn, params)
  end

  def callback(conn, _params) do
    GithubAuth.callback(conn)
  end
end
