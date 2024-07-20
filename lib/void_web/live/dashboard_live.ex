defmodule VoidWeb.DashboardLive do
  use VoidWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Void Dashboard")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Hey <%= @current_user.email %></h1>
    """
  end
end
