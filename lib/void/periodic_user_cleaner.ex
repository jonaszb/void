defmodule Void.PeriodicUserCleaner do
  use GenServer
  import Ecto.Query
  alias Void.Repo
  alias Void.Rooms
  alias Void.Rooms.RoomUser

  @interval :timer.seconds(15)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_cleanup()
    {:ok, state}
  end

  def handle_info(:cleanup, state) do
    delete_expired_users()
    schedule_cleanup()
    {:noreply, state}
  end

  defp schedule_cleanup do
    Process.send_after(self(), :cleanup, @interval)
  end

  defp delete_expired_users do
    now = DateTime.utc_now()

    from(ru in RoomUser, where: not is_nil(ru.expires_at) and ru.expires_at < ^now)
    |> Repo.all()
    |> Enum.each(fn room_user ->
      Rooms.deny_user_access(room_user)
    end)
  end
end
