defmodule VoidWeb.ThemeToggle do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def theme_toggle(assigns) do
    ~H"""
    <button phx-click={JS.dispatch("toggle-darkmode")} aria-label="Theme toggle">Toggle</button>
    """
  end
end
