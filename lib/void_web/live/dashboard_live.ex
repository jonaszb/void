defmodule VoidWeb.DashboardLive do
  alias Phoenix.LiveView
  use VoidWeb, :live_view
  import Void.Rooms

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: "Void Dashboard")
    rooms = list_room_states_for_user(socket.assigns.current_user.id)
    {:ok, socket |> assign(rooms: rooms)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl">
      <h1 class="font-work text-2xl -translate-y-4 md:-translate-y-12 font-bold text-blue-950 dark:text-blue-50 uppercase tracking-wider">
        Dashboard
      </h1>
      <section class="bg-blue-100/50 dark:bg-gray-900/50 border rounded-lg border-gray-200 dark:border-gray-700">
        <header class="px-4 py-6 transparent text-xl flex items-center justify-between gap-4 border-b dark:border-gray-700">
          <h2 class="text-blue-950/80 text-xl font-bold dark:text-blue-300/80">My rooms</h2>
          <span class="flex items-center gap-4">
            <span class="text-sm font-light text-black/75 dark:text-white/80 tracking-wide">
              <%= length(@rooms) %> / 10
            </span>
            <button phx-click="new_room" class="btn-primary">
              <span class="hidden sm:inline-block">New Room</span>
              <.icon name="hero-plus-solid" class="h-6 w-6 sm:ml-2" />
            </button>
          </span>
        </header>
        <div class="py-8 px-6 items-center justify-center h-[min(32rem,60vh)] bg-[url('/images/luminary.svg')] bg-cover bg-no-repeat overflow-scroll">
          <%= if @rooms == [] do %>
            <div class="flex flex-col w-full items-center">
              <p class="text-lg sm:text-xl mt-6 font-work text-blue-950 dark:text-blue-200/70">
                You don't have any rooms yet.
              </p>
            </div>
          <% else %>
            <ul class="grid gap-x-8 gap-y-8 grid-cols-1 sm:grid-cols-2 md:grid-cols-3 text-black/75 dark:text-blue-100/75">
              <%= for room <- @rooms do %>
                <li class="p-4 rounded cursor-pointer bg-blue-300/20 dark:bg-blue-100/20 shadow-md backdrop-blur-sm border border-gray-300/20 hover:scale-105 hover:backdrop-brightness-125 transition-all">
                  <.link
                    navigate={~p"/rooms/#{room.room_id}"}
                    class="flex flex-col items-center h-full justify-between"
                  >
                    <header class="font-bold text-center"><%= room.name %></header>
                    <div class="flex flex-col items-center">
                      <.icon name="hero-code-bracket-solid" class="h-12 w-12 my-6 text-amber-500/75" />
                      <p>Last updated:</p>
                      <time><%= relative_time_ago(room.updated_at) %></time>
                    </div>
                  </.link>
                </li>
              <% end %>
            </ul>
          <% end %>
        </div>
      </section>
    </div>
    """
  end

  def handle_event("new_room", _, socket) do
    # socket = put_flash(socket, :error, "Cannot create more rooms");
    socket =
      case create_room_for_user(socket.assigns.current_user) do
        {:ok, %{room: room}} -> LiveView.push_navigate(socket, to: ~p"/rooms/#{room.room_id}")
        {:limit, message} -> put_flash(socket, :info, message)
        {:error, _} -> put_flash(socket, :error, "Failed to create room")
      end

    {:noreply, socket}
  end

  defp relative_time_ago(utc_timestamp) do
    local_time =
      utc_timestamp
      |> Timex.to_datetime("Etc/UTC")
      |> Timex.Timezone.convert("Etc/UTC")

    Timex.format!(local_time, "{relative}", :relative)
  end
end
