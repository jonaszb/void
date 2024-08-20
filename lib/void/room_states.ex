defmodule Void.RoomStates do
  import Ecto.Query, warn: false
  alias Phoenix.PubSub
  alias Void.Rooms.RoomUser
  alias Void.Rooms.RoomState
  alias Ecto.Multi
  alias Void.Repo
  alias Void.Rooms.Room
  alias Void.Accounts.User

  def broadcast({:ok, room_state}, event \\ :room_state_updated) do
    Phoenix.PubSub.broadcast(
      Void.PubSub,
      "room-state:#{room_state.room_id}",
      {event, room_state}
    )

    {:ok, room_state}
  end

  def get_room_state(uuid) when is_binary(uuid), do: Repo.get_by(RoomState, room_id: uuid)

  def update_room_state(room_state, updated_data) do
    room_state |> RoomState.changeset(updated_data) |> Repo.update() |> broadcast()
  end
end
