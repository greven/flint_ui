import { FlintHook } from "../lib/core";
import { createPositioner, type Positioner } from "../lib/position";
import { awaitAnimationsPromise } from "../lib/util";

const MENU_SELECTOR = '[data-element="navbar_menu"]';
const OPEN_MENU_SELECTOR = `${MENU_SELECTOR}[data-state="open"]`;
const MENU_ITEM_SELECTOR = '[data-element="navbar_menu_item"]';
const DEFAULT_OFFSET = 4;

/**
 * Owns the behavior shared by the navbar's disclosure menus.
 *
 * Each `navbar_menu` still uses `FlintUI.Collapsible` for its own toggle and
 * ARIA wiring. This hook adds the behavior that spans menus: the panel is shown
 * in the top layer and positioned beneath its trigger, only one menu stays open,
 * `Escape` closes the open menu and returns focus to its trigger, clicking
 * outside closes every open menu, and following a menu link closes its menu.
 *
 * The top layer keeps the panel out of the page's stacking contexts and out of
 * `overflow` clipping, so a navbar inside a scrolling card or a preview surface
 * still opens above the surrounding page.
 */
export class Navbar extends FlintHook {
  private positioners = new Map<
    HTMLElement,
    { trigger: HTMLElement; content: HTMLElement; positioner: Positioner }
  >();

  private openMenus(): HTMLElement[] {
    return Array.from(this.el.querySelectorAll<HTMLElement>(OPEN_MENU_SELECTOR));
  }

  private menuTrigger(menu: HTMLElement): HTMLElement | null {
    return menu.querySelector<HTMLElement>(':scope > [data-part="trigger"]');
  }

  private menuContent(menu: HTMLElement): HTMLElement | null {
    return menu.querySelector<HTMLElement>(':scope > [data-part="content"]');
  }

  /**
   * Reads the public `--fl-navbar-menu-offset` input so the positioned panel
   * keeps the gap the stylesheet declares. The default length is `--fl-spacing-xs`
   * (4px); a computed `calc()` that cannot be reduced to one length falls back to
   * the same value.
   */
  private menuOffset(content: HTMLElement): number {
    const raw = getComputedStyle(content).getPropertyValue("--fl-navbar-menu-offset").trim();
    const value = Number.parseFloat(raw);

    if (!Number.isFinite(value)) return DEFAULT_OFFSET;

    if (raw.endsWith("rem")) {
      const rootSize = Number.parseFloat(getComputedStyle(document.documentElement).fontSize);
      return Number.isFinite(rootSize) ? value * rootSize : value * 16;
    }

    if (raw.endsWith("em")) {
      const localSize = Number.parseFloat(getComputedStyle(content).fontSize);
      return Number.isFinite(localSize) ? value * localSize : value * 16;
    }

    return value;
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

    let entry = this.positioners.get(menu);

    if (!entry || entry.trigger !== trigger || entry.content !== content) {
      entry?.positioner.stop();

      entry = {
        trigger,
        content,
        positioner: createPositioner(trigger, content, {
          placement: "bottom",
          align: "start",
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
    menu.dispatchEvent(new CustomEvent("fl:collapsible:close", { bubbles: true }));

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

  private handleKeydown = (event: KeyboardEvent): void => {
    if (event.key !== "Escape") return;

    const open = this.openMenus();
    if (open.length === 0) return;

    event.preventDefault();

    const focused = document.activeElement;
    const owning =
      open.find((menu) => focused instanceof Node && menu.contains(focused)) ??
      open[open.length - 1];

    if (owning) this.closeMenu(owning, true);
  };

  private handleClick = (event: MouseEvent): void => {
    const target = event.target;
    if (!(target instanceof Element)) return;

    const menu = target.closest<HTMLElement>(MENU_SELECTOR);
    if (!menu || !this.el.contains(menu)) return;

    const item = target.closest<HTMLElement>(MENU_ITEM_SELECTOR);
    if (item && menu.contains(item)) this.closeMenu(menu, false);
  };

  private handleMenuChange = (event: Event): void => {
    const detail = (event as CustomEvent<{ state?: string }>).detail;
    const menu = event.target;
    if (!(menu instanceof HTMLElement) || !menu.matches(MENU_SELECTOR)) return;

    if (detail?.state === "closed") {
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

    this.el.addEventListener("keydown", this.handleKeydown);
    this.el.addEventListener("click", this.handleClick);
    this.el.addEventListener("fl:collapsible:change", this.handleMenuChange);
    document.addEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.addEventListener("phx:page-loading-start", this.handlePageLoading);

    for (const menu of this.openMenus()) this.showMenu(menu);
  }

  updated() {
    const open = new Set(this.openMenus());

    for (const menu of Array.from(this.positioners.keys())) {
      if (!open.has(menu)) this.hideMenu(menu);
    }

    for (const menu of open) this.showMenu(menu);
  }

  destroyed() {
    this.el.removeEventListener("keydown", this.handleKeydown);
    this.el.removeEventListener("click", this.handleClick);
    this.el.removeEventListener("fl:collapsible:change", this.handleMenuChange);
    document.removeEventListener("pointerdown", this.handleOutsidePointerDown, true);
    document.removeEventListener("phx:page-loading-start", this.handlePageLoading);

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
