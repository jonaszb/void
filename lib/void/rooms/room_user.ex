defmodule Void.Rooms.RoomUser do
  use Ecto.Schema
  import Ecto.Changeset
  @foreign_key_type :binary_id

  schema "room_users" do
    field :role, :string
    belongs_to :room, Void.Rooms.Room, type: :binary_id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_user, attrs) do
    room_user
    |> cast(attrs, [:role, :room_id, :user_id])
    |> validate_required([:role, :room_id, :user_id])
  end
end
