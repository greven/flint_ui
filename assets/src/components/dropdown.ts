import { FlintHook } from "../lib/core";
import { getGracePolygon, isPointInPolygon, type Point } from "../lib/geometry";
import { createPositioner, type Align, type Positioner, type Side } from "../lib/position";
import { awaitAnimationsPromise, readCssLength } from "../lib/util";

enum Events {
  Open = "fl:dropdown:open",
  Close = "fl:dropdown:close",
  Toggle = "fl:dropdown:toggle",
  Change = "fl:dropdown:change",
}

type DropdownState = "open" | "closed";
type FocusTarget = "first" | "last" | "menu" | "none";
type OpenSource = "pointer" | "click" | "keyboard" | "command" | "server" | "select";

interface ShowOptions {
  focus?: FocusTarget;
  source?: OpenSource;
}

interface HideOptions {
  returnFocus?: boolean;
  source?: OpenSource;
}

interface GraceArea {
  trigger: HTMLElement;
  target: HTMLElement;
  /** The submenu this path leads to; `null` when it leads to the root content. */
  menu: HTMLElement | null;
  polygon: Point[];
}

const DEFAULT_OFFSET = 4;
const DEFAULT_PLACEMENT: Side = "bottom";
const DEFAULT_ALIGN: Align = "start";
const SUBMENU_OFFSET = 10;
const HOVER_CLOSE_GRACE = 150;
const TYPEAHEAD_TIMEOUT = 500;

function readNumber(value: string | undefined, fallback: number): number {
  if (value === undefined || value === "") return fallback;

  const number = Number(value);

  return Number.isFinite(number) ? number : fallback;
}

function isDisabled(item: HTMLElement): boolean {
  return (
    item.hasAttribute("disabled") ||
    item.hasAttribute("data-disabled") ||
    item.getAttribute("aria-disabled") === "true"
  );
}

/**
 * Owns the client-side half of a dropdown: opening, hover intent, dismissal,
 * roving focus, submenus, and the floating position of the menu and its nested
 * menus.
 *
 * The menu is a `popover="manual"` element, so the browser renders it in the
 * top layer instead of being clipped by an `overflow` ancestor or losing to a
 * z-index. Keeping it in the DOM lets LiveView patch it like any other part.
 */
export class Dropdown extends FlintHook {
  private state: DropdownState = "closed";
  private placement: Side = DEFAULT_PLACEMENT;
  private align: Align = DEFAULT_ALIGN;
  private offset = DEFAULT_OFFSET;
  private openDelay = 0;
  private closeDelay = 0;
  private openOnHover = false;

  private trigger: HTMLElement | null = null;
  private content: HTMLElement | null = null;
  private arrowElement: HTMLElement | null = null;

  private positioner: Positioner | null = null;
  private positionedTrigger: HTMLElement | null = null;
  private positionedContent: HTMLElement | null = null;
  private positionedArrow: HTMLElement | null = null;
  private positionedWith = "";

  private submenuPositioners = new Map<HTMLElement, Positioner>();
  private submenuStack: HTMLElement[] = [];

  private syncedRootId = "";
  private syncedContentId = "";

  private openTimer: number | null = null;
  private closeTimer: number | null = null;
  private generation = 0;
  private openedByHover = false;
  private keyboardOpen = false;

  private submenuOpenTimer: number | null = null;
  private submenuCloseTimer: number | null = null;
  private hoveredSubmenuTrigger: HTMLElement | null = null;
  private hoverOpenedSubmenus = new Set<HTMLElement>();
  private graceAreas = new Map<HTMLElement, GraceArea>();

  private typeahead = "";
  private typeaheadTimer: number | null = null;

  // --- Config and parts ---

  private readConfig(): void {
    this.placement = (this.el.dataset.placement as Side | undefined) ?? DEFAULT_PLACEMENT;
    this.align = (this.el.dataset.align as Align | undefined) ?? DEFAULT_ALIGN;
    this.offset = readNumber(this.el.dataset.offset, DEFAULT_OFFSET);
    this.openDelay = readNumber(this.el.dataset.openDelay, 0);
    this.closeDelay = readNumber(this.el.dataset.closeDelay, 0);
    this.openOnHover = this.el.hasAttribute("data-open-on-hover");
  }

  private configKey(offset: number): string {
    return `${this.placement}:${this.align}:${offset}:${this.arrowElement ? "arrow" : "plain"}`;
  }

  /**
   * The arrow protrudes into the gap, so the stylesheet's
   * `--fl-dropdown-arrow-gap` is added to the configured offset. The variable
   * lets the arrow keep its clearance without every caller tuning `offset` to
   * the arrow size.
   */
  private positioningOffset(): number {
    if (!this.arrowElement) return this.offset;

    return this.offset + readCssLength(this.el, "--fl-dropdown-arrow-gap");
  }

