defmodule Void.Repo.Migrations.CreateRoomUsers do
  use Ecto.Migration

  def change do
    create table(:room_users) do
      add :has_access, :boolean
      add :is_editor, :boolean
      add :is_owner, :boolean
      add :is_guest, :boolean
      add :display_name, :string
      add :expires_at, :utc_datetime

      add :room_id,
          references(:rooms, on_delete: :delete_all, type: :binary_id, column: :room_id)

      add :user_id, references(:users, on_delete: :nothing, type: :binary_id, column: :uuid)

      timestamps(type: :utc_datetime)
    end

    create index(:room_users, [:room_id])
    create index(:room_users, [:user_id])
  end
end
