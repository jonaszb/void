defmodule VoidWeb.RoomLive do
  # alias Phoenix.LiveView
  use VoidWeb, :live_view
  alias Void.Rooms
  # alias Phoenix.LiveView
  import VoidWeb.ThemeToggle
  # use Phoenix.LiveView

  def mount(%{"room" => room_uuid}, _session, %{assigns: %{current_user: current_user}} = socket) do
    IO.inspect(current_user)

    socket =
      case Rooms.user_can_access_room(current_user, room_uuid) do
        {:ok, true} ->
          {room, owner_name} = Rooms.get_room_by_uuid(room_uuid)
          assign(socket, room: room, owner_name: owner_name)

        _ ->
          push_navigate(socket, to: ~p"/dashboard")
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
    """
  end
end
