import { FlintHook } from "../lib/core";

enum Events {
  BeforeChange = "fl:tabs:before-change",
  Change = "fl:tabs:change",
  Select = "fl:tabs:select",
}

type Orientation = "horizontal" | "vertical";
type ActivationMode = "automatic" | "manual";

export class Tabs extends FlintHook {
  private currentValue: string | null = null;
  private lastServerValue: string | null = null;
  private boundTablist: HTMLElement | null = null;
  private boundPanels: HTMLElement[] = [];
  private resizeObserver: ResizeObserver | null = null;

  private readServerValue(): string | null {
    return this.el.getAttribute("data-value");
  }

  private get findable(): boolean {
    return this.el.hasAttribute("data-findable");
  }

  private get fadable(): boolean {
    return this.el.hasAttribute("data-fadable");
  }

  private get scrollable(): boolean {
    return (
      this.orientation === "horizontal" && (this.el.hasAttribute("data-scrollable") || this.fadable)
    );
  }

  private get orientation(): Orientation {
    return this.el.getAttribute("data-orientation") === "vertical" ? "vertical" : "horizontal";
  }

  private get activationMode(): ActivationMode {
    return this.el.getAttribute("data-activation") === "manual" ? "manual" : "automatic";
  }

  private get loop(): boolean {
    return this.el.getAttribute("data-loop") !== "false";
  }

  private get disabled(): boolean {
    return this.el.hasAttribute("data-disabled");
  }

  private directChild(part: string): HTMLElement | null {
    for (const child of Array.from(this.el.children)) {
      if (child instanceof HTMLElement && child.getAttribute("data-part") === part) {
        return child;
      }
    }

    return null;
  }

  private directDescendants(container: HTMLElement, part: string): HTMLElement[] {
    const result: HTMLElement[] = [];

    for (const child of Array.from(container.children)) {
      if (child instanceof HTMLElement && child.getAttribute("data-part") === part) {
        result.push(child);
      }
    }

    return result;
  }

  private get tablist(): HTMLElement | null {
    return this.directChild("tablist");
  }

  private get tabs(): HTMLElement[] {
    const tablist = this.tablist;
    if (!tablist) return [];

    // A composed trigger may carry a different `data-part`, so the trigger
    // marker, not the part hook, identifies tabs.
    return Array.from(tablist.children).filter(
      (child): child is HTMLElement =>
        child instanceof HTMLElement && child.hasAttribute("data-tabs-trigger"),
    );
  }

  private get panels(): HTMLElement[] {
    return this.directDescendants(this.el, "panel");
  }

  private tabValue(tab: HTMLElement): string | null {
    return tab.getAttribute("data-value");
  }

  private findTab(value: string): HTMLElement | null {
    return this.tabs.find((tab) => this.tabValue(tab) === value) ?? null;
  }

  private isDisabledTab(tab: HTMLElement): boolean {
    return this.disabled || tab.hasAttribute("disabled") || tab.hasAttribute("data-disabled");
  }

  private isLink(tab: HTMLElement): boolean {
    return tab.tagName === "A" && (tab.hasAttribute("href") || tab.hasAttribute("data-phx-link"));
  }

  private enabledTabs(): HTMLElement[] {
    return this.tabs.filter((tab) => !this.isDisabledTab(tab));
  }

  private defaultValue(): string | null {
    const tabs = this.tabs;
    const first = tabs.find((tab) => !this.isDisabledTab(tab)) ?? tabs[0];
    return first ? this.tabValue(first) : null;
  }

  private syncParts(): void {
    const tablist = this.tablist;

    if (this.boundTablist !== tablist) {
      if (this.boundTablist) {
        this.boundTablist.removeEventListener("click", this.handleClick);
        this.boundTablist.removeEventListener("keydown", this.handleKeydown);
        this.boundTablist.removeEventListener("scroll", this.handleScroll);
      }

      if (tablist) {
        tablist.addEventListener("click", this.handleClick);
        tablist.addEventListener("keydown", this.handleKeydown);
        tablist.addEventListener("scroll", this.handleScroll, { passive: true });
      }

      this.boundTablist = tablist;
      this.resizeObserver?.disconnect();
      if (tablist) this.resizeObserver?.observe(tablist);
    }

    this.syncPanels();
  }

  private syncPanels(): void {
    const panels = this.panels;

    for (const panel of this.boundPanels) {
      if (!panels.includes(panel)) {
        panel.removeEventListener("beforematch", this.handleBeforeMatch);
      }
    }

    for (const panel of panels) {
      panel.addEventListener("beforematch", this.handleBeforeMatch);
    }

    this.boundPanels = panels;
  }

