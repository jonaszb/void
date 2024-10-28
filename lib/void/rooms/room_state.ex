defmodule Void.Rooms.RoomState do
  use Ecto.Schema
  import Ecto.Changeset
  @foreign_key_type :binary_id

  schema "room_states" do
    field :name, :string
    field :description, :string
    field :formatter, :string
    field :language, :string
    field :contents, :string
    belongs_to :room, Void.Rooms.Room, type: :binary_id, references: :room_id
    field :owner_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_state, attrs) do
    room_state
    |> cast(attrs, [:name, :description, :language, :formatter, :contents, :room_id, :owner_id])
    |> validate_length(:name, max: 50)
    |> validate_required([:name, :room_id])
  end
end
