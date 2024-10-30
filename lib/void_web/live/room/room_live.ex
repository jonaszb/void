defmodule VoidWeb.RoomLive do
  use VoidWeb, :live_view
  alias Expo.Message
  alias Phoenix.PubSub
  alias Void.Accounts
  alias Void.Messages
  alias Void.Rooms
  alias Void.Rooms.Message
  alias Void.Rooms.RoomState
  alias Void.Rooms.RoomUser
  alias Void.RoomStates
  alias Void.RoomUsers
  alias VoidWeb.NotificationComponent
  alias VoidWeb.Presence
  import VoidWeb.Logos
  import VoidWeb.ThemeToggle
  import VoidWeb.Room.RoomComponents

  @sidebar_tabs ["chat", "users", "settings", "nil"]
  @supported_languages [
    {"Bash", "shell"},
    {"C", "c"},
    {"C#", "csharp"},
    {"C++", "cpp"},
    {"CSS", "css"},
    {"Dockerfile", "dockerfile"},
    {"Elixir", "elixir"},
    {"Go", "go"},
    {"HTML", "html"},
    {"Java", "java"},
    {"JavaScript", "javascript"},
    {"JSON", "json"},
    {"Julia", "julia"},
    {"Kotlin", "kotlin"},
    {"Less", "less"},
    {"Pascal", "pascal"},
    {"PHP", "php"},
    {"PowerShell", "powershell"},
    {"Python", "python"},
    {"Rust", "rust"},
    {"Scala", "scala"},
    {"SCSS", "scss"},
    {"SQL", "sql"},
    {"TypeScript", "typescript"},
    {"YAML", "yaml"}
  ]
  @impl true
  def mount(
        %{"room" => room_uuid},
        %{"user_token" => user_token},
        %{assigns: %{current_user: nil}} = socket
      ) do
    socket = socket |> setup_or_redirect(user_token, room_uuid)
    {:ok, socket, layout: false}
  end

  def mount(%{"room" => room_uuid}, _session, %{assigns: %{current_user: current_user}} = socket) do
    socket = socket |> setup_or_redirect(current_user, room_uuid)
    {:ok, socket, layout: false}
  end

  defp setup_or_redirect(socket, current_user, room_uuid) do
    case Rooms.user_can_access_room(current_user, room_uuid) do
      {:ok, true} ->
        room = Rooms.get_room_by_uuid(room_uuid)
        messages = Messages.get_messages(room_uuid)
        room_users = Rooms.get_room_users(room)
        room_state = RoomStates.get_room_state(room_uuid)
        this_room_user = get_current_room_user(room_users, current_user)
        presences = track_presence(room_uuid, this_room_user)
        Phoenix.PubSub.subscribe(Void.PubSub, "messages:#{room_uuid}")
        Phoenix.PubSub.subscribe(Void.PubSub, "room-state:#{room_uuid}")
        Phoenix.PubSub.subscribe(Void.PubSub, "room-users:#{room_uuid}")

        if this_room_user.is_owner == true do
          Phoenix.PubSub.subscribe(Void.PubSub, "access-request:#{room_uuid}")
        end

        message_user_data = %Message{user_id: this_room_user.id, room_id: room_uuid}
        socket = assign(socket, presences: presences)

        assign(socket,
          room: room,
          message_user_data: message_user_data,
          messages: messages,
          message_counter: 0,
          users_counter: 0,
          message_form: to_form(Message.changeset(message_user_data, %{content: ""})),
          active_tab: :users,
          room_users: room_users,
          room_user: this_room_user,
          room_state: room_state,
          room_state_form: to_form(RoomState.changeset(room_state, %{})),
          presences: presences,
          notifications: [],
          notification_counter: 0,
          editors: %{}
        )

      _ ->
        push_navigate(socket, to: ~p"/rooms/#{room_uuid}/lobby")
    end
  end

  defp get_current_room_user(room_users, current_user) when is_binary(current_user) do
    Enum.find(room_users, fn u -> u.user_id == current_user end)
  end

  defp get_current_room_user(room_users, current_user) do
    Enum.find(room_users, fn u -> u.user_id == current_user.uuid end)
  end

  defp get_supported_languages, do: @supported_languages

  defp track_presence(room_uuid, user) do
    # Track the presence of the user in the room
    topic = "room:#{room_uuid}"

    Presence.track(self(), topic, user.user_id, %{
      room_user: user,
      picture: Accounts.get_user_picture(user.user_id),
      online_at: inspect(System.system_time(:second))
    })

    # Subscribe to the topic to receive presence diffs
    VoidWeb.Endpoint.subscribe(topic)
    Presence.list(topic)
  end

  @spec add_notification(Socket.t(), %{
          message: String.t() | nil,
          type: Atom.t() | nil,
          user: RoomUser.t() | nil
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

  def update_room_user(socket, room_user) do
    update(
      socket,
      :room_users,
      &Enum.map(&1, fn ru ->
        if ru.id == room_user.id, do: room_user, else: ru
      end)
    )
  end

  @impl true
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
        %{"id" => id, "notification_id" => notification_id} = params,
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

  def handle_event("validate_message", params, socket) do
    %{"message" => message} = params

    message_form =
      socket.assigns.message_user_data
      |> Message.changeset(message)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, message_form: message_form)}
  end

  def handle_event("send_message", %{"message" => %{content: ""}}, socket), do: {:noreply, socket}

  def handle_event("send_message", params, socket) do
    %{"message" => message} = params

    socket.assigns.message_user_data
    |> Message.changeset(message)
    |> Messages.add_message()

    {:noreply,
     assign(socket,
       message_form: to_form(Message.changeset(socket.assigns.message_user_data, %{content: ""}))
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

  @impl true
  def handle_event("notification_action", %{"id" => id, "action" => action}, socket) do
    # IO.inspect("Action button clicked for notification #{id} with action #{action}")
    {:noreply, socket}
  end

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

  @impl true
  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    topic = "room:#{socket.assigns.room.room_id}"
    presences = Presence.list(topic)
    {:noreply, assign(socket, presences: presences)}
  end

  def handle_info({:access_requested, room_user}, socket) do
    socket =
      case socket.assigns.active_tab do
        :users ->
          socket

        # |> add_notification(%{type: :access_requested, user: room_user})

        _ ->
          socket
          |> update(:users_counter, &(&1 + 1))
          |> add_notification(%{type: :access_requested, user: room_user})
      end

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
      |> push_event("remove_user_cursor", %{
        userId: room_user.id
      })
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
     |> redirect(to: ~p"/")}
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

    {:noreply, assign(socket, messages: [message | socket.assigns.messages])}
  end

  @impl true
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
        # Send update to client for other users' cursors
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
end