  /**
   * The trigger is the first non-content child. A direct child that already
   * carries the hook wins; the default trigger is rendered by the server.
   */
  private resolveTrigger(): HTMLElement | null {
    for (const child of Array.from(this.el.children)) {
      if (!(child instanceof HTMLElement)) continue;

      const part = child.getAttribute("data-part");
      if (part === "trigger") return child;
      if (part === "content" || part === "submenu" || part === "arrow") continue;

      return child;
    }

    return null;
  }

  private findContent(): HTMLElement | null {
    if (!this.el.id) return null;

    const found = document.getElementById(`${this.el.id}-content`);

    return found instanceof HTMLElement ? found : null;
  }

  private resolveArrow(content: HTMLElement | null): HTMLElement | null {
    return content?.querySelector<HTMLElement>('[data-part="arrow"]') ?? this.parts.arrow ?? null;
  }

  private wireTrigger(trigger: HTMLElement): void {
    this.js().setAttribute(trigger, "data-part", "trigger");
    this.js().setAttribute(trigger, "data-state", this.state);
    this.js().setAttribute(trigger, "aria-haspopup", "menu");
    this.js().setAttribute(trigger, "aria-expanded", this.state === "open" ? "true" : "false");

    if (this.content) {
      this.js().setAttribute(trigger, "aria-controls", this.content.id);
    }
  }

  private wireContent(content: HTMLElement): void {
    this.js().setAttribute(content, "role", "menu");
    this.js().setAttribute(content, "tabindex", "-1");
  }

  /**
   * Gives the menu a name from the trigger. An author-provided `aria-label`
   * always wins, so a menu can be named independently of its trigger.
   */
  private syncLabelling(): void {
    const trigger = this.trigger;
    const content = this.content;

    if (!trigger || !content) return;

    if (content.hasAttribute("aria-label")) {
      this.js().removeAttribute(content, "aria-labelledby");
      return;
    }

    if (!trigger.id) {
      this.js().setAttribute(trigger, "id", `${this.el.id}-trigger`);
    }

    this.js().setAttribute(content, "aria-labelledby", trigger.id);
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
    }

