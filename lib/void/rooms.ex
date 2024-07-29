defmodule Void.Rooms do
  import Ecto.Query, warn: false
  alias Void.Rooms.RoomUser
  alias Void.Rooms.RoomState
  alias Ecto.Multi
  alias Void.Repo
  alias Void.Rooms.Room
  alias Void.Accounts.User

  def list_rooms_for_user(user_id) do
    Repo.all(from r in Room, where: r.owner_id == ^user_id, order_by: [desc: r.updated_at])
  end

  def get_room_by_uuid(room_uuid) do
    query =
      from r in Room,
        join: u in User,
        on: r.owner_id == u.id,
        where: r.uuid == ^room_uuid,
        select: {r, u.display_name}

    Repo.one(query)
  end

  def user_can_access_room(user, room_uuid) do
    query = from ru in RoomUser, where: ru.room_id == ^room_uuid and ru.user_id == ^user.id

    case Repo.aggregate(query, :count) do
      0 -> {:ok, false}
      1 -> {:ok, true}
      _ -> {:error, false}
    end
  end

  def create_room_for_user(user) do
    IO.inspect(user)
    room_uuid = Ecto.UUID.generate()

    room_changeset =
      %Room{}
      |> Room.changeset(%{"name" => "New Room", "owner_id" => user.id, "uuid" => room_uuid})

    room_state_attrs = %{content: "", name: "New Room", room_id: room_uuid}
    room_user_attrs = %{role: "O", room_id: room_uuid, user_id: user.id}

    Multi.new()
    |> Multi.insert(:room, room_changeset)
    |> Multi.insert(:room_state, RoomState.changeset(%RoomState{}, room_state_attrs))
    |> Multi.insert(:room_user, RoomUser.changeset(%RoomUser{}, room_user_attrs))
    |> Repo.transaction()
  end
end
