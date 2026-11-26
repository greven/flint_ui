import { afterEach, beforeEach, describe, expect, it, vi, type Mock } from "vitest";
import { createPositioner } from "../lib/position";
import { Navbar } from "./navbar";

vi.mock("../lib/position", () => ({ createPositioner: vi.fn() }));

const create = vi.mocked(createPositioner);

interface PositionerMock {
  start: Mock;
  stop: Mock;
  update: Mock;
  placement: Mock;
}

let positioners: PositionerMock[];

function makePositioner(): PositionerMock {
  const positioner = {
    start: vi.fn(() => Promise.resolve()),
    stop: vi.fn(),
    update: vi.fn(() => Promise.resolve()),
    placement: vi.fn(() => ({ side: "bottom", align: "start" })),
  };

  positioners.push(positioner);

  return positioner;
}

function popover(content: HTMLElement): { show: Mock; hide: Mock } {
  const show = vi.fn();
  const hide = vi.fn();

  Object.assign(content, { showPopover: show, hidePopover: hide });

  return { show, hide };
}

function setup(openMenus = 1) {
  document.body.innerHTML = `
    <nav id="navbar" data-element="navbar">
      <ul data-part="list">
        <li data-element="navbar_item">
          <a data-part="content" href="/">Home</a>
        </li>
        <li data-element="navbar_item" data-disabled>
          <span data-part="content" aria-disabled="true">Soon</span>
        </li>
        <li data-element="navbar_menu" data-state="closed">
          <button data-part="trigger" aria-expanded="false">Products</button>
          <div data-part="content" popover="manual" hidden>
            <ul data-part="list">
              <li data-element="navbar_menu_item">
                <a data-part="content">Products</a>
              </li>
            </ul>
          </div>
        </li>
        <li data-element="navbar_menu" data-state="closed" data-open-on-hover>
          <button data-part="trigger" aria-expanded="false">Company</button>
          <div data-part="content" popover="manual" hidden>
            <ul data-part="list">
              <li data-element="navbar_menu_item">
                <a data-part="content">About</a>
              </li>
            </ul>
          </div>
        </li>
      </ul>
    </nav>
  `;

  const el = document.getElementById("navbar") as HTMLElement;
  const menus = Array.from(el.querySelectorAll<HTMLElement>('[data-element="navbar_menu"]'));
  const view = { isDead: false, liveSocket: {} };

  for (const menu of menus) {
    const content = menu.querySelector<HTMLElement>('[data-part="content"]');
    if (content) popover(content);
  }

  const opening = menus.slice(menus.length - openMenus);

  for (const menu of opening) {
    menu.dataset.state = "open";
    menu.querySelector('[data-part="content"]')?.removeAttribute("hidden");
  }

  const hook = new Navbar(view as never, el);

  hook.mounted();

  return { el, hook, menus };
}

function menuAt(menus: HTMLElement[], index: number): HTMLElement {
  const menu = menus[index];

  if (!menu) throw new Error(`expected a menu at index ${index}`);

  return menu;
}

function countCloses(menu: HTMLElement) {
  const counter = { count: 0, events: [] as Event[] };

  menu.addEventListener("fl:collapsible:close", (event) => {
    counter.count += 1;
    counter.events.push(event);
  });

  return counter;
}

function pointerEvent(type: string, relatedTarget?: EventTarget | null): PointerEvent {
  const event = new PointerEvent(type, { bubbles: true, pointerType: "mouse" });

  if (relatedTarget !== undefined) {
    Object.defineProperty(event, "relatedTarget", { value: relatedTarget });
  }

  return event;
}

function openMenu(menu: HTMLElement): void {
  menu.dataset.state = "open";
  menu.querySelector('[data-part="trigger"]')?.setAttribute("aria-expanded", "true");
  menu.dispatchEvent(
    new CustomEvent("fl:collapsible:change", {
      bubbles: true,
      detail: { state: "open" },
    }),
  );
}

beforeEach(() => {
  positioners = [];
  create.mockImplementation(() => makePositioner());
});

afterEach(() => {
  document.body.innerHTML = "";
  positioners = [];
  vi.restoreAllMocks();
});

