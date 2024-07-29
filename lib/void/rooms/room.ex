defmodule Void.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset
  @primary_key {:uuid, :binary_id, autogenerate: false}

  schema "rooms" do
    field :name, :string
    field :owner_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :uuid, :owner_id])
    |> validate_required([:name, :uuid, :owner_id])
  end
end
