defmodule VoidWeb.ThemeToggle do
  use Phoenix.Component

  import VoidWeb.CoreComponents
  alias Phoenix.LiveView.JS

  def theme_toggle(assigns) do
    ~H"""
    <button phx-click={JS.dispatch("toggle-darkmode")} aria-label="Theme toggle" class={@class || ""}>
      <.icon name="hero-moon" class="bg-gray-700 dark:hidden" />
      <.icon name="hero-sun" class="bg-blue-50 hidden dark:block" />
    </button>
    """
  end
end
