defmodule Void.RoomUsers do
  import Ecto.Query, warn: false
  alias Void.Rooms.RoomUser
  alias Void.Repo

  def broadcast(message, event \\ :room_user_updated)

  def broadcast({:ok, room_users}, event) when is_list(room_users) do
    [room_user | _] = room_users

    Phoenix.PubSub.broadcast(
      Void.PubSub,
      "room-users:#{room_user.room_id}",
      {event, room_users}
    )

    {:ok, room_users}
  end

  def broadcast({:ok, room_user}, event) do
    Phoenix.PubSub.broadcast(
      Void.PubSub,
      "room-users:#{room_user.room_id}",
      {event, room_user}
    )

    {:ok, room_user}
  end

  def get_room_user(id) when is_binary(id), do: Repo.get_by(RoomUser, id: id)

  def request_edit(room_user) when is_binary(room_user) do
    get_room_user(room_user) |> request_edit()
  end

  def request_edit(room_user) do
    room_user
    |> RoomUser.changeset(%{requesting_edit: true})
    |> Repo.update()
    |> broadcast(:edit_request)
  end

  def grant_edit(room_user) when is_binary(room_user) do
    get_room_user(room_user) |> grant_edit()
  end

  def grant_edit(room_user) do
    Repo.transaction(fn ->
      # Revoke edit permissions for all other users in the same room
      from(ru in RoomUser,
        where: ru.room_id == ^room_user.room_id and ru.id != ^room_user.id,
        update: [set: [is_editor: false]]
      )
      |> Repo.update_all([])

      # Grant edit permission to the selected user and remove their edit request
      room_user
      |> RoomUser.changeset(%{is_editor: true, requesting_edit: false})
      |> Repo.update()

      {:ok, Repo.all(from ru in RoomUser, where: ru.room_id == ^room_user.room_id)}
      |> broadcast(:edit_granted)
    end)
  end
end
