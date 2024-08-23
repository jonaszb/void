defmodule Void.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:room_id, :binary_id, autogenerate: false}

  schema "rooms" do
    field :owner_id, :id
    has_many :room_users, Void.Rooms.RoomUser, foreign_key: :room_id, on_delete: :delete_all
    has_many :room_states, Void.Rooms.RoomState, foreign_key: :room_id, on_delete: :delete_all

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:room_id, :owner_id])
    |> validate_required([:room_id, :owner_id])
  end
end
