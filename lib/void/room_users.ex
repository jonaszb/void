defmodule Void.RoomUsers do
  @moduledoc """
  The Room User context.
  """

  import Ecto.Query, warn: false
  alias Void.Repo
  alias Void.Rooms.RoomUser

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

  def get_room_users(room_id) do
    Repo.get_by(RoomUser, room_id: room_id)
  end

  def request_edit(room_user) when is_binary(room_user) do
    get_room_user(room_user) |> request_edit()
  end

  def request_edit(room_user) do
    room_user
    |> RoomUser.changeset(%{requesting_edit: true})
    |> Repo.update()
    |> broadcast(:edit_request)
  end

  def cancel_request_edit(room_user) when is_binary(room_user) do
    get_room_user(room_user) |> cancel_request_edit()
  end

  def cancel_request_edit(room_user) do
    room_user
    |> RoomUser.changeset(%{requesting_edit: false})
    |> Repo.update()
    |> broadcast(:edit_request)
  end

  def grant_edit(room_user) when is_binary(room_user) do
    get_room_user(room_user) |> grant_edit()
  end

  def grant_edit(room_user) do
    Repo.transaction(fn ->
      room_user
      |> RoomUser.changeset(%{is_editor: true, requesting_edit: false})
      |> Repo.update()
      |> broadcast(:edit_granted)
    end)
  end

  def revoke_edit(room_user) when is_binary(room_user) do
    get_room_user(room_user) |> revoke_edit()
  end

  def revoke_edit(room_user) do
    Repo.transaction(fn ->
      room_user
      |> RoomUser.changeset(%{is_editor: false, requesting_edit: false})
      |> Repo.update()
      |> broadcast(:edit_revoked)
    end)
  end
end
