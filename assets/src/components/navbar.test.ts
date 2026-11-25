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
        <li data-element="navbar_menu" data-state="closed">
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
      align: "start",
      offset: 4,
    });
    expect(positioners[0]?.start).toHaveBeenCalled();
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
});
