import { FlintHook } from "../lib/core";
import { createPositioner, type Align, type Positioner } from "../lib/position";
import { awaitAnimationsPromise, readCssLength } from "../lib/util";

const MENU_SELECTOR = '[data-element="navbar_menu"]';
const OPEN_MENU_SELECTOR = `${MENU_SELECTOR}[data-state="open"]`;
const MENU_ITEM_SELECTOR = '[data-element="navbar_menu_item"]';
const DEFAULT_OFFSET = 4;
const ARROW_KEYS = ["ArrowRight", "ArrowLeft", "Home", "End"];
const HOVER_CLOSE_GRACE = 150;

/**
 * Owns the behavior shared by the navbar's disclosure menus.
 *
 * Each `navbar_menu` still uses `FlintUI.Collapsible` for its own toggle and
 * ARIA wiring. This hook adds the behavior that spans menus: the panel is shown
 * in the top layer and positioned beneath its trigger, only one menu stays open,
 * `Escape` closes the open menu and returns focus to its trigger, clicking
 * outside closes every open menu, and following a menu link closes its menu.
 *
 * It also owns the navbar-level navigation: arrow keys move focus between the
 * top-level items and menu triggers (wrapping when `data-loop` is set), and
 * `scrollable`/`fadable` turn the list into a horizontal scroll container with
 * edge-fade cues.
 *
 * The top layer keeps the panel out of the page's stacking contexts and out of
 * `overflow` clipping, so a navbar inside a scrolling card or a preview surface
 * still opens above the surrounding page.
 */
export class Navbar extends FlintHook {
  private positioners = new Map<
    HTMLElement,
    {
      trigger: HTMLElement;
      content: HTMLElement;
      align: Align;
      positioner: Positioner;
    }
  >();

  private boundList: HTMLElement | null = null;
  private resizeObserver: ResizeObserver | null = null;
  private hoverOpened = new Set<HTMLElement>();
  private hoverCloseTimer: number | null = null;
  private hoverCloseMenu: HTMLElement | null = null;

  private get disabled(): boolean {
    return (
      this.el.hasAttribute("data-disabled") || this.el.hasAttribute("inert")
    );
  }

  private get fadable(): boolean {
    return this.el.hasAttribute("data-fadable");
  }

  private get scrollable(): boolean {
    return this.el.hasAttribute("data-scrollable") || this.fadable;
  }

  private get loop(): boolean {
    return this.el.getAttribute("data-loop") !== "false";
  }

  private list(): HTMLElement | null {
    for (const child of Array.from(this.el.children)) {
      if (
        child instanceof HTMLElement &&
        child.getAttribute("data-part") === "list"
      ) {
        return child;
      }
    }

    return null;
  }

  private openMenus(): HTMLElement[] {
    return Array.from(
      this.el.querySelectorAll<HTMLElement>(OPEN_MENU_SELECTOR),
    );
  }

  private menuTrigger(menu: HTMLElement): HTMLElement | null {
    return menu.querySelector<HTMLElement>(':scope > [data-part="trigger"]');
  }

  private menuContent(menu: HTMLElement): HTMLElement | null {
    return menu.querySelector<HTMLElement>(':scope > [data-part="content"]');
  }

  private menuAlign(menu: HTMLElement): Align {
    const position = menu.getAttribute("data-position");

    return position === "start" || position === "end" ? position : "center";
  }

  /**
   * The focusable top-level controls, in DOM order. Menu links live inside a
   * panel, so they are not part of the arrow-key sequence. Disabled and
   * plain-text items are skipped.
   */
  private topLevelControls(): HTMLElement[] {
    const list = this.list();
    if (!list) return [];

    const controls: HTMLElement[] = [];

    for (const child of Array.from(list.children)) {
      if (
        !(child instanceof HTMLElement) ||
        child.hasAttribute("data-disabled")
      )
        continue;

      const element = child.getAttribute("data-element");
      const selector =
        element === "navbar_item"
          ? ':scope > [data-part="content"]'
          : element === "navbar_menu"
            ? ':scope > [data-part="trigger"]'
            : null;

      if (!selector) continue;

      const control = child.querySelector<HTMLElement>(selector);
      if (control?.matches("a[href], button:not([disabled])"))
        controls.push(control);
    }

    return controls;
  }