    if (previousContent !== content) {
      this.closeAllSubmenus();
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

  private bindTrigger(trigger: HTMLElement | null): void {
    trigger?.addEventListener("click", this.handleTriggerClick);
    trigger?.addEventListener("keydown", this.handleTriggerKeydown);
  }

  private unbindTrigger(trigger: HTMLElement | null): void {
    trigger?.removeEventListener("click", this.handleTriggerClick);
    trigger?.removeEventListener("keydown", this.handleTriggerKeydown);
  }

  private setState(state: DropdownState, includeContent = true): void {
    this.js().setAttribute(this.el, "data-state", state);

    const trigger = this.trigger;
    if (trigger) {
      this.js().setAttribute(trigger, "data-state", state);
      this.js().setAttribute(trigger, "aria-expanded", state === "open" ? "true" : "false");

      // Focus moved into the menu, but a keyboard open leaves the trigger
      // looking focused so the menu still has a visible owner.
      if (state === "open" && this.keyboardOpen) {
        this.js().setAttribute(trigger, "data-focus-ring", "");
      } else {
        this.js().removeAttribute(trigger, "data-focus-ring");
      }
    }

    // The menu only joins the state once it has been positioned, so it is never
    // painted at the top-layer default position.
    const content = this.content;
    if (includeContent && content) {
      this.js().setAttribute(content, "data-state", state);
    }
  }

  private dispatch(event: Events, detail?: Record<string, unknown>): void {
    this.el.dispatchEvent(new CustomEvent(event, { bubbles: true, detail }));
  }

  private emitChange(state: DropdownState): void {
    this.dispatch(Events.Change, { state });
  }

  // --- Opening and closing ---

  private ensurePositioner(): Positioner | null {
    const trigger = this.trigger;
    const content = this.content;

    if (!trigger || !content) return null;

    const offset = this.positioningOffset();
    const key = this.configKey(offset);

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
      offset,
      arrow: this.arrowElement,
      arrowVarPrefix: "dropdown",
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

  private clearSubmenuOpenTimer(): void {
    if (this.submenuOpenTimer === null) return;

    window.clearTimeout(this.submenuOpenTimer);
    this.submenuOpenTimer = null;
  }

  private clearSubmenuCloseTimer(): void {
    if (this.submenuCloseTimer === null) return;

    window.clearTimeout(this.submenuCloseTimer);
    this.submenuCloseTimer = null;
  }

  private clearSubmenuHoverTimers(): void {
    this.clearSubmenuOpenTimer();
    this.clearSubmenuCloseTimer();
    this.hoveredSubmenuTrigger = null;
  }

  private scheduleHoverOpen(): void {
    if (!this.openOnHover || this.state === "open") return;

    this.clearCloseTimer();

    if (this.openDelay <= 0) {
      this.show({ focus: "none", source: "pointer" });
      return;
    }

    this.clearOpenTimer();
    this.openTimer = window.setTimeout(() => {
      this.openTimer = null;
      this.show({ focus: "none", source: "pointer" });
    }, this.openDelay);
  }

  private scheduleHoverClose(): void {
    if (!this.openOnHover) return;

    this.clearOpenTimer();

    if (this.state !== "open" || !this.openedByHover) return;

    // The menu is offset from its trigger, so the pointer crosses a gap it
    // does not own on the way in. Wait that gap out before closing; entering
    // the menu clears the timer.
    const delay = Math.max(this.closeDelay, HOVER_CLOSE_GRACE);

    this.clearCloseTimer();
    this.closeTimer = window.setTimeout(() => {
      this.closeTimer = null;

      // The pointer is on its way from the trigger to the menu; the
      // pointermove handler closes as soon as it leaves the corridor.
      if (this.hasContentGrace()) return;

      this.hide({ returnFocus: false, source: "pointer" });
    }, delay);
  }

  private scheduleSubmenuHoverOpen(trigger: HTMLElement): void {
    const menu = this.submenuFor(trigger);

    if (!menu || this.submenuStack.includes(menu)) return;

    this.clearSubmenuOpenTimer();

    if (this.openDelay <= 0) {
      this.openSubmenu(trigger, "none", true);
      return;
    }

    this.submenuOpenTimer = window.setTimeout(() => {
      this.submenuOpenTimer = null;

      if (this.state !== "open" || this.hoveredSubmenuTrigger !== trigger || !trigger.isConnected) {
        return;
      }

      this.openSubmenu(trigger, "none", true);
    }, this.openDelay);
  }

  private scheduleSubmenuHoverClose(): void {
    if (this.hoverOpenedSubmenus.size === 0) return;

    this.clearSubmenuCloseTimer();

    // The trigger and its submenu are separated by an offset, so the pointer
    // briefly leaves both while crossing the gap. Give it time to arrive.
    const delay = Math.max(this.closeDelay, HOVER_CLOSE_GRACE);

    this.submenuCloseTimer = window.setTimeout(() => {
      this.submenuCloseTimer = null;
      this.closeHoverSubmenus();
    }, delay);
  }

  private show(options: ShowOptions = {}): void {
    const { focus = "first", source = "click" } = options;

    if (this.state === "open") return;

    const trigger = this.trigger;
    const content = this.content ?? this.findContent();

    if (!trigger || !content) return;

    this.content = content;
    this.parts.content = content;
    this.wireTrigger(trigger);
    this.clearTimers();

    this.state = "open";
    this.openedByHover = source === "pointer";

    // A server patch re-opens a menu that is already open, so it keeps the
    // interaction that opened it. Every other source settles the indicator.
    if (source === "keyboard") {
      this.keyboardOpen = true;
    } else if (source !== "server") {
      this.keyboardOpen = false;
    }

    const generation = ++this.generation;

    try {
      content.showPopover?.();
    } catch {
      // The menu may already be open after a remount or a patch.
    }

    this.setState("open", false);

    const positioner = this.ensurePositioner();

    const reveal = () => {
      if (this.generation !== generation || this.state !== "open") return;

      this.js().setAttribute(content, "data-state", "open");

      if (focus !== "none" && !this.openedByHover) {
        if (focus === "menu") {
          this.focusMenuContainer(content);
        } else {
          this.focusMenu(content, focus);
        }
      }

      this.emitChange("open");
    };

    if (positioner) {
      positioner.start().then(reveal, reveal);
    } else {
      reveal();
    }
  }

  private hide(options: HideOptions = {}): void {
    const { returnFocus = false } = options;

    this.clearTimers();
    this.clearSubmenuHoverTimers();
    this.clearGraceAreas();

    if (this.state !== "open") {
      this.closeAllSubmenus();
      return;
    }

    const content = this.content;

    this.state = "closed";
    this.openedByHover = false;
    this.keyboardOpen = false;
    const generation = ++this.generation;

    this.closeAllSubmenus();
    this.positioner?.stop();

    this.setState("closed");
    this.clearActive();

    if (returnFocus && this.trigger) {
      this.focusTrigger();
    }

    if (content) {
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

  /**
   * Focuses the menu surface itself and leaves every item inactive. A pointer
   * open uses this: keyboard navigation then starts at the top of the list,
   * while no row looks hovered just because the menu opened.
   */
  private focusMenuContainer(menu: HTMLElement): void {
    this.clearActive();

    try {
      menu.focus();
    } catch {
      // The menu may have been removed between the check and the call.
    }
  }

  private focusMenu(menu: HTMLElement, target: Exclude<FocusTarget, "none" | "menu">): void {
    const items = this.items(menu);
    const item = target === "last" ? items[items.length - 1] : items[0];

    if (item) {
      this.setActive(menu, item);
      return;
    }

    try {
      menu.focus();
    } catch {
      // The menu may have been removed between the check and the call.
    }
  }

  // --- Menu items ---

  private items(menu: HTMLElement): HTMLElement[] {
    return Array.from(menu.querySelectorAll<HTMLElement>('[role="menuitem"]')).filter(
      (item) =>
        !isDisabled(item) &&
        !item.hasAttribute("data-custom") &&
        !item.hidden &&
        item.getAttribute("aria-hidden") !== "true",
    );
  }

  private setActive(menu: HTMLElement, item: HTMLElement): void {
    for (const candidate of this.items(menu)) {
      this.js().setAttribute(candidate, "tabindex", "-1");
      this.js().removeAttribute(candidate, "data-active");
    }

    this.js().setAttribute(item, "tabindex", "0");
    this.js().setAttribute(item, "data-active", "");

    try {
      item.focus();
    } catch {
      // The item may have been removed between the check and the call.
    }
  }

  private clearActive(): void {
    for (const item of Array.from(this.el.querySelectorAll<HTMLElement>('[role="menuitem"]'))) {
      this.js().setAttribute(item, "tabindex", "-1");
      this.js().removeAttribute(item, "data-active");
    }
  }

  private moveFocus(menu: HTMLElement, delta: 1 | -1): void {
    const items = this.items(menu);

    if (items.length === 0) {
      this.focusMenu(menu, "first");
      return;
    }

    const active = document.activeElement;
    const current = items.indexOf(active as HTMLElement);
    const nextIndex =
      current === -1
        ? delta > 0
          ? 0
          : items.length - 1
        : (current + delta + items.length) % items.length;

    const next = items[nextIndex];
    if (next) this.setActive(menu, next);
  }

  private focusBoundary(menu: HTMLElement, target: "first" | "last"): void {
    const items = this.items(menu);
    const item = target === "first" ? items[0] : items[items.length - 1];

    if (item) {
      this.setActive(menu, item);
    } else {
      this.focusMenu(menu, target);
    }
  }

  private typeaheadMatch(menu: HTMLElement, key: string): boolean {
    if (key.length !== 1 || key === " " || /^\s$/.test(key)) return false;

    if (this.typeaheadTimer !== null) {
      window.clearTimeout(this.typeaheadTimer);
    }

    this.typeahead += key.toLowerCase();
    this.typeaheadTimer = window.setTimeout(() => {
      this.typeahead = "";
      this.typeaheadTimer = null;
    }, TYPEAHEAD_TIMEOUT);

    const items = this.items(menu);
    if (items.length === 0) return false;

    const active = document.activeElement;
    const current = items.indexOf(active as HTMLElement);
    const start = current === -1 ? 0 : current + 1;

    const ordered = [...items.slice(start), ...items.slice(0, start)];
    const match = ordered.find((item) =>
      (item.textContent ?? "").trim().toLowerCase().startsWith(this.typeahead),
    );

    if (!match) return false;

    this.setActive(menu, match);
    return true;
  }

  // --- Submenus ---

  private submenuFor(trigger: HTMLElement): HTMLElement | null {
    const id = trigger.dataset.menu;
    if (!id) return null;

    const menu = document.getElementById(id);

    return menu instanceof HTMLElement && this.el.contains(menu) ? menu : null;
  }

  private triggerForSubmenu(menu: HTMLElement): HTMLElement | null {
    const triggers = Array.from(
      this.el.querySelectorAll<HTMLElement>('[data-part="submenu-trigger"]'),
    );

    return triggers.find((trigger) => trigger.dataset.menu === menu.id) ?? null;
  }

  private openSubmenu(
    trigger: HTMLElement,
    focus: "first" | "menu" | "none" = "first",
    openedByHover = false,
  ): void {
    if (isDisabled(trigger)) return;

    const menu = this.submenuFor(trigger);
    if (!menu) return;

    const parent = trigger.closest<HTMLElement>('[data-part="content"], [data-part="submenu"]');
    const parentIndex = parent ? this.submenuStack.indexOf(parent) : -1;

    while (this.submenuStack.length > parentIndex + 1) {
      const closing = this.submenuStack.pop();
      if (closing) this.closeSubmenuElement(closing, false);
    }

    if (this.submenuStack.includes(menu)) {
      if (!openedByHover) {
        this.hoverOpenedSubmenus.delete(menu);
        this.clearGrace(menu);
      }
      if (focus !== "none") this.focusSubmenu(menu, focus);
      return;
    }

    if (openedByHover) {
      this.hoverOpenedSubmenus.add(menu);
    } else {
      this.hoverOpenedSubmenus.delete(menu);
      this.clearGrace(menu);
    }

    this.submenuStack.push(menu);

    const generation = this.generation;

    try {
      menu.showPopover?.();
    } catch {
      // The menu may already be open after a remount or a patch.
    }

    this.js().setAttribute(menu, "data-state", "closed");
    this.js().setAttribute(trigger, "aria-expanded", "false");

    let positioner = this.submenuPositioners.get(menu);

    if (!positioner) {
      positioner = createPositioner(trigger, menu, {
        placement: "right",
        align: "start",
        offset: SUBMENU_OFFSET,
        arrow: null,
        arrowVarPrefix: "dropdown",
      });
      this.submenuPositioners.set(menu, positioner);
    }

    const reveal = () => {
      if (this.generation !== generation || this.state !== "open") return;
      if (!this.submenuStack.includes(menu)) return;

      this.js().setAttribute(menu, "data-state", "open");
      this.js().setAttribute(trigger, "aria-expanded", "true");
      if (focus !== "none") this.focusSubmenu(menu, focus);
    };

    positioner.start().then(reveal, reveal);
  }

  private focusSubmenu(menu: HTMLElement, focus: "first" | "menu"): void {
    if (focus === "menu") {
      this.focusMenuContainer(menu);
      return;
    }

    this.focusMenu(menu, "first");
  }

  /**
   * The open submenus that contain the target, from the nearest menu outward.
   * Submenus are DOM siblings of the root content, so the parent chain comes
   * from each menu's trigger rather than from the DOM.
   */
  private submenuAncestors(target: Element): Set<HTMLElement> {
    const menus = new Set<HTMLElement>();
    let menu = target.closest<HTMLElement>('[data-part="submenu"]');

    while (menu && this.el.contains(menu)) {
      menus.add(menu);

      const trigger = this.triggerForSubmenu(menu);
      menu = trigger?.closest<HTMLElement>('[data-part="submenu"]') ?? null;
    }

    return menus;
  }

  private closeHoverSubmenusOutside(
    target: Element,
    keep: HTMLElement | null = null,
    point?: Point,
  ): void {
    if (this.hoverOpenedSubmenus.size === 0) return;

    const keepMenus = this.submenuAncestors(target);
    if (keep) keepMenus.add(keep);

    // A pointer that is inside a grace corridor is on its way to that
    // submenu, so crossing a sibling row there must not dismiss it.
    if (point) {
      for (const menu of this.gracedMenusAt(point)) keepMenus.add(menu);
    }

    for (const menu of Array.from(this.hoverOpenedSubmenus)) {
      if (!keepMenus.has(menu)) this.closeSubmenu(menu, false);
    }
  }

  private closeHoverSubmenus(): void {
    const keep = this.gracedMenus();

    for (const menu of Array.from(this.hoverOpenedSubmenus)) {
      if (!keep.has(menu)) this.closeSubmenu(menu, false);
    }
  }

  private closeSubmenu(menu: HTMLElement, returnFocus: boolean): void {
    const index = this.submenuStack.indexOf(menu);
    if (index === -1) return;

    while (this.submenuStack.length > index) {
      const closing = this.submenuStack.pop();
      if (closing) this.closeSubmenuElement(closing, returnFocus && closing === menu);
    }
  }

  private closeSubmenuElement(menu: HTMLElement, returnFocus: boolean): void {
    const trigger = this.triggerForSubmenu(menu);
    const positioner = this.submenuPositioners.get(menu);

    this.hoverOpenedSubmenus.delete(menu);
    this.clearGrace(menu);
    positioner?.stop();
    this.submenuPositioners.delete(menu);

    for (const item of this.items(menu)) {
      this.js().setAttribute(item, "tabindex", "-1");
      this.js().removeAttribute(item, "data-active");
    }

    this.js().setAttribute(menu, "data-state", "closed");

    if (trigger) {
      this.js().setAttribute(trigger, "aria-expanded", "false");
    }

    if (
      returnFocus &&
      trigger?.isConnected &&
      document.activeElement instanceof Node &&
      menu.contains(document.activeElement)
    ) {
      try {
        trigger.focus();
      } catch {
        // The trigger may have been removed between the check and the call.
      }
    }

    awaitAnimationsPromise(menu).then(() => {
      if (this.submenuStack.includes(menu)) return;

      try {
        menu.hidePopover?.();
      } catch {
        // Already hidden or detached.
      }
    });
  }

  private closeAllSubmenus(): void {
    while (this.submenuStack.length > 0) {
      const closing = this.submenuStack.pop();
      if (closing) this.closeSubmenuElement(closing, false);
    }

    this.hoverOpenedSubmenus.clear();
  }

  // --- Hover path grace ---

  /**
   * Records the corridor the pointer is expected to travel from a trigger to
   * its open panel. The pointermove handler closes the panel once the pointer
   * leaves the corridor, so the pointer can cross the gap slowly and may pass
   * over the parent menu's chrome or a sibling row on the way.
   */
  private startGrace(
    trigger: HTMLElement,
    target: HTMLElement,
    menu: HTMLElement | null,
    point: Point,
  ): void {
    const rect = target.getBoundingClientRect();
    const polygon = getGracePolygon(point, trigger.getBoundingClientRect(), rect);

    if (polygon.length === 0) return;

    this.graceAreas.set(target, { trigger, target, menu, polygon });
  }

  private clearGrace(target: HTMLElement | null): void {
    if (target) this.graceAreas.delete(target);
  }

  private clearGraceAreas(): void {
    this.graceAreas.clear();
  }

  private gracedMenus(): Set<HTMLElement> {
    const menus = new Set<HTMLElement>();

    for (const area of this.graceAreas.values()) {
      if (area.menu) menus.add(area.menu);
    }

    return menus;
  }

  private gracedMenusAt(point: Point): Set<HTMLElement> {
    const menus = new Set<HTMLElement>();

    for (const area of this.graceAreas.values()) {
      if (area.menu && isPointInPolygon(point, area.polygon)) menus.add(area.menu);
    }

    return menus;
  }

  private hasContentGrace(): boolean {
    for (const area of this.graceAreas.values()) {
      if (!area.menu) return true;
    }

    return false;
  }

  /**
   * Starts a corridor when the pointer leaves a submenu trigger or the root
   * trigger on its way to the panel. Leaving a trigger towards anything else
   * remains a normal dismissal.
   */
  private startPathGrace(target: Element, next: EventTarget | null, point: Point): void {
    const nextNode = next instanceof Node ? next : null;

    const submenuTrigger = target.closest<HTMLElement>('[data-part="submenu-trigger"]');

    if (
      submenuTrigger &&
      this.el.contains(submenuTrigger) &&
      !(nextNode && submenuTrigger.contains(nextNode))
    ) {
      const menu = this.submenuFor(submenuTrigger);

      if (menu && this.hoverOpenedSubmenus.has(menu) && !(nextNode && menu.contains(nextNode))) {
        this.startGrace(submenuTrigger, menu, menu, point);
      }
    }

    if (
      this.trigger?.contains(target) &&
      !(nextNode && (this.trigger.contains(nextNode) || this.content?.contains(nextNode)))
    ) {
      if (this.state === "open" && this.openedByHover && this.content) {
        this.startGrace(this.trigger, this.content, null, point);
      }
    }
  }

  /**
   * Abandons the active corridors and lets the normal hover close take over,
   * for example when the pointer leaves the window or the menu repositions.
   */
  private releaseGraceAreas(): void {
    if (this.graceAreas.size === 0) return;

    const gracedMenus = this.gracedMenus();
    const hadContent = this.hasContentGrace();
    this.clearGraceAreas();

    if (gracedMenus.size > 0) this.scheduleSubmenuHoverClose();
    if (hadContent) this.scheduleHoverClose();
  }

  // --- Event handlers ---

  private handleTriggerClick = (event: MouseEvent): void => {
    if (event.defaultPrevented) return;

    if (this.state === "open") {
      if (this.openedByHover) {
        this.openedByHover = false;
        this.clearTimers();
        this.clearGraceAreas();
        this.focusMenuContainer(this.content ?? this.findContent() ?? this.el);
        return;
      }

      this.hide({ returnFocus: true, source: "click" });
      return;
    }

    // `detail` is 0 for the click the browser synthesizes from `Enter` or
    // `Space` on the trigger, which is keyboard intent. A real pointer click
    // focuses the menu surface so the first row does not look selected.
    const keyboard = event.detail === 0;

    this.show({
      focus: keyboard ? "first" : "menu",
      source: keyboard ? "keyboard" : "click",
    });
  };

  private handleTriggerKeydown = (event: KeyboardEvent): void => {
    if (event.key !== "ArrowDown" && event.key !== "ArrowUp") return;

    event.preventDefault();
    event.stopPropagation();

    const target = event.key === "ArrowDown" ? "first" : "last";

    if (this.state === "open") {
      const menu = this.content;
      if (menu) this.focusBoundary(menu, target === "first" ? "first" : "last");
      return;
    }

    this.show({ focus: target, source: "keyboard" });
  };

  private handleClick = (event: MouseEvent): void => {
    const target = event.target;
    if (!(target instanceof Element)) return;

    const item = target.closest<HTMLElement>(
      '[data-element="dropdown_item"], [data-element="dropdown_sub"]',
    );

    if (!item || !this.el.contains(item)) return;

    if (isDisabled(item)) {
      event.preventDefault();
      event.stopPropagation();
      return;
    }

    if (item.getAttribute("data-element") === "dropdown_sub") {
      event.preventDefault();
      this.clearSubmenuHoverTimers();
      this.openSubmenu(item, event.detail === 0 ? "first" : "menu");
      return;
    }

    if (item.hasAttribute("data-custom")) return;

    this.hide({ returnFocus: true, source: "select" });
  };

  private handlePointerOver = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;

    const target = event.target;
    if (!(target instanceof Element)) return;

    // Re-entering any part of the dropdown (the trigger, the menu, or a
    // submenu) keeps a hover-opened menu open and ends the transit.
    for (const area of Array.from(this.graceAreas.values())) {
      if (area.trigger.contains(target) || area.target.contains(target)) {
        this.graceAreas.delete(area.target);
      }
    }

    this.clearCloseTimer();
    this.clearSubmenuCloseTimer();

    if (this.state === "closed") {
      if (!this.openOnHover) return;

      this.scheduleHoverOpen();
      return;
    }

    const trigger = target.closest<HTMLElement>('[data-part="submenu-trigger"]');
    const submenuTrigger = trigger && this.el.contains(trigger) ? trigger : null;
    const point = { x: event.clientX, y: event.clientY };

    this.hoveredSubmenuTrigger = submenuTrigger;

    if (!submenuTrigger) {
      this.clearSubmenuOpenTimer();

      // The submenu is offset from its trigger, so the pointer crosses the
      // parent menu's chrome (list padding, a header) on the way in. Only
      // another item dismisses a hover-opened submenu at once; chrome gets the
      // same grace as leaving the menu, so entering the submenu still cancels
      // the close.
      const insideSubmenu = this.submenuAncestors(target).size > 0;
      const menuItem = target.closest('[role="menuitem"]');

      if (insideSubmenu || menuItem) {
        this.closeHoverSubmenusOutside(target, null, point);
      } else {
        this.scheduleSubmenuHoverClose();
      }

      return;
    }

    this.closeHoverSubmenusOutside(submenuTrigger, this.submenuFor(submenuTrigger), point);

    if (submenuTrigger.hasAttribute("data-open-on-hover") && !isDisabled(submenuTrigger)) {
      this.scheduleSubmenuHoverOpen(submenuTrigger);
    } else {
      this.clearSubmenuOpenTimer();
    }
  };

  private handlePointerOut = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;

    const target = event.target;
    const next = event.relatedTarget;

    if (target instanceof Element) {
      this.startPathGrace(target, next, { x: event.clientX, y: event.clientY });
    }

    if (next instanceof Node && this.el.contains(next)) return;

    this.hoveredSubmenuTrigger = null;
    this.clearSubmenuOpenTimer();
    this.scheduleSubmenuHoverClose();

    if (!this.openOnHover) return;

    this.scheduleHoverClose();
  };

  private handleGracePointerMove = (event: PointerEvent): void => {
    if (this.graceAreas.size === 0) return;
    if (event.pointerType && event.pointerType !== "mouse") return;

    const point = { x: event.clientX, y: event.clientY };
    const node = event.target instanceof Node ? event.target : null;

    for (const area of Array.from(this.graceAreas.values())) {
      const target = area.target;

      if (!target.isConnected) {
        this.graceAreas.delete(target);
        continue;
      }

      if (node && (area.trigger.contains(node) || target.contains(node))) {
        this.graceAreas.delete(target);
        continue;
      }

      if (isPointInPolygon(point, area.polygon)) continue;

      this.graceAreas.delete(target);

      if (area.menu) {
        this.closeSubmenu(area.menu, false);
      } else if (this.state === "open" && this.openedByHover) {
        this.hide({ returnFocus: false, source: "pointer" });
      }
    }
  };

  private handleGracePointerLeave = (): void => {
    this.releaseGraceAreas();
  };

  private handleGraceViewportChange = (): void => {
    this.releaseGraceAreas();
  };

  private handleOutsidePointerDown = (event: PointerEvent): void => {
    if (this.state !== "open") return;

    const target = event.target;
    if (!(target instanceof Node)) return;
    if (this.el.contains(target)) return;

    this.hide({ returnFocus: false, source: "click" });
  };

  private handleFocusIn = (event: FocusEvent): void => {
    if (this.state !== "open") return;

    const target = event.target;
    if (!(target instanceof Node)) return;

    if (!this.el.contains(target)) {
      this.hide({ returnFocus: false, source: "server" });
      return;
    }

    if (this.submenuStack.length === 0) return;

    for (const menu of this.submenuStack) {
      if (menu.contains(target)) return;
    }

    const trigger = this.submenuStack[this.submenuStack.length - 1];
    const owner = trigger ? this.triggerForSubmenu(trigger) : null;

    if (owner?.contains(target)) return;

    this.closeAllSubmenus();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (this.state !== "open") return;
    if (event.defaultPrevented) return;

    if (event.key === "Escape") {
      event.preventDefault();

      const submenu = this.submenuStack[this.submenuStack.length - 1];
      if (submenu) {
        this.closeSubmenu(submenu, true);
        return;
      }

      this.hide({ returnFocus: true, source: "keyboard" });
      return;
    }

    if (event.key === "Tab") {
      this.hide({ returnFocus: false, source: "keyboard" });
      return;
    }

    const target = event.target;
    if (!(target instanceof Element)) return;

    const menu = target.closest<HTMLElement>('[data-part="content"], [data-part="submenu"]');
    if (!menu || !this.el.contains(menu)) return;

    // Custom content owns its own keys, so an input inside it keeps typing and
    // its cursor keys. A pointer open leaves focus on the menu surface, so the
    // navigation keys must still work from there.
    if (target.closest("[data-custom]")) return;

    const item = target.closest<HTMLElement>('[role="menuitem"]');

    switch (event.key) {
      case "ArrowDown":
        event.preventDefault();
        this.moveFocus(menu, 1);
        return;

      case "ArrowUp":
        event.preventDefault();
        this.moveFocus(menu, -1);
        return;

      case "Home":
        event.preventDefault();
        this.focusBoundary(menu, "first");
        return;

      case "End":
        event.preventDefault();
        this.focusBoundary(menu, "last");
        return;

      case "ArrowRight": {
        if (!item || item.getAttribute("data-element") !== "dropdown_sub") return;

        event.preventDefault();
        this.openSubmenu(item);
        return;
      }

      case "ArrowLeft":
        if (menu.getAttribute("data-part") !== "submenu") return;

        event.preventDefault();
        this.closeSubmenu(menu, true);
        return;

      case "Enter":
      case " ": {
        if (!item) return;
        if (item instanceof HTMLButtonElement || item instanceof HTMLAnchorElement) return;
        if (isDisabled(item)) return;

        event.preventDefault();
        item.click();
        return;
      }

      default:
        if (
          !event.ctrlKey &&
          !event.metaKey &&
          !event.altKey &&
          this.typeaheadMatch(menu, event.key)
        ) {
          event.preventDefault();
        }
    }
  };

  private handleOpenCommand = (): void => {
    this.show({ focus: "first", source: "command" });
  };

  private handleCloseCommand = (): void => {
    this.hide({ returnFocus: true, source: "command" });
  };

  private handleToggleCommand = (): void => {
    if (this.state === "open") {
      this.hide({ returnFocus: true, source: "command" });
    } else {
      this.show({ focus: "first", source: "command" });
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

    this.el.addEventListener(Events.Open, this.handleOpenCommand);
    this.el.addEventListener(Events.Close, this.handleCloseCommand);
    this.el.addEventListener(Events.Toggle, this.handleToggleCommand);

    this.el.addEventListener("click", this.handleClick);
    this.el.addEventListener("pointerover", this.handlePointerOver);
    this.el.addEventListener("pointerout", this.handlePointerOut);

    document.addEventListener("keydown", this.handleKeydown);
    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.addEventListener("focusin", this.handleFocusIn);
    document.addEventListener("phx:update", this.handlePageUpdate);
    document.addEventListener("pointermove", this.handleGracePointerMove, { passive: true });
    document.documentElement.addEventListener("pointerleave", this.handleGracePointerLeave);
    window.addEventListener("scroll", this.handleGraceViewportChange, true);
    window.addEventListener("resize", this.handleGraceViewportChange);
  }

  updated() {
    this.refresh();
  }

  destroyed() {
    this.clearTimers();
    this.clearSubmenuHoverTimers();
    this.clearGraceAreas();
    this.generation++;

    this.positioner?.stop();
    this.positioner = null;
    this.closeAllSubmenus();

    this.el.removeEventListener(Events.Open, this.handleOpenCommand);
    this.el.removeEventListener(Events.Close, this.handleCloseCommand);
    this.el.removeEventListener(Events.Toggle, this.handleToggleCommand);

    this.el.removeEventListener("click", this.handleClick);
    this.el.removeEventListener("pointerover", this.handlePointerOver);
    this.el.removeEventListener("pointerout", this.handlePointerOut);

    document.removeEventListener("keydown", this.handleKeydown);
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.removeEventListener("focusin", this.handleFocusIn);
    document.removeEventListener("phx:update", this.handlePageUpdate);
    document.removeEventListener("pointermove", this.handleGracePointerMove);
    document.documentElement.removeEventListener("pointerleave", this.handleGracePointerLeave);
    window.removeEventListener("scroll", this.handleGraceViewportChange, true);
    window.removeEventListener("resize", this.handleGraceViewportChange);

    this.unbindTrigger(this.trigger);

    try {
      this.content?.hidePopover?.();
    } catch {
      // Already hidden or detached.
    }
  }

  private refresh(): void {
    const previousTrigger = this.trigger;
    const previousContent = this.content;
    const wasOpen = this.state === "open";

    this.readConfig();
    this.syncParts();

    const triggerChanged = previousTrigger !== this.trigger;
    const contentChanged = previousContent !== this.content;

    if (triggerChanged && wasOpen) {
      this.hide({ returnFocus: false });
    }

    if (contentChanged) {
      this.reset();

      if (wasOpen && !triggerChanged) {
        this.show({ focus: "none", source: "server" });
      }
    } else if (wasOpen && this.state === "open") {
      this.closeAllSubmenus();
      this.positioner?.stop();
      this.positioner = this.ensurePositioner();
      void this.positioner?.start();
    }

    this.setState(this.state);
  }

  private reset(): void {
    this.clearTimers();
    this.clearSubmenuHoverTimers();
    this.clearGraceAreas();
    this.generation++;
    this.state = "closed";
    this.openedByHover = false;
    this.closeAllSubmenus();
    this.submenuPositioners.clear();
    this.positioner?.stop();
    this.positioner = null;
    this.positionedTrigger = null;
    this.positionedContent = null;
    this.positionedArrow = null;
    this.positionedWith = "";
    this.typeahead = "";
  }
}
