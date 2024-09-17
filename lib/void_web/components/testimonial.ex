defmodule VoidWeb.Testimonial do
  use Phoenix.Component

  attr :img, :string, required: true
  attr :rest, :global
  slot :content
  slot :name
  slot :position

  def testimonial(assigns) do
    ~H"""
    <div {@rest}>
      <figure class="flex lg:flex-row flex-col bg-amber-50 rounded-xl p-4 lg:p-0 dark:bg-gray-900 shadow-lg overflow-hidden lg:min-w-[640px] items-center">
        <div class="w-48 min-w-48 flex items-center justify-center">
          <img
            class="rounded-full lg:rounded-none w-full object-cover h-48 overflow-hidden"
            src={@img}
            alt=""
          />
        </div>
        <div class="pt-6 md:p-8 text-center lg:text-left space-y-4">
          <blockquote>
            <p class="text-lg font-medium text-blue-950 dark:text-blue-100">
              <%= render_slot(@content) %>
            </p>
          </blockquote>
          <figcaption class="font-medium">
            <div class="text-amber-600 dark:text-amber-400">
              <%= render_slot(@name) %>
            </div>
            <div class="text-slate-700 dark:text-slate-500">
              <%= render_slot(@position) %>
            </div>
          </figcaption>
        </div>
      </figure>
    </div>
    """
  end
end
