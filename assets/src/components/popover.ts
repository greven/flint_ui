import { FlintHook } from "../lib/core";
import { focusFirst } from "../lib/focus";
import { createPositioner, type Align, type Positioner, type Side } from "../lib/position";
import { awaitAnimationsPromise } from "../lib/util";

enum Events {
  Open = "fl:popover:open",
  Close = "fl:popover:close",
  Toggle = "fl:popover:toggle",
  Change = "fl:popover:change",
}

type PopoverState = "open" | "closed";
type OpenSource = "pointer" | "click" | "keyboard" | "command" | "server" | "initial";

interface ShowOptions {
  focus?: boolean;
  source?: OpenSource;
  emit?: boolean;
}

interface HideOptions {
  returnFocus?: boolean;
  source?: OpenSource;
  emit?: boolean;
}

const DEFAULT_OFFSET = 8;
const DEFAULT_PLACEMENT: Side = "bottom";
const DEFAULT_ALIGN: Align = "center";

function readNumber(value: string | undefined, fallback: number): number {
  if (value === undefined || value === "") return fallback;

  const number = Number(value);

  return Number.isFinite(number) ? number : fallback;
}

/**
 * Owns the client-side half of a popover: opening, hover intent, dismissal,
 * focus management, and the floating position of the content.
 *
 * The content is a `popover="manual"` element, so the browser renders it in the
 * top layer instead of being clipped by an `overflow` ancestor or losing to a
 * z-index. Keeping it in the DOM lets LiveView patch it like any other part.
 * When the component uses a Phoenix portal, the content lives outside the root
 * element, so parts are resolved by their derived DOM id instead of by
 * `querySelector` from the root.
 */
export class Popover extends FlintHook {
  private state: PopoverState = "closed";
  private placement: Side = DEFAULT_PLACEMENT;
  private align: Align = DEFAULT_ALIGN;
  private offset = DEFAULT_OFFSET;
  private openDelay = 0;
  private closeDelay = 0;
  private openOnHover = false;
  private dismissible = true;

  private trigger: HTMLElement | null = null;
  private content: HTMLElement | null = null;
  private arrowElement: HTMLElement | null = null;

  private positioner: Positioner | null = null;
  private positionedTrigger: HTMLElement | null = null;
  private positionedContent: HTMLElement | null = null;
  private positionedArrow: HTMLElement | null = null;
  private positionedWith = "";

  // The trigger id published as the content's accessible name, so a regenerated
  // id can be swapped instead of leaving a dead `aria-labelledby` reference.
  private ownedTriggerId: string | null = null;
  private labelledWith: string | null = null;

  // The ids seen by the last sync, used to tell whether a page update touched
  // this popover at all.
  private syncedRootId = "";
  private syncedContentId = "";
  private syncedOpened = false;

  private openTimer: number | null = null;
  private closeTimer: number | null = null;
  private generation = 0;
  private openedByHover = false;

  // --- Config and parts ---

  private readConfig(): void {
    this.placement = (this.el.dataset.placement as Side | undefined) ?? DEFAULT_PLACEMENT;
    this.align = (this.el.dataset.align as Align | undefined) ?? DEFAULT_ALIGN;
    this.offset = readNumber(this.el.dataset.offset, DEFAULT_OFFSET);
    this.openDelay = readNumber(this.el.dataset.openDelay, 0);
    this.closeDelay = readNumber(this.el.dataset.closeDelay, 0);
    this.openOnHover = this.el.hasAttribute("data-open-on-hover");
    this.dismissible = this.el.hasAttribute("data-dismissible");
  }

  private serverOpened(): boolean {
    return this.el.getAttribute("data-opened") === "true";
  }

  private configKey(): string {
    return `${this.placement}:${this.align}:${this.offset}:${this.arrowElement ? "arrow" : "plain"}`;
  }

  /**
   * The trigger is the first element in the default slot. A direct child that
   * already carries the hook wins. A nested popover's trigger is ignored, even
   * though `refreshParts` would find it first in a flat query.
   */
  private resolveTrigger(): HTMLElement | null {
    for (const child of Array.from(this.el.children)) {
      if (!(child instanceof HTMLElement)) continue;
      if (child.getAttribute("data-part") === "trigger") return child;
      if (child.getAttribute("data-part") === "content") continue;
      if (child instanceof HTMLTemplateElement && child.hasAttribute("data-phx-portal")) {
        continue;
      }

      return child;
    }

    return null;
  }

