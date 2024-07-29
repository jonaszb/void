defmodule Void.Repo.Migrations.CreateRoomUsers do
  use Ecto.Migration

  def change do
    create table(:room_users) do
      add :role, :string

      add :room_id,
          references(:rooms, on_delete: :nothing, type: :binary_id, column: :uuid)

      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:room_users, [:room_id])
    create index(:room_users, [:user_id])
  end
end
