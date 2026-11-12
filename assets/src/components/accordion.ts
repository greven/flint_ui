import { FlintHook } from "../lib/core";

const ACCORDION = "accordion";
const ITEM = "accordion_item";
const TRIGGER = "trigger";

enum Events {
  Change = "fl:collapsible:change",
  BeforeClose = "fl:collapsible:before-close",
  Close = "fl:collapsible:close",
}

/**
 * Coordinates the accordion items. Each item keeps its own Collapsible hook and
 * state; this hook adds single mode, the "keep one open" guard, and the header
 * keyboard shortcut.
 */
export class Accordion extends FlintHook {
  private get multiple(): boolean {
    return this.el.hasAttribute("data-multiple");
  }

  private get requireOpen(): boolean {
    return this.el.hasAttribute("data-require-open");
  }

  private get disabled(): boolean {
    return this.el.hasAttribute("data-disabled");
  }

  /**
   * Items that belong to this accordion. The nearest accordion check keeps a
   * nested accordion's items (and collapsibles inside a panel) out of the outer
   * open set.
   */
  private items(): HTMLElement[] {
    return Array.from(this.el.querySelectorAll<HTMLElement>(`[data-element="${ITEM}"]`)).filter(
      (item) => item.closest(`[data-element="${ACCORDION}"]`) === this.el,
    );
  }

  private headerFor(item: HTMLElement): HTMLButtonElement | null {
    return item.querySelector<HTMLButtonElement>(`[data-part="${TRIGGER}"]`);
  }

  private itemFor(trigger: Element): HTMLElement | null {
    const item = trigger.closest<HTMLElement>(`[data-element="${ITEM}"]`);
    if (!item || item.closest(`[data-element="${ACCORDION}"]`) !== this.el) return null;
    return item;
  }

  private openItems(): HTMLElement[] {
    return this.items().filter((item) => item.getAttribute("data-state") === "open");
  }

  private isDisabledItem(item: HTMLElement): boolean {
    const header = this.headerFor(item);
    return item.hasAttribute("data-disabled") || !header || header.disabled;
  }

  private enabledHeaders(): HTMLButtonElement[] {
    const headers: HTMLButtonElement[] = [];

    for (const item of this.items()) {
      if (this.isDisabledItem(item)) continue;
      const header = this.headerFor(item);
      if (header) headers.push(header);
    }

    return headers;
  }

  private focusedHeader(): HTMLButtonElement | null {
    const active = document.activeElement;
    if (!(active instanceof HTMLElement)) return null;

    const header = active.closest<HTMLButtonElement>(`[data-part="${TRIGGER}"]`);
    if (!header || !this.itemFor(header)) return null;
    return header;
  }

  private syncDisabled(): void {
    for (const item of this.items()) {
      const header = this.headerFor(item);
      if (!header) continue;

      const disabled = this.disabled || item.hasAttribute("data-disabled");
      if (disabled) {
        header.setAttribute("disabled", "");
        header.setAttribute("aria-disabled", "true");
      } else {
        header.removeAttribute("disabled");
        header.setAttribute("aria-disabled", "false");
      }
    }
  }

  private handleChange = (event: Event): void => {
    if (this.multiple) return;

    const item = event.target;
    if (!(item instanceof HTMLElement) || !this.items().includes(item)) return;

    const detail = (event as CustomEvent<{ state?: unknown }>).detail;
    if (detail?.state !== "open") return;

    for (const other of this.openItems()) {
      if (other === item) continue;
      other.dispatchEvent(new CustomEvent(Events.Close));
    }
  };

  private handleBeforeClose = (event: Event): void => {
    if (!this.requireOpen) return;

    const item = event.target;
    if (!(item instanceof HTMLElement) || !this.items().includes(item)) return;
    if (item.getAttribute("data-state") !== "open") return;

    if (this.openItems().length <= 1) event.preventDefault();
  };

  private handleClickCapture = (event: MouseEvent): void => {
    if (!this.disabled) return;

    const target = event.target;
    if (!(target instanceof Element)) return;

    const header = target.closest(`[data-part="${TRIGGER}"]`);
    if (!header || !this.itemFor(header)) return;

    event.preventDefault();
    event.stopPropagation();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (this.disabled || event.defaultPrevented) return;

    const current = this.focusedHeader();
    if (!current) return;

    const headers = this.enabledHeaders();
    if (headers.length === 0) return;

    const index = headers.indexOf(current);
    let next: HTMLButtonElement | null = null;

    switch (event.key) {
      case "ArrowDown":
        next = headers[index < 0 ? 0 : (index + 1) % headers.length] ?? null;
        break;
      case "ArrowUp":
        next =
          headers[index < 0 ? headers.length - 1 : (index - 1 + headers.length) % headers.length] ??
          null;
        break;
      case "Home":
        next = headers[0] ?? null;
        break;
      case "End":
        next = headers[headers.length - 1] ?? null;
        break;
      default:
        return;
    }

    event.preventDefault();
    next?.focus();
  };

  mounted(): void {
    super.mounted();

    this.el.addEventListener(Events.Change, this.handleChange);
    this.el.addEventListener(Events.BeforeClose, this.handleBeforeClose);
    this.el.addEventListener("click", this.handleClickCapture, true);
    this.el.addEventListener("keydown", this.handleKeydown);
    this.syncDisabled();
  }

  updated(): void {
    this.syncDisabled();
  }

  destroyed(): void {
    this.el.removeEventListener(Events.Change, this.handleChange);
    this.el.removeEventListener(Events.BeforeClose, this.handleBeforeClose);
    this.el.removeEventListener("click", this.handleClickCapture, true);
    this.el.removeEventListener("keydown", this.handleKeydown);
  }
}