  /**
   * Resolves the content by its derived id, because a Phoenix portal moves it
   * out of the root element and a nested popover can also answer to the
   * `content` part name. The id is the only stable handle across both cases.
   */
  private findContent(): HTMLElement | null {
    if (!this.el.id) return null;

    const found = document.getElementById(`${this.el.id}-content`);

    return found instanceof HTMLElement ? found : null;
  }

  private resolveArrow(content: HTMLElement | null): HTMLElement | null {
    return content?.querySelector<HTMLElement>('[data-part="arrow"]') ?? this.parts.arrow ?? null;
  }

  private syncParts(): void {
    const previousTrigger = this.trigger;
    const previousContent = this.content;
    const previousArrow = this.arrowElement;

    this.refreshParts();

    const content = this.findContent();
    const trigger = this.resolveTrigger();
    const arrow = this.resolveArrow(content);

    this.content = content;
    this.trigger = trigger;
    this.arrowElement = arrow;

    if (content) {
      this.parts.content = content;
    } else {
      delete this.parts.content;
    }

    if (trigger) {
      this.parts.trigger = trigger;
    } else {
      delete this.parts.trigger;
    }

    if (previousTrigger !== trigger) {
      this.unbindTrigger(previousTrigger);
      this.bindTrigger(trigger);
      this.ownedTriggerId = null;
    }

    if (previousContent !== content) {
      this.unbindContent(previousContent);
      this.bindContent(content);
      this.labelledWith = null;
    }

    if (previousArrow !== arrow) {
      this.positioner?.stop();
      this.positioner = null;
      this.positionedArrow = null;
    }

    if (trigger) this.wireTrigger(trigger);
    if (content) this.wireContent(content);
    this.syncLabelling();

    this.syncedRootId = this.el.id;
    this.syncedContentId = content?.id ?? "";
  }

  private wireTrigger(trigger: HTMLElement): void {
    this.js().setAttribute(trigger, "data-part", "trigger");
    this.js().setAttribute(trigger, "data-state", this.state);
    this.js().setAttribute(trigger, "aria-haspopup", "dialog");
    this.js().setAttribute(trigger, "aria-expanded", this.state === "open" ? "true" : "false");

    if (this.content) {
      this.js().setAttribute(trigger, "aria-controls", this.content.id);
    } else {
      this.js().removeAttribute(trigger, "aria-controls");
    }
  }

  private wireContent(content: HTMLElement): void {
    this.js().setAttribute(content, "tabindex", "-1");
  }

  /**
   * Gives the content a name even when the app did not. The trigger already has
   * a meaningful accessible name, so the dialog can borrow it. An author-provided
   * `aria-label` or a different `aria-labelledby` always wins.
   */
  private syncLabelling(): void {
    const trigger = this.trigger;
    const content = this.content;

    if (!trigger || !content) return;

    if (content.hasAttribute("aria-label")) {
      if (this.labelledWith && content.getAttribute("aria-labelledby") === this.labelledWith) {
        this.js().removeAttribute(content, "aria-labelledby");
      }
      this.labelledWith = null;
      return;
    }

    const authorLabelledBy = content.getAttribute("aria-labelledby");
    if (authorLabelledBy && authorLabelledBy !== this.labelledWith) {
      this.labelledWith = null;
      return;
    }

    if (this.ownedTriggerId && trigger.id === this.ownedTriggerId) {
      const nextId = `${this.el.id}-trigger`;

      if (this.ownedTriggerId !== nextId) {
        trigger.id = nextId;
        this.ownedTriggerId = nextId;
      }
    }

    if (!trigger.id) {
      const id = `${this.el.id}-trigger`;
      this.js().setAttribute(trigger, "id", id);
      this.ownedTriggerId = id;
    }

    const target = trigger.id;
    if (!target) return;

    this.js().setAttribute(content, "aria-labelledby", target);
    this.labelledWith = target;
  }

  private bindTrigger(trigger: HTMLElement | null): void {
    trigger?.addEventListener("click", this.handleTriggerClick);
    trigger?.addEventListener("pointerenter", this.handleTriggerPointerEnter);
    trigger?.addEventListener("pointerleave", this.handleTriggerPointerLeave);
  }

