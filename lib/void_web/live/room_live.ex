defmodule VoidWeb.RoomLive do
  # alias Phoenix.LiveView
  alias Void.RoomStates
  alias Void.Rooms.RoomState
  use VoidWeb, :live_view
  alias Void.Rooms
  alias VoidWeb.Presence
  # alias Phoenix.LiveView
  import VoidWeb.ThemeToggle
  # use Phoenix.LiveView

  @impl true
  def mount(
        %{"room" => room_uuid},
        %{"user_token" => user_token},
        %{assigns: %{current_user: nil}} = socket
      ) do
    socket =
      case Rooms.user_can_access_room(user_token, room_uuid) do
        {:ok, true} ->
          {room, owner_name} = Rooms.get_room_by_uuid(room_uuid)
          room_users = Rooms.get_room_users(room)
          room_state = RoomStates.get_room_state(room_uuid)
          this_room_user = Enum.find(room_users, fn u -> u.user_id == user_token end)
          presences = track_presence(room_uuid, user_token)
          Phoenix.PubSub.subscribe(Void.PubSub, "room-state:#{room_uuid}")

          socket = assign(socket, presences: presences)

          assign(socket,
            room: room,
            owner_name: owner_name,
            room_users: room_users,
            room_user: this_room_user,
            room_state: room_state,
            room_state_form: to_form(RoomState.changeset(room_state, %{})),
            presences: presences
          )

        _ ->
          push_navigate(socket, to: ~p"/rooms/#{room_uuid}/lobby")
      end

    # socket =
    #   push_navigate(socket, to: ~p"/rooms/#{room_uuid}/lobby")

    {:ok, socket, layout: false}
  end

  def mount(%{"room" => room_uuid}, _session, %{assigns: %{current_user: current_user}} = socket) do
    socket =
      case Rooms.user_can_access_room(current_user, room_uuid) do
        {:ok, true} ->
          {room, owner_name} = Rooms.get_room_by_uuid(room_uuid)
          room_users = Rooms.get_room_users(room)
          room_state = RoomStates.get_room_state(room_uuid)
          this_room_user = Enum.find(room_users, fn u -> u.user_id == current_user.uuid end)

          presences = track_presence(room_uuid, current_user)
          Phoenix.PubSub.subscribe(Void.PubSub, "room-state:#{room_uuid}")

          is_owner = room.owner_id == current_user.id

          if is_owner do
            Phoenix.PubSub.subscribe(Void.PubSub, "access-request:#{room_uuid}")
          end

          socket = assign(socket, presences: presences)

          assign(socket,
            room: room,
            owner_name: owner_name,
            room_users: room_users,
            room_user: this_room_user,
            room_state: room_state,
            room_state_form: to_form(RoomState.changeset(room_state, %{})),
            presences: presences
          )

        _ ->
          push_navigate(socket, to: ~p"/rooms/#{room_uuid}/lobby")
      end

    {:ok, socket, layout: false}
  end

  defp track_presence(room_uuid, uuid) when is_binary(uuid) do
    room_user = Rooms.get_room_user(uuid, room_uuid)
    # As a guest, a different name can be displayed per room, so use the one chosen for this room
    user = Void.Accounts.get_user_by_uuid(uuid) |> Map.put(:display_name, room_user.display_name)
    track_presence(room_uuid, user)
  end

  defp track_presence(room_uuid, user) do
    # Track the presence of the user in the room
    topic = "room:#{room_uuid}"

    Presence.track(self(), topic, user.uuid, %{
      user_uuid: user.uuid,
      display_name: user.display_name,
      online_at: inspect(System.system_time(:second))
    })

    # Subscribe to the topic to receive presence diffs
    VoidWeb.Endpoint.subscribe(topic)
    Presence.list(topic)
  end

  def render(assigns) do
    ~H"""
    <.theme_toggle class="" />
    <h1><%= "Hello from #{@room.name} owned by #{@owner_name}" %></h1>
    <button :if={@room_user.is_owner} phx-click="delete">DELETE ROOM</button>
    <ul :if={@room_user.is_owner}>
      <%= for user <- @room_users do %>
        <li class="flex gap-4">
          <span><%= user.display_name %></span>
          <span><%= user.id %></span>
          <span :if={user.is_guest}>(Guest)</span>
          <span :if={not user.has_access}> -- awaiting access --</span>
          <button
            :if={not user.has_access}
            class="btn-primary"
            phx-click="grant_access"
            phx-value-id={user.id}
          >
            GRANT ACCESS
          </button>
          <button
            :if={not user.has_access}
            class="btn-primary"
            phx-click="deny_access"
            phx-value-id={user.id}
          >
            DENY ACCESS
          </button>
        </li>
      <% end %>
    </ul>
    <h1>WHO'S HERE?</h1>
    <ul>
      <%= for {user_id, %{metas: [meta | _]}} <- @presences do %>
        <li>
          <b><%= meta.display_name %></b>: User ID: <%= user_id %>, Online Since: <%= meta
          |> Map.get(:online_at) %>
        </li>
      <% end %>
    </ul>
    <%!-- <.form for={@room_state_form} id="room-content-form" phx-change="update_room_state">
      <.input field={@room_state_form[:contents]} />
    </.form> --%>
    <div id="editor-container" phx-update="ignore">
      <div
        class="min-h-56"
        id="editor"
        phx-hook="MonacoEditor"
        data-content={@room_state.contents}
        data-uuid={@room.room_id}
        data-read-only={"#{@room_user.is_editor == false}"}
      >
      </div>
    </div>
    """
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
    if(socket.assigns.room_user.is_editor == true) do
      RoomStates.update_room_state(socket.assigns.room_state, updated_room_state)
    end

    {:noreply, socket}
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

  def handle_info({:room_state_updated, room_state}, socket) do
    socket =
      case socket.assigns.room_user.is_editor do
        false ->
          push_event(socket, "update_editor", %{
            content: room_state.contents,
            is_read_only: not socket.assigns.room_user.is_editor
          })

        true ->
          socket
      end

    {:noreply,
     assign(socket,
       room_state: room_state
     )}
  end
end
