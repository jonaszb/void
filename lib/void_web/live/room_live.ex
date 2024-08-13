defmodule VoidWeb.RoomLive do
  # alias Phoenix.LiveView
  use VoidWeb, :live_view
  alias Void.Rooms
  # alias Phoenix.LiveView
  import VoidWeb.ThemeToggle
  # use Phoenix.LiveView

  def mount(%{"room" => room_uuid}, _session, %{assigns: %{current_user: nil}} = socket) do
    socket =
      push_navigate(socket, to: ~p"/rooms/#{room_uuid}/lobby")

    {:ok, socket, layout: false}
  end

  def mount(%{"room" => room_uuid}, _session, %{assigns: %{current_user: current_user}} = socket) do
    socket =
      case Rooms.user_can_access_room(current_user, room_uuid) do
        {:ok, true} ->
          {room, owner_name} = Rooms.get_room_by_uuid(room_uuid)
          assign(socket, room: room, owner_name: owner_name)

        _ ->
          push_navigate(socket, to: ~p"/rooms/#{room_uuid}/lobby")
      end

    {:ok, socket, layout: false}
  end

  # def mount(%{"room" => room_uuid}, _session,  = socket) do
  #   {room, owner_name} = Rooms.get_room_by_uuid(room_uuid)
  #   {:ok, assign(socket, room: room, owner_name: owner_name)}
  # end

  def render(assigns) do
    ~H"""
    <.theme_toggle class="" />
    <h1><%= "Hello from #{@room.name} owned by #{@owner_name}" %></h1>
    <button phx-click="delete">DELETE ROOM</button>
    """
  end

  def handle_event("delete", _, socket) do
    socket =
      case Rooms.delete_room(socket.assigns.room) do
        {:ok, _} -> push_navigate(socket, to: "/dashboard")
        {:error, _} -> put_flash(socket, :error, "Room could not be deleted")
      end

    {:noreply, socket}
  end
end
