import { FlintHook } from "../lib/core";
import { createPositioner, type Align, type Positioner, type Side } from "../lib/position";
import { awaitAnimationsPromise } from "../lib/util";

enum Events {
  Open = "fl:tooltip:open",
  Close = "fl:tooltip:close",
}

type TooltipState = "open" | "closed";

const DEFAULT_DELAY = 200;
const DEFAULT_OFFSET = 6;

function readNumber(value: string | undefined, fallback: number): number {
  if (value === undefined || value === "") return fallback;

  const number = Number(value);

  return Number.isFinite(number) ? number : fallback;
}

/**
 * Owns the client-side half of a tooltip: hover intent, keyboard focus,
 * dismissal, and the floating position of the content.
 *
 * The content is a `popover="manual"` element, so the browser renders it in the
 * top layer instead of being clipped by an `overflow` ancestor or losing to a
 * z-index. Keeping it in the DOM (rather than portalling it to `<body>`) lets
 * LiveView patch it like any other part.
 */
export class Tooltip extends FlintHook {
  private state: TooltipState = "closed";
  private placement: Side = "top";
  private align: Align = "center";
  private offset = DEFAULT_OFFSET;
  private delay = DEFAULT_DELAY;
  private disabled = false;

  private trigger: HTMLElement | null = null;
  private positioner: Positioner | null = null;
  private positionedTrigger: HTMLElement | null = null;
  private positionedContent: HTMLElement | null = null;
  private positionedWith = "";

  // The content id published through `aria-describedby`, so a regenerated id
  // can be swapped instead of piling up dead references.
  private describedWith: string | null = null;

  // The ids seen by the last sync, used to tell whether a page update touched this tooltip at all.
  private syncedRootId = "";
  private syncedContentId = "";

  private openTimer: number | null = null;
  private generation = 0;

  // Focus that follows a pointer press must not open the tooltip: a click is
  // not a request for help, and it would pin the label open after the pointer
  // moves away.
  private pointerFocus = false;

  // --- Config and parts ---

  private readConfig(): void {
    this.placement = (this.el.dataset.placement as Side | undefined) ?? "top";
    this.align = (this.el.dataset.align as Align | undefined) ?? "center";
    this.offset = readNumber(this.el.dataset.offset, DEFAULT_OFFSET);
    this.delay = readNumber(this.el.dataset.delay, DEFAULT_DELAY);
    this.disabled = this.el.hasAttribute("data-disabled");
  }

  private configKey(): string {
    return `${this.placement}:${this.align}:${this.offset}:${this.parts.arrow ? "arrow" : "plain"}`;
  }

  /**
   * The trigger is the first element in the default slot. A trigger already
   * marked on the server (or by a previous run) wins. The hook uses its own
   * `data-tooltip-trigger` marker rather than `data-part`, so it never replaces
   * a marker the trigger component owns.
   */
  private resolveTrigger(): HTMLElement | null {
    const marked = this.el.querySelector<HTMLElement>("[data-tooltip-trigger]");
    if (marked) return marked;

    for (const child of Array.from(this.el.children)) {
      if (!(child instanceof HTMLElement)) continue;
      if (child.getAttribute("data-part") === "content") continue;

      return child;
    }

    return null;
  }

  /**
   * Points the trigger's description at the content, keeping any description
   * the app already put on the trigger and dropping the id this hook published
   * when the server generated a new one.
   */
  private syncDescription(trigger: HTMLElement): void {
    const contentId = this.parts.content?.id;
    const published = contentId && !this.disabled ? contentId : null;

    const ids = (trigger.getAttribute("aria-describedby") ?? "")
      .split(/\s+/)
      .filter((id) => id.length > 0 && id !== contentId && id !== this.describedWith);

    if (published) ids.push(published);

    this.describedWith = published;

    const next = ids.join(" ");
    if (next === (trigger.getAttribute("aria-describedby") ?? "")) return;

    if (next === "") {
      this.js().removeAttribute(trigger, "aria-describedby");
    } else {
      this.js().setAttribute(trigger, "aria-describedby", next);
    }
  }

