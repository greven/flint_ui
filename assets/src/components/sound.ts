import { FlintHook } from "../lib/core";
import { sound } from "../lib/sound";
import type { Macros } from "../lib/sound";

/**
 * One provider for the whole document.
 *
 * The hook delegates from `document`, so a single element, mounted once in
 * the app layout, covers every page, every live navigation, and markup
 * rendered later. Sounds are opt-in per element:
 *
 *   data-sound="tap"            click / keyboard activation
 *   data-sound-press="press"    pointerdown
 *   data-sound-release="release" pointerup
 *   data-sound-toggle           click, reading the resulting on/off state
 *   data-sound-hover="tick"     pointerover / keyboard focus
 *   data-sound-type="thock"     keydown inside a field
 *   data-sound-enter="bubble"   element added to the DOM, or gains the attribute
 *   data-sound-exit="whoosh"    element removed from the DOM
 *   data-sound-change="switch"  watched state attribute changed
 *   data-sound-open="rise"      state became open/on/true
 *   data-sound-close="drop"     state became closed/off/false
 *
 * Four dials tune a single play: data-sound-pitch (semitones),
 * -length, -air, -space, plus -volume and -pan.
 */
const STATE_ATTRS = [
  "open",
  "data-state",
  "aria-expanded",
  "aria-selected",
  "aria-checked",
  "aria-pressed",
];

export class Sound extends FlintHook {
  private observer: MutationObserver | null = null;
  private seenEnabled: string | null = null;
  private seenTheme: string | null = null;
  private seenVolume: string | null = null;
  private hovered: Element | null = null;
  private pressed: { el: Element; at: number } | null = null;

  mounted(): void {
    super.mounted();

    this.syncProvider();
    this.observe();

    document.addEventListener("pointerdown", this.handlePointerDown);
    document.addEventListener("pointerup", this.handlePointerUp);
    document.addEventListener("pointerover", this.handlePointerOver);
    document.addEventListener("pointerout", this.handlePointerOut);
    document.addEventListener("click", this.handleClick);
    document.addEventListener("focusin", this.handleFocusIn);
    document.addEventListener("keydown", this.handleKeyDown);

    document.addEventListener("fl:sound", this.handleSoundEvent);
    document.addEventListener("fl:sound:toggle", this.handleToggle);
    document.addEventListener("fl:sound:set", this.handleSet);
    document.addEventListener("fl:sound:theme", this.handleTheme);

    // Server-triggered cues:
    //   push_event(socket, "fl:sound", %{name: "success", space: 1.2})
    this.handleEvent("fl:sound", (payload?: unknown) => this.playPayload(payload));
  }

  updated(): void {
    this.syncProvider();
  }

  destroyed(): void {
    this.observer?.disconnect();
    this.observer = null;

    document.removeEventListener("pointerdown", this.handlePointerDown);
    document.removeEventListener("pointerup", this.handlePointerUp);
    document.removeEventListener("pointerover", this.handlePointerOver);
    document.removeEventListener("pointerout", this.handlePointerOut);
    document.removeEventListener("click", this.handleClick);
    document.removeEventListener("focusin", this.handleFocusIn);
    document.removeEventListener("keydown", this.handleKeyDown);

    document.removeEventListener("fl:sound", this.handleSoundEvent);
    document.removeEventListener("fl:sound:toggle", this.handleToggle);
    document.removeEventListener("fl:sound:set", this.handleSet);
    document.removeEventListener("fl:sound:theme", this.handleTheme);
  }

  private syncProvider(): void {
    const enabled = this.el.getAttribute("data-sound-enabled");
    const theme = this.el.getAttribute("data-sound-theme");
    const volume = this.el.getAttribute("data-sound-volume");
    const reduced = this.el.getAttribute("data-sound-reduced-motion");

    if (this.seenEnabled === null) {
      sound.init({
        enabled: enabled === "true",
        theme,
        volume: volume === null ? undefined : Number(volume),
        reducedMotion: reduced === "allow" ? "allow" : "mute",
      });

      this.seenEnabled = enabled;
      this.seenTheme = theme;
      this.seenVolume = volume;
      return;
    }

    if (enabled !== this.seenEnabled) {
      this.seenEnabled = enabled;
      sound.setEnabled(enabled === "true");
    }

    if (theme !== this.seenTheme) {
      this.seenTheme = theme;
      sound.setTheme(theme);
    }

    if (volume !== this.seenVolume) {
      this.seenVolume = volume;
      if (volume !== null) sound.setVolume(Number(volume));
    }
  }

