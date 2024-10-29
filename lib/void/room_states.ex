defmodule Void.RoomStates do
  alias Void.Rooms.RoomState
  alias Void.Repo

  def broadcast({:ok, room_state}, updating_user, event \\ :room_state_updated) do
    Phoenix.PubSub.broadcast(
      Void.PubSub,
      "room-state:#{room_state.room_id}",
      {event, room_state, updating_user}
    )

    {:ok, room_state}
  end

  def get_room_state(uuid) when is_binary(uuid), do: Repo.get_by(RoomState, room_id: uuid)

  def update_room_state(room_state, updated_data, updating_user) do
    room_state |> RoomState.changeset(updated_data) |> Repo.update() |> broadcast(updating_user)
  end

  def update_cursor_position(position, room_user) do
    Phoenix.PubSub.broadcast(
      Void.PubSub,
      "room-state:#{room_user.room_id}",
      {:cursor_update, position, room_user}
    )

    {:ok, position, room_user}
  end
end
