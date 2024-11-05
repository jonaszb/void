defmodule VoidWeb.Room.AccessControlModal do
  use Phoenix.LiveComponent
  alias Void.Rooms
  import VoidWeb.CoreComponents

  def update(assigns, socket) do
    room_users = assigns.room_users
    {admitted_users, pending_users} = Enum.split_with(room_users, fn ru -> ru.has_access end)

    {present_users, absent_users} =
      Enum.split_with(admitted_users, fn ru -> Map.has_key?(assigns.presences, ru.user_id) end)

    admitted_users = present_users ++ absent_users

    {:ok,
     assign(socket,
       admitted_users: admitted_users,
       pending_users: pending_users,
       presences: assigns.presences
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="max-h-[80vh]">
      <header class="text-lg sm:text-xl uppercase tracking-widest font-bold text-blue-400/70 dark:text-blue-200/70 mb-6 sm:mb-12">
        Manage users
      </header>
      <ul class="text-sm overflow-scroll h-[60vh]">
        <p
          :if={length(@admitted_users) == 1}
          class="text-xl text-zinc-500/80 dark:text-zinc-400/80 text-center"
        >
          No users to display
        </p>
        <%= for ru <- @admitted_users  do %>
          <% role =
            cond do
              # Add condition for a room admin role (not implemented yet)
              ru.is_editor -> "Editor"
              true -> "Viewer"
            end %>
          <li
            :if={not ru.is_owner}
            class="flex justify-between group odd:bg-black/5 dark:odd:bg-white/5"
          >
            <div class="flex  p-3 rounded w-[calc(100%-2.5rem)] justify-between">
              <div class="flex gap-2 items-start flex-col grow">
                <div class="flex gap-2 items-center">
                  <div class={"min-w-2 h-2 rounded-full #{if Map.has_key?(@presences, ru.user_id), do: "bg-green-500", else: "bg-zinc-400"}"} />

                  <span
                    name={ru.display_name}
                    class={"font-bold text-ellipsis line-clamp-1 #{unless Map.has_key?(@presences, ru.user_id), do: "text-zinc-400/80"}"}
                  >
                    <%= ru.display_name %>
                  </span>
                </div>
                <span>
                  <div class="text-xs ml-4  text-zinc-500/80 dark:text-zinc-400/80 flex gap-1 items-center">
                    <span><%= if ru.expires_at, do: "Guest", else: "Verified" %></span>
                    <button :if={ru.expires_at} class="group/time relative flex items-center">
                      <.icon
                        name="hero-clock"
                        class="w-3 h-3 dark:text-amber-500 text-amber-700 cursor-pointer"
                      />
                      <time
                        id={"expiry-countdown-#{ru.id}"}
                        phx-hook="Countdown"
                        msg-timestamp={"#{DateTime.to_iso8601(ru.expires_at)}"}
                        name="expiry countdown"
                        class="absolute transition-all opacity-0 group-hover/time:opacity-100 dark:bg-black bg-white border border-zinc-500/40 px-4 py-2 rounded-md -top-8 -left-8 pointer-events-none whitespace-nowrap"
                      />
                    </button>
                  </div>
                </span>
              </div>
              <div class="flex gap-2 items-center">
                <.form phx-change="set_role" phx-value-id={ru.id}>
                  <.dropdown
                    id={"role-dd-#{ru.id}"}
                    name="role"
                    options={[{"Editor", "Editor"}, {"Viewer", "Viewer"}]}
                    value={role}
                  />
                </.form>
              </div>
            </div>
            <button
              phx-click="remove_user"
              phx-value-id={ru.id}
              phx-target={@myself}
              title="Remove user"
              class="text-zinc-500 hover:text-red-500 mr-6 transition-all"
            >
              <.icon name="hero-user-minus" />
            </button>
          </li>
        <% end %>
      </ul>
    </div>
    """
  end

  def handle_event("remove_user", %{"id" => id}, socket) do
    Rooms.deny_user_access(id)
    {:noreply, socket}
  end
end
