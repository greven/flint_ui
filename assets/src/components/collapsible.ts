import { FlintHook } from "../lib/core";

type CollapsibleState = "open" | "closed";

enum Events {
  Open = "fl:collapsible:open",
  Close = "fl:collapsible:close",
  Toggle = "fl:collapsible:toggle",
  Change = "fl:collapsible:change",
}

export class Collapsible extends FlintHook {
  hiddenUntilFound = false;

  private isMountAnimationPrevented = false;
  private currentState: CollapsibleState = "closed";

  private setState(state: CollapsibleState) {
    const isOpen = state === "open";
    const { trigger, content } = this.parts;

    this.currentState = state;
    this.js().setAttribute(this.el, "data-state", state);

    if (trigger) {
      this.js().setAttribute(trigger, "data-state", state);
      this.js().setAttribute(trigger, "aria-expanded", isOpen.toString());
    }

    if (content) {
      if (isOpen) this.js().removeAttribute(content, "hidden");

      // Freeze transitions/animations to measure natural size
      const origTransition = content.style.transitionDuration;
      const origAnimation = content.style.animationName;
      content.style.transitionDuration = "0s";
      content.style.animationName = "none";

      const height = content.scrollHeight;
      const width = content.scrollWidth;
      content.style.setProperty("--fl-collapsible-content-height", `${height}px`);
      content.style.setProperty("--fl-collapsible-content-width", `${width}px`);

      // Don't restore on initial mount so no animation plays
      if (!this.isMountAnimationPrevented) {
        content.style.transitionDuration = origTransition;
        content.style.animationName = origAnimation;
      }

      this.js().setAttribute(content, "data-state", state);

      if (!isOpen) {
        this.awaitAnimations(content, () => {
          this.js().setAttribute(content, "hidden", this.hiddenUntilFound ? "until-found" : "");
        });
      }
    }

    this.el.dispatchEvent(
      new CustomEvent(Events.Change, { bubbles: true, detail: { state, open: isOpen } }),
    );
  }

  private awaitAnimations(el: HTMLElement, callback: () => void): void {
    requestAnimationFrame(() => {
      const animations = el.getAnimations();
      if (animations.length === 0) {
        callback();
        return;
      }
      Promise.all(animations.map((a) => a.finished))
        .then(callback)
        .catch(callback);
    });
  }

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

  private handleOpen = () => this.setState("open");

  private handleClose = () => this.setState("closed");

  private handleToggle = () => {
    if (this.el.dataset.disabled === "true") return;
    const current = this.el.getAttribute("data-state") as CollapsibleState;
    this.setState(current === "open" ? "closed" : "open");
  };

  private handleBeforeMatch = () => this.setState("open");

  mounted() {
    super.mounted();
    const { trigger, content } = this.parts;

    this.hiddenUntilFound = content?.getAttribute("hidden") === "until-found";
    this.currentState = (this.el.getAttribute("data-state") as CollapsibleState) ?? "closed";

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
