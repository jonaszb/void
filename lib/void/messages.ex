defmodule Void.Messages do
  import Ecto.Query, warn: false
  alias Void.Repo
  alias Void.Rooms.Message

  def broadcast({:ok, message}, event) do
    Phoenix.PubSub.broadcast(
      Void.PubSub,
      "messages:#{message.room_id}",
      {event, message}
    )

    {:ok, message}
  end

  def get_messages(room_id) do
    Repo.all(from m in Message, where: m.room_id == ^room_id, order_by: [desc: m.inserted_at])
    |> Repo.preload([:user, replied_message: :user])
  end

  def add_message(message) do
    case Repo.insert(message) do
      {:ok, msg} ->
        broadcast({:ok, Repo.preload(msg, [:user, replied_message: :user])}, :new_message)

      _ ->
        nil
    end
  end
end
