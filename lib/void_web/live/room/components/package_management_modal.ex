defmodule VoidWeb.Room.PackageManagementModal do
  use Phoenix.LiveComponent
  import VoidWeb.CoreComponents

  def update(assigns, socket) do
    {:ok,
     assign(socket,
       room: assigns.room
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-h-[80vh]">
      <header class="text-lg sm:text-xl uppercase tracking-widest font-bold text-blue-400/70 dark:text-blue-200/70 mb-6 sm:mb-12">
        Manage packages
      </header>
      <div id="npm-search" phx-hook="NpmSearch">
        <.input
          value=""
          name="NPM search"
          type="text"
          id="search-query"
          placeholder="Search for npm packages..."
        />
        <ul class="h-[460px]" id="search-results"></ul>
        <div class="mt-2 text-sm flex justify-center gap-4 h-5 text-zinc-500" id="pagination-controls">
        </div>
      </div>
    </div>
    """
  end
end