  private unbindTrigger(trigger: HTMLElement | null): void {
    trigger?.removeEventListener("click", this.handleTriggerClick);
    trigger?.removeEventListener("pointerenter", this.handleTriggerPointerEnter);
    trigger?.removeEventListener("pointerleave", this.handleTriggerPointerLeave);
  }

  private bindContent(content: HTMLElement | null): void {
    content?.addEventListener("pointerenter", this.handleContentPointerEnter);
    content?.addEventListener("pointerleave", this.handleContentPointerLeave);
  }

  private unbindContent(content: HTMLElement | null): void {
    content?.removeEventListener("pointerenter", this.handleContentPointerEnter);
    content?.removeEventListener("pointerleave", this.handleContentPointerLeave);
  }

  private setState(state: PopoverState, includeContent = true): void {
    this.js().setAttribute(this.el, "data-state", state);

    const trigger = this.trigger;
    if (trigger) {
      this.js().setAttribute(trigger, "data-state", state);
      this.js().setAttribute(trigger, "aria-expanded", state === "open" ? "true" : "false");
    }

    // The content only joins the state once it has been positioned, so it is
    // never painted at the top-layer default position.
    const content = this.content;
    if (includeContent && content) {
      this.js().setAttribute(content, "data-state", state);
    }
  }

  private dispatch(event: Events, detail?: Record<string, unknown>): void {
    this.el.dispatchEvent(new CustomEvent(event, { bubbles: true, detail }));
  }

  private emitChange(state: PopoverState): void {
    this.dispatch(Events.Change, { state });
  }

  private pushStateEvents(state: PopoverState, emit: boolean): void {
    if (!emit) return;

    const isOpen = state === "open";
    const payload = { id: this.el.id, open: isOpen };
    const { openEvent, closeEvent, toggleEvent } = this.el.dataset;

    if (isOpen && openEvent) this.pushEvent(openEvent, payload);
    if (!isOpen && closeEvent) this.pushEvent(closeEvent, payload);
    if (toggleEvent) this.pushEvent(toggleEvent, payload);
  }

  // --- Opening and closing ---

  private ensurePositioner(): Positioner | null {
    const trigger = this.trigger;
    const content = this.content;

    if (!trigger || !content) return null;

    const key = this.configKey();

    if (
      this.positioner &&
      this.positionedTrigger === trigger &&
      this.positionedContent === content &&
      this.positionedArrow === this.arrowElement &&
      this.positionedWith === key
    ) {
      return this.positioner;
    }

    this.positioner?.stop();
    this.positioner = createPositioner(trigger, content, {
      placement: this.placement,
      align: this.align,
      offset: this.offset,
      arrow: this.arrowElement,
      arrowVarPrefix: "popover",
    });
    this.positionedTrigger = trigger;
    this.positionedContent = content;
    this.positionedArrow = this.arrowElement;
    this.positionedWith = key;

    return this.positioner;
  }

  private clearOpenTimer(): void {
    if (this.openTimer === null) return;

    window.clearTimeout(this.openTimer);
    this.openTimer = null;
  }

  private clearCloseTimer(): void {
    if (this.closeTimer === null) return;

    window.clearTimeout(this.closeTimer);
    this.closeTimer = null;
  }

  private clearTimers(): void {
    this.clearOpenTimer();
    this.clearCloseTimer();
  }

  private scheduleHoverOpen(): void {
    if (!this.openOnHover || this.state === "open") return;

    this.clearCloseTimer();

    if (this.openDelay <= 0) {
      this.show({ focus: false, source: "pointer" });
      return;
    }

    this.clearOpenTimer();
    this.openTimer = window.setTimeout(() => {
      this.openTimer = null;
      this.show({ focus: false, source: "pointer" });
    }, this.openDelay);
  }

  private scheduleHoverClose(): void {
    if (!this.openOnHover) return;

    this.clearOpenTimer();

    if (this.state !== "open" || !this.openedByHover) return;

    if (this.closeDelay <= 0) {
      this.hide({ returnFocus: false, source: "pointer" });
      return;
    }

    this.clearCloseTimer();
    this.closeTimer = window.setTimeout(() => {
      this.closeTimer = null;
      this.hide({ returnFocus: false, source: "pointer" });
    }, this.closeDelay);
  }

