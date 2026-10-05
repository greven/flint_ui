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
  private isMountAnimationPrevented = false;
  private animationGeneration = 0;
  private boundTrigger: HTMLElement | null = null;
  private boundContent: HTMLElement | null = null;

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
    if (prevContent && prevContent !== content) {
      prevContent.removeEventListener("beforematch", this.handleBeforeMatch);
    }

    // addEventListener de-duplicates identical (type, listener) pairs, so this
    // is safe to call on every update.
    trigger?.addEventListener("click", this.handleTriggerClick);
    this.boundTrigger = trigger ?? null;

    if (this.hiddenUntilFound) {
      content?.addEventListener("beforematch", this.handleBeforeMatch);
    }
    this.boundContent = content ?? null;
  }

  private setInitialCssVars(): void {
    const content = this.parts.content;
    if (!content) return;

    content.style.setProperty(`--fl-${CSS_VAR_PREFIX}-height`, `${content.scrollHeight}px`);
    content.style.setProperty(`--fl-${CSS_VAR_PREFIX}-width`, `${content.scrollWidth}px`);
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
   * Applies `state`, running the enter/leave animation.
   *
   * `emit` controls whether the server events (`data-open-event`, …) are pushed.
   * It is `false` when the state change originated from the server to avoid
   * echoing events back to the LiveView that produced them.
   */
  private setState(state: CollapsibleState, emit = true): void {
    if (state === this.currentState) return;

    const isOpen = state === "open";
    const { trigger, content } = this.parts;
    const gen = ++this.animationGeneration;

    this.currentState = state;
    this.js().setAttribute(this.el, "data-state", state);

    if (trigger) {
      this.js().setAttribute(trigger, "data-state", state);
      this.js().setAttribute(trigger, "aria-expanded", isOpen.toString());
    }

    if (content) {
      // The server may have applied `hidden` for the target state already;
      // remove it so the transition can run from the measured natural size.
      this.js().removeAttribute(content, "hidden");

      const { done } = animatePresence(content, {
        present: isOpen,
        liveSocket: this.liveSocket,
        mountPrevented: this.isMountAnimationPrevented,
        cssVarPrefix: CSS_VAR_PREFIX,
      });

      this.js().setAttribute(content, "data-state", state);

      if (!isOpen) {
        const hide = () => {
          if (this.animationGeneration !== gen) return;
          this.js().setAttribute(content, "hidden", this.hiddenUntilFound ? "until-found" : "");
        };
        done.then(hide).catch(hide);
      }
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
    this.setInitialCssVars();

    // Prevent the enter animation on initial open mount
    this.isMountAnimationPrevented = this.currentState === "open";
    if (this.isMountAnimationPrevented) {
      requestAnimationFrame(() => {
        this.isMountAnimationPrevented = false;
      });
    }

    this.el.addEventListener(Events.Open, this.handleOpen);
    this.el.addEventListener(Events.Close, this.handleClose);
    this.el.addEventListener(Events.Toggle, this.handleToggle);
  }

  updated() {
    // The server may have replaced the trigger/content nodes and changed state.
    this.syncParts();

    const state = this.readState();
    if (state !== this.currentState) {
      this.setState(state, false);
    }
  }

  destroyed() {
    this.el.removeEventListener(Events.Open, this.handleOpen);
    this.el.removeEventListener(Events.Close, this.handleClose);
    this.el.removeEventListener(Events.Toggle, this.handleToggle);
    this.boundTrigger?.removeEventListener("click", this.handleTriggerClick);
    this.boundContent?.removeEventListener("beforematch", this.handleBeforeMatch);
  }
}