  private wireTrigger(trigger: HTMLElement): void {
    // Keep a component's own part marker; a plain trigger gets the familiar
    // `trigger` part for consumers styling `[data-part="trigger"]`.
    if (!trigger.hasAttribute("data-part")) {
      this.js().setAttribute(trigger, "data-part", "trigger");
    }

    this.js().setAttribute(trigger, "data-tooltip-trigger", "");
    this.js().setAttribute(trigger, "data-tooltip-state", this.state);

    if (this.disabled) {
      this.js().setAttribute(trigger, "data-tooltip-disabled", "");
    } else {
      this.js().removeAttribute(trigger, "data-tooltip-disabled");
    }

    this.syncDescription(trigger);
  }

  /**
   * Re-reads the parts, wires the trigger, and binds its listeners. Binding is
   * skipped when the trigger element is the same node, so a page update does
   * not stack duplicate listeners.
   */
  private syncParts(): void {
    const previous = this.trigger;

    this.refreshParts();

    const trigger = this.resolveTrigger();

    if (trigger) {
      // A replacement node has no description of its own: forget what was
      // published on the previous one.
      if (previous !== trigger) this.describedWith = null;

      this.wireTrigger(trigger);
      this.parts.trigger = trigger;
    } else {
      delete this.parts.trigger;
    }

    if (previous !== trigger) {
      this.unbindTrigger(previous);
      this.bindTrigger(trigger);
    }

    this.trigger = trigger;
    this.syncedRootId = this.el.id;
    this.syncedContentId = this.parts.content?.id ?? "";
  }

  private bindTrigger(trigger: HTMLElement | null): void {
    trigger?.addEventListener("pointerenter", this.handlePointerEnter);
    trigger?.addEventListener("pointerleave", this.handlePointerLeave);
    trigger?.addEventListener("pointerdown", this.handlePointerDown);
    trigger?.addEventListener("pointerup", this.handlePointerUp);
    trigger?.addEventListener("focusin", this.handleFocusIn);
    trigger?.addEventListener("focusout", this.handleFocusOut);
  }

  private unbindTrigger(trigger: HTMLElement | null): void {
    trigger?.removeEventListener("pointerenter", this.handlePointerEnter);
    trigger?.removeEventListener("pointerleave", this.handlePointerLeave);
    trigger?.removeEventListener("pointerdown", this.handlePointerDown);
    trigger?.removeEventListener("pointerup", this.handlePointerUp);
    trigger?.removeEventListener("focusin", this.handleFocusIn);
    trigger?.removeEventListener("focusout", this.handleFocusOut);
  }

  private setState(state: TooltipState, includeContent = true): void {
    this.js().setAttribute(this.el, "data-state", state);

    const trigger = this.parts.trigger;
    if (trigger) this.js().setAttribute(trigger, "data-tooltip-state", state);

    // The content only joins the state once it has been positioned, so it is
    // never painted at the top-layer default position.
    const content = this.parts.content;
    if (includeContent && content) this.js().setAttribute(content, "data-state", state);
  }

  private dispatch(event: Events): void {
    this.el.dispatchEvent(new CustomEvent(event, { bubbles: true }));
  }

  // --- Opening and closing ---

  private ensurePositioner(): Positioner | null {
    const trigger = this.parts.trigger;
    const content = this.parts.content;

    if (!trigger || !content) return null;

    const key = this.configKey();

    if (
      this.positioner &&
      this.positionedTrigger === trigger &&
      this.positionedContent === content &&
      this.positionedWith === key
    ) {
      return this.positioner;
    }

    this.positioner?.stop();
    this.positioner = createPositioner(trigger, content, {
      placement: this.placement,
      align: this.align,
      offset: this.offset,
      arrow: this.parts.arrow ?? null,
      arrowVarPrefix: "tooltip",
    });
    this.positionedTrigger = trigger;
    this.positionedContent = content;
    this.positionedWith = key;

    return this.positioner;
  }

  private clearOpenTimer(): void {
    if (this.openTimer === null) return;

    window.clearTimeout(this.openTimer);
    this.openTimer = null;
  }

  private scheduleOpen(): void {
    if (this.disabled || this.state === "open") return;

    this.clearOpenTimer();

    if (this.delay <= 0) {
      this.show();
      return;
    }

    this.openTimer = window.setTimeout(() => {
      this.openTimer = null;
      this.show();
    }, this.delay);
  }

