defmodule VoidWeb.LobbyLive do
  alias Void.Accounts.User
  use VoidWeb, :live_view
  alias Void.Rooms
  alias Void.Accounts

  def mount(
        %{"room" => room_uuid},
        %{"user_token" => user_token},
        %{assigns: %{current_user: nil}} = socket
      ) do
    name_placeholder = "#{Faker.Person.first_name()} #{Faker.Person.last_name()}"

    socket =
      if Rooms.room_exists?(room_uuid) do
        name_form = to_form(Accounts.change_user_display_name(%User{}))

        assign(socket,
          guest_uuid: user_token,
          room_uuid: room_uuid,
          name_form: name_form
        )
      else
        push_navigate(socket, to: ~p"/rooms/404")
      end

    {:ok, socket, layout: false, temporary_assigns: [name_placeholder: name_placeholder]}
  end

  def mount(%{"room" => room_uuid}, _session, %{assigns: %{current_user: current_user}} = socket) do
    # Redirect to 404 if room does not exist
    socket =
      if Rooms.room_exists?(room_uuid) do
        case Rooms.user_can_access_room(current_user, room_uuid) do
          {:ok, true} -> push_navigate(socket, to: ~p"/rooms/#{room_uuid}")
          _ -> assign(socket, room_uuid: room_uuid)
        end
      else
        push_navigate(socket, to: ~p"/rooms/404")
      end

    {:ok, socket, layout: false}
  end

  def render(assigns) do
    ~H"""
    <div class="flex gap-4 flex-col items-center justify-center h-screen text-center p-8 sm:p-32">
      <%!-- <.icon name="hero-hand-raised-solid" class="dark:text-amber-500 h-32 w-32" /> --%>
      <%!-- <img src={~p"/images/logo_image.svg"} class="w-44 sm:w-64 mb-4" /> --%>
      <.logo_round class="h-44 w-44 sm:h-64 sm:w-64 mb-4 sm:mb-8" />
      <h2 class="text-xl sm:text-3xl dark:text-blue-50">You don't have access to this room</h2>
      <%= if @current_user == nil do %>
        <p class="text-md sm:text-xl dark:text-gray-300/80">
          Submit your name or log in to request access.<br /> Guest access will expire <b>24 hours</b>
          after it's granted.<br />
        </p>
        <.form
          for={@name_form}
          class="grid gap-4 w-full sm:w-[32rem] sm:grid-cols-[1fr_max-content] sm:items-baseline auto-cols-fr"
          phx-change="validate_display_name"
          phx-submit="request_access"
        >
          <.input field={@name_form[:display_name]} placeholder={@name_placeholder} />
          <button
            class="btn-primary sm:w-fit justify-center"
            disabled={@name_form.action !== :validate || @name_form.errors !== []}
          >
            Request access <.icon name="hero-lock-open-mini" class="ml-2 h-4" />
          </button>
        </.form>
      <% else %>
        <button
          phx-click={show_modal("user-config")}
          class="flex gap-2 items-center cursor-pointer border px-4 py-2 rounded-lg mb-4 bg-gray-200/80 dark:bg-gray-900 dark:border-gray-500 hover:brightness-95 transition-all"
        >
          <img
            src={@current_user.picture}
            alt="User profile picture"
            class="w-8 rounded-full bg-gray-200 dark:bg-gray-600 p-0.5"
          />
          <span class="dark:text-blue-50 text-gray-700">
            <%= @current_user.display_name %>
          </span>
        </button>
        <button class="btn-primary sm:w-fit justify-center" type="button" phx-click="request_access">
          Request access <.icon name="hero-lock-open-mini" class="ml-2 h-4" />
        </button>
      <% end %>
      <%= if @current_user == nil do %>
        <div class="grid grid-cols-[1fr_min-content_1fr] w-full sm:w-96 before:content-[' '] before:h-px before:w-full before:bg-gray-500 after:content-[' '] after:h-px after:w-full after:bg-gray-500 items-center">
          <span class="dark:text-gray-300 text-lg px-4">
            or
          </span>
        </div>
        <.link
          href={~p"/auth/github"}
          class="flex gap-2 rounded-lg bg-blue-50 hover:bg-blue-100 px-4 py-2 text-gray-800 dark:border-transparent border border-gray-700 w-full sm:w-fit justify-center font-bold"
        >
          <span>Sign in with GitHub</span>
          <svg xmlns="http://www.w3.org/2000/svg" class="w-6 h-6 flex-shrink-0" viewBox="0 0 100 100">
            <path
              fill-rule="evenodd"
              clip-rule="evenodd"
              d="M48.854 0C21.839 0 0 22 0 49.217c0 21.756 13.993 40.172 33.405 46.69 2.427.49 3.316-1.059 3.316-2.362 0-1.141-.08-5.052-.08-9.127-13.59 2.934-16.42-5.867-16.42-5.867-2.184-5.704-5.42-7.17-5.42-7.17-4.448-3.015.324-3.015.324-3.015 4.934.326 7.523 5.052 7.523 5.052 4.367 7.496 11.404 5.378 14.235 4.074.404-3.178 1.699-5.378 3.074-6.6-10.839-1.141-22.243-5.378-22.243-24.283 0-5.378 1.94-9.778 5.014-13.2-.485-1.222-2.184-6.275.486-13.038 0 0 4.125-1.304 13.426 5.052a46.97 46.97 0 0 1 12.214-1.63c4.125 0 8.33.571 12.213 1.63 9.302-6.356 13.427-5.052 13.427-5.052 2.67 6.763.97 11.816.485 13.038 3.155 3.422 5.015 7.822 5.015 13.2 0 18.905-11.404 23.06-22.324 24.283 1.78 1.548 3.316 4.481 3.316 9.126 0 6.6-.08 11.897-.08 13.526 0 1.304.89 2.853 3.316 2.364 19.412-6.52 33.405-24.935 33.405-46.691C97.707 22 75.788 0 48.854 0z"
              fill="#24292f"
            />
          </svg>
        </.link>
      <% end %>
    </div>
    <.flash_group flash={@flash} />
    <%= if @current_user do %>
      <.modal id="user-config">
        <%= live_render(@socket, VoidWeb.UserConfigLive,
          id: "user-config-live",
          session: %{"user" => @current_user, "redirect_to" => ~p"/rooms/#{@room_uuid}/lobby"}
        ) %>
      </.modal>
    <% end %>
    """
  end

  def handle_event("validate_display_name", %{"user" => user_params}, socket) do
    name_form =
      %User{}
      |> Accounts.change_user_display_name(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, name_form: name_form)}
  end

  def handle_event("request_access", %{"user" => %{"display_name" => display_name}}, socket) do
    Accounts.get_guest_user_or_register(%User{
      display_name: display_name,
      uuid: socket.assigns.guest_uuid
    })
    |> Rooms.request_room_access(socket.assigns.room_uuid, display_name)

    {:noreply, socket}
  end
end
