defmodule VoidWeb.UserConfigLive do
  alias Phoenix.LiveView.JS
  use Phoenix.LiveComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section>
      <header class="text-2xl uppercase tracking-widest font-bold text-blue-400/70 dark:text-blue-200/70 mb-12">
        Profile settings
      </header>
      <form></form>
      <footer class="flex w-full justify-end gap-4">
        <button class="px-4 py-2 text-blue-50 bg-blue-500 rounded-md hover:brightness-110">
          Save
        </button>
        <button
          phx-click={JS.exec("data-cancel", to: "##{@modal_id}")}
          class="px-4 py-2 text-gray-700 dark:text-gray-300 border bg-transparent rounded-md border-gray-500"
        >
          Cancel
        </button>
      </footer>
    </section>
    """
  end
end