describe("Navbar", () => {
  it("closes the open menu on Escape and returns focus to its trigger", () => {
    const { el, menus } = setup(1);
    const products = menuAt(menus, 0);
    const company = menuAt(menus, 1);
    const closed = countCloses(company);
    const trigger = company.querySelector<HTMLElement>('[data-part="trigger"]')!;

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));

    expect(closed.count).toBe(1);
    expect(document.activeElement).toBe(trigger);
    expect(products.dataset.state).toBe("closed");
  });

  it("ignores Escape when no menu is open", () => {
    const { el, menus } = setup(0);
    const closed = countCloses(menuAt(menus, 0));

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "Escape", bubbles: true }));

    expect(closed.count).toBe(0);
  });

  it("closes every open menu when the pointer goes outside the navbar", () => {
    const { menus } = setup(2);
    const first = countCloses(menuAt(menus, 0));
    const second = countCloses(menuAt(menus, 1));

    document.body.dispatchEvent(new Event("pointerdown", { bubbles: true }));

    expect(first.count).toBe(1);
    expect(second.count).toBe(1);
  });

  it("keeps a menu open when the pointer goes inside it", () => {
    const { menus } = setup(1);
    const company = menuAt(menus, 1);
    const closed = countCloses(company);
    const content = company.querySelector<HTMLElement>('[data-part="content"]')!;

    content.dispatchEvent(new Event("pointerdown", { bubbles: true }));

    expect(closed.count).toBe(0);
  });

  it("keeps only one menu open when another menu opens", () => {
    const { menus } = setup(2);
    const products = menuAt(menus, 0);
    const company = menuAt(menus, 1);
    const firstClosed = countCloses(products);
    const secondClosed = countCloses(company);

    company.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "open" },
      }),
    );

    expect(firstClosed.count).toBe(1);
    expect(secondClosed.count).toBe(0);
  });

  it("closes a menu when a link inside it is activated", () => {
    const { menus } = setup(1);
    const company = menuAt(menus, 1);
    const closed = countCloses(company);
    const link = company.querySelector<HTMLElement>('[data-element="navbar_menu_item"] a')!;

    link.addEventListener("click", (event) => event.preventDefault());
    link.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(closed.count).toBe(1);
  });

  it("closes open menus when a page navigation starts", () => {
    const { menus } = setup(2);
    const first = countCloses(menuAt(menus, 0));
    const second = countCloses(menuAt(menus, 1));

    document.dispatchEvent(new Event("phx:page-loading-start"));

    expect(first.count).toBe(1);
    expect(second.count).toBe(1);
  });

  it("shows an open menu in the top layer and positions it beneath the trigger", () => {
    const { menus } = setup(0);
    const menu = menuAt(menus, 0);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const content = menu.querySelector<HTMLElement>('[data-part="content"]')!;
    const show = content.showPopover as Mock;

    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "open" },
      }),
    );

    expect(show).toHaveBeenCalledTimes(1);
    expect(create).toHaveBeenCalledWith(trigger, content, {
      placement: "bottom",
      align: "center",
      offset: 4,
    });
    expect(positioners[0]?.start).toHaveBeenCalled();
  });

  it("reads the menu offset from the public CSS variable", () => {
    const { menus } = setup(0);
    const menu = menuAt(menus, 0);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const content = menu.querySelector<HTMLElement>('[data-part="content"]')!;

    content.style.setProperty("--fl-navbar-menu-offset", "0.5rem");

    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "open" },
      }),
    );

    expect(create).toHaveBeenCalledWith(trigger, content, {
      placement: "bottom",
      align: "center",
      offset: 8,
    });
  });

  it("aligns the panel to the menu position", () => {
    const { menus } = setup(0);
    const menu = menuAt(menus, 0);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const content = menu.querySelector<HTMLElement>('[data-part="content"]')!;

    menu.setAttribute("data-position", "end");
    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "open" },
      }),
    );

    expect(create).toHaveBeenCalledWith(trigger, content, {
      placement: "bottom",
      align: "end",
      offset: 4,
    });
  });

  it("repositions an open menu when its position changes", () => {
    const { hook, menus } = setup(0);
    const menu = menuAt(menus, 0);

    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "open" },
      }),
    );

    expect(create).toHaveBeenCalledTimes(1);

    menu.dataset.state = "open";
    menu.setAttribute("data-position", "start");
    hook.updated();

    expect(create).toHaveBeenCalledTimes(2);
    expect(positioners[0]?.stop).toHaveBeenCalled();
    expect(vi.mocked(create).mock.calls.at(-1)?.[2]).toMatchObject({ align: "start" });
  });

  it("opens a server-rendered menu in the top layer on mount", () => {
    const { menus } = setup(1);
    const content = menuAt(menus, 1).querySelector<HTMLElement>('[data-part="content"]')!;

    expect(content.showPopover as Mock).toHaveBeenCalledTimes(1);
    expect(positioners).toHaveLength(1);
    expect(positioners[0]?.start).toHaveBeenCalled();
  });

  it("hides the top-layer panel after the close animation", async () => {
    const { menus } = setup(1);
    const menu = menuAt(menus, 1);
    const content = menu.querySelector<HTMLElement>('[data-part="content"]')!;
    const hide = content.hidePopover as Mock;

    menu.dataset.state = "closed";
    menu.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "closed" },
      }),
    );

    await new Promise((resolve) => setTimeout(resolve, 50));

    expect(hide).toHaveBeenCalledTimes(1);
    expect(positioners[0]?.stop).toHaveBeenCalled();
  });

  it("moves focus across top-level controls and wraps when loop is on", () => {
    const { el } = setup(0);
    const home = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;
    const triggers = Array.from(
      el.querySelectorAll<HTMLElement>('[data-element="navbar_menu"] > [data-part="trigger"]'),
    );

    home.focus();

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }));
    expect(document.activeElement).toBe(triggers[0]);

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }));
    expect(document.activeElement).toBe(triggers[1]);

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }));
    expect(document.activeElement).toBe(home);

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowLeft", bubbles: true }));
    expect(document.activeElement).toBe(triggers[1]);
  });

  it("stops at the ends when loop is off", () => {
    const { el } = setup(0);
    el.setAttribute("data-loop", "false");

    const home = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;
    const triggers = Array.from(
      el.querySelectorAll<HTMLElement>('[data-element="navbar_menu"] > [data-part="trigger"]'),
    );

    home.focus();
    el.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowLeft", bubbles: true }));
    expect(document.activeElement).toBe(home);

    triggers[1]?.focus();
    el.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }));
    expect(document.activeElement).toBe(triggers[1]);
  });

  it("moves to the first and last control with Home and End", () => {
    const { el } = setup(0);
    const home = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;
    const triggers = Array.from(
      el.querySelectorAll<HTMLElement>('[data-element="navbar_menu"] > [data-part="trigger"]'),
    );

    triggers[1]?.focus();

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "Home", bubbles: true }));
    expect(document.activeElement).toBe(home);

    el.dispatchEvent(new KeyboardEvent("keydown", { key: "End", bubbles: true }));
    expect(document.activeElement).toBe(triggers[1]);
  });

  it("closes open menus when the navbar becomes disabled", () => {
    const { el, hook, menus } = setup(1);
    const closed = countCloses(menuAt(menus, 1));

    el.setAttribute("data-disabled", "");
    hook.updated();

    expect(closed.count).toBe(1);
  });

  it("keeps the menu open when a disabled item is clicked", () => {
    const { menus } = setup(1);
    const menu = menuAt(menus, 1);
    const closed = countCloses(menu);
    const item = menu.querySelector<HTMLElement>('[data-element="navbar_menu_item"]')!;
    const link = item.querySelector<HTMLElement>("a")!;

    item.setAttribute("data-disabled", "");
    link.addEventListener("click", (event) => event.preventDefault());
    link.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(closed.count).toBe(0);
  });

  it("publishes fade cues for a fadable list", () => {
    const { el, hook } = setup(0);
    el.setAttribute("data-fadable", "");

    const list = el.querySelector<HTMLElement>(':scope > [data-part="list"]')!;
    Object.defineProperty(list, "scrollWidth", { configurable: true, value: 300 });
    Object.defineProperty(list, "clientWidth", { configurable: true, value: 100 });
    Object.defineProperty(list, "scrollLeft", {
      configurable: true,
      writable: true,
      value: 0,
    });

    hook.updated();

    expect(list.hasAttribute("data-fade-start")).toBe(false);
    expect(list.hasAttribute("data-fade-end")).toBe(true);

    list.scrollLeft = 100;
    list.dispatchEvent(new Event("scroll"));

    expect(list.hasAttribute("data-fade-start")).toBe(true);
    expect(list.hasAttribute("data-fade-end")).toBe(true);

    list.scrollLeft = 250;
    list.dispatchEvent(new Event("scroll"));

    expect(list.hasAttribute("data-fade-start")).toBe(true);
    expect(list.hasAttribute("data-fade-end")).toBe(false);
  });

  it("removes fade cues when the list is not fadable", () => {
    const { el, hook } = setup(0);

    const list = el.querySelector<HTMLElement>(':scope > [data-part="list"]')!;
    list.setAttribute("data-fade-start", "");
    list.setAttribute("data-fade-end", "");

    hook.updated();

    expect(list.hasAttribute("data-fade-start")).toBe(false);
    expect(list.hasAttribute("data-fade-end")).toBe(false);
  });

  it("opens a menu when its trigger is hovered", () => {
    const { menus } = setup(0);
    const menu = menuAt(menus, 1);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const opened = vi.fn();

    menu.addEventListener("fl:collapsible:open", opened);
    trigger.dispatchEvent(pointerEvent("pointerover"));

    expect(opened).toHaveBeenCalledTimes(1);
  });

  it("does not open a menu on hover without data-open-on-hover", () => {
    const { menus } = setup(0);
    const menu = menuAt(menus, 0);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const opened = vi.fn();

    menu.addEventListener("fl:collapsible:open", opened);
    trigger.dispatchEvent(pointerEvent("pointerover"));

    expect(opened).not.toHaveBeenCalled();
  });

  it("closes a hover-opened menu after the pointer leaves", async () => {
    const { el, menus } = setup(0);
    const menu = menuAt(menus, 1);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const outside = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;

    trigger.dispatchEvent(pointerEvent("pointerover"));
    openMenu(menu);
    const closed = countCloses(menu);

    trigger.dispatchEvent(pointerEvent("pointerout", outside));
    await new Promise((resolve) => setTimeout(resolve, 250));

    expect(closed.count).toBe(1);
  });

  it("keeps a hover-opened menu open while the pointer moves into its panel", async () => {
    const { el, menus } = setup(0);
    const menu = menuAt(menus, 1);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const content = menu.querySelector<HTMLElement>('[data-part="content"]')!;
    const outside = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;

    trigger.dispatchEvent(pointerEvent("pointerover"));
    openMenu(menu);
    const closed = countCloses(menu);

    trigger.dispatchEvent(pointerEvent("pointerout", outside));
    await new Promise((resolve) => setTimeout(resolve, 50));
    content.dispatchEvent(pointerEvent("pointerover", outside));
    await new Promise((resolve) => setTimeout(resolve, 250));

    expect(closed.count).toBe(0);
  });

  it("pins a hover-opened menu open when its trigger is clicked", async () => {
    const { el, menus } = setup(0);
    const menu = menuAt(menus, 1);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const outside = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;

    trigger.dispatchEvent(pointerEvent("pointerover"));
    openMenu(menu);
    const closed = countCloses(menu);

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    trigger.dispatchEvent(pointerEvent("pointerout", outside));
    await new Promise((resolve) => setTimeout(resolve, 250));

    expect(closed.count).toBe(0);
  });

  it("pins a hover-opened menu open when it receives focus", async () => {
    const { el, menus } = setup(0);
    const menu = menuAt(menus, 1);
    const trigger = menu.querySelector<HTMLElement>('[data-part="trigger"]')!;
    const outside = el.querySelector<HTMLElement>('[data-element="navbar_item"] a')!;

    trigger.dispatchEvent(pointerEvent("pointerover"));
    openMenu(menu);
    const closed = countCloses(menu);

    trigger.focus();
    trigger.dispatchEvent(pointerEvent("pointerout", outside));
    await new Promise((resolve) => setTimeout(resolve, 250));

    expect(closed.count).toBe(0);
  });
});
