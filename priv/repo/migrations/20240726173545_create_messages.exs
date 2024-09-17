defmodule Void.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :room_id, references(:rooms, on_delete: :delete_all, column: :room_id, type: :binary_id)

      add :user_id,
          references(:room_users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:room_id])
    create index(:messages, [:user_id])
  end
end
