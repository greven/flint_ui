defmodule FlintUIDocsWeb.SoundLive do
  @moduledoc false

  use FlintUIDocsWeb, :live_view

  alias FlintUIDocsWeb.Components
  alias FlintUIDocsWeb.DocsComponents

  @themes ~w(default soft mechanical glass)

  @dials [
    %{key: "pitch", label: "Pitch", hint: "semitones", min: -12, max: 12, step: 1, value: 0},
    %{key: "length", label: "Length", hint: "decay ×", min: 0.4, max: 2.5, step: 0.05, value: 1},
    %{key: "air", label: "Air", hint: "noise ×", min: 0, max: 2, step: 0.05, value: 1},
    %{key: "space", label: "Space", hint: "reverb ×", min: 0, max: 2, step: 0.05, value: 1}
  ]

  @sound_attrs [
    {"data-sound", "click, Enter, or Space", "tap"},
    {"data-sound-press", "pointerdown", "press"},
    {"data-sound-release", "pointerup", "release"},
    {"data-sound-toggle", "click, read as on/off", "on / off"},
    {"data-sound-hover", "pointerover, keyboard focus", "tick"},
    {"data-sound-type", "keydown in a field", "thock"},
    {"data-sound-enter", "element inserted, or gains the attribute", "bubble"},
    {"data-sound-exit", "element removed from the DOM", "whoosh"},
    {"data-sound-change", "a watched state attribute changes", "switch"},
    {"data-sound-open", "state became on / open", "rise"},
    {"data-sound-close", "state became off / closed", "drop"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Sounds",
       saving: false,
       saved: false,
       toast: nil,
       families: FlintUI.Sound.by_family(),
       themes: @themes,
       dials: @dials,
       sound_attrs: @sound_attrs
     )}
  end

  @impl true
  def handle_event("save", _params, %{assigns: %{saving: true}} = socket), do: {:noreply, socket}

  def handle_event("save", _params, socket) do
    Process.send_after(self(), :saved, 900)
    {:noreply, assign(socket, saving: true, saved: false)}
  end

  def handle_event("notify", _params, socket) do
    Process.send_after(self(), :dismiss_toast, 2800)
    {:noreply, assign(socket, toast: "Deployed to production")}
  end

  def handle_event("dismiss_toast", _params, socket) do
    {:noreply, assign(socket, toast: nil)}
  end

  @impl true
  def handle_info(:saved, socket) do
    {:noreply,
     socket
     |> assign(saving: false, saved: true)
     |> push_event("fl:sound", %{name: "success", space: 1.2})}
  end

  def handle_info(:dismiss_toast, socket) do
    {:noreply, assign(socket, toast: nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} section={:guides} page={:sound}>
      <div class="max-w-3xl">
        <h1 class="text-3xl font-semibold tracking-tight">Sounds</h1>
        <p class="mt-3 text-zinc-600 dark:text-zinc-400">
          FlintUI can give interaction a voice: short cues synthesized in the browser with the
          Web Audio API. There are no audio files, no network requests, and nothing plays until
          you ask for it.
        </p>
        <p class="mt-2 text-zinc-600 dark:text-zinc-400">
          The palette is adapted from
          <a
            href="https://github.com/eakbulut/foley"
            class="font-medium underline underline-offset-2"
            target="_blank"
            rel="noopener"
          >
            Foley
          </a>
          (MIT) — the same seven families, four themes, and four dials.
        </p>
      </div>

      <DocsComponents.section title="Setup" id="setup" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          Sounds are a second, optional bundle. Apps that never use them never download it:
          the core <code class="font-mono">flint.js</code>
          stays small, and <code class="font-mono">flint-sound.js</code>
          is only added when you ask for it.
        </p>

        <DocsComponents.code_block code="mix flint.setup --sound" lang={:bash} />

        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          If you install by hand, add both bundles to <code class="font-mono">assets/js/app.js</code>
          and merge their hooks:
        </p>

        <DocsComponents.code_block code={snippet(:js_setup)} lang={:javascript} />

        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          That registers the hook; it does not mount it, and nothing plays until you do. If you
          manage <code class="font-mono">app.js</code>
          yourself, pass <code class="font-mono">--no-js</code>
          to the task. Mounting the provider without the
          sound bundle leaves the hook unregistered, so nothing plays.
        </p>
      </DocsComponents.section>

      <DocsComponents.section title="Where the provider goes" id="provider" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          Mount the provider <strong>once per document</strong>, in the shared layout. In a
          default Phoenix app that is
          <code class="font-mono">lib/my_app_web/components/layouts.ex</code>
          — the <code class="font-mono">Layouts.app/1</code>
          function every LiveView wraps its content in. Put the provider at the top of its
          template, above the page content. The hook listens on
          <code class="font-mono">document</code>
          and delegates, so one hidden element covers every page, every live navigation, and
          markup rendered later.
        </p>

        <div class="mt-4 rounded-lg border border-amber-300/60 bg-amber-50 p-4 text-sm dark:border-amber-500/30 dark:bg-amber-500/10">
          <p class="font-medium text-amber-900 dark:text-amber-200">
            One element per document. Put it in the shared layout, not in a page or a component.
          </p>
          <p class="mt-1 text-amber-800/90 dark:text-amber-200/80">
            The hook delegates from <code class="font-mono">document</code>, so a provider in the
            layout covers every page without repeating it. Mounting a second one — for example a
            layout provider plus a page-level provider — double-binds the listeners and plays a
            cue twice. If you run separate root layouts (say, a public and an admin one), put one
            provider in each; that is still one per document. On live navigation the hook
            re-mounts and the stored preference is restored, so state survives the trip.
          </p>
        </div>

        <DocsComponents.code_block code={snippet(:provider)} />
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          The <code class="font-mono">enabled</code>
          assign is yours. Flip it from the server, or
          let a button dispatch <code class="font-mono">fl:sound:toggle</code>; the provider
          persists the choice in <code class="font-mono">localStorage</code>. For a dead view (no
          LiveView on the page), call <code class="font-mono">sound.init()</code>
          from <code class="font-mono">app.js</code>
          instead.
        </p>
      </DocsComponents.section>

      <DocsComponents.section title="A sound language" id="catalog" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          Cues are grouped by the job they do, not by their timbre. Pick a family, audition the
          cues, then attach the name that fits. Sounds are off until you turn them on:
        </p>

        <div class="mt-4 flex flex-wrap items-center gap-3 rounded-xl border border-zinc-200 bg-zinc-50 p-3 dark:border-zinc-800 dark:bg-zinc-900/40">
          <button
            type="button"
            data-sound-enable
            aria-pressed="false"
            aria-label="Toggle interface sounds"
            phx-click={JS.dispatch("fl:sound:toggle")}
            class="inline-flex items-center gap-2 rounded-lg border border-zinc-300 bg-white px-3 py-1.5 text-sm font-medium text-zinc-700 transition-colors aria-pressed:border-zinc-900 aria-pressed:bg-zinc-900 aria-pressed:text-white dark:border-zinc-700 dark:bg-zinc-900 dark:text-zinc-200 dark:aria-pressed:border-zinc-100 dark:aria-pressed:bg-zinc-100 dark:aria-pressed:text-zinc-900"
          >
            <span data-sound-icon="on" class="inline-flex items-center gap-2">
              <.icon name="lucide-volume-2" class="size-4" /> Sound on
            </span>
            <span data-sound-icon="off" class="inline-flex items-center gap-2">
              <.icon name="lucide-volume-x" class="size-4" /> Sound off
            </span>
          </button>

          <div class="flex flex-wrap items-center gap-1.5" aria-label="Sound theme">
            <span class="text-xs font-medium tracking-wide text-zinc-400 uppercase">Theme</span>
            <button
              :for={theme <- @themes}
              type="button"
              data-sound-theme-option={theme}
              aria-pressed={to_string(theme == "default")}
              phx-click={JS.dispatch("fl:sound:theme", detail: %{theme: theme})}
              class="rounded-full border border-zinc-300 px-2.5 py-1 text-xs font-medium text-zinc-600 transition-colors aria-pressed:border-zinc-900 aria-pressed:bg-zinc-900 aria-pressed:text-white dark:border-zinc-700 dark:text-zinc-300 dark:aria-pressed:border-zinc-100 dark:aria-pressed:bg-zinc-100 dark:aria-pressed:text-zinc-900"
            >
              {String.capitalize(theme)}
            </button>
          </div>
        </div>

        <div :for={family <- @families} class="mt-8">
          <h3 class="text-sm font-semibold tracking-tight">{family.name}</h3>
          <p class="mt-0.5 text-sm text-zinc-500 dark:text-zinc-400">{family.description}</p>

          <div class="mt-3 grid gap-2 sm:grid-cols-2">
            <button
              :for={cue <- family.cues}
              type="button"
              data-sound={cue.name}
              class="group flex items-center justify-between gap-3 rounded-lg border border-zinc-200 bg-white px-3 py-2.5 text-left transition-colors hover:border-zinc-300 hover:bg-zinc-50 dark:border-zinc-800 dark:bg-zinc-900/40 dark:hover:border-zinc-700 dark:hover:bg-zinc-900"
            >
              <span class="min-w-0">
                <span class="text-sm font-medium">{cue.name}</span>
                <span class="mt-0.5 block truncate text-xs text-zinc-500 dark:text-zinc-400">
                  {cue.description}
                </span>
              </span>
              <.icon
                name="lucide-play"
                class="size-3.5 shrink-0 text-zinc-300 transition-colors group-hover:text-zinc-600 dark:text-zinc-600 dark:group-hover:text-zinc-300"
              />
            </button>
          </div>
        </div>
      </DocsComponents.section>

      <DocsComponents.section title="Hear it where it lives" id="in-place" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          The attributes compose: a control can own a press and a release, a toggle picks its cue
          from the resulting state, and an element can sound when it enters or leaves the DOM.
        </p>

        <div class="mt-4 grid gap-3">
          <div class="rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
            <p class="text-sm font-medium">Two-part press</p>
            <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
              Down and up are different cues, so a click feels like a mechanism. Hold the button —
              the release waits for you. Keyboard activation falls back to <code class="font-mono">data-sound</code>.
            </p>
            <div class="mt-3 flex flex-wrap gap-2">
              <Components.button
                variant="outline"
                data-sound-press="press"
                data-sound-release="release"
                data-sound="tap"
              >
                Press and hold
              </Components.button>
            </div>
            <DocsComponents.code_block code={snippet(:press)} />
          </div>

          <div class="grid gap-3 sm:grid-cols-2">
            <div class="rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
              <p class="text-sm font-medium">Toggle</p>
              <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                Reads the resulting state, so on and off are siblings rather than twins.
              </p>
              <div class="mt-3">
                <.toggle data-sound-toggle>Dark mode</.toggle>
              </div>
              <DocsComponents.code_block code={snippet(:toggle)} />
            </div>

            <div class="rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
              <p class="text-sm font-medium">Collapsible</p>
              <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                State changes pick between two cues.
              </p>
              <div class="mt-3">
                <Components.collapsible
                  id="sound-collapsible"
                  data-sound-open="rise"
                  data-sound-close="drop"
                >
                  <:trigger :let={attrs}>
                    <button {attrs} class="text-sm font-medium underline underline-offset-2">
                      Show details
                    </button>
                  </:trigger>
                  <:content :let={attrs}>
                    <p {attrs} class="pt-2 text-sm text-zinc-500 dark:text-zinc-400">
                      Content that arrives with a lift and leaves with a settle.
                    </p>
                  </:content>
                </Components.collapsible>
              </div>
              <DocsComponents.code_block code={snippet(:collapsible)} />
            </div>
          </div>

          <div class="grid gap-3 sm:grid-cols-2">
            <div class="rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
              <p class="text-sm font-medium">Toast</p>
              <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                <code class="font-mono">enter</code> and <code class="font-mono">exit</code> watch
                the DOM, so any toast library can opt in with an attribute.
              </p>
              <div class="mt-3 flex flex-wrap gap-2">
                <Components.button variant="outline" phx-click="notify" data-sound="tap">
                  Notify
                </Components.button>
                <Components.button
                  :if={@toast}
                  variant="ghost"
                  size="sm"
                  phx-click="dismiss_toast"
                >
                  Dismiss
                </Components.button>
              </div>
              <div
                :if={@toast}
                data-sound-enter="bubble"
                data-sound-exit="whoosh"
                class="mt-3 rounded-lg border border-zinc-200 bg-white px-3 py-2 text-sm shadow-sm dark:border-zinc-700 dark:bg-zinc-900"
              >
                {@toast}
              </div>
              <DocsComponents.code_block code={snippet(:toast)} />
            </div>

            <div class="rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
              <p class="text-sm font-medium">Typing</p>
              <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
                Per-key cue with a little pitch drift; <code class="font-mono">Enter</code> gets
                its own arrival.
              </p>
              <input
                type="text"
                data-sound-type="thock"
                placeholder="Type a few words…"
                {FlintUI.Autofill.ignore_attributes()}
                class="keeper-ignore mt-3 w-full rounded-lg border border-zinc-300 bg-white px-3 py-2 text-sm dark:border-zinc-700 dark:bg-zinc-900"
              />
              <DocsComponents.code_block code={snippet(:type)} />
            </div>
          </div>
        </div>
      </DocsComponents.section>

      <DocsComponents.section title="The four dials" id="dials" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          Every cue is data. Four perceptual macros reshape it per play, and the same four are
          available as attributes. Move a slider to hear the cue change:
        </p>

        <div
          id="sound-dials"
          phx-hook=".SoundDials"
          class="mt-4 rounded-xl border border-zinc-200 p-4 dark:border-zinc-800"
        >
          <div class="grid gap-4 sm:grid-cols-2">
            <label :for={dial <- @dials} class="block">
              <span class="flex items-baseline justify-between text-sm">
                <span class="font-medium">{dial.label}</span>
                <span class="text-xs text-zinc-500">{dial.hint}</span>
              </span>
              <input
                id={"sound-dial-#{dial.key}"}
                type="range"
                data-dial={dial.key}
                min={dial.min}
                max={dial.max}
                step={dial.step}
                value={dial.value}
                class="mt-2 w-full accent-zinc-900 dark:accent-zinc-100"
              />
            </label>
          </div>

          <button
            type="button"
            data-sound="tap"
            data-sound-dial-demo
            class="mt-4 rounded-lg border border-zinc-300 px-3 py-1.5 text-sm font-medium dark:border-zinc-700"
          >
            Play this cue
          </button>

          <DocsComponents.code_block code={snippet(:dials)} />
        </div>

        <script :type={Phoenix.LiveView.ColocatedHook} name=".SoundDials">
          export default {
            mounted() {
              this.button = this.el.querySelector("[data-sound-dial-demo]")
              this.el.querySelectorAll("[data-dial]").forEach((input) => {
                input.addEventListener("input", () => this.preview())
              })
            },
            preview() {
              const read = (key) => Number(this.el.querySelector(`[data-dial="${key}"]`).value)
              const macros = {
                pitch: read("pitch"),
                length: read("length"),
                air: read("air"),
                space: read("space"),
              }
              Object.assign(this.button.dataset, {
                soundPitch: String(macros.pitch),
                soundLength: String(macros.length),
                soundAir: String(macros.air),
                soundSpace: String(macros.space),
              })
              this.el.dispatchEvent(
                new CustomEvent("fl:sound", { detail: { name: "tap", ...macros }, bubbles: true })
              )
            }
          }
        </script>
      </DocsComponents.section>

      <DocsComponents.section title="Attributes" id="attributes" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          Every trigger is opt-in. An empty value uses the default cue; set a name to override it.
          Add the macros (<code class="font-mono">data-sound-pitch</code>, <code class="font-mono">-length</code>, <code class="font-mono">-air</code>, <code class="font-mono">-space</code>, <code class="font-mono">-volume</code>, <code class="font-mono">-pan</code>) to any trigger to tune that play.
        </p>

        <div class="mt-4 overflow-x-auto">
          <table class="w-full text-left text-sm">
            <thead>
              <tr class="border-b border-zinc-200 text-xs tracking-wide text-zinc-400 uppercase dark:border-zinc-800">
                <th class="py-2 pr-4 font-medium">Attribute</th>
                <th class="py-2 pr-4 font-medium">Fires on</th>
                <th class="py-2 font-medium">Default</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-zinc-100 dark:divide-zinc-800/60">
              <tr :for={{attr, fires, cue} <- @sound_attrs}>
                <td class="py-2 pr-4 align-top">
                  <code class="font-mono text-xs">{attr}</code>
                </td>
                <td class="py-2 pr-4 align-top text-zinc-600 dark:text-zinc-400">{fires}</td>
                <td class="py-2 align-top">
                  <code class="font-mono text-xs">{cue}</code>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          A press/release pair suppresses the click cue for that same pointer interaction, so a
          pointer gets one gesture's worth of sound while keyboard activation still gets the click
          cue. Cues are opt-out per element with <code class="font-mono">data-sound="none"</code>.
        </p>
      </DocsComponents.section>

      <DocsComponents.section title="From the server" id="server" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          Results often arrive after the click. The gesture itself still gets the two-part press,
          the pending state announces itself when it appears — even when LiveView updates the
          element in place rather than inserting it — and the verdict comes back from the
          LiveView:
        </p>

        <div class="mt-4 rounded-xl border border-zinc-200 p-4 dark:border-zinc-800">
          <p class="text-sm font-medium">A save round trip</p>
          <p class="mt-1 text-sm text-zinc-500 dark:text-zinc-400">
            Down-stroke, spring, wait, verdict. The button owns the press pair, the
            <code class="font-mono">Saving…</code>
            state sounds as it appears, and the server pushes the success with the same four
            dials.
          </p>
          <div class="mt-3 flex flex-wrap items-center gap-3">
            <Components.button
              variant="solid"
              phx-click="save"
              loading={@saving}
              data-sound-press="press"
              data-sound-release="release"
              data-sound="tap"
            >
              Save changes
            </Components.button>

            <span role="status" aria-live="polite" class="text-sm">
              <span :if={not @saving and not @saved} class="text-zinc-500 dark:text-zinc-400">
                Autosave off
              </span>
              <span
                :if={@saving}
                data-sound-enter="loading"
                class="flex items-center gap-1.5 text-zinc-500 dark:text-zinc-400"
              >
                <%!-- <.icon name="lucide-loader-circle" class="size-4 animate-spin" /> Saving… --%>
                <.loading class="size-4" /> Save Saving…
              </span>
              <span
                :if={@saved}
                class="flex items-center gap-1.5 font-medium text-emerald-700 dark:text-emerald-400"
              >
                <.icon name="lucide-check" class="size-4" /> Saved just now
              </span>
            </span>
          </div>
          <DocsComponents.code_block code={snippet(:save)} />
        </div>

        <p class="mt-4 text-sm text-zinc-600 dark:text-zinc-400">
          The cue is pushed from the LiveView with the same four dials, so each result can be
          tuned per event:
        </p>
        <DocsComponents.code_block code={snippet(:server)} lang={:elixir} />
      </DocsComponents.section>

      <DocsComponents.section title="Bring your own" id="custom" class="mt-10">
        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          A cue is a list of tone, noise, and cluster layers. Register or replace one at runtime;
          no build step and no assets:
        </p>
        <DocsComponents.code_block code={snippet(:register)} lang={:javascript} />

        <p class="mt-3 text-sm text-zinc-600 dark:text-zinc-400">
          For reference and further listening, Foley's
          <a
            href="https://usefoley.dev/"
            class="font-medium underline underline-offset-2"
            target="_blank"
            rel="noopener"
          >
            demo and Cue Designer
          </a>
          are the source of this palette. Cue specs and themes are adapted under the MIT license;
          see <code class="font-mono">NOTICE.md</code>
          in the repository.
        </p>
      </DocsComponents.section>

      <DocsComponents.section title="Accessibility" id="accessibility" class="mt-10">
        <ul class="mt-3 list-disc space-y-2 pl-5 text-sm text-zinc-600 dark:text-zinc-400">
          <li>Sounds are off by default and persist the user's choice.</li>
          <li>
            A cue is never the only feedback: every interaction it marks still changes visually,
            and no information is carried by sound alone.
          </li>
          <li>
            Keyboard activation is covered by <code class="font-mono">data-sound</code>; hover cues
            fire on <code class="font-mono">:focus-visible</code>, never on pointer-driven focus.
          </li>
          <li>
            When the OS asks for reduced motion, the provider starts muted unless you pass <code class="font-mono">reduced_motion="allow"</code>.
          </li>
          <li>
            Browsers gate audio until the first gesture. The provider warms the context on the
            first pointer or key event, but the very first cue can still be late.
          </li>
          <li>
            iOS Safari follows the Ring/Silent switch, so a muted phone stays silent. Treat sound
            as optional polish, never as required feedback.
          </li>
        </ul>
      </DocsComponents.section>
    </Layouts.app>
    """
  end

  defp snippet(:js_setup) do
    """
    import {hooks as flintHooks} from "flint_ui"
    import {hooks as soundHooks} from "flint_ui/sound"

    const liveSocket = new LiveSocket("/live", Socket, {
      hooks: {...flintHooks, ...soundHooks},
    })
    """
  end

  defp snippet(:provider) do
    """
    # lib/my_app_web/components/layouts.ex
    def app(assigns) do
      ~H\"\"\"
      <FlintUI.sound_provider enabled={@sound_enabled} theme="default" />

      <main class="mx-auto max-w-3xl">
        {render_slot(@inner_block)}
      </main>
      ~H\"\"\"
    end
    """
  end

  defp snippet(:press) do
    """
    <.button data-sound="tap" data-sound-press="press" data-sound-release="release">
      Press and hold
    </.button>
    """
  end

  defp snippet(:save) do
    """
    <.button
      phx-click="save"
      loading={@saving}
      data-sound-press="press"
      data-sound-release="release"
      data-sound="tap"
    >
      Save changes
    </.button>

    <span :if={@saving} data-sound-enter="loading">Saving…</span>
    <span :if={@saved}>Saved just now</span>
    """
  end

  defp snippet(:toggle) do
    """
    <.toggle data-sound-toggle>Dark mode</.toggle>
    """
  end

  defp snippet(:collapsible) do
    """
    <.collapsible id="details" data-sound-open="rise" data-sound-close="drop">
      <:trigger :let={attrs}>
        <button {attrs}>Show details</button>
      </:trigger>
      <:content :let={attrs}>
        <p {attrs}>The content.</p>
      </:content>
    </.collapsible>
    """
  end

  defp snippet(:toast) do
    """
    <div :if={@toast} data-sound-enter="bubble" data-sound-exit="whoosh">
      {@toast}
    </div>
    """
  end

  defp snippet(:type) do
    """
    <input type="text" data-sound-type="thock" placeholder="Type here…" />
    """
  end

  defp snippet(:dials) do
    """
    <button
      data-sound="tap"
      data-sound-pitch="-2"
      data-sound-length="1.2"
      data-sound-air="0.6"
      data-sound-space="1.4"
    >
      Play this cue
    </button>
    """
  end

  defp snippet(:server) do
    """
    def handle_event("save", _params, socket) do
      Process.send_after(self(), :saved, 900)
      {:noreply, assign(socket, saving: true, saved: false)}
    end

    def handle_info(:saved, socket) do
      {:noreply,
       socket
       |> assign(saving: false, saved: true)
       |> push_event("fl:sound", %{name: "success", space: 1.2})}
    end
    """
  end

  defp snippet(:register) do
    """
    import { sound } from "flint_ui/sound"

    sound.register("boop", [
      { kind: "tone", f: 660, f2: 990, a: 0.004, d: 0.08, peak: 0.16, send: 0.2 },
      { kind: "noise", filter: "bandpass", f: 2400, q: 1.2, a: 0.002, d: 0.015, peak: 0.08 }
    ])

    sound.play("boop", { pitch: -2, length: 1.1, air: 0.7, space: 1.3 })
    """
  end
end
