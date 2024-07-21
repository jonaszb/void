defmodule VoidWeb.DashboardLive do
  use VoidWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Void Dashboard")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <h1 class="font-work text-2xl -translate-y-12 font-bold text-blue-950 dark:text-blue-50 uppercase tracking-wider">
        Dashboard
      </h1>
      <section>
        <header class="w-full px-4 py-6 bg-blue-500 text-xl rounded">
          <h2 class="text-amber-50 text-xl font-bold">My rooms</h2>
        </header>
      </section>
    </div>
    """
  end
end
