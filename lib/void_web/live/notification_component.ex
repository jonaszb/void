defmodule VoidWeb.NotificationComponent do
  @moduledoc """
  Custom notifications in Rooms
  """

  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  import VoidWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      phx-hook="Notification"
      phx-remove={
        JS.hide(
          transition:
            {"ease-out duration-500", "opacity-100 translate-y-0", "opacity-0 -translate-y-full"},
          time: 500
        )
      }
      class="transition-all duration-500 opacity-0 translate-y-full w-72 relative group"
    >
      <%= render_notification(assigns) %>
      <button
        phx-click="remove_notification"
        phx-value-id={@id}
        class="p-1 opacity-0 flex items-center group-hover:opacity-100 transition-all absolute -right-2 -top-2 bg-white dark:bg-black rounded-full border border-zinc-500"
      >
        <.icon name="hero-x-mark h-4 w-4" />
      </button>
    </div>
    """
  end

  def render_notification(%{type: :chat_message} = assigns) do
    ~H"""
    <div class="flex items-start border bg-white dark:bg-zinc-950 border-zinc-300/50 p-4 shadow-md rounded">
      <div class="flex-1 w-full" title="Chat message notification">
        <.username_header>
          <%= @user.display_name %>
        </.username_header>
        <p class="text-zinc-700 dark:text-zinc-300 max-w-full break-words"><%= @message %></p>
      </div>
    </div>
    """
  end

  def render_notification(%{type: :hand_raised} = assigns) do
    ~H"""
    <div class="flex items-start border bg-white dark:bg-zinc-950 border-zinc-300/50 p-4 shadow-md rounded">
      <div class="flex-1 w-full" title="Raised hand notification">
        <.username_header>
          <%= @user.display_name %>
        </.username_header>
        <div class="flex justify-center">
          <.icon
            name="hero-hand-raised-solid"
            class="text-amber-500 w-12 h-12 mb-2 mt-4 animate-bounce"
          />
        </div>
      </div>
    </div>
    """
  end

  # def render_notification(%{type: :new_editor} = assigns) do
  #   ~H"""
  #   <div class="flex items-start border border-l-4 bg-white dark:bg-zinc-950 border-zinc-300/50 border-l-blue-500 p-4 shadow-md rounded">
  #     <div class="flex-1 w-full flex" title="Edit granted notification">
  #       <p class="text-zinc-700 dark:text-zinc-300">
  #         <b><%= @user.display_name %></b> is now the editor
  #       </p>
  #     </div>
  #   </div>
  #   """
  # end

  def render_notification(%{type: :edit_granted} = assigns) do
    ~H"""
    <div class="flex items-start border border-l-4 bg-white dark:bg-zinc-950 border-zinc-300/50 border-l-blue-500 p-4 shadow-md rounded">
      <div class="flex-1 w-full flex" title="Edit granted notification">
        <p class="text-zinc-700 dark:text-zinc-300">
          You are now an editor
        </p>
      </div>
    </div>
    """
  end

  def render_notification(%{type: :edit_revoked} = assigns) do
    ~H"""
    <div class="flex items-start border border-l-4 bg-white dark:bg-zinc-950 border-zinc-300/50 border-l-red-500 p-4 shadow-md rounded">
      <div class="flex-1 w-full flex" title="Edit revoked notification">
        <p class="text-zinc-700 dark:text-zinc-300">
          You are no longer an editor
        </p>
      </div>
    </div>
    """
  end

  def render_notification(%{type: :access_requested} = assigns) do
    ~H"""
    <div class="flex items-start bg-white dark:bg-zinc-950 p-4 shadow-md rounded">
      <div class="flex-1 w-full flex items-center gap-2" title="Access request notification">
        <p class="text-zinc-700 dark:text-zinc-300">
          <b><%= @user.display_name %></b> wants to join the room
        </p>
        <button
          class="rounded-full bg-green-500 p-2 h-fit disabled:bg-zinc-500"
          phx-click="grant_access"
          phx-value-id={@user.id}
          phx-value-notification_id={@id}
        >
          <.icon name="hero-check" />
        </button>
      </div>
    </div>
    """
  end

  defp username_header(assigns) do
    ~H"""
    <p class="text-sm font-bold text-gray-600 dark:text-gray-100 mb-2 overflow-ellipsis overflow-hidden whitespace-nowrap">
      <%= render_slot(@inner_block) %>
    </p>
    """
  end
end
