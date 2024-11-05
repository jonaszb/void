defmodule VoidWeb.Room.RoomComponents do
  @moduledoc """
  Component collection for Rooms
  """

  use Phoenix.Component
  import VoidWeb.CoreComponents
  alias Phoenix.LiveView.JS

  attr :is_owner, :boolean, required: true
  attr :active_tab, :atom, required: true
  attr :message_counter, :integer, required: true
  attr :users_counter, :integer, required: true

  def nav_menu(assigns) do
    ~H"""
    <nav id="sidebar-tabs" role="tablist" class="@[200px]:border-b-2 border-zinc-500/50">
      <ul class="grid @[200px]:grid-flow-col">
        <.nav_menu_item
          name="hero-chat-bubble-left-right"
          counter={@message_counter}
          tab_name={:chat}
          is_active={@active_tab == :chat}
          title="Chat"
        />
        <.nav_menu_item
          name="hero-users"
          counter={@users_counter}
          tab_name={:users}
          is_active={@active_tab == :users}
          title="User list"
        />
        <.nav_menu_item
          :if={@is_owner}
          name="hero-wrench"
          tab_name={:settings}
          is_active={@active_tab == :settings}
          title="Settings"
        />
      </ul>
    </nav>
    """
  end

  attr :name, :string, required: true
  attr :is_active, :boolean, required: true
  attr :tab_name, :atom, required: true
  attr :counter, :integer, default: 0
  attr :rest, :global

  def nav_menu_item(assigns) do
    ~H"""
    <li
      role="tab"
      {@rest}
      class="border-zinc-500/50 @[200px]:[&:not(:last-child)]:border-r-2 relative cursor-pointer"
    >
      <span
        :if={@counter > 0}
        class="absolute left-1/2 top-1/2 -translate-x-1/2 translate-y-2 text-xs bg-red-500 text-white rounded-lg py-px px-2 z-20 pointer-events-none"
      >
        <%= @counter %>
      </span>
      <a
        class="py-7  flex justify-center transition-all group hover:brightness-105"
        phx-value-tab_name={@tab_name}
        phx-click="select_tab"
      >
        <.icon
          name={@name}
          class={"h-6 transition-all group-hover:scale-110 group-hover:text-amber-500 #{if @is_active == true, do: "@[200px]:text-amber-500 @[200px]:scale-110"}"}
        />
      </a>
    </li>
    """
  end

  def chat_section(assigns) do
    ~H"""
    <section class="p-4 h-full grid grid-rows-[1fr,min-content] grid-cols-1 justify-between text-sm">
      <ul
        class="flex flex-col-reverse overflow-scroll gap-1 p-4 flex-grow rounded bg-zinc-100 dark:bg-zinc-800 shadow-inner h-full scroll-smooth"
        id="msg-container"
        phx-hook="FormatTimestampsHook"
      >
        <%= for {message, index} <- Enum.with_index(@messages) do %>
          <% is_mine = message.user_id == @user_id %>
          <% is_reply = message.replies_to != nil %>
          <% show_info =
            index == length(@messages) - 1 || Enum.at(@messages, index + 1).user_id != message.user_id ||
              minutes_apart(message, Enum.at(@messages, index + 1)) > 15 %>
          <li
            aria-label="Message"
            id={"message-#{message.id}"}
            class={"flex max-w-full #{is_reply && "w-full"} group flex-col gap-0.5 #{if is_mine, do: "self-end items-end", else: "self-start items-start"}"}
          >
            <span :if={show_info} class="text-xs">
              <span :if={not is_mine} class="font-bold mr-1">
                <%= (message.user && message.user.display_name) || message.user_display_name %>
              </span>
              <time msg-timestamp={"#{DateTime.to_iso8601(message.inserted_at)}"}></time>
            </span>
            <div class={["w-full flex items-center", is_mine && "flex-row-reverse"]}>
              <div class={[
                "rounded-lg max-w-[85%] break-words flex flex-col gap-1 grow-1",
                is_mine && "bg-amber-500/25 dark:bg-amber-500/50 items-end",
                not is_mine && "bg-[#cdebf8]/50 dark:bg-[#0d455d]/75 items-start",
                is_reply && "p-2",
                not is_reply && "py-2 px-4"
              ]}>
                <a
                  :if={is_reply}
                  href={"#message-#{message.replied_message.id}"}
                  class="relative p-2 rounded w-full max-w-full bg-black/5 dark:bg-white/10 border-dashed border border-black/20 dark:border-white/20"
                >
                  <div class="font-bold">
                    <%= get_message_display_name(message.replied_message, @user_id) %>
                  </div>
                  <span class="line-clamp-3 break-words ">
                    <%= message.replied_message.content %>
                  </span>
                </a>
                <span class="max-w-full"><%= message.content %></span>
              </div>
              <button
                title="Reply"
                phx-click={JS.focus(to: "#message_content") |> JS.push("reply_to")}
                phx-value-id={message.id}
                class="transition-all opacity-0 p-2 h-8 w-8 rounded-full  dark:hover:bg-white/20  hover:bg-black/10 mx-2 flex items-center group-hover:opacity-100 "
              >
                <.icon class="w-4 h-4" name="hero-arrow-uturn-right" />
              </button>
            </div>
          </li>
        <% end %>
      </ul>
      <div
        :if={@active_reply_to}
        class="relative p-2 rounded max-w-full bg-black/5 dark:bg-white/10 border-l-amber-500 border-l-4 mt-4"
      >
        <div class="font-bold">
          <%= get_message_display_name(@active_reply_to, @user_id) %>
        </div>
        <span class="line-clamp-3 break-words ">
          <%= @active_reply_to.content %>
        </span>
        <button phx-click="reply_to" class="absolute right-0.5 top-0.5 scale-75">
          <.icon name="hero-x-mark" />
        </button>
      </div>

      <.form for={@message_form} phx-submit="send_message" phx-change="validate_message">
        <div class="flex gap-2  pt-2">
          <span class="flex-grow">
            <.input autocomplete="off" placeholder="Type a message" field={@message_form[:content]} />
          </span>
          <button title="Send message" class="w-fit mt-2 group">
            <.icon
              name="hero-paper-airplane"
              class="h-6 transition-all group-hover:scale-110 group-hover:text-amber-500"
            />
          </button>
        </div>
      </.form>
    </section>
    """
  end

  def settings_section(assigns) do
    ~H"""
    <section class="p-4 h-full flex flex-col">
      <.form
        for={@room_state_form}
        phx-change="validate_room_state_form"
        class="flex flex-col gap-4 content-between items-end"
        phx-submit="update_room_state"
      >
        <fieldset class="w-full flex flex-col gap-4">
          <.input label="Room name" field={@room_state_form[:name]} />
        </fieldset>
        <button disabled={@room_state_form.source.errors !== []} class="btn-primary w-fit">
          SAVE
        </button>
      </.form>
      <div class="flex flex-col content-between justify-between flex-grow">
        <div>
          <div class="h-px w-full bg-gray-500/50 my-8" />
          <button class="flex w-full justify-center" phx-click={show_modal("access-modal")}>
            MANAGE USERS
          </button>
          <p class="text-center text-zinc-600 dark:text-zinc-400 mt-2 text-sm">
            Manage user roles and access
          </p>
        </div>

        <div>
          <div class="h-px w-full bg-gray-500/50 my-8" />
          <button
            class="btn-danger flex w-full justify-center"
            data-confirm="Are you sure you want to delete this room?"
            phx-click="delete"
          >
            DELETE ROOM
          </button>
        </div>
      </div>
      <.modal id="access-modal" small={true}>
        <.live_component
          module={VoidWeb.Room.AccessControlModal}
          id="access-control-modal-live"
          room_users={@room_users}
          room={@room}
          presences={@presences}
        />
      </.modal>
    </section>
    """
  end

  attr :current_user, :map, required: true
  attr :room_users, :map, required: true
  attr :presences, :map, required: true

  def users_section(assigns) do
    assigns =
      assign(assigns,
        pending_users: Enum.filter(assigns.room_users, fn ru -> ru.has_access == false end)
      )

    ~H"""
    <div class="text-center my-2 text-gray-500"><%= count_users(@presences) %></div>
    <ul class="flex flex-col">
      <%= for {user_uuid, %{metas: [ %{picture: picture, room_user: room_user} | _]}} <- @presences do %>
        <li title="Room user" class="flex justify-between p-2 items-center" ,>
          <span class="flex items-center gap-2">
            <img
              :if={picture}
              src={picture}
              alt={"#{room_user.display_name} profile picture"}
              class="w-8 rounded-full bg-gray-200 dark:bg-gray-600 p-0.5"
            />
            <span
              :if={picture == nil}
              aria-role="presentation"
              class="w-8 h-8 rounded-full bg-gray-200 dark:bg-gray-600 p-0.5 flex justify-center items-center cursor-default"
            >
              <%= get_initial(room_user.display_name) %>
            </span>
            <span class={[@current_user.id == room_user.id && "font-bold"]}>
              <%= room_user.display_name %>
            </span>
          </span>
          <ul class="flex gap-2 items-center px-2">
            <li :if={requesting_edit?(@room_users, user_uuid)} title="Raised hand">
              <.icon name="hero-hand-raised" class="text-amber-500 w-5" />
            </li>
            <%= if not editor?(@room_users, user_uuid) do %>
              <li :if={
                room_user.id !== @current_user.id and
                  @current_user.is_owner and editor?(@room_users, user_uuid) == false
              }>
                <button title="Make editor" phx-value-id={room_user.id} phx-click="grant_edit">
                  <.icon name="hero-pencil" class="text-gray-500 w-5 hover:text-amber-500" />
                </button>
              </li>
            <% else %>
              <%= if @current_user.is_owner and not room_user.is_owner do %>
                <button
                  class="group relative w-5 h-8 overflow-hidden"
                  title="Remove editor"
                  phx-value-id={room_user.id}
                  phx-click="revoke_edit"
                >
                  <.icon
                    name="hero-pencil"
                    class="text-amber-500 w-5 transition-all absolute left-0 -translate-y-1/2 group-hover:-translate-y-8 group-hover:opacity-0 group-hover"
                  />
                  <.icon
                    name="hero-x-mark"
                    class="text-red-500 w-5 transition-all absolute left-0 translate-y-1/2  opacity-0 group-hover:-translate-y-1/2 group-hover:opacity-100"
                  />
                </button>
              <% else %>
                <i title="Editor">
                  <.icon name="hero-pencil" class="text-amber-500 w-5 group-hover:hidden" />
                </i>
              <% end %>
            <% end %>
          </ul>
        </li>
      <% end %>
      <div :if={Enum.count(@pending_users) > 0}>
        <div class="text-center my-2 text-gray-500">Awaiting access:</div>
        <ul>
          <%= for room_user <- @pending_users do %>
            <li title="Pending user" class="flex justify-between p-2 items-center">
              <span class="flex items-center gap-2">
                <span
                  aria-role="presentation"
                  class="w-8 h-8 rounded-full bg-gray-200 dark:bg-gray-600 p-0.5 flex justify-center items-center"
                >
                  <%= get_initial(room_user.display_name) %>
                </span>
                <span class={[@current_user.id == room_user.id && "font-bold"]}>
                  <%= room_user.display_name %>
                </span>
              </span>
              <ul class="flex gap-2 items-center px-2">
                <button class="btn bg-green-500" phx-click="grant_access" phx-value-id={room_user.id}>
                  ADMIT
                </button>
                <button class="btn-danger" phx-click="deny_access" phx-value-id={room_user.id}>
                  DENY
                </button>
              </ul>
            </li>
          <% end %>
        </ul>
      </div>
    </ul>
    """
  end

  defp count_users(enum) do
    case Enum.count(enum) do
      1 -> "1 user is here"
      count -> "#{count} users are here"
    end
  end

  defp get_this_room_user(room_users, user_uuid) do
    room_users |> Enum.find(fn ru -> ru.user_id == user_uuid end)
  end

  defp requesting_edit?(room_users, user_uuid) do
    user = get_this_room_user(room_users, user_uuid)
    user.requesting_edit
  end

  defp editor?(room_users, user_uuid) do
    user = get_this_room_user(room_users, user_uuid)
    user.is_editor
  end

  attr :room_user, :map, required: true

  def action_bar(assigns) do
    ~H"""
    <ul class="flex gap-2 md:gap-4 px-4 py-2 rounded-full border border-gray-500 items-center dark:text-gray-200 text-gray-700 ">
      <.action_bar_button
        :if={@room_user.requesting_edit == false}
        name="hero-hand-raised"
        phx-value-id={@room_user.id}
        phx-click="request_edit"
        title="Raise hand"
      />
      <.action_bar_button
        :if={@room_user.requesting_edit == true}
        name="hero-hand-raised-solid"
        phx-value-id={@room_user.id}
        phx-click="cancel_request_edit"
        class="text-amber-500"
        title="Lower hand"
      />
      <.action_bar_button
        :if={@muted == true}
        name="hero-speaker-x-mark"
        phx-value-id={@room_user.id}
        phx-click={
          JS.dispatch("js:play-sound", detail: %{name: "tap", force: true})
          |> JS.push("toggle_sound")
        }
        title="Enable sound"
      />
      <.action_bar_button
        :if={@muted == false}
        name="hero-speaker-wave"
        phx-value-id={@room_user.id}
        phx-click={JS.push("toggle_sound")}
        title="Disable sound"
      />
      <.action_bar_button
        class="hidden dark:block"
        name="hero-moon"
        phx-click={JS.dispatch("toggle-darkmode")}
        title="Toggle dark mode"
      />
      <.action_bar_button
        class="block dark:hidden"
        name="hero-sun"
        phx-click={JS.dispatch("toggle-darkmode")}
        title="Toggle dark mode"
      />
    </ul>
    """
  end

  attr :name, :string, required: true
  attr :disabled, :boolean, default: false
  attr :danger, :boolean, default: false
  attr :class, :string, default: ""
  attr :rest, :global

  def action_bar_button(assigns) do
    ~H"""
    <button disabled={@disabled} {@rest} class={"group #{@class}"}>
      <.icon
        name={@name}
        class={"w-5 group-disabled:text-gray-500/50 transition-all #{if @danger, do: "text-red-500", else: "hover:text-amber-500" }"}
      />
    </button>
    """
  end

  defp get_message_display_name(message, current_user_id) do
    case message.user do
      nil ->
        message.user_display_name

      user ->
        case user.id == current_user_id do
          true -> "You"
          false -> message.user.display_name
        end
    end
  end

  defp get_initial(name), do: name |> String.at(0) |> String.upcase()

  defp minutes_apart(message, next),
    do: Timex.diff(message.inserted_at, next.inserted_at, :minutes)
end
