defmodule VoidWeb.Room.RoomInfo do
  import Phoenix.LiveView,
    only: [push_event: 3, put_flash: 3, redirect: 2, push_navigate: 2]

  import Phoenix.Component
  alias VoidWeb.Presence
  alias Void.Rooms

  def update_room_user(socket, room_user) do
    update(
      socket,
      :room_users,
      &Enum.map(&1, fn ru ->
        if ru.id == room_user.id, do: room_user, else: ru
      end)
    )
  end

  def play_sound(socket, _) when socket.assigns.muted, do: socket
  def play_sound(socket, params), do: push_event(socket, "play-sound", params)

  @spec add_notification(Socket.t(), %{
          optional(:message) => String.t(),
          optional(:type) => Atom.t(),
          optional(:user) => RoomUser.t()
        }) :: Socket.t()
  def add_notification(
        socket,
        params
      ) do
    send(
      self(),
      {:new_notification, params}
    )

    socket
  end

  def terminate(_reason, socket) do
    user = socket.assigns.room_user
    Presence.untrack(self(), "room:#{user.room_id}", user.user_id)
  end

  def remove_user_cursor(socket, user_id),
    do: push_event(socket, "remove_user_cursor", %{userId: user_id})

  def handle_info(%{event: "presence_diff", payload: diff}, socket) do
    topic = "room:#{socket.assigns.room.room_id}"
    presences = Presence.list(topic)

    socket =
      Enum.reduce(diff.leaves, socket, fn {_, %{metas: [user | _]}}, acc_socket ->
        remove_user_cursor(acc_socket, user.room_user.id)
      end)

    {:noreply, assign(socket, presences: presences)}
  end

  def handle_info({:access_requested, room_user}, socket) do
    socket =
      case socket.assigns.active_tab do
        :users ->
          socket

        _ ->
          socket
          |> update(:users_counter, &(&1 + 1))
          |> add_notification(%{type: :access_requested, user: room_user})
      end
      |> play_sound(%{name: "access_request"})

    {:noreply, assign(socket, room_users: Rooms.get_room_users(socket.assigns.room))}
  end

  def handle_info({:edit_request, room_user}, socket) do
    room_users =
      socket.assigns.room_users
      |> Enum.map(fn ru ->
        if ru.id == room_user.id, do: room_user, else: ru
      end)

    socket =
      case room_user.requesting_edit do
        true -> socket |> add_notification(%{type: :hand_raised, user: room_user})
        false -> socket
      end

    room_user =
      case room_user.user_id == socket.assigns.room_user.user_id do
        true -> room_user
        false -> socket.assigns.room_user
      end

    {:noreply, assign(socket, room_users: room_users, room_user: room_user)}
  end

  def handle_info({:edit_granted, room_user}, socket)
      when socket.assigns.room_user.id == room_user.id do
    socket =
      update_room_user(socket, room_user)
      |> push_event("set_read_only", %{
        read_only: false
      })
      |> add_notification(%{type: :edit_granted})

    {:noreply, assign(socket, room_user: room_user)}
  end

  def handle_info({:edit_granted, room_user}, socket) do
    {:noreply, update_room_user(socket, room_user)}
  end

  def handle_info({:edit_revoked, room_user}, socket)
      when socket.assigns.room_user.id == room_user.id do
    socket =
      update_room_user(socket, room_user)
      |> push_event("set_read_only", %{
        read_only: true
      })
      |> add_notification(%{type: :edit_revoked})

    {:noreply, assign(socket, room_user: room_user)}
  end

  def handle_info({:edit_revoked, room_user}, socket) do
    socket =
      socket
      |> remove_user_cursor(room_user.id)
      |> update_room_user(room_user)

    {:noreply, socket}
  end

  def handle_info({:room_state_updated, room_state, updating_user}, socket)
      when updating_user.id === socket.assigns.room_user.id do
    socket =
      push_event(socket, "update_editor", %{
        language: room_state.language
      })

    {:noreply,
     assign(socket,
       room_state: room_state
     )}
  end

  def handle_info({:room_state_updated, room_state, _}, socket) do
    socket =
      push_event(socket, "update_editor", %{
        # content: room_state.contents,
        language: room_state.language
      })

    {:noreply,
     assign(socket,
       room_state: room_state
     )}
  end

  def handle_info({:room_deleted, _}, socket) do
    {:noreply,
     socket
     |> put_flash(:error, "Room #{socket.assigns.room_state.name} has been deleted.")
     |> redirect(to: "/")}
  end

  def handle_info({:new_message, message}, socket) do
    socket =
      case socket.assigns.active_tab do
        :chat ->
          socket

        _ ->
          socket
          |> update(:message_counter, &(&1 + 1))
          |> add_notification(%{type: :chat_message, user: message.user, message: message.content})
      end
      |> play_sound(%{name: "message"})

    {:noreply, assign(socket, messages: [message | socket.assigns.messages])}
  end

  def handle_info({:new_notification, params}, socket) do
    id = "notif-" <> Integer.to_string(socket.assigns.notification_counter + 1)

    notification = %{
      id: id,
      message: params[:message],
      type: params[:type] || :info,
      user: params[:user]
    }

    notifications = [notification | socket.assigns.notifications]

    {:noreply,
     assign(socket,
       notifications: notifications,
       notification_counter: socket.assigns.notification_counter + 1
     )}
  end

  def handle_info({:cursor_position_update, user_id, position}, socket) do
    socket =
      if user_id != socket.assigns.room_user.id do
        push_event(socket, "update_cursor_positions", %{
          userId: user_id,
          position: position
        })
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_info({:editor_updated, _, updating_user}, socket)
      when updating_user.id == socket.assigns.room_user.id do
    {:noreply, socket}
  end

  def handle_info({:editor_updated, changes, _}, socket) do
    socket = push_event(socket, "apply_changes", %{changes: changes})
    {:noreply, socket}
  end

  def handle_info({:access_revoked, user}, socket) when user.id == socket.assigns.room_user.id do
    Presence.untrack(self(), "room:#{user.room_id}", user.user_id)
    {:noreply, push_navigate(socket, to: "/access_denied")}
  end

  def handle_info({:access_revoked, user}, socket),
    do:
      {:noreply,
       socket
       |> remove_user_cursor(user.id)
       |> assign(room_users: Rooms.get_room_users(socket.assigns.room))}
end