  private syncDom(active: string | null, preserveFocus = false): void {
    const tabs = this.tabs;
    const focused = preserveFocus ? this.focusedTab() : null;
    let focusable: HTMLElement | null = null;

    for (const tab of tabs) {
      const selected = active !== null && this.tabValue(tab) === active;
      const disabled = this.isDisabledTab(tab);
      const tabindex = selected && !disabled ? "0" : "-1";

      this.js().setAttribute(tab, "aria-selected", selected ? "true" : "false");
      this.js().setAttribute(tab, "data-state", selected ? "active" : "inactive");
      this.js().setAttribute(tab, "tabindex", tabindex);

      if (tabindex === "0" && !focusable) focusable = tab;
    }

    // Keep the roving tab stop on the tab the user is focused on, even while
    // the selection is unchanged (manual activation).
    if (focused && !this.isDisabledTab(focused)) {
      for (const tab of tabs) {
        this.js().setAttribute(tab, "tabindex", tab === focused ? "0" : "-1");
      }
    } else if (!focusable) {
      const fallback = tabs.find((tab) => !this.isDisabledTab(tab));
      if (fallback) this.js().setAttribute(fallback, "tabindex", "0");
    }

    for (const panel of this.panels) {
      const selected = active !== null && panel.getAttribute("data-value") === active;
      this.js().setAttribute(panel, "data-state", selected ? "active" : "inactive");

      if (selected) {
        this.js().removeAttribute(panel, "hidden");
      } else {
        this.js().setAttribute(panel, "hidden", this.findable ? "until-found" : "");
      }
    }
  }

  private syncFade(): void {
    const tablist = this.tablist;
    if (!tablist) return;

    if (!this.fadable || this.orientation !== "horizontal") {
      this.js().removeAttribute(tablist, "data-fade-start");
      this.js().removeAttribute(tablist, "data-fade-end");
      return;
    }

    const max = tablist.scrollWidth - tablist.clientWidth;
    const start = tablist.scrollLeft > 1;
    const end = max > 1 && tablist.scrollLeft < max - 1;

    this.setRuntimeAttribute(tablist, "data-fade-start", start);
    this.setRuntimeAttribute(tablist, "data-fade-end", end);
  }

  private setRuntimeAttribute(element: HTMLElement, name: string, enabled: boolean): void {
    if (enabled) {
      this.js().setAttribute(element, name, "");
    } else {
      this.js().removeAttribute(element, name);
    }
  }

  private scrollTabIntoView(tab: HTMLElement | null): void {
    if (!tab || !this.scrollable) return;

    const tablist = this.tablist;
    if (!tablist) return;

    const listRect = tablist.getBoundingClientRect();
    const tabRect = tab.getBoundingClientRect();

    if (tabRect.left < listRect.left) {
      tablist.scrollLeft -= listRect.left - tabRect.left;
    } else if (tabRect.right > listRect.right) {
      tablist.scrollLeft += tabRect.right - listRect.right;
    }

    this.syncFade();
  }

  private beforeChange(tab: HTMLElement, value: string): boolean {
    return tab.dispatchEvent(
      new CustomEvent(Events.BeforeChange, {
        bubbles: true,
        cancelable: true,
        detail: { id: this.el.id, value, previous: this.currentValue },
      }),
    );
  }

  private activate(value: string): void {
    const previous = this.currentValue;
    if (value === previous) return;

    this.currentValue = value;
    this.syncDom(value);
    this.scrollTabIntoView(this.findTab(value));
    this.emitChange(value, previous);
    this.pushChange(value);
    this.syncFade();
  }

  private tryActivate(tab: HTMLElement): boolean {
    const value = this.tabValue(tab);
    if (!value || value === this.currentValue) return false;
    if (!this.beforeChange(tab, value)) return false;

    this.activate(value);
    return true;
  }

  private emitChange(value: string, previous: string | null): void {
    this.el.dispatchEvent(
      new CustomEvent(Events.Change, {
        bubbles: true,
        detail: { id: this.el.id, value, previous },
      }),
    );
  }

  private pushChange(value: string): void {
    const event = this.el.getAttribute("data-change-event");
    if (event) this.pushEvent(event, { id: this.el.id, value });
  }

  private focusedTab(): HTMLElement | null {
    const active = document.activeElement;
    if (!(active instanceof HTMLElement)) return null;

    const tab = active.closest<HTMLElement>("[data-tabs-trigger]");
    if (!tab || tab.parentElement !== this.boundTablist) return null;

    return tab;
  }

  private moveFocus(tab: HTMLElement): void {
    for (const other of this.tabs) {
      this.js().setAttribute(other, "tabindex", other === tab ? "0" : "-1");
    }

    tab.focus();
    this.scrollTabIntoView(tab);
    this.syncFade();
  }

  private moveBy(delta: number, from: HTMLElement | null): HTMLElement | null {
    const enabled = this.enabledTabs();
    if (enabled.length === 0) return null;

    const index = from ? enabled.indexOf(from) : -1;
    let nextIndex = index === -1 ? 0 : index + delta;

    if (nextIndex < 0) nextIndex = this.loop ? enabled.length - 1 : 0;
    if (nextIndex >= enabled.length) nextIndex = this.loop ? 0 : enabled.length - 1;

    return enabled[nextIndex] ?? null;
  }

