defmodule VoidWeb.RoomLive do
  # alias Phoenix.LiveView
  alias Expo.Message
  alias Void.Messages
  alias Void.Accounts
  alias Void.RoomStates
  alias Void.RoomUsers
  alias Void.Rooms.RoomState
  alias Void.Rooms.Message
  use VoidWeb, :live_view
  alias Void.Rooms
  alias VoidWeb.Presence
  import VoidWeb.ThemeToggle
  import VoidWeb.Logos
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
        IO.inspect(this_room_user)
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
          messages: messages,
          message_user_data: message_user_data,
          message_form: to_form(Message.changeset(message_user_data, %{content: ""})),
          active_tab: :users,
          room_users: room_users,
          room_user: this_room_user,
          room_state: room_state,
          room_state_form: to_form(RoomState.changeset(room_state, %{})),
          presences: presences
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

  defp get_supported_languages(), do: @supported_languages

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

  def handle_event("grant_access", %{"id" => id}, socket) do
    Rooms.grant_user_access(id)
    {:noreply, assign(socket, room_users: Rooms.get_room_users(socket.assigns.room))}
  end

  def handle_event("update_room_state", %{"room_state" => updated_room_state}, socket) do
    if(socket.assigns.room_user.is_editor or socket.assigns.room_user.is_owner) do
      RoomStates.update_room_state(socket.assigns.room_state, updated_room_state)
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

  def handle_event("send_message", params, socket) do
    %{"message" => message} = params

    IO.inspect(
      socket.assigns.message_user_data
      |> Message.changeset(message)
      |> Messages.add_message()
    )

    {:noreply, socket}
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

  def handle_event("select_tab", %{"tab_name" => "nil"}, %{assigns: %{active_tab: nil}} = socket) do
    {:noreply, assign(socket, active_tab: :users)}
  end

  def handle_event("select_tab", %{"tab_name" => tab_name}, socket)
      when tab_name in @sidebar_tabs do
    {:noreply, assign(socket, active_tab: String.to_atom(tab_name))}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: _diff}, socket) do
    topic = "room:#{socket.assigns.room.room_id}"
    presences = Presence.list(topic)
    {:noreply, assign(socket, presences: presences)}
  end

  def handle_info({:access_requested, _room_user}, socket) do
    {:noreply, assign(socket, room_users: Rooms.get_room_users(socket.assigns.room))}
  end

  def handle_info({:edit_request, room_user}, socket) do
    room_users =
      socket.assigns.room_users
      |> Enum.map(fn ru ->
        if ru.id == room_user.id, do: room_user, else: ru
      end)

    room_user =
      case room_user.user_id == socket.assigns.room_user.user_id do
        true -> room_user
        false -> socket.assigns.room_user
      end

    {:noreply, assign(socket, room_users: room_users, room_user: room_user)}
  end

  def handle_info({:edit_granted, room_users}, socket) do
    this_room_user = get_current_room_user(room_users, socket.assigns.room_user.user_id)

    socket =
      push_event(socket, "set_read_only", %{
        read_only: not this_room_user.is_editor
      })

    {:noreply, assign(socket, room_users: room_users, room_user: this_room_user)}
  end

  def handle_info({:room_state_updated, room_state}, socket) do
    socket =
      case socket.assigns.room_user.is_editor do
        false ->
          push_event(socket, "update_editor", %{
            content: room_state.contents,
            language: room_state.language
          })

        true ->
          push_event(socket, "update_editor", %{
            language: room_state.language
          })
      end

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
end