  private observe(): void {
    if (typeof MutationObserver === "undefined") return;

    this.observer = new MutationObserver((records) => {
      for (const record of records) {
        if (record.type === "attributes") {
          const el = record.target;
          if (!(el instanceof HTMLElement)) continue;

          // LiveView morphs conditionals in place: a span that gains
          // `data-sound-enter` is never inserted, so childList alone would
          // stay silent. Treat the attribute's arrival as the entrance.
          if (record.attributeName === "data-sound-enter") {
            if (record.oldValue === null && el.hasAttribute("data-sound-enter")) {
              this.playFor(el, el.getAttribute("data-sound-enter") || "bubble");
            }
            continue;
          }

          const change = el.getAttribute("data-sound-change");
          if (change) this.playFor(el, change);

          const open = el.getAttribute("data-sound-open");
          const close = el.getAttribute("data-sound-close");

          if (open || close) {
            const name = isOn(el) ? open : close;
            if (name) this.playFor(el, name);
          }

          continue;
        }

        record.addedNodes.forEach((node) => {
          each(node, "[data-sound-enter]", (el) =>
            this.playFor(el, el.getAttribute("data-sound-enter") || "bubble"),
          );
        });

        record.removedNodes.forEach((node) => {
          each(node, "[data-sound-exit]", (el) =>
            this.playFor(el, el.getAttribute("data-sound-exit") || "whoosh", 0),
          );
        });
      }
    });

    this.observer.observe(document.documentElement, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeOldValue: true,
      attributeFilter: [...STATE_ATTRS, "data-sound-enter"],
    });
  }

  private handlePointerDown = (event: PointerEvent): void => {
    if (event.button !== 0) return;

    const el = triggerFor(event, "[data-sound-press]");
    if (!el) return;

    this.pressed = { el, at: performance.now() };
    this.playFor(el, el.getAttribute("data-sound-press") || "press");
  };

  private handlePointerUp = (event: PointerEvent): void => {
    if (event.button !== 0) return;

    const el = triggerFor(event, "[data-sound-release]");
    if (!el) return;

    this.playFor(el, el.getAttribute("data-sound-release") || "release");
  };

  private handleClick = (event: MouseEvent): void => {
    if (event.defaultPrevented) return;

    const target = event.target;
    if (!(target instanceof Element)) return;

    const el = target.closest<HTMLElement>("[data-sound]");
    if (el && !isDisabled(el)) {
      // A press/release pair already gave this gesture a voice; keep the click
      // cue for keyboard activation, which never fires a pointer event.
      const pressed = this.pressed;
      const sameGesture =
        pressed !== null && pressed.el === el && performance.now() - pressed.at < 800;

      if (!sameGesture) this.playFor(el, el.getAttribute("data-sound") || "tap");
    }

    const toggle = target.closest<HTMLElement>("[data-sound-toggle]");
    if (toggle && !isDisabled(toggle)) {
      // The toggle flips its state client-side before the click bubbles, so
      // this is the resulting state.
      const cue = toggle.getAttribute("data-sound-toggle") || (isOn(toggle) ? "on" : "off");
      this.playFor(toggle, cue);
    }
  };

  private handlePointerOver = (event: PointerEvent): void => {
    const el = triggerFor(event, "[data-sound-hover]");
    if (!el || el === this.hovered) return;

    this.hovered = el;
    this.playFor(el, el.getAttribute("data-sound-hover") || "tick");
  };

  private handlePointerOut = (event: PointerEvent): void => {
    if (this.hovered && !this.hovered.contains(event.relatedTarget as Node | null)) {
      this.hovered = null;
    }
  };

  private handleFocusIn = (event: FocusEvent): void => {
    const el = triggerFor(event, "[data-sound-hover]");
    if (!el) return;

    // Pointer clicks also move focus; only keyboard focus should tick.
    try {
      if (!el.matches(":focus-visible")) return;
    } catch {
      return;
    }

    this.playFor(el, el.getAttribute("data-sound-hover") || "tick");
  };

  private handleKeyDown = (event: KeyboardEvent): void => {
    const target = event.target;
    if (!(target instanceof Element)) return;

    const el = target.closest<HTMLElement>("[data-sound-type]");
    if (!el || isDisabled(el)) return;

    if (event.key === "Enter") {
      sound.play("complete", macrosFor(el));
      return;
    }

    if (event.key.length === 1 || event.key === "Backspace") {
      const macros = macrosFor(el);
      sound.play(el.getAttribute("data-sound-type") || "thock", {
        ...macros,
        pitch: (macros.pitch ?? 0) + (Math.random() * 2 - 1),
      });
    }
  };

  private handleSoundEvent = (event: Event): void => {
    this.playPayload((event as CustomEvent<unknown>).detail);
  };

  private handleToggle = (): void => {
    sound.toggle();
  };

  private handleSet = (event: Event): void => {
    const detail = (event as CustomEvent<{ enabled?: boolean }>).detail;
    if (typeof detail?.enabled === "boolean") sound.setEnabled(detail.enabled);
  };

  private handleTheme = (event: Event): void => {
    const detail = (event as CustomEvent<{ theme?: string }>).detail;
    if (detail?.theme) sound.setTheme(detail.theme);
  };

  private playPayload(payload: unknown): void {
    if (!payload) return;

    if (typeof payload === "string") {
      sound.play(payload);
      return;
    }

    if (typeof payload !== "object") return;

    const data = payload as { name?: string } & Macros & {
        loop?: boolean;
        every?: number;
      };
    if (!data.name) return;

    const { name, ...options } = data;
    sound.play(name, options);
  }

  private playFor(el: HTMLElement, name: string, pan?: number): void {
    const macros = macrosFor(el);
    if (pan !== undefined) macros.pan = pan;
    sound.play(name, macros);
  }
}