  private show(options: ShowOptions = {}): void {
    const { focus = false, source = "click", emit = true } = options;

    if (this.state === "open") return;

    const trigger = this.trigger;
    const content = this.content ?? this.findContent();

    if (!trigger || !content) return;

    this.content = content;
    this.parts.content = content;
    if (trigger) this.wireTrigger(trigger);
    this.clearTimers();

    this.state = "open";
    this.openedByHover = source === "pointer";
    const generation = ++this.generation;

    try {
      content.showPopover?.();
    } catch {
      // The content may already be open after a remount or a patch.
    }
    this.setState("open", false);

    const positioner = this.ensurePositioner();

    const reveal = () => {
      if (this.generation !== generation || this.state !== "open") return;

      this.js().setAttribute(content, "data-state", "open");

      if (focus) this.focusContent();

      this.emitChange("open");
      this.pushStateEvents("open", emit);
    };

    if (positioner) {
      positioner.start().then(reveal, reveal);
    } else {
      reveal();
    }
  }

  private hide(options: HideOptions = {}): void {
    const { returnFocus = false, emit = true } = options;

    this.clearTimers();

    if (this.state !== "open") {
      return;
    }

    const content = this.content;

    this.state = "closed";
    this.openedByHover = false;
    const generation = ++this.generation;

    this.positioner?.stop();

    this.setState("closed");

    if (returnFocus && this.trigger) {
      this.focusTrigger();
    }

    if (content) {
      // Let the leave animation finish before the browser drops the element out
      // of the top layer; without one this resolves on the next frame.
      awaitAnimationsPromise(content).then(() => {
        if (this.generation !== generation || this.state !== "closed") return;

        try {
          content.hidePopover?.();
        } catch {
          // Already hidden or detached.
        }
      });
    }

    this.emitChange("closed");
    this.pushStateEvents("closed", emit);
  }

  private focusTrigger(): void {
    const trigger = this.trigger;
    if (!trigger?.isConnected) return;

    try {
      trigger.focus();
    } catch {
      // The trigger may have been removed between the check and the call.
    }
  }

  private focusContent(): void {
    const content = this.content;
    if (!content) return;

    focusFirst(content, content);
  }

  // --- Event handlers ---

  private handleTriggerClick = (event: MouseEvent): void => {
    if (event.defaultPrevented) return;

    if (this.state === "open") {
      // A hover-opened popover is pinned by the first click instead of being
      // closed under the pointer.
      if (this.openedByHover) {
        this.openedByHover = false;
        this.clearTimers();
        this.focusContent();
        return;
      }

      this.hide({ returnFocus: true, source: "click" });
      return;
    }

    this.show({
      focus: true,
      source: event.detail === 0 ? "keyboard" : "click",
    });
  };

  private handleTriggerPointerEnter = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;
    if (!this.openOnHover) return;

