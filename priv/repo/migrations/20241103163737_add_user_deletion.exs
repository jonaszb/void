defmodule Void.Repo.Migrations.UpdateUserIdOnDeleteToNilifyAll do
  use Ecto.Migration

  def change do
    # Step 1: Drop the existing foreign key constraint on :user_id
    execute "ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_user_id_fkey"

    # Step 2: Modify the :user_id column with the new constraint settings
    alter table(:messages) do
      modify :user_id, references(:room_users, on_delete: :nilify_all), null: true
      # Add new column for user display name
      add :user_display_name, :string
    end

    # Step 3: Populate the new :user_display_name field based on the associated room_user's display_name
    execute("""
    UPDATE messages
    SET user_display_name = room_users.display_name
    FROM room_users
    WHERE messages.user_id = room_users.id
    """)
  end

  def down do
    execute "ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_user_id_fkey"

    alter table(:messages) do
      modify :user_id, references(:room_users, on_delete: :nothing), null: false
      remove :user_display_name
    end
  end
end
