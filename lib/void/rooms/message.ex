defmodule Void.Rooms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :room, Void.Rooms.Room, type: :binary_id, references: :room_id
    belongs_to :user, Void.Rooms.RoomUser, type: :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content])
    |> validate_required([:content])
    |> validate_length(:content, min: 1)
    |> validate_length(:content, max: 1000)
  end
end