  private nextControl(
    controls: HTMLElement[],
    index: number,
    key: string,
  ): HTMLElement | null {
    if (key === "Home") return controls[0] ?? null;
    if (key === "End") return controls[controls.length - 1] ?? null;

    const delta = key === "ArrowRight" ? 1 : -1;
    let next = index + delta;

    if (next < 0) next = this.loop ? controls.length - 1 : 0;
    if (next >= controls.length) next = this.loop ? 0 : controls.length - 1;

    return controls[next] ?? null;
  }

  /**
   * Reads the public `--fl-navbar-menu-offset` input so the positioned panel
   * keeps the gap the stylesheet declares. The default length is `--fl-spacing-xs`
   * (4px); a computed `calc()` that cannot be reduced to one length falls back to
   * the same value.
   */
  private menuOffset(content: HTMLElement): number {
    return readCssLength(content, "--fl-navbar-menu-offset", DEFAULT_OFFSET);
  }

  private showMenu(menu: HTMLElement): void {
    const content = this.menuContent(menu);
    const trigger = this.menuTrigger(menu);

    if (!content || !trigger) return;

    try {
      content.showPopover?.();
    } catch {
      // The panel may already be open after a remount or a patch.
    }

    const align = this.menuAlign(menu);
    let entry = this.positioners.get(menu);

    if (
      !entry ||
      entry.trigger !== trigger ||
      entry.content !== content ||
      entry.align !== align
    ) {
      entry?.positioner.stop();

      entry = {
        trigger,
        content,
        align,
        positioner: createPositioner(trigger, content, {
          placement: "bottom",
          align,
          offset: this.menuOffset(content),
        }),
      };

      this.positioners.set(menu, entry);
    }

    void entry.positioner.start();
  }

  /**
   * Stops tracking and takes the panel out of the top layer once the close
   * animation has finished. A panel that reopens before then stays open.
   */
  private hideMenu(menu: HTMLElement): void {
    const entry = this.positioners.get(menu);
    const content = entry?.content ?? this.menuContent(menu);

    this.positioners.delete(menu);
    entry?.positioner.stop();

    if (!content) return;

    awaitAnimationsPromise(content).then(() => {
      if (menu.getAttribute("data-state") === "open") return;

      try {
        content.hidePopover?.();
      } catch {
        // Already hidden or detached.
      }
    });
  }

  private closeMenu(menu: HTMLElement, returnFocus = false): void {
    this.hoverOpened.delete(menu);
    if (this.hoverCloseMenu === menu) this.clearHoverCloseTimer();

    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:close", { bubbles: true }),
    );

    if (!returnFocus) return;

    const trigger = this.menuTrigger(menu);

