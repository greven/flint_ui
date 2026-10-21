import { FlintHook } from "../lib/core";
import { animatePresence } from "../lib/presence";

const CSS_VAR_PREFIX = "collapsible";

enum Events {
  Open = "fl:collapsible:open",
  Close = "fl:collapsible:close",
  Toggle = "fl:collapsible:toggle",
  Change = "fl:collapsible:change",
}

type CollapsibleState = "open" | "closed";

export class Collapsible extends FlintHook {
  private currentState: CollapsibleState = "closed";
  private hiddenUntilFound = false;
  private animationGeneration = 0;
  private boundTrigger: HTMLElement | null = null;
  private boundContent: HTMLElement | null = null;
  private resizeObserver: ResizeObserver | null = null;

  // --- State helpers ---

  private isDisabled(): boolean {
    return this.el.hasAttribute("data-disabled");
  }

  private readState(): CollapsibleState {
    return (this.el.getAttribute("data-state") as CollapsibleState) ?? "closed";
  }

  /**
   * Re-reads the component parts and (re)binds listeners to the trigger and
   * content. Called on mount and on every server update, since LiveView may
   * have replaced those elements.
   */
  private syncParts(): void {
    const prevTrigger = this.boundTrigger;
    const prevContent = this.boundContent;

    this.refreshParts();
    const { trigger, content } = this.parts;

    if (prevTrigger && prevTrigger !== trigger) {
      prevTrigger.removeEventListener("click", this.handleTriggerClick);
    }

    // Remove unconditionally: `hidden_until_found` may have been toggled off
    // server-side while the content element itself stayed the same.
    prevContent?.removeEventListener("beforematch", this.handleBeforeMatch);

    // addEventListener de-duplicates identical (type, listener) pairs, so this
    // is safe to call on every update.
    trigger?.addEventListener("click", this.handleTriggerClick);
    this.boundTrigger = trigger ?? null;

    if (this.hiddenUntilFound) {
      content?.addEventListener("beforematch", this.handleBeforeMatch);
    }
    this.boundContent = content ?? null;

    if (prevContent !== content) {
      this.observeContent();
    }
  }

  private updateCssVars(): void {
    const content = this.parts.content;
    if (!content) return;

    content.style.setProperty(`--_fl-${CSS_VAR_PREFIX}-height`, `${content.scrollHeight}px`);
    content.style.setProperty(`--_fl-${CSS_VAR_PREFIX}-width`, `${content.scrollWidth}px`);
  }

  /**
   * Keeps `--_fl-collapsible-height` fresh while open, so CSS consumers that read
   * the variable (and the next animation) see the current natural size even when
   * async content is patched in. Updates are skipped while an animation runs to
   * avoid feeding the animating size back into the keyframes.
   */
  private observeContent(): void {
    if (typeof ResizeObserver === "undefined") return;

    this.resizeObserver?.disconnect();
    const content = this.parts.content;
    if (!content) return;

    this.resizeObserver = new ResizeObserver(() => {
      const current = this.parts.content;
      if (!current || this.currentState !== "open") return;
      if (current.getAnimations().length > 0) return;
      this.updateCssVars();
    });

    this.resizeObserver.observe(content);
  }

  private emitChange(state: CollapsibleState): void {
    this.el.dispatchEvent(
      new CustomEvent(Events.Change, {
        bubbles: true,
        detail: { state },
      }),
    );
  }

  private pushStateEvents(state: CollapsibleState): void {
    const isOpen = state === "open";
    const payload = { id: this.el.id, open: isOpen };
    const { openEvent, closeEvent, toggleEvent } = this.el.dataset;

    if (isOpen && openEvent) this.pushEvent(openEvent, payload);
    if (!isOpen && closeEvent) this.pushEvent(closeEvent, payload);
    if (toggleEvent) this.pushEvent(toggleEvent, payload);
  }

  /**
   * Applies `state`, running the enter/leave keyframe animation.
   */
  private setState(state: CollapsibleState, emit = true): void {
    if (state === this.currentState) return;

    const isOpen = state === "open";
    const { trigger, content } = this.parts;
    const gen = ++this.animationGeneration;

    this.currentState = state;

    // Arm the keyframes. They are gated on `data-animate` so the initial
    // server-rendered state never animates before the hook mounts; from here on
    // every driven transition runs the enter/leave animation.
    this.js().setAttribute(this.el, "data-animate", "");

    const applyState = () => {
      this.js().setAttribute(this.el, "data-state", state);

      if (trigger) {
        this.js().setAttribute(trigger, "data-state", state);
        this.js().setAttribute(trigger, "aria-expanded", isOpen.toString());
      }

      if (content) {
        this.js().setAttribute(content, "data-state", state);
      }
    };

    if (content) {
      // The server may have applied `hidden` for the target state already;
      // remove it so the content can be measured and the transition can run.
      this.js().removeAttribute(content, "hidden");

      const { done } = animatePresence(content, {
        liveSocket: this.liveSocket,
        cssVarPrefix: CSS_VAR_PREFIX,
        applyState,
      });

      if (!isOpen) {
        const hide = () => {
          if (this.animationGeneration !== gen) return;
          this.js().setAttribute(content, "hidden", this.hiddenUntilFound ? "until-found" : "");
        };
        done.then(hide).catch(hide);
      }
    } else {
      applyState();
    }

    this.emitChange(state);

    if (emit) this.pushStateEvents(state);
  }

  // --- Event handlers ---

  private handleOpen = () => this.setState("open");

  private handleClose = () => this.setState("closed");

  private handleToggle = () => {
    if (this.isDisabled()) return;
    this.setState(this.currentState === "open" ? "closed" : "open");
  };

  private handleTriggerClick = () => {
    if (this.isDisabled()) return;
    this.setState(this.currentState === "open" ? "closed" : "open");
  };

  private handleBeforeMatch = () => this.setState("open");

  // --- Lifecycle ---

  mounted() {
    super.mounted();

    this.hiddenUntilFound = this.el.hasAttribute("data-hidden-until-found");
    this.currentState = this.readState();

    this.syncParts();
    this.updateCssVars();

    // An initially-open element renders open, without animation: the keyframes
    // are gated on `data-animate`, which is only set when `setState` drives a
    // transition. Freeze any keyframes left armed by a previous mount so a
    // remount cannot replay the enter animation.
    if (this.currentState === "open") {
      const content = this.parts.content;
      if (content) content.style.animationName = "none";
    }

    this.el.addEventListener(Events.Open, this.handleOpen);
    this.el.addEventListener(Events.Close, this.handleClose);
    this.el.addEventListener(Events.Toggle, this.handleToggle);
  }

  updated() {
    // The server may have replaced the trigger/content nodes, and may have
    // changed `hidden_until_found` or the state.
    this.hiddenUntilFound = this.el.hasAttribute("data-hidden-until-found");
    this.syncParts();

    const state = this.readState();
    if (state !== this.currentState) {
      this.setState(state, false);
    } else if (state === "open") {
      // The server may have patched in taller/async content while open.
      this.updateCssVars();
    }
  }

  destroyed() {
    this.el.removeEventListener(Events.Open, this.handleOpen);
    this.el.removeEventListener(Events.Close, this.handleClose);
    this.el.removeEventListener(Events.Toggle, this.handleToggle);
    this.boundTrigger?.removeEventListener("click", this.handleTriggerClick);
    this.boundContent?.removeEventListener("beforematch", this.handleBeforeMatch);
    this.resizeObserver?.disconnect();
  }
}
