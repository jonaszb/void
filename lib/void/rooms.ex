defmodule Void.Rooms do
  @moduledoc """
  The Room context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Phoenix.PubSub
  alias Void.Accounts.User
  alias Void.Repo
  alias Void.Rooms.Room
  alias Void.Rooms.RoomState
  alias Void.Rooms.RoomUser
  alias Void.Rooms.Message
  @default_room_cap 10

  def broadcast(topic, message) do
    PubSub.broadcast(Void.PubSub, topic, message)
  end

  def list_room_states_for_user(user_id) do
    Repo.all(
      from rs in RoomState, where: rs.owner_id == ^user_id, order_by: [desc: rs.updated_at]
    )
  end

  def get_room_by_uuid(room_uuid) do
    Repo.one(from r in Room, where: r.room_id == ^room_uuid)
  end

  def get_room_users(room) do
    query =
      from ru in RoomUser, where: ru.room_id == ^room.room_id, order_by: [desc: ru.has_access]

    Repo.all(query)
  end

  def get_room_user(id), do: Repo.get_by(RoomUser, id: id)

  def get_room_user(uuid, room_id), do: Repo.get_by(RoomUser, user_id: uuid, room_id: room_id)

  def delete_room(room) do
    del = Repo.delete(room)

    case del do
      {:ok, deleted_room} ->
        broadcast("room-state:#{room.room_id}", {:room_deleted, deleted_room})

      _ ->
        nil
    end

    del
  end

  def room_exists?(room_uuid) do
    if match?({:ok, _}, Ecto.UUID.dump(room_uuid)) do
      query =
        from r in Room,
          where: r.room_id == ^room_uuid,
          select: count(r.room_id)

      case Repo.one(query) do
        0 -> false
        _ -> true
      end
    else
      false
    end
  end

  def user_can_access_room(nil, _room_uuid), do: false

  def user_can_access_room(uuid, room_uuid) when is_binary(uuid) do
    Repo.get_by(User, uuid: uuid) |> user_can_access_room(room_uuid)
  end

  def user_can_access_room(user, room_uuid) do
    if room_exists?(room_uuid) do
      query =
        from ru in RoomUser,
          where: ru.room_id == ^room_uuid and ru.user_id == ^user.uuid and ru.has_access == true

      case Repo.aggregate(query, :count) do
        0 -> {:ok, false}
        1 -> {:ok, true}
        _ -> {:error, false}
      end
    else
      {:ok, false}
    end
  end

  def get_room_count_for_user(user) do
    query = from r in Room, where: r.owner_id == ^user.id
    Repo.aggregate(query, :count)
  end

  def create_room_for_user(user) do
    if get_room_count_for_user(user) >= @default_room_cap do
      {:limit, "You can have a maximum of #{@default_room_cap} rooms"}
    else
      room_name = Void.Slugs.generate()
      room_id = Ecto.UUID.generate()

      room_attrs = %{owner_id: user.id, room_id: room_id}

      room_state_attrs = %{
        contents: "// Welcome to #{room_name}!",
        language: "typescript",
        name: room_name,
        room_id: room_id,
        owner_id: user.id
      }

      room_user_attrs = %{
        has_access: true,
        is_owner: true,
        is_editor: true,
        is_guest: false,
        requesting_edit: false,
        display_name: user.display_name,
        room_id: room_id,
        user_id: user.uuid,
        name: room_name
      }

      Multi.new()
      |> Multi.insert(:room, Room.changeset(%Room{}, room_attrs))
      |> Multi.insert(:room_state, RoomState.changeset(%RoomState{}, room_state_attrs))
      |> Multi.insert(:room_user, RoomUser.changeset(%RoomUser{}, room_user_attrs))
      |> Repo.transaction()
    end
  end

  def request_room_access(user, room_id) do
    request_room_access(user, room_id, user.display_name)
  end

  def request_room_access(user, room_id, display_name) do
    case Repo.get_by(RoomUser, user_id: user.uuid, room_id: room_id) do
      nil ->
        room_user_attrs = %{
          has_access: false,
          is_owner: false,
          is_editor: false,
          is_guest: user.is_guest,
          requesting_edit: false,
          room_id: room_id,
          user_id: user.uuid,
          display_name: display_name
        }

        case Repo.insert(RoomUser.changeset(%RoomUser{}, room_user_attrs)) do
          {:ok, room_user} ->
            broadcast("access-request:#{room_user.room_id}", {:access_requested, room_user})
            {:ok, room_user}

          {:error, changeset} ->
            {:error, changeset}
        end

      _ ->
        {:error, "Request is already pending"}
    end
  end

  def deny_user_access(room_user) when is_binary(room_user) do
    user = get_room_user(room_user)

    Repo.transaction(fn ->
      from(m in Message, where: m.user_id == ^user.id)
      |> Repo.update_all(set: [user_display_name: user.display_name])

      Repo.delete(user)
    end)
    |> case do
      {:ok, _result} ->
        case user.has_access do
          true -> broadcast("room-users:#{user.room_id}", {:access_revoked, user})
          false -> broadcast("lobby:#{user.room_id}", {:access_denied, user})
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def grant_user_access(room_user) when is_binary(room_user) do
    case get_room_user(room_user)
         |> maybe_set_expiration_date()
         |> Ecto.Changeset.change(%{has_access: true})
         |> Repo.update() do
      {:ok, room_user} ->
        broadcast("lobby:#{room_user.room_id}", {:access_granted, room_user})

      _ ->
        :error
    end
  end

  defp maybe_set_expiration_date(%{is_guest: true} = room_user) do
    Ecto.Changeset.change(room_user, %{
      expires_at:
        DateTime.utc_now() |> DateTime.add(86_400, :second) |> DateTime.truncate(:second)
    })
  end

  defp maybe_set_expiration_date(room_user), do: room_user
end
