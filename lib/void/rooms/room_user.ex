defmodule Void.Rooms.RoomUser do
  use Ecto.Schema
  import Ecto.Changeset
  @foreign_key_type :binary_id

  schema "room_users" do
    belongs_to :room, Void.Rooms.Room, type: :binary_id
    has_many :messages, Void.Rooms.Message, foreign_key: :user_id, on_delete: :nothing
    field :user_id, :binary_id
    field :has_access, :boolean
    field :is_owner, :boolean
    field :is_editor, :boolean
    field :is_guest, :boolean
    field :display_name, :string
    field :requesting_edit, :boolean
    field :expires_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room_user, attrs) do
    room_user
    |> cast(attrs, [
      :has_access,
      :room_id,
      :user_id,
      :is_owner,
      :is_editor,
      :is_guest,
      :expires_at,
      :requesting_edit,
      :display_name
    ])
    |> validate_required([:has_access, :room_id, :user_id, :is_owner, :is_editor])
  end
end
