defmodule VoidWeb.UserConfigLive do
  alias Phoenix.LiveView.JS
  alias Void.Accounts
  import VoidWeb.CoreComponents

  use Phoenix.LiveView

  @impl true
  def mount(_params, %{"user" => user, "redirect_to" => redirect_to}, socket) do
    name_changeset = Accounts.change_user_display_name(user)

    socket =
      socket
      |> assign(
        trigger_submit: false,
        name_form: to_form(name_changeset),
        user: user,
        redirect_to: redirect_to
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section>
      <.flash_group flash={@flash} />
      <header class="text-xl sm:text-2xl uppercase tracking-widest font-bold text-blue-400/70 dark:text-blue-200/70 mb-6 sm:mb-12">
        Profile settings
      </header>
      <.form
        for={@name_form}
        id="user-config-form"
        phx-submit="update_display_name"
        phx-change="validate_display_name"
      >
        <div class="grid grid-cols-1 sm:grid-cols-2 sm:gap-4 gap-3">
          <.input field={@name_form[:username]} label="Username" disabled />
          <.input field={@name_form[:email]} label="Email" disabled />
          <div class="sm:col-span-2">
            <.input field={@name_form[:display_name]} label="Display name" />
          </div>
        </div>
        <footer class="flex w-full justify-end gap-4 mt-8">
          <button class="px-4 py-2 text-blue-50 bg-blue-500 rounded-md hover:brightness-110">
            Save
          </button>
          <button
            phx-click={JS.exec("data-cancel", to: "#user-config")}
            type="button"
            class="px-4 py-2 text-gray-700 dark:text-gray-300 border bg-transparent rounded-md border-gray-500"
          >
            Cancel
          </button>
        </footer>
      </.form>
    </section>
    """
  end

  @impl true
  def handle_event("update_display_name", params, socket) do
    %{"user" => %{"display_name" => display_name} = user_params} = params
    user = socket.assigns.user

    case Accounts.update_user_display_name(user, display_name, user_params) do
      {:ok, applied_user} ->
        # info = "Display name updated!"
        JS.exec("data-cancel", to: "#user-config")

        {:noreply,
         socket
         #  |> put_flash(:info, info)
         |> assign(user: applied_user)
         |> push_navigate(to: socket.assigns.redirect_to || "/")}

      {:error, changeset} ->
        {:noreply, assign(socket, :name_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_display_name", params, socket) do
    %{"user" => user_params} = params

    name_form =
      socket.assigns.user
      |> Accounts.change_user_display_name(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, name_form: name_form)}
  end
end