  private handleBeforeMatch = (event: Event): void => {
    if (!this.findable) return;

    const panel = event.currentTarget;
    if (!(panel instanceof HTMLElement)) return;

    const value = panel.getAttribute("data-value");
    if (value && this.findTab(value)) this.activate(value);
  };

  private handleScroll = (): void => {
    this.syncFade();
  };

  private handleSelect = (event: Event): void => {
    if (event.target !== this.el) return;

    const value = (event as CustomEvent<{ value?: unknown }>).detail?.value;
    if (typeof value !== "string" || value === this.currentValue) return;

    const tab = this.findTab(value);
    if (!tab || this.isDisabledTab(tab)) return;

    if (this.isLink(tab)) {
      tab.click();
      return;
    }

    this.activate(value);
  };

  private handleClick = (event: MouseEvent): void => {
    if (event.defaultPrevented) return;

    const tablist = this.boundTablist;
    if (!tablist) return;

    const target = event.target;
    if (!(target instanceof Element)) return;

    const tab = target.closest<HTMLElement>("[data-tabs-trigger]");
    if (!tab || tab.parentElement !== tablist) return;

    if (this.isDisabledTab(tab)) {
      event.preventDefault();
      event.stopPropagation();
      return;
    }

    const link = this.isLink(tab);
    const modified =
      event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button !== 0;
    if (link && modified) return;

    // A link owns its navigation. The server patch or the navigation updates
    // the selection, so never change local state or push here.
    if (link) return;

    if (!this.tryActivate(tab)) {
      event.preventDefault();
      return;
    }

    tab.focus();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (this.disabled || event.defaultPrevented) return;

    const current = this.focusedTab();
    if (!current) return;

    const nextKey = this.orientation === "vertical" ? "ArrowDown" : "ArrowRight";
    const previousKey = this.orientation === "vertical" ? "ArrowUp" : "ArrowLeft";

    if (event.key === nextKey || event.key === previousKey) {
      event.preventDefault();

      const next = this.moveBy(event.key === nextKey ? 1 : -1, current);
      if (!next) return;

      this.moveFocus(next);
      if (this.activationMode === "automatic" && !this.isLink(next)) this.tryActivate(next);
      return;
    }

    if (event.key === "Home" || event.key === "End") {
      event.preventDefault();

      const enabled = this.enabledTabs();
      const next = event.key === "Home" ? enabled[0] : enabled[enabled.length - 1];
      if (!next) return;

      this.moveFocus(next);
      if (this.activationMode === "automatic" && !this.isLink(next)) this.tryActivate(next);
      return;
    }

    if (event.key !== "Enter" && event.key !== " ") return;
    if (this.isLink(current) || this.isDisabledTab(current)) return;

    // Handle activation explicitly so synthetic triggers behave like native
    // buttons. Preventing the key default also keeps the native button's
    // click from running the selection twice.
    event.preventDefault();
    this.tryActivate(current);
  };

  mounted(): void {
    super.mounted();

    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(() => this.syncFade());
    }

    this.lastServerValue = this.readServerValue();
    this.currentValue = this.lastServerValue;
    this.syncParts();
    this.el.addEventListener(Events.Select, this.handleSelect);

    if (!this.currentValue || !this.findTab(this.currentValue)) {
      this.currentValue = this.defaultValue();
    }

    this.syncDom(this.currentValue);
    if (this.currentValue) this.scrollTabIntoView(this.findTab(this.currentValue));
    this.syncFade();
  }

  updated(): void {
    this.syncParts();

    const next = this.readServerValue();
    const serverChanged = next !== this.lastServerValue;

    if (serverChanged) {
      this.lastServerValue = next;
      this.currentValue = next;
    }

    if (!this.currentValue || !this.findTab(this.currentValue)) {
      this.currentValue = this.defaultValue();
    }

    // A patch with an unchanged server value may be unrelated to the tabs;
    // keep the roving tab stop on the tab the user focused.
    this.syncDom(this.currentValue, !serverChanged);

    if (serverChanged && this.currentValue) {
      this.scrollTabIntoView(this.findTab(this.currentValue));
    }

    this.syncFade();
  }

  destroyed(): void {
    this.el.removeEventListener(Events.Select, this.handleSelect);
    this.boundTablist?.removeEventListener("click", this.handleClick);
    this.boundTablist?.removeEventListener("keydown", this.handleKeydown);
    this.boundTablist?.removeEventListener("scroll", this.handleScroll);

    for (const panel of this.boundPanels) {
      panel.removeEventListener("beforematch", this.handleBeforeMatch);
    }

    this.resizeObserver?.disconnect();
  }
}
