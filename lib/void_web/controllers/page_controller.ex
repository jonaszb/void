defmodule VoidWeb.PageController do
  use VoidWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def not_found(conn, _params) do
    render(conn, :not_found, layout: false)
  end

  def access_denied(conn, _params) do
    render(conn, :access_denied, layout: false)
  end
end
