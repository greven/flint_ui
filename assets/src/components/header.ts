import { FlintHook } from "../lib/core";

type HeaderState = "open" | "closed";

const TOGGLE_SELECTOR = ':scope > [data-part="bar"] > [data-part="toggle"]';
const NAV_SELECTOR = ':scope > [data-part="bar"] > [data-part="nav"]';
const MOBILE_SELECTOR = ':scope > [data-part="bar"] > [data-part="mobile"]';
const ICON_SELECTOR = "[data-toggle-icon]";
const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  "[tabindex]:not([tabindex='-1'])",
].join(",");

/**
 * Owns the header's mobile disclosure.
 *
 * The server renders the state on the root, the nav region, and the optional
 * custom mobile panel. This hook toggles that state, keeps `aria-expanded` in
 * step, swaps the state-specific toggle icons, and closes the panel when the
 * user dismisses it or leaves the mobile layout. CSS owns the breakpoint; the
 * hook only checks whether the toggle is still visible after a resize.
 *
 * The panel flows under the bar. When the toggle sits after the panel in the
 * DOM (the default end position with the inline nav), opening the panel moves
 * focus into it so the keyboard path stays in reading order.
 */
export class Header extends FlintHook {
  private state: HeaderState = "closed";
  private boundToggle: HTMLElement | null = null;

  private get open(): boolean {
    return this.state === "open";
  }

  private readState(): HeaderState {
    return (this.el.getAttribute("data-state") as HeaderState) ?? "closed";
  }

  private toggle(): HTMLElement | null {
    return this.el.querySelector<HTMLElement>(TOGGLE_SELECTOR);
  }

  /**
   * The custom mobile panel wins when it exists; otherwise the nav region is
   * the panel.
   */
  private panel(): HTMLElement | null {
    return (
      this.el.querySelector<HTMLElement>(MOBILE_SELECTOR) ??
      this.el.querySelector<HTMLElement>(NAV_SELECTOR)
    );
  }

  private applyState(state: HeaderState): void {
    this.state = state;
    this.js().setAttribute(this.el, "data-state", state);

    const panel = this.panel();
    if (panel) this.js().setAttribute(panel, "data-state", state);

    const toggle = this.toggle();
    if (toggle) {
      this.js().setAttribute(
        toggle,
        "aria-expanded",
        state === "open" ? "true" : "false",
      );
    }

    this.syncToggleIcons();
  }

  /**
   * Keep the `hidden` attribute on the state-specific icons in step with the
   * panel. The markup owns the initial state, so the icons never both show.
   */
  private syncToggleIcons(): void {
    const toggle = this.toggle();
    if (!toggle) return;

    const js = this.js();

    for (const icon of Array.from(
      toggle.querySelectorAll<HTMLElement>(ICON_SELECTOR),
    )) {
      const openIcon = icon.getAttribute("data-toggle-icon") === "open";
      if (openIcon === this.open) {
        js.removeAttribute(icon, "hidden");
      } else {
        js.setAttribute(icon, "hidden", "");
      }
    }
  }

  /**
   * Move focus into the panel when it precedes the toggle, so the inline nav
   * fallback stays reachable with the default end position.
   */
  private focusPanel(): void {
    const panel = this.panel();
    const toggle = this.toggle();
    if (!panel || !toggle) return;

    const panelFollows =
      toggle.compareDocumentPosition(panel) & Node.DOCUMENT_POSITION_FOLLOWING;
    if (panelFollows) return;

    const target = panel.querySelector<HTMLElement>(FOCUSABLE_SELECTOR) ?? panel;
    target.focus();
  }

  private close(returnFocus = false): void {
    if (!this.open) return;

    this.applyState("closed");

    if (!returnFocus) return;

    try {
      this.toggle()?.focus();
    } catch {
      // The toggle may have been removed between the check and the call.
    }
  }

  private handleToggleClick = (): void => {
    const next = this.open ? "closed" : "open";
    this.applyState(next);

    if (next === "open") this.focusPanel();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (event.key !== "Escape" || !this.open) return;

    event.preventDefault();
    this.close(true);
  };

  private handleClick = (event: MouseEvent): void => {
    const target = event.target;
    if (!(target instanceof Element) || !this.open) return;

    const panel = this.panel();
    const link = target.closest("a[href]");

    if (panel && link && panel.contains(link)) this.close();
  };

  private handleOutsidePointerDown = (event: Event): void => {
    const target = event.target;
    if (!(target instanceof Node) || !this.open) return;
    if (this.el.contains(target)) return;

    this.close();
  };

  private handlePageLoading = (): void => {
    this.close();
  };

  private handleResize = (): void => {
    if (!this.open) return;

    const toggle = this.toggle();
    if (toggle && getComputedStyle(toggle).display === "none") this.close();
  };

  private syncToggle(): void {
    const toggle = this.toggle();
    if (this.boundToggle === toggle) return;

    this.boundToggle?.removeEventListener("click", this.handleToggleClick);
    toggle?.addEventListener("click", this.handleToggleClick);
    this.boundToggle = toggle ?? null;
  }

  mounted() {
    super.mounted();

    this.state = this.readState();
    this.syncToggle();
    this.applyState(this.state);

    this.el.addEventListener("keydown", this.handleKeydown);
    this.el.addEventListener("click", this.handleClick);
    document.addEventListener(
      "pointerdown",
      this.handleOutsidePointerDown,
      true,
    );
    document.addEventListener("phx:page-loading-start", this.handlePageLoading);
    window.addEventListener("resize", this.handleResize, { passive: true });
  }

  updated() {
    this.syncToggle();
    this.applyState(this.readState());
  }

  destroyed() {
    this.boundToggle?.removeEventListener("click", this.handleToggleClick);
    this.el.removeEventListener("keydown", this.handleKeydown);
    this.el.removeEventListener("click", this.handleClick);
    document.removeEventListener(
      "pointerdown",
      this.handleOutsidePointerDown,
      true,
    );
    document.removeEventListener("phx:page-loading-start", this.handlePageLoading);
    window.removeEventListener("resize", this.handleResize);
  }
}
