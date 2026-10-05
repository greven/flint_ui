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

  private setState(state: CollapsibleState) {
    const isOpen = state === "open";
    const { trigger, content } = this.parts;

    // Invalidate any pending close-hide callbacks
    const gen = ++this.animationGeneration;

    this.currentState = state;
    this.js().setAttribute(this.el, "data-state", state);

    if (trigger) {
      this.js().setAttribute(trigger, "data-state", state);
      this.js().setAttribute(trigger, "aria-expanded", isOpen.toString());
    }

    if (content) {
      // Show: remove hidden before measuring so scrollHeight is accurate
      if (isOpen) {
        this.js().removeAttribute(content, "hidden");
      }

      const { done } = animatePresence(content, {
        present: isOpen,
        liveSocket: this.liveSocket,
        mountPrevented: this.isMountAnimationPrevented,
        cssVarPrefix: CSS_VAR_PREFIX,
      });

      // Set data-state on content to trigger CSS transition
      this.js().setAttribute(content, "data-state", state);

      // On close, wait for animation before applying hidden
      if (!isOpen) {
        done
          .then(() => {
            if (this.animationGeneration !== gen) return;
            this.js().setAttribute(
              content,
              "hidden",
              this.hiddenUntilFound ? "until-found" : "",
            );
          })
          .catch(() => {
            if (this.animationGeneration !== gen) return;
            this.js().setAttribute(
              content,
              "hidden",
              this.hiddenUntilFound ? "until-found" : "",
            );
          });
      }
    }

    // Emit change event for internal listeners
    this.el.dispatchEvent(
      new CustomEvent(Events.Change, {
        bubbles: true,
        detail: { state: state },
      }),
    );

    // Push server events after state is updated
    const payload = { id: this.el.id, open: isOpen };
    const openEvent = this.el.dataset.openEvent;
    const closeEvent = this.el.dataset.closeEvent;
    const toggleEvent = this.el.dataset.toggleEvent;

    if (isOpen && openEvent) this.pushEvent(openEvent, payload);
    if (!isOpen && closeEvent) this.pushEvent(closeEvent, payload);
    if (toggleEvent) this.pushEvent(toggleEvent, payload);
  }

  private handleOpen = () => this.setState("open");

  private handleClose = () => this.setState("closed");

  private handleToggle = () => {
    if (this.el.dataset.disabled === "true") return;
    const current = this.el.getAttribute("data-state") as CollapsibleState;
    this.setState(current === "open" ? "closed" : "open");
  };

  private handleTriggerClick = () => {
    if (this.el.dataset.disabled === "true") return;
    const current = this.el.getAttribute("data-state") as CollapsibleState;
    this.setState(current === "open" ? "closed" : "open");
  };

  private handleTriggerKeydown = (e: KeyboardEvent) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      this.handleTriggerClick();
    }
  };

  private handleBeforeMatch = () => this.setState("open");

  // Hooks

  mounted() {
    super.mounted();
    const { trigger, content } = this.parts;

    this.hiddenUntilFound = content?.getAttribute("hidden") === "until-found";
    this.currentState =
      (this.el.getAttribute("data-state") as CollapsibleState) ?? "closed";

    // Set initial CSS vars on mount
    if (content) {
      content.style.setProperty(
        `--fl-${CSS_VAR_PREFIX}-height`,
        `${content.offsetHeight}px`,
      );
      content.style.setProperty(
        `--fl-${CSS_VAR_PREFIX}-width`,
        `${content.offsetWidth}px`,
      );
    }

    if (this.hiddenUntilFound) {
      content?.addEventListener("beforematch", this.handleBeforeMatch);
    }

    // Prevent animation on initial open mount
    this.isMountAnimationPrevented = this.el.dataset.state === "open";
    if (this.isMountAnimationPrevented) {
      requestAnimationFrame(() => {
        this.isMountAnimationPrevented = false;
      });
    }

    this.el.addEventListener(Events.Open, this.handleOpen);
    this.el.addEventListener(Events.Close, this.handleClose);
    this.el.addEventListener(Events.Toggle, this.handleToggle);
    trigger?.addEventListener("click", this.handleTriggerClick);
    trigger?.addEventListener("keydown", this.handleTriggerKeydown);
  }

  updated() {
    const state = this.el.getAttribute("data-state") as CollapsibleState;
    if (state !== this.currentState) {
      this.setState(state);
    }
  }

  destroyed() {
    const { trigger, content } = this.parts;

    this.el.removeEventListener(Events.Open, this.handleOpen);
    this.el.removeEventListener(Events.Close, this.handleClose);
    this.el.removeEventListener(Events.Toggle, this.handleToggle);
    content?.removeEventListener("beforematch", this.handleBeforeMatch);
    trigger?.removeEventListener("click", this.handleTriggerClick);
    trigger?.removeEventListener("keydown", this.handleTriggerKeydown);
  }
}