function triggerFor(event: Event, selector: string): HTMLElement | null {
  const target = event.target;
  if (!(target instanceof Element)) return null;

  const el = target.closest<HTMLElement>(selector);
  if (!el || isDisabled(el)) return null;

  return el;
}

function isDisabled(el: HTMLElement): boolean {
  if (el.closest('[aria-disabled="true"]')) return true;
  if (el.hasAttribute("data-loading") || el.hasAttribute("data-disabled")) return true;
  if (el instanceof HTMLButtonElement && el.disabled) return true;
  return false;
}

function isOn(el: HTMLElement): boolean {
  if (el.getAttribute("aria-pressed") === "true") return true;
  if (el.getAttribute("aria-expanded") === "true") return true;
  if (el.getAttribute("aria-checked") === "true") return true;
  if (el.hasAttribute("open")) return true;

  const state = el.getAttribute("data-state");
  return state === "on" || state === "open" || state === "checked";
}

function macrosFor(el: HTMLElement): Macros {
  return {
    pitch: numberAttr(el, "data-sound-pitch"),
    length: numberAttr(el, "data-sound-length"),
    air: numberAttr(el, "data-sound-air"),
    space: numberAttr(el, "data-sound-space"),
    volume: numberAttr(el, "data-sound-volume"),
    pan: numberAttr(el, "data-sound-pan"),
  };
}

function numberAttr(el: HTMLElement, name: string): number | undefined {
  const raw = el.getAttribute(name);
  if (raw === null || raw.trim() === "") return undefined;

  const value = Number(raw);
  return Number.isFinite(value) ? value : undefined;
}

function each(node: Node, selector: string, fn: (el: HTMLElement) => void): void {
  if (!(node instanceof Element)) return;

  if (node.matches(selector)) fn(node as HTMLElement);
  node.querySelectorAll<HTMLElement>(selector).forEach(fn);
}
