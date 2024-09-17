defmodule Void.Messages do
  import Ecto.Query, warn: false
  alias Void.Rooms.Message
  alias Phoenix.PubSub
  alias Void.Rooms.RoomUser
  alias Void.Rooms.RoomState
  alias Ecto.Multi
  alias Void.Repo
  alias Void.Rooms.Room
  alias Void.Accounts.User

  def broadcast(topic, message) do
    PubSub.broadcast(Void.PubSub, topic, message)
  end

  def get_messages(room_id) do
    Repo.all(from m in Message, where: m.room_id == ^room_id, order_by: [desc: m.inserted_at])
  end

  def add_message(message) do
    {:ok, msg} = Repo.insert(message)
    Repo.preload(msg, :user)
  end
end