  private show = (): void => {
    if (this.disabled || this.state === "open") return;

    const trigger = this.parts.trigger;
    const content = this.parts.content;
    if (!trigger || !content) return;

    this.clearOpenTimer();
    this.state = "open";
    const generation = ++this.generation;

    // Show first: the content must be laid out before its position can be
    // measured. It stays transparent until `data-state` flips, so the browser
    // never paints it at the top-layer default position.
    content.showPopover?.();
    this.setState("open", false);

    const positioner = this.ensurePositioner();

    const reveal = () => {
      if (this.generation !== generation || this.state !== "open") return;

      this.js().setAttribute(content, "data-state", "open");
      this.dispatch(Events.Open);
    };

    if (positioner) {
      positioner.start().then(reveal, reveal);
    } else {
      reveal();
    }
  };

  private hide = (): void => {
    this.clearOpenTimer();

    if (this.state !== "open") return;

    const content = this.parts.content;

    this.state = "closed";
    const generation = ++this.generation;

    this.positioner?.stop();

    if (!content) {
      this.setState("closed");
      return;
    }

    this.setState("closed");

    // Let the leave animation finish before the browser drops the element out
    // of the top layer; without one this resolves on the next frame.
    awaitAnimationsPromise(content).then(() => {
      if (this.generation !== generation || this.state !== "closed") return;

      content.hidePopover?.();
    });

    this.dispatch(Events.Close);
  };

  // --- Event handlers ---

  private handlePointerEnter = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;

    this.scheduleOpen();
  };

  private handlePointerLeave = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;

    this.hide();
  };

  private handlePointerDown = (): void => {
    this.pointerFocus = true;
  };

  private handlePointerUp = (): void => {
    window.setTimeout(() => {
      this.pointerFocus = false;
    }, 0);
  };

  private handleFocusIn = (): void => {
    if (this.pointerFocus) {
      this.pointerFocus = false;
      return;
    }

    this.show();
  };

  private handleFocusOut = (event: FocusEvent): void => {
    const next = event.relatedTarget;

    if (next instanceof Node && this.trigger?.contains(next)) return;

    this.hide();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (event.key !== "Escape" || this.state !== "open") return;

    event.preventDefault();
    this.hide();
  };

  private handleWindowBlur = (): void => {
    this.hide();
  };

  // --- Lifecycle ---

  mounted() {
    super.mounted();

    this.readConfig();
    this.syncParts();
    this.setState("closed");

    this.el.addEventListener("keydown", this.handleKeydown);
    window.addEventListener("blur", this.handleWindowBlur);

    // A generated id changes on every render, and LiveView keys hook updates by
    // the element id it had before the patch, so it never calls `updated/0`
    // for those patches. The page-level update event runs after every patch and
    // is the fallback that keeps the parts and the description in sync.
    document.addEventListener("phx:update", this.handlePageUpdate);
  }

  updated() {
    this.refresh();
  }

  destroyed() {
    this.clearOpenTimer();
    this.generation++;

    this.positioner?.stop();
    this.positioner = null;

    this.el.removeEventListener("keydown", this.handleKeydown);
    window.removeEventListener("blur", this.handleWindowBlur);
    document.removeEventListener("phx:update", this.handlePageUpdate);

    this.unbindTrigger(this.trigger);

    this.parts.content?.hidePopover?.();
  }

  /**
   * Re-reads the configuration and the parts after the server rendered again.
   */
  private refresh(): void {
    const previousTrigger = this.trigger;
    const previousContent = this.parts.content;

    this.readConfig();
    this.syncParts();

    // A replaced trigger detaches the positioner's reference, so the open
    // tooltip is closed rather than left floating next to a stale node.
    if (previousTrigger !== this.trigger) this.hide();

    if (previousContent !== this.parts.content) {
      this.reset();
      this.setState("closed");
    }

    if (this.disabled) this.hide();
  }

  /**
   * Patch updates reach this hook even when LiveView skipped `updated/0`. The
   * cheap id and connectivity check keeps unrelated page updates free.
   */
  private handlePageUpdate = (): void => {
    const content = this.parts.content;

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

  /**
   * Drops any client state after the server replaced the content element: the
   * new element is closed by the browser, so the hook must not believe a
   * previous open state is still current.
   */
  private reset(): void {
    this.clearOpenTimer();
    this.generation++;
    this.state = "closed";
    this.positioner?.stop();
    this.positioner = null;
    this.positionedTrigger = null;
    this.positionedContent = null;
    this.positionedWith = "";
  }
}
