import { afterEach, beforeEach, describe, expect, it, vi, type Mock } from "vitest";
import { createPositioner } from "../lib/position";
import { Dropdown } from "./dropdown";

vi.mock("../lib/position", () => ({ createPositioner: vi.fn() }));

const create = vi.mocked(createPositioner);

interface SetupOptions {
  openOnHover?: boolean;
  openDelay?: number;
  closeDelay?: number;
  arrow?: boolean;
}

interface PositionerMock {
  start: Mock;
  stop: Mock;
}

let positioners: PositionerMock[];

const mounted: Dropdown[] = [];

function makePositioner(start?: Mock): PositionerMock {
  const positioner = {
    start: start ?? vi.fn(() => Promise.resolve()),
    stop: vi.fn(),
  };

  positioners.push(positioner);

  return positioner;
}

function setup(options: SetupOptions = {}) {
  const { openOnHover = false, openDelay = 0, closeDelay = 0, arrow = true } = options;

  document.body.innerHTML = `
    <div id="app">
      <div
        id="menu"
        data-element="dropdown"
        data-part="root"
        data-placement="bottom"
        data-align="start"
        data-offset="4"
        data-state="closed"
        data-open-delay="${openDelay}"
        data-close-delay="${closeDelay}"
        ${openOnHover ? "data-open-on-hover" : ""}
      >
        <button id="menu-trigger" data-part="trigger" aria-haspopup="menu" aria-expanded="false">
          Actions
          <span data-part="indicator"></span>
        </button>
        <div
          id="menu-content"
          data-part="content"
          data-dropdown-content
          role="menu"
          tabindex="-1"
          popover="manual"
          data-state="closed"
        >
          ${arrow ? '<span data-part="arrow"></span>' : ""}
          <div data-element="dropdown_heading" data-part="heading" role="presentation">Account</div>
          <button
            id="settings"
            data-element="dropdown_item"
            data-part="item"
            data-intent="neutral"
            role="menuitem"
            tabindex="-1"
          >
            Settings
          </button>
          <button
            id="referrals"
            data-element="dropdown_item"
            data-part="item"
            data-intent="neutral"
            role="menuitem"
            tabindex="-1"
            disabled
            data-disabled
          >
            Referrals
          </button>
          <div id="custom" data-element="dropdown_item" data-part="item" data-custom>
            <label>Signed in as ada@example.com</label>
            <input id="custom-input" type="text" />
          </div>
          <button
            id="logout"
            data-element="dropdown_item"
            data-part="item"
            data-intent="error"
            role="menuitem"
            tabindex="-1"
          >
            Log out
          </button>
          <button
            id="more-trigger"
            data-element="dropdown_sub"
            data-part="submenu-trigger"
            data-menu="more"
            role="menuitem"
            aria-haspopup="menu"
            aria-expanded="false"
            aria-controls="more"
            tabindex="-1"
          >
            More
            <span data-part="submenu-indicator"></span>
          </button>
        </div>
        <div
          id="more"
          data-part="submenu"
          data-dropdown-submenu
          role="menu"
          tabindex="-1"
          popover="manual"
          data-state="closed"
        >
          <button
            id="docs"
            data-element="dropdown_item"
            data-part="item"
            data-intent="neutral"
            role="menuitem"
            tabindex="-1"
          >
            Documentation
          </button>
        </div>
      </div>
    </div>
    <div id="outside">Outside</div>
  `;

  const el = document.getElementById("menu") as HTMLElement;
  const trigger = document.getElementById("menu-trigger") as HTMLElement;
  const content = document.getElementById("menu-content") as HTMLElement;
  const submenu = document.getElementById("more") as HTMLElement;

  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: vi.fn() } },
  };

  const hook = new Dropdown(view as never, el);

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  hook.mounted();

  mounted.push(hook);

  return { el, trigger, content, submenu, hook, js };
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 20));

function click(element: HTMLElement, detail = 1) {
  element.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true, detail }));
}

function key(element: EventTarget, key: string, options: KeyboardEventInit = {}) {
  element.dispatchEvent(
    new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true, ...options }),
  );
}

function pointer(
  element: HTMLElement,
  type: "pointerover" | "pointerout",
  options: { pointerType?: string; relatedTarget?: EventTarget | null } = {},
) {
  const event = new MouseEvent(type, { relatedTarget: options.relatedTarget ?? null });
  if (options.pointerType) {
    Object.defineProperty(event, "pointerType", { value: options.pointerType });
  }
  element.dispatchEvent(event);
}

function outsidePointerDown(element: HTMLElement = document.getElementById("outside")!) {
  element.dispatchEvent(new MouseEvent("pointerdown", { bubbles: true, cancelable: true }));
}

beforeEach(() => {
  positioners = [];
  create.mockReset();
  create.mockImplementation(() => makePositioner() as never);
});

