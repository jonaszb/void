defmodule VoidWeb.UserConfigLive do
  use Phoenix.LiveComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section>
      Hello <%= @user.username %>!
    </section>
    """
  end
end
