defmodule VoidWeb.RoomLive do
  alias VoidWeb.Room.RoomInfo
  use VoidWeb, :live_view
  alias Expo.Message
  alias Void.Accounts
  alias Void.Messages
  alias Void.Rooms
  alias Void.Rooms.Message
  alias Void.Rooms.RoomState
  alias Void.RoomStates
  alias VoidWeb.NotificationComponent
  alias VoidWeb.Presence
  import VoidWeb.Logos
  import VoidWeb.Room.RoomComponents
  alias VoidWeb.Room.RoomEvents

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

        sounds_json =
          Jason.encode!(%{
            message: ~p"/audio/chat_sound.mp3",
            tap: ~p"/audio/tap.mp3",
            access_request: ~p"/audio/beavis.mp3"
          })

        assign(socket,
          room: room,
          message_user_data: message_user_data,
          messages: messages,
          message_counter: 0,
          users_counter: 0,
          message_form:
            to_form(Message.changeset(message_user_data, %{content: "", replies_to: nil})),
          active_tab: nil,
          room_users: room_users,
          room_user: this_room_user,
          room_state: room_state,
          room_state_form: to_form(RoomState.changeset(room_state, %{})),
          presences: presences,
          notifications: [],
          notification_counter: 0,
          editors: %{},
          muted: true,
          sounds: sounds_json,
          active_reply_to: nil
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

  @impl true
  def handle_event(event, params, socket), do: RoomEvents.handle_event(event, params, socket)

  @impl true
  def handle_info(message, socket), do: RoomInfo.handle_info(message, socket)
end
