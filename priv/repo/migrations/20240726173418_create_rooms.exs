defmodule Void.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms, primary_key: false) do
      add :room_id, :binary_id, primary_key: true
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:rooms, [:owner_id])
  end
end
