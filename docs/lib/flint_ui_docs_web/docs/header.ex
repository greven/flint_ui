defmodule FlintUIDocsWeb.Docs.Header do
  @moduledoc false

  use FlintUIDocsWeb.Docs.Page, component: :header

  alias FlintUIDocsWeb.Components

  @impl true
  def base_docs, do: :all

  @impl true
  def sections do
    [
      %{
        tab: :styled,
        section: :usage,
        id: :basic,
        title: "Usage"
      }
    ]
  end

  @impl true
  def render_section(%{section: :usage, id: :basic} = assigns) do
    ~H"""
    <.prose content={
      ~s|A header is a page-level bar with brand, navigation, and action zones. The navigation collapses into a toggle panel below the breakpoint;
      put a `.navbar` in `:nav` and the header handles the rest.|
    } />

    <.preview {assigns} code={usage_code()} canvas_class="min-h-32" flush resizable>
      <div class="fl-w-full">
        <Components.header>
          <:brand>
            <.link navigate="/" class="fl-cluster fl-items-center fl-gap-sm">
              <Components.icon name="lucide-box" class="text-toned" /> Box Inc.
            </.link>
          </:brand>

          <:nav>
            <Components.navbar label="Primary">
              <Components.navbar_item navigate="/">Home</Components.navbar_item>
              <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
              <Components.navbar_item navigate="/docs">Docs</Components.navbar_item>
            </Components.navbar>
          </:nav>

          <:actions>
            <Components.button variant="ghost">Sign in</Components.button>
            <Components.button>Get started</Components.button>
          </:actions>
        </Components.header>
      </div>
    </.preview>
    """
  end

  @impl true
  def parts_demo(assigns) do
    ~H"""
    <div class="fl-w-full">
      <Components.header
        id={"#{@parts_id}-header"}
        collapse="never"
        sticky={false}
        class="fl-rounded-lg"
      >
        <:brand>
          <span class="fl-font-semibold">Acme</span>
        </:brand>

        <:nav>
          <Components.navbar label="Primary">
            <Components.navbar_item navigate="/">Home</Components.navbar_item>
            <Components.navbar_item navigate="/pricing">Pricing</Components.navbar_item>
          </Components.navbar>
        </:nav>

        <:actions>
          <Components.button size="sm">Sign in</Components.button>
        </:actions>

        <:secondary>
          <p class="fl-py-sm fl-text-sm fl-text-toned">Secondary row</p>
        </:secondary>
      </Components.header>
    </div>
    """
  end

  defp usage_code do
    """
    <.header>
      <:brand>
        <.link navigate="/" class="fl-cluster fl-items-center fl-gap-sm">
          <.icon name="lucide-box" class="text-toned" /> Box Inc.
          Box Inc.
        </.link>
      </:brand>

      <:nav>
        <.navbar label="Primary">
          <.navbar_item navigate="/">Home</.navbar_item>
          <.navbar_item navigate="/pricing">Pricing</.navbar_item>
          <.navbar_item navigate="/docs">Docs</.navbar_item>
        </.navbar>
      </:nav>

      <:actions>
        <.button variant="ghost">Sign in</.button>
        <.button>Get started</.button>
      </:actions>
    </.header>
    """
    |> String.trim()
  end
end
