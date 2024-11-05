defmodule Void.Rooms.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string
    field :user_display_name, :string

    belongs_to :room, Void.Rooms.Room, type: :binary_id, references: :room_id
    belongs_to :user, Void.Rooms.RoomUser, type: :id, on_replace: :nilify

    belongs_to :replied_message, Void.Rooms.Message,
      foreign_key: :replies_to,
      type: :id,
      on_replace: :nilify

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :replies_to, :user_display_name])
    |> validate_required([:content])
    |> validate_length(:content, min: 1)
    |> validate_length(:content, max: 1000)
    |> foreign_key_constraint(:replies_to)
  end
end
