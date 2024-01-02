defmodule FlintDevWeb.HomeLive do
  @moduledoc false

  use FlintDevWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="">
      <.collapsible>
      </.collapsible>
    </div>
    """
  end

  defp collapsible(assigns) do
    ~H"""
    <.fl_collapsible :let={api}>
      <div {api.root} class="relative mx-auto mb-28 w-[18rem] max-w-full sm:w-[25rem]">
        <div class="flex items-center justify-between">
          <span class="text-sm font-semibold text-gray-900">
            @greven starred 7 repositories
          </span>
          <button {api.trigger} aria-label="Toggle" class="relative group h-6 w-6 place-items-center rounded-md bg-white text-sm text-gray-800 shadow hover:opacity-75 data-[disabled]:cursor-not-allowed data-[disabled]:opacity-75">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-6 h-6 p-1 group-data-[state=open]:rotate-180">
              <path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5" />
            </svg>
          </button>
        </div>

        <div class="my-2 rounded-lg bg-white p-3 shadow">
          <span class="text-base text-black">melt-ui/melt-ui</span>
        </div>

        <div {api.content} class="">
          <div class="flex flex-col gap-2">
            <div class="rounded-lg bg-white p-3 shadow">
              <span class="text-base text-black">sveltejs/svelte</span>
            </div>
            <div class="rounded-lg bg-white p-3 shadow">
              <span class="text-base text-black">sveltejs/kit</span>
            </div>
          </div>
        </div>
      </div>
    </.fl_collapsible>
    """
  end
end
