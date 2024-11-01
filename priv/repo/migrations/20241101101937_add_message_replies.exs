defmodule Void.Repo.Migrations.AddMessageReplies do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :replies_to, references(:messages, on_delete: :nothing)
    end

    create index(:messages, [:replies_to])
  end
end