    this.clearCloseTimer();
    if (this.state === "closed") this.scheduleHoverOpen();
  };

  private handleTriggerPointerLeave = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;
    if (!this.openOnHover) return;

    const next = event.relatedTarget;
    if (next instanceof Node && this.content?.contains(next)) return;

    this.scheduleHoverClose();
  };

  private handleContentPointerEnter = (): void => {
    if (!this.openOnHover) return;

    this.clearCloseTimer();
  };

  private handleContentPointerLeave = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;
    if (!this.openOnHover) return;

    const next = event.relatedTarget;
    if (next instanceof Node && this.trigger?.contains(next)) return;

    this.scheduleHoverClose();
  };

  private handleOutsidePointerDown = (event: PointerEvent): void => {
    if (this.state !== "open" || !this.dismissible) return;

    const target = event.target;
    if (!(target instanceof Node)) return;

    if (this.trigger?.contains(target) || this.content?.contains(target)) return;

    this.hide({ returnFocus: false, source: "click" });
  };

  private handleFocusIn = (event: FocusEvent): void => {
    if (this.state !== "open") return;

    const target = event.target;
    if (!(target instanceof Node)) return;

    if (this.trigger?.contains(target) || this.content?.contains(target)) return;

    if (this.dismissible) this.hide({ returnFocus: false, source: "click" });
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (this.state !== "open") return;

    if (event.key === "Escape") {
      if (!this.dismissible || event.defaultPrevented) return;

      event.preventDefault();
      this.hide({ returnFocus: true, source: "keyboard" });
    }
  };

  private handleOpenCommand = (): void => {
    this.show({ focus: true, source: "command" });
  };

  private handleCloseCommand = (): void => {
    this.hide({ returnFocus: true, source: "command" });
  };

  private handleToggleCommand = (): void => {
    if (this.state === "open") {
      this.hide({ returnFocus: true, source: "command" });
    } else {
      this.show({ focus: true, source: "command" });
    }
  };

  private handlePageUpdate = (): void => {
    const content = this.content;

    if (
      this.el.id === this.syncedRootId &&
      this.trigger?.isConnected &&
      content?.isConnected &&
      content.id === this.syncedContentId
    ) {
      return;
    }

    this.refresh();
  };

  // --- Lifecycle ---

  mounted() {
    super.mounted();

    this.readConfig();
    this.syncParts();

    this.state = "closed";
    this.setState("closed");
    this.syncedOpened = this.serverOpened();

    this.el.addEventListener(Events.Open, this.handleOpenCommand);
    this.el.addEventListener(Events.Close, this.handleCloseCommand);
    this.el.addEventListener(Events.Toggle, this.handleToggleCommand);

    // Escape and outside-pointer dismissal must work from portalled content,
    // which is not a descendant of the root.
    document.addEventListener("keydown", this.handleKeydown);
    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.addEventListener("focusin", this.handleFocusIn);

    // A generated id changes on every render, and LiveView keys hook updates by
    // the element id it had before the patch, so it never calls `updated/0` for
    // those patches. The page-level update event is the fallback.
    document.addEventListener("phx:update", this.handlePageUpdate);

    if (this.syncedOpened) {
      this.show({ focus: false, source: "initial", emit: false });

      if (!this.content) {
        requestAnimationFrame(() => {
          if (this.syncedOpened && this.state === "closed") {
            this.syncParts();
            this.show({ focus: false, source: "initial", emit: false });
          }
        });
      }
    }
  }

  updated() {
    this.refresh();
  }

  destroyed() {
    this.clearTimers();
    this.generation++;

    this.positioner?.stop();
    this.positioner = null;

    this.el.removeEventListener(Events.Open, this.handleOpenCommand);
    this.el.removeEventListener(Events.Close, this.handleCloseCommand);
    this.el.removeEventListener(Events.Toggle, this.handleToggleCommand);

    document.removeEventListener("keydown", this.handleKeydown);
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.removeEventListener("focusin", this.handleFocusIn);
    document.removeEventListener("phx:update", this.handlePageUpdate);

    this.unbindTrigger(this.trigger);
    this.unbindContent(this.content);

    try {
      this.content?.hidePopover?.();
    } catch {
      // Already hidden or detached.
    }
  }

  /**
   * Re-reads the configuration and the parts after the server rendered again.
   */
  private refresh(): void {
    const previousTrigger = this.trigger;
    const previousContent = this.content;
    const wasOpen = this.state === "open";

    this.readConfig();
    this.syncParts();

    const nextOpened = this.serverOpened();
    const openedChanged = nextOpened !== this.syncedOpened;
    this.syncedOpened = nextOpened;

    const triggerChanged = previousTrigger !== this.trigger;
    const contentChanged = previousContent !== this.content;

    if (triggerChanged && this.state === "open") {
      this.hide({ returnFocus: false, source: "server", emit: false });
    }

    if (contentChanged) {
      this.reset();

      if (wasOpen && !triggerChanged) {
        this.show({ focus: false, source: "server", emit: false });
      }
    }

    if (openedChanged) {
      if (nextOpened) {
        this.show({ focus: false, source: "server", emit: false });
      } else {
        this.hide({ returnFocus: false, source: "server", emit: false });
      }
    }

    this.setState(this.state);
  }

  /**
   * Drops any client state after the server replaced the content element: the
   * new element is closed by the browser, so the hook must not believe a
   * previous open state is still current.
   */
  private reset(): void {
    this.clearTimers();
    this.generation++;
    this.state = "closed";
    this.openedByHover = false;
    this.labelledWith = null;
    this.positioner?.stop();
    this.positioner = null;
    this.positionedTrigger = null;
    this.positionedContent = null;
    this.positionedArrow = null;
    this.positionedWith = "";
  }
}
