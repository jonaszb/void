defmodule Void.Repo.Migrations.CreateRoomStates do
  use Ecto.Migration

  def change do
    create table(:room_states) do
      add :name, :string
      add :description, :text
      add :language, :string
      add :formatter, :string
      add :contents, :text
      add :room_id, references(:rooms, on_delete: :nothing, column: :uuid, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    # create index(:room_states, [:room_id], )
  end
end
