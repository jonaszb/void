defmodule VoidWeb.Room.RoomEvents do
  import Phoenix.Component
  import Phoenix.LiveView, only: [push_navigate: 2, put_flash: 3]
  alias Void.RoomStates
  alias Void.Messages
  alias Void.RoomUsers
  alias Void.Rooms.Message
  alias Void.Rooms
  alias Void.Rooms.RoomState
  alias Phoenix.PubSub

  @sidebar_tabs ["chat", "users", "settings", "nil"]

  def handle_event("toggle_sound", _, socket) do
    {:noreply, update(socket, :muted, &(not &1))}
  end

  def handle_event("delete", _, socket) do
    socket =
      case Rooms.delete_room(socket.assigns.room) do
        {:ok, _} -> push_navigate(socket, to: "/dashboard")
        {:error, _} -> put_flash(socket, :error, "Room could not be deleted")
      end

    {:noreply, socket}
  end

  def handle_event("deny_access", %{"id" => id}, socket) do
    Rooms.deny_user_access(id)
    {:noreply, assign(socket, room_users: Rooms.get_room_users(socket.assigns.room))}
  end

  def handle_event(
        "grant_access",
        %{"id" => id, "notification_id" => notification_id},
        socket
      ) do
    {:noreply, socket} = handle_event("remove_notification", %{"id" => notification_id}, socket)
    handle_event("grant_access", %{"id" => id}, socket)
  end

  def handle_event("grant_access", %{"id" => id}, socket) do
    Rooms.grant_user_access(id)
    {:noreply, assign(socket, room_users: Rooms.get_room_users(socket.assigns.room))}
  end

  def handle_event("update_room_state", %{"room_state" => updated_room_state}, socket) do
    if(socket.assigns.room_user.is_editor or socket.assigns.room_user.is_owner) do
      RoomStates.update_room_state(
        socket.assigns.room_state,
        updated_room_state,
        socket.assigns.room_user
      )
    end

    {:noreply, socket}
  end

  def handle_event("change_language", %{"language" => language}, socket),
    do: handle_event("update_room_state", %{"room_state" => %{language: language}}, socket)

  def handle_event(
        "update_editor_state",
        params,
        socket
      ) do
    if(socket.assigns.room_user.is_editor or socket.assigns.room_user.is_owner) do
      RoomStates.update_editor_state(
        socket.assigns.room_state,
        params,
        socket.assigns.room_user
      )
    end

    {:noreply, socket}
  end

  def handle_event("validate_room_state_form", params, socket) do
    %{"room_state" => room_state} = params

    room_state_form =
      socket.assigns.room_state
      |> RoomState.changeset(room_state)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, room_state_form: room_state_form)}
  end

  def handle_event("validate_message", %{"message" => %{"content" => content} = message}, socket) do
    validate_message(Map.put(message, "content", String.trim(content)), socket)
  end

  def handle_event("send_message", %{"message" => %{content: ""}}, socket), do: {:noreply, socket}

  def handle_event("send_message", %{"message" => message}, socket) do
    message =
      Map.put(message, "replies_to", Map.get(socket.assigns.active_reply_to || %{}, :id, nil))

    socket.assigns.message_form.source
    |> Message.changeset(message)
    |> Map.put(:action, :insert)
    |> Messages.add_message()

    {:noreply,
     assign(socket,
       message_form:
         to_form(
           Message.changeset(socket.assigns.message_user_data, %{content: "", replies_to: nil})
         ),
       active_reply_to: nil
     )}
  end

  def handle_event("request_edit", %{"id" => user_id}, socket) do
    RoomUsers.request_edit(user_id)
    {:noreply, socket}
  end

  def handle_event("cancel_request_edit", %{"id" => user_id}, socket) do
    RoomUsers.cancel_request_edit(user_id)
    {:noreply, socket}
  end

  def handle_event("grant_edit", %{"id" => user_id}, socket) do
    RoomUsers.grant_edit(user_id)
    {:noreply, socket}
  end

  def handle_event("revoke_edit", %{"id" => user_id}, socket) do
    RoomUsers.revoke_edit(user_id)
    {:noreply, socket}
  end

  def handle_event("select_tab", %{"tab_name" => "nil"}, %{assigns: %{active_tab: nil}} = socket) do
    handle_event("select_tab", %{"tab_name" => "users"}, socket)
  end

  def handle_event("select_tab", %{"tab_name" => tab_name}, socket)
      when tab_name in @sidebar_tabs do
    socket =
      case tab_name do
        "chat" -> assign(socket, message_counter: 0)
        "users" -> assign(socket, users_counter: 0)
        _ -> socket
      end

    {:noreply, assign(socket, active_tab: String.to_atom(tab_name))}
  end

  def handle_event("set_role", %{"role" => "Editor"} = params, socket),
    do: handle_event("grant_edit", params, socket)

  def handle_event("set_role", %{"role" => "Viewer"} = params, socket),
    do: handle_event("revoke_edit", params, socket)

  # @impl true
  # def handle_event("notification_action", %{"id" => id, "action" => action}, socket) do
  #   # IO.inspect("Action button clicked for notification #{id} with action #{action}")
  #   {:noreply, socket}
  # end

  def handle_event("remove_notification", %{"id" => id}, socket) do
    notifications =
      Enum.reject(socket.assigns.notifications, fn %{id: notif_id} -> notif_id == id end)

    {:noreply, assign(socket, notifications: notifications)}
  end

  def handle_event("cursor_position_change", _, socket)
      when not socket.assigns.room_user.is_editor do
    {:noreply, socket}
  end

  def handle_event("cursor_position_change", %{"lineNumber" => line, "column" => column}, socket) do
    user_id = socket.assigns.room_user.id
    position = %{lineNumber: line, column: column}

    PubSub.broadcast(
      Void.PubSub,
      "room-state:#{socket.assigns.room.room_id}",
      {:cursor_position_update, user_id, position}
    )

    {:noreply, socket}
  end

  def handle_event("reply_to", %{"id" => id}, socket) do
    id = String.to_integer(id)
    message = Enum.find(socket.assigns.messages, fn m -> m.id == id end)
    {:noreply, assign(socket, active_reply_to: message)}
  end

  def handle_event("reply_to", _, socket) do
    {:noreply, assign(socket, active_reply_to: nil)}
  end

  def validate_message(%{"content" => content}, socket) when content == "" do
    {:noreply,
     assign(socket,
       message_form: to_form(Message.changeset(socket.assigns.message_user_data, %{content: ""}))
     )}
  end

  def validate_message(message, socket) do
    message_form =
      socket.assigns.message_user_data
      |> Message.changeset(message)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, message_form: message_form)}
  end
end