afterEach(() => {
  mounted.splice(0).forEach((hook) => hook.destroyed());
  document.body.innerHTML = "";
  vi.useRealTimers();
  vi.restoreAllMocks();
});

describe("Dropdown hook", () => {
  it("wires the trigger and names the menu from it", () => {
    const { trigger, content } = setup();

    expect(trigger.getAttribute("data-state")).toBe("closed");
    expect(trigger.getAttribute("aria-haspopup")).toBe("menu");
    expect(trigger.getAttribute("aria-expanded")).toBe("false");
    expect(trigger.getAttribute("aria-controls")).toBe(content.id);
    expect(content.getAttribute("aria-labelledby")).toBe(trigger.id);
    expect(content.getAttribute("role")).toBe("menu");
  });

  it("opens on click, positions the menu, and focuses the first item", async () => {
    const { trigger, content } = setup();
    const settings = document.getElementById("settings") as HTMLElement;

    click(trigger);
    await flush();

    expect(content.dataset.state).toBe("open");
    expect(content.dataset.popover).toBe("open");
    expect(trigger.getAttribute("aria-expanded")).toBe("true");
    expect(document.activeElement).toBe(settings);
    expect(settings.getAttribute("tabindex")).toBe("0");
    expect(settings.hasAttribute("data-active")).toBe(true);

    expect(create).toHaveBeenCalledWith(
      trigger,
      content,
      expect.objectContaining({
        placement: "bottom",
        align: "start",
        offset: 4,
        arrowVarPrefix: "dropdown",
      }),
    );
  });

  it("closes on a second trigger click and returns focus to the trigger", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    click(trigger);
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(trigger);
  });

  it("opens with ArrowDown and ArrowUp and focuses the first or last item", async () => {
    const first = setup();
    key(first.trigger, "ArrowDown");
    await flush();

    expect(first.content.dataset.state).toBe("open");
    expect(document.activeElement).toBe(document.getElementById("settings"));

    mounted.splice(0).forEach((hook) => hook.destroyed());
    document.body.innerHTML = "";

    const last = setup();
    key(last.trigger, "ArrowUp");
    await flush();

    expect(last.content.dataset.state).toBe("open");
    expect(document.activeElement).toBe(document.getElementById("more-trigger"));
  });

  it("moves through enabled items, skipping disabled ones and wrapping", async () => {
    setup();
    const trigger = document.getElementById("menu-trigger") as HTMLElement;
    const settings = document.getElementById("settings") as HTMLElement;
    const logout = document.getElementById("logout") as HTMLElement;
    const more = document.getElementById("more-trigger") as HTMLElement;

    click(trigger);
    await flush();

    key(settings, "ArrowDown");
    expect(document.activeElement).toBe(logout);

    key(logout, "ArrowDown");
    expect(document.activeElement).toBe(more);

    key(more, "ArrowDown");
    expect(document.activeElement).toBe(settings);

    key(settings, "ArrowUp");
    expect(document.activeElement).toBe(more);

    key(more, "Home");
    expect(document.activeElement).toBe(settings);

    key(settings, "End");
    expect(document.activeElement).toBe(more);
  });

  it("closes on Escape and returns focus to the trigger", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    key(document, "Escape");
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(trigger);
  });

  it("closes on an outside pointer down", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    outsidePointerDown();

    expect(content.dataset.state).toBe("closed");
  });

  it("closes on Tab and lets focus leave", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    key(document, "Tab");

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(document.getElementById("settings"));
  });

  it("closes when an item is selected", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    click(document.getElementById("logout") as HTMLElement);
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(trigger);
  });

  it("keeps the menu open when a custom content block is clicked", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    click(document.getElementById("custom") as HTMLElement);

    expect(content.dataset.state).toBe("open");
  });

  it("does not hijack arrow keys inside custom content", async () => {
    const { trigger, content } = setup();
    const input = document.getElementById("custom-input") as HTMLInputElement;

    click(trigger);
    await flush();
    input.focus();
    key(input, "ArrowDown");

    expect(content.dataset.state).toBe("open");
    expect(document.activeElement).toBe(input);
  });

  it("opens and closes on hover after the configured delays", async () => {
    vi.useFakeTimers();
    const { content } = setup({ openOnHover: true, openDelay: 200, closeDelay: 100 });
    const el = document.getElementById("menu") as HTMLElement;

    pointer(el, "pointerover");
    await vi.advanceTimersByTimeAsync(199);
    expect(content.dataset.state).toBe("closed");

    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("open");

    pointer(el, "pointerout");
    await vi.advanceTimersByTimeAsync(99);
    expect(content.dataset.state).toBe("open");

    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("closed");
  });

  it("keeps a hover-opened menu open when the pointer moves inside it", async () => {
    vi.useFakeTimers();
    const { content } = setup({ openOnHover: true, openDelay: 0, closeDelay: 100 });
    const el = document.getElementById("menu") as HTMLElement;

    pointer(el, "pointerover");
    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("open");

    pointer(document.getElementById("settings") as HTMLElement, "pointerout", {
      relatedTarget: content,
    });
    await vi.advanceTimersByTimeAsync(200);

    expect(content.dataset.state).toBe("open");
  });

  it("ignores non-mouse hover pointers", async () => {
    vi.useFakeTimers();
    const { content } = setup({ openOnHover: true });
    const el = document.getElementById("menu") as HTMLElement;

    pointer(el, "pointerover", { pointerType: "touch" });
    await vi.advanceTimersByTimeAsync(1);

    expect(content.dataset.state).toBe("closed");
  });

  it("opens a submenu and closes it back to its trigger", async () => {
    const { trigger, submenu } = setup();
    const more = document.getElementById("more-trigger") as HTMLElement;
    const docs = document.getElementById("docs") as HTMLElement;

    click(trigger);
    await flush();
    click(more);
    await flush();

    expect(submenu.dataset.state).toBe("open");
    expect(more.getAttribute("aria-expanded")).toBe("true");
    expect(document.activeElement).toBe(docs);
    expect(create).toHaveBeenLastCalledWith(
      more,
      submenu,
      expect.objectContaining({ placement: "right", align: "start", offset: 2 }),
    );

    key(docs, "ArrowLeft");
    await flush();

    expect(submenu.dataset.state).toBe("closed");
    expect(more.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(more);
  });

  it("opens a submenu with ArrowRight", async () => {
    const { trigger, submenu } = setup();
    const more = document.getElementById("more-trigger") as HTMLElement;

    click(trigger);
    await flush();
    more.focus();
    key(more, "ArrowRight");
    await flush();

    expect(submenu.dataset.state).toBe("open");
    expect(document.activeElement).toBe(document.getElementById("docs"));
  });

  it("keeps a reopened submenu open while its leave animation is pending", async () => {
    const { trigger, submenu } = setup();
    const more = document.getElementById("more-trigger") as HTMLElement;
    const docs = document.getElementById("docs") as HTMLElement;

    click(trigger);
    await flush();
    click(more);
    await flush();
    key(docs, "ArrowLeft");

    click(more);
    await flush();

    expect(submenu.dataset.state).toBe("open");
    expect(more.getAttribute("aria-expanded")).toBe("true");
  });

  it("closes the submenu before the menu on Escape", async () => {
    const { trigger, content, submenu } = setup();

    click(trigger);
    await flush();
    click(document.getElementById("more-trigger") as HTMLElement);
    await flush();

    key(document, "Escape");
    await flush();

    expect(submenu.dataset.state).toBe("closed");
    expect(content.dataset.state).toBe("open");
    expect(document.activeElement).toBe(document.getElementById("more-trigger"));

    key(document, "Escape");
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(trigger);
  });

  it("closes the menu and all submenus on an outside pointer down", async () => {
    const { trigger, content, submenu } = setup();

    click(trigger);
    await flush();
    click(document.getElementById("more-trigger") as HTMLElement);
    await flush();
    outsidePointerDown();

    expect(submenu.dataset.state).toBe("closed");
    expect(content.dataset.state).toBe("closed");
  });

  it("opens from the open command and closes from the close command", async () => {
    const { el, trigger, content } = setup();

    el.dispatchEvent(new CustomEvent("fl:dropdown:open", { bubbles: true }));
    await flush();

    expect(content.dataset.state).toBe("open");
    expect(document.activeElement).toBe(document.getElementById("settings"));

    el.dispatchEvent(new CustomEvent("fl:dropdown:close", { bubbles: true }));
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(trigger);
  });

  it("emits a change event when the menu opens and closes", async () => {
    const { el, trigger } = setup();
    const changes: string[] = [];

    el.addEventListener("fl:dropdown:change", (event) => {
      changes.push((event as CustomEvent<{ state: string }>).detail.state);
    });

    click(trigger);
    await flush();
    key(document, "Escape");
    await flush();

    expect(changes).toEqual(["open", "closed"]);
  });

  it("reopens with replacement content while open", async () => {
    const { trigger, hook, content } = setup();

    click(trigger);
    await flush();
    expect(create).toHaveBeenCalledTimes(1);

    const replacement = document.createElement("div");
    replacement.id = content.id;
    replacement.setAttribute("data-part", "content");
    replacement.setAttribute("data-dropdown-content", "");
    replacement.setAttribute("role", "menu");
    replacement.setAttribute("popover", "manual");
    replacement.setAttribute("data-state", "closed");
    replacement.innerHTML =
      '<button id="inside-2" data-element="dropdown_item" role="menuitem" tabindex="-1">Inside</button>';
    content.replaceWith(replacement);

    hook.updated();
    await flush();

    expect(create).toHaveBeenCalledTimes(2);
    expect(replacement.dataset.state).toBe("open");
  });
});
