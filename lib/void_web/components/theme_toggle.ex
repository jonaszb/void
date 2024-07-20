defmodule VoidWeb.ThemeToggle do
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  def theme_toggle(assigns) do
    ~H"""
    <button phx-click={JS.toggle_class("dark", to: "html")}>Toggle</button>
    """
  end
end