    try {
      trigger?.focus();
    } catch {
      // The trigger may have been removed between the check and the call.
    }
  }

  private closeMenus(returnFocus = false): void {
    for (const menu of this.openMenus()) this.closeMenu(menu, returnFocus);
  }

  private clearHoverCloseTimer(): void {
    if (this.hoverCloseTimer !== null)
      window.clearTimeout(this.hoverCloseTimer);

    this.hoverCloseTimer = null;
    this.hoverCloseMenu = null;
  }

  /**
   * Opens a menu that opted into hover. The event runs the menu's own
   * collapsible, so ARIA and the server state stay in charge. Hover never moves
   * focus.
   */
  private openHoverMenu(menu: HTMLElement): void {
    if (menu.getAttribute("data-state") === "open") return;

    this.hoverOpened.add(menu);
    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:open", { bubbles: true }),
    );
  }

  /**
   * Waits out the gap between the trigger and the panel before closing a menu
   * that was opened by hover. Re-entering the menu clears the timer. A menu
   * that gained focus or was clicked stays open.
   */
  private scheduleHoverClose(menu: HTMLElement): void {
    if (!this.hoverOpened.has(menu)) return;

    this.clearHoverCloseTimer();
    this.hoverCloseMenu = menu;

    this.hoverCloseTimer = window.setTimeout(() => {
      this.hoverCloseTimer = null;

      const target = this.hoverCloseMenu;
      this.hoverCloseMenu = null;

      if (!target || !this.hoverOpened.has(target)) return;

      if (target.getAttribute("data-state") !== "open") {
        this.hoverOpened.delete(target);
        return;
      }

      // A pointer can leave after the user tabbed into the menu. Keep it open
      // and pin it rather than closing under the keyboard user.
      if (target.contains(document.activeElement)) {
        this.hoverOpened.delete(target);
        return;
      }

      this.hoverOpened.delete(target);
      this.closeMenu(target, false);
    }, HOVER_CLOSE_GRACE);
  }

  private handlePointerOver = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;

    const target = event.target;
    if (!(target instanceof Element)) return;

    const menu = target.closest<HTMLElement>(MENU_SELECTOR);
    if (
      !menu ||
      !this.el.contains(menu) ||
      !menu.hasAttribute("data-open-on-hover")
    )
      return;

    const related = event.relatedTarget;
    if (related instanceof Node && menu.contains(related)) return;

    this.clearHoverCloseTimer();
    this.openHoverMenu(menu);
  };

  private handlePointerOut = (event: PointerEvent): void => {
    if (event.pointerType && event.pointerType !== "mouse") return;

    const target = event.target;
    if (!(target instanceof Element)) return;

    const menu = target.closest<HTMLElement>(MENU_SELECTOR);
    if (!menu || !this.el.contains(menu)) return;

    const related = event.relatedTarget;
    if (related instanceof Node && menu.contains(related)) return;

    if (!this.hoverOpened.has(menu)) return;

    this.scheduleHoverClose(menu);
  };

  private resetHover(): void {
    this.clearHoverCloseTimer();
    this.hoverOpened.clear();
  }

  private syncList(): void {
    const list = this.list();

    if (this.boundList === list) return;

    this.boundList?.removeEventListener("scroll", this.handleListScroll);
    list?.addEventListener("scroll", this.handleListScroll, { passive: true });

    this.resizeObserver?.disconnect();
    if (list) this.resizeObserver?.observe(list);

    this.boundList = list;
  }

  private setRuntimeAttribute(
    element: HTMLElement,
    name: string,
    enabled: boolean,
  ): void {
    if (enabled) {
      this.js().setAttribute(element, name, "");
    } else {
      this.js().removeAttribute(element, name);
    }
  }

  private syncFade(): void {
    const list = this.boundList;
    if (!list) return;

    if (!this.fadable) {
      this.js().removeAttribute(list, "data-fade-start");
      this.js().removeAttribute(list, "data-fade-end");
      return;
    }

    const max = list.scrollWidth - list.clientWidth;
    const start = list.scrollLeft > 1;
    const end = max > 1 && list.scrollLeft < max - 1;

    this.setRuntimeAttribute(list, "data-fade-start", start);
    this.setRuntimeAttribute(list, "data-fade-end", end);
  }

  private scrollControlIntoView(control: HTMLElement | null): void {
    const list = this.boundList;
    if (!control || !list || !this.scrollable) return;

    const listRect = list.getBoundingClientRect();
    const controlRect = control.getBoundingClientRect();

    if (controlRect.left < listRect.left) {
      list.scrollLeft -= listRect.left - controlRect.left;
    } else if (controlRect.right > listRect.right) {
      list.scrollLeft += controlRect.right - listRect.right;
    }

    this.syncFade();
  }

  private scrollActiveIntoView(): void {
    const list = this.boundList;
    if (!list || !this.scrollable) return;

    const active = list.querySelector<HTMLElement>(
      ':scope > [data-element="navbar_item"][data-active] > [data-part="content"]',
    );

    this.scrollControlIntoView(active);
  }

  private handleListScroll = (): void => {
    this.syncFade();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (event.key === "Escape") {
      const open = this.openMenus();
      if (open.length === 0) return;

      event.preventDefault();

      const focused = document.activeElement;
      const owning =
        open.find(
          (menu) => focused instanceof Node && menu.contains(focused),
        ) ?? open[open.length - 1];

      if (owning) this.closeMenu(owning, true);
      return;
    }

    if (this.disabled || event.defaultPrevented) return;
    if (!ARROW_KEYS.includes(event.key)) return;

    const current = document.activeElement;
    if (!(current instanceof HTMLElement)) return;

    const controls = this.topLevelControls();
    const index = controls.indexOf(current);
    if (index === -1) return;

    event.preventDefault();

    const next = this.nextControl(controls, index, event.key);
    if (!next || next === current) return;

    // Focus is leaving the item that owns an open menu, so close it. The next
    // trigger only receives focus; it does not open automatically.
    this.closeMenus(false);

    try {
      next.focus();
    } catch {
      // The control may have been removed between the check and the call.
    }

    this.scrollControlIntoView(next);
    this.syncFade();
  };

  private handleClick = (event: MouseEvent): void => {
    const target = event.target;
    if (!(target instanceof Element)) return;

    const menu = target.closest<HTMLElement>(MENU_SELECTOR);
    if (!menu || !this.el.contains(menu)) return;

    // Clicking the trigger pins the menu. It then stays open until the user
    // closes it, even when the pointer leaves.
    const trigger = this.menuTrigger(menu);

    if (trigger?.contains(target)) {
      this.hoverOpened.delete(menu);
      if (this.hoverCloseMenu === menu) this.clearHoverCloseTimer();
      return;
    }

    const item = target.closest<HTMLElement>(MENU_ITEM_SELECTOR);
    if (item && menu.contains(item) && !item.hasAttribute("data-disabled")) {
      this.closeMenu(menu, false);
    }
  };

  private handleMenuChange = (event: Event): void => {
    const detail = (event as CustomEvent<{ state?: string }>).detail;
    const menu = event.target;
    if (!(menu instanceof HTMLElement) || !menu.matches(MENU_SELECTOR)) return;

    if (detail?.state === "closed") {
      this.hoverOpened.delete(menu);
      if (this.hoverCloseMenu === menu) this.clearHoverCloseTimer();
      this.hideMenu(menu);
      return;
    }

    if (detail?.state !== "open") return;

    this.showMenu(menu);

    for (const other of this.openMenus()) {
      if (other !== menu) this.closeMenu(other, false);
    }
  };

  private handleOutsidePointerDown = (event: PointerEvent): void => {
    const target = event.target;
    if (!(target instanceof Node)) return;

    const open = this.openMenus();
    if (open.length === 0) return;
    if (open.some((menu) => menu.contains(target))) return;

    this.closeMenus(false);
  };

  private handlePageLoading = (): void => {
    this.closeMenus(false);
  };

  mounted() {
    super.mounted();

    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(() => this.syncFade());
    }

    this.el.addEventListener("keydown", this.handleKeydown);
    this.el.addEventListener("click", this.handleClick);
    this.el.addEventListener("pointerover", this.handlePointerOver);
    this.el.addEventListener("pointerout", this.handlePointerOut);
    this.el.addEventListener("fl:collapsible:change", this.handleMenuChange);
    document.addEventListener(
      "pointerdown",
      this.handleOutsidePointerDown,
      true,
    );
    document.addEventListener("phx:page-loading-start", this.handlePageLoading);

    this.syncList();
    this.scrollActiveIntoView();
    this.syncFade();

    if (this.disabled) {
      this.resetHover();
      this.closeMenus(false);
      return;
    }

    for (const menu of this.openMenus()) this.showMenu(menu);
  }

  updated() {
    this.syncList();
    this.scrollActiveIntoView();
    this.syncFade();

    for (const menu of Array.from(this.hoverOpened)) {
      if (!menu.isConnected || !this.el.contains(menu))
        this.hoverOpened.delete(menu);
    }

    if (this.disabled) {
      this.resetHover();
      this.closeMenus(false);

      for (const menu of Array.from(this.positioners.keys()))
        this.hideMenu(menu);

      return;
    }

    const open = new Set(this.openMenus());

    for (const menu of Array.from(this.positioners.keys())) {
      if (!open.has(menu)) this.hideMenu(menu);
    }

    for (const menu of open) this.showMenu(menu);
  }

  destroyed() {
    this.el.removeEventListener("keydown", this.handleKeydown);
    this.el.removeEventListener("click", this.handleClick);
    this.el.removeEventListener("pointerover", this.handlePointerOver);
    this.el.removeEventListener("pointerout", this.handlePointerOut);
    this.el.removeEventListener("fl:collapsible:change", this.handleMenuChange);
    document.removeEventListener(
      "pointerdown",
      this.handleOutsidePointerDown,
      true,
    );
    document.removeEventListener(
      "phx:page-loading-start",
      this.handlePageLoading,
    );

    this.boundList?.removeEventListener("scroll", this.handleListScroll);
    this.resizeObserver?.disconnect();
    this.resetHover();

    for (const entry of this.positioners.values()) {
      entry.positioner.stop();

      try {
        entry.content.hidePopover?.();
      } catch {
        // Already hidden or detached.
      }
    }

    this.positioners.clear();
  }
}
