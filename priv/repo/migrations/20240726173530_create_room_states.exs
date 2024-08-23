defmodule Void.Repo.Migrations.CreateRoomStates do
  use Ecto.Migration

  def change do
    create table(:room_states) do
      add :name, :string
      add :description, :text
      add :language, :string
      add :formatter, :string
      add :contents, :text
      add :room_id, references(:rooms, on_delete: :delete_all, column: :room_id, type: :binary_id)
      add :owner_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    # create index(:room_states, [:room_id], )
  end
end
