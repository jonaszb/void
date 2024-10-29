defmodule VoidWeb.Room.RoomComponents do
  use Phoenix.Component
  import VoidWeb.CoreComponents

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
    <section class="p-4 h-full grid grid-rows-[1fr,min-content] grid-cols-1 justify-between">
      <ul
        class="flex flex-col-reverse overflow-scroll gap-1 p-4 flex-grow rounded bg-zinc-100 dark:bg-zinc-800 shadow-inner h-full"
        id="msg-container"
        phx-hook="FormatTimestampsHook"
      >
        <%= for {message, index} <- Enum.with_index(@messages) do %>
          <% is_mine = message.user_id == @user_id %>
          <% show_info =
            index == length(@messages) - 1 || Enum.at(@messages, index + 1).user_id != message.user_id ||
              minutes_apart(message, Enum.at(@messages, index + 1)) > 15 %>
          <li class={"flex max-w-[80%] flex-col gap-0.5 #{if is_mine, do: "self-end items-end", else: "self-start items-start"}"}>
            <span :if={show_info} class="text-xs">
              <span :if={not is_mine} class="font-bold mr-1">
                <%= message.user.display_name %>
              </span>
              <time msg-timestamp={"#{DateTime.to_iso8601(message.inserted_at)}"}></time>
            </span>
            <span class={[
              "py-2 px-4 rounded-lg break-all",
              is_mine && "bg-amber-500/25 dark:bg-amber-500/50",
              not is_mine && "bg-[#cdebf8]/50 dark:bg-[#0d455d]/75"
            ]}>
              <%= message.content %>
            </span>
          </li>
        <% end %>
      </ul>
      <.form for={@message_form} phx-submit="send_message" phx-change="validate_message">
        <div class="flex gap-2  pt-2">
          <span class="flex-grow">
            <.input autocomplete="off" placeholder="Type a message" field={@message_form[:content]} />
          </span>
          <button class="w-fit mt-2 group">
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
    <section class="p-4 ">
      <.form
        for={@room_state_form}
        phx-change="validate_room_state_form"
        class="flex flex-col gap-4 content-between items-end"
        phx-submit="update_room_state"
      >
        <fieldset class="w-full flex flex-col gap-4">
          <.input label="Room name" field={@room_state_form[:name]} />
          <.input
            label="Language"
            field={@room_state_form[:language]}
            type="select"
            options={@supported_languages}
          />
        </fieldset>
        <button disabled={@room_state_form.source.errors !== []} class="btn-primary w-fit">
          SAVE
        </button>
      </.form>
      <div class="h-px w-full bg-gray-500/50 my-8" />
      <button
        class="btn-danger flex w-full justify-center"
        data-confirm="Are you sure you want to delete this room?"
        phx-click="delete"
      >
        DELETE ROOM
      </button>
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
            <li :if={is_requesting_edit?(@room_users, user_uuid)} title="Raised hand">
              <.icon name="hero-hand-raised" class="text-amber-500 w-5" />
            </li>
            <%= if not is_editor?(@room_users, user_uuid) do %>
              <li :if={
                room_user.id !== @current_user.id and
                  @current_user.is_owner and is_editor?(@room_users, user_uuid) == false
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

  defp is_requesting_edit?(room_users, user_uuid) do
    user = get_this_room_user(room_users, user_uuid)
    user.requesting_edit
  end

  defp is_editor?(room_users, user_uuid) do
    user = get_this_room_user(room_users, user_uuid)
    user.is_editor
  end

  attr :room_user, :map, required: true

  def action_bar(assigns) do
    ~H"""
    <ul class="flex gap-2 md:gap-4 px-4 rounded-full border border-gray-500 my-4 items-center dark:text-gray-200 text-gray-700 ">
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
      <%!-- <.action_bar_button
        :if={@room_user.is_owner}
        name="hero-pencil-solid"
        danger={true}
        disabled={@room_user.is_editor}
        phx-value-id={@room_user.id}
        phx-click="grant_edit"
        title="Become editor"
      /> --%>
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

  defp get_initial(name), do: name |> String.at(0) |> String.upcase()

  defp minutes_apart(message, next),
    do: Timex.diff(message.inserted_at, next.inserted_at, :minutes)
end
