defmodule VoidWeb.Room.RoomComponents do
  use Phoenix.Component
  import VoidWeb.CoreComponents

  attr :is_owner, :boolean, required: true

  def nav_menu(assigns) do
    ~H"""
    <nav id="sidebar-tabs" role="tablist" class="border-b-2 border-zinc-500/50">
      <ul class="grid grid-flow-col">
        <.nav_menu_item
          name="hero-chat-bubble-left-right"
          tab_name={:chat}
          is_active={@active_tab == :chat}
          title="Chat"
        />
        <.nav_menu_item
          name="hero-users"
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
  attr :rest, :global

  def nav_menu_item(assigns) do
    ~H"""
    <li role="tab" {@rest} class="border-zinc-500/50 [&:not(:last-child)]:border-r-2">
      <a
        class="py-7  flex justify-center cursor-pointer transition-all group hover:brightness-105"
        phx-value-tab_name={@tab_name}
        phx-click="select_tab"
      >
        <.icon
          name={@name}
          class={[
            "h-6 transition-all group-hover:scale-110 group-hover:text-amber-500",
            @is_active == true && "text-amber-500 scale-110"
          ]}
        />
      </a>
    </li>
    """
  end

  def chat_section(assigns) do
    ~H"""
    <div class="flex items-center justify-center text-3xl text-gray-500 font-work mt-24">
      <h2 class="text-center">COMING <br />SOON</h2>
    </div>
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
                  (@current_user.is_editor or
                     @current_user.is_owner) and is_editor?(@room_users, user_uuid) == false
              }>
                <button title="Make editor" phx-value-id={room_user.id} phx-click="grant_edit">
                  <.icon name="hero-pencil" class="text-gray-500 w-5 hover:text-amber-500" />
                </button>
              </li>
            <% else %>
              <button
                title="Make editor"
                phx-value-id={room_user.id}
                phx-click="grant_edit"
                disabled={true}
              >
                <.icon name="hero-pencil" class="text-amber-500 w-5" />
              </button>
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

  def request_edit_btn(assigns) do
    ~H"""
    <button
      :if={not @room_user.is_editor}
      class="btn-primary"
      phx-click="request_edit"
      phx-value-id={@room_user.id}
    >
      <%!-- <.icon name="hero-hand-raised" class="w-8" /> --%> EDIT
    </button>
    """
  end

  attr :room_user, :map, required: true

  def action_bar(assigns) do
    ~H"""
    <ul class="flex gap-2 md:gap-4 px-4 rounded-full border border-gray-500 my-4 items-center dark:text-gray-200 text-gray-700 ">
      <.action_bar_button
        :if={@room_user.requesting_edit == false}
        name="hero-hand-raised"
        disabled={@room_user.is_editor}
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
        :if={@room_user.is_owner}
        name="hero-pencil-solid"
        danger={true}
        disabled={@room_user.is_editor}
        phx-value-id={@room_user.id}
        phx-click="grant_edit"
        title="Become editor"
      />
    </ul>
    """
  end

  attr :name, :string, required: true
  attr :danger, :boolean, default: false
  attr :class, :string, default: ""
  attr :rest, :global

  def action_bar_button(assigns) do
    ~H"""
    <button {@rest} class={"group #{@class}"}>
      <.icon
        name={@name}
        class={[
          "w-5 group-disabled:text-gray-500/50 transition-all",
          @danger == true && "text-red-500",
          @danger == false && "hover:text-amber-500 "
        ]}
      />
    </button>
    """
  end

  defp get_initial(name), do: name |> String.at(0) |> String.upcase()
end
