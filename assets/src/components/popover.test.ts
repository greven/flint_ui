import { afterEach, beforeEach, describe, expect, it, vi, type Mock } from "vitest";
import { createPositioner } from "../lib/position";
import { Popover } from "./popover";

vi.mock("../lib/position", () => ({ createPositioner: vi.fn() }));

const create = vi.mocked(createPositioner);

interface SetupOptions {
  opened?: boolean;
  dismissible?: boolean;
  openOnHover?: boolean;
  openDelay?: number;
  closeDelay?: number;
  portal?: boolean;
  arrow?: boolean;
  openEvent?: string;
  closeEvent?: string;
  toggleEvent?: string;
}

interface PositionerMock {
  start: Mock;
  stop: Mock;
}

let positioner: PositionerMock;

const mounted: Popover[] = [];

function makePositioner(start?: Mock): PositionerMock {
  positioner = {
    start: start ?? vi.fn(() => Promise.resolve()),
    stop: vi.fn(),
  };

  return positioner;
}

function setup(options: SetupOptions = {}) {
  const {
    opened = false,
    dismissible = true,
    openOnHover = false,
    openDelay = 0,
    closeDelay = 0,
    portal = false,
    arrow = true,
    openEvent,
    closeEvent,
    toggleEvent,
  } = options;

  document.body.innerHTML = `
    <div id="app">
      <div
        id="pop"
        data-element="popover"
        data-part="root"
        data-placement="bottom"
        data-align="center"
        data-offset="8"
        data-opened="${opened}"
        data-state="${opened ? "open" : "closed"}"
        data-open-delay="${openDelay}"
        data-close-delay="${closeDelay}"
        ${dismissible ? "data-dismissible" : ""}
        ${openOnHover ? "data-open-on-hover" : ""}
        ${openEvent ? `data-open-event="${openEvent}"` : ""}
        ${closeEvent ? `data-close-event="${closeEvent}"` : ""}
        ${toggleEvent ? `data-toggle-event="${toggleEvent}"` : ""}
      >
        <button>Open</button>
        <div
          id="pop-content"
          data-part="content"
          data-popover-content
          role="dialog"
          tabindex="-1"
          popover="manual"
          data-state="closed"
        >
          ${arrow ? '<span data-part="arrow"></span>' : ""}
          <button id="inside">Inside</button>
          <a id="link" href="#">Link</a>
        </div>
      </div>
    </div>
    <div id="outside">Outside</div>
  `;

  const el = document.getElementById("pop") as HTMLElement;
  const content = el.querySelector<HTMLElement>('[data-part="content"]')!;

  if (portal) {
    content.remove();
    document.body.appendChild(content);
  }

  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: vi.fn() } },
  };

  const hook = new Popover(view as never, el);

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  hook.mounted();

  mounted.push(hook);

  const trigger = el.querySelector<HTMLElement>('[data-part="trigger"]')!;

  return {
    el,
    trigger,
    content,
    arrowElement: content.querySelector<HTMLElement>('[data-part="arrow"]'),
    hook,
    js,
    view,
  };
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 20));

function pointer(
  element: HTMLElement,
  type: "pointerenter" | "pointerleave",
  options: { pointerType?: string; relatedTarget?: EventTarget | null } = {},
) {
  const event = new MouseEvent(type, { relatedTarget: options.relatedTarget ?? null });
  if (options.pointerType) {
    Object.defineProperty(event, "pointerType", { value: options.pointerType });
  }
  element.dispatchEvent(event);
}

function click(element: HTMLElement, detail = 1) {
  element.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true, detail }));
}

function outsidePointerDown(element: HTMLElement = document.getElementById("outside")!) {
  element.dispatchEvent(new MouseEvent("pointerdown", { bubbles: true, cancelable: true }));
}

function key(key: string, options: KeyboardEventInit = {}) {
  document.dispatchEvent(
    new KeyboardEvent("keydown", { key, bubbles: true, cancelable: true, ...options }),
  );
}

beforeEach(() => {
  create.mockReset();
  create.mockImplementation(() => makePositioner() as never);
});

afterEach(() => {
  mounted.splice(0).forEach((hook) => hook.destroyed());
  document.body.innerHTML = "";
  vi.useRealTimers();
  vi.restoreAllMocks();
});

describe("Popover hook", () => {
  it("wires the trigger and names the dialog from it", () => {
    const { el, trigger, content } = setup();

    expect(trigger.getAttribute("data-part")).toBe("trigger");
    expect(trigger.getAttribute("data-state")).toBe("closed");
    expect(trigger.getAttribute("aria-haspopup")).toBe("dialog");
    expect(trigger.getAttribute("aria-expanded")).toBe("false");
    expect(trigger.getAttribute("aria-controls")).toBe(content.id);
    expect(trigger.id).toBe(`${el.id}-trigger`);
    expect(content.getAttribute("aria-labelledby")).toBe(trigger.id);
  });

  it("keeps an author-provided accessible name", () => {
    const { content } = setup();

    content.setAttribute("aria-label", "Account");
    // Re-run the sync the way a patch would.
    const hook = mounted[mounted.length - 1]!;
    hook.updated();

    expect(content.getAttribute("aria-label")).toBe("Account");
    expect(content.getAttribute("aria-labelledby")).toBeNull();
  });

  it("opens on click, positions the content, and focuses into it", async () => {
    const { trigger, content, arrowElement } = setup();

    click(trigger);
    await flush();

    expect(content.dataset.state).toBe("open");
    expect(content.dataset.popover).toBe("open");
    expect(trigger.getAttribute("aria-expanded")).toBe("true");
    expect(document.activeElement).toBe(document.getElementById("inside"));

    expect(create).toHaveBeenCalledWith(
      trigger,
      content,
      expect.objectContaining({
        placement: "bottom",
        align: "center",
        offset: 8,
        arrow: arrowElement,
        arrowVarPrefix: "popover",
      }),
    );
  });

  it("adds the stylesheet's arrow gap to the offset when an arrow is rendered", async () => {
    const { el, trigger, content } = setup();
    el.style.setProperty("--fl-popover-arrow-gap", "4px");

    click(trigger);
    await flush();

    expect(create).toHaveBeenLastCalledWith(
      trigger,
      content,
      expect.objectContaining({ offset: 12 }),
    );
  });

  it("ignores the arrow gap without an arrow", async () => {
    const { el, trigger, content } = setup({ arrow: false });
    el.style.setProperty("--fl-popover-arrow-gap", "4px");

    click(trigger);
    await flush();

    expect(create).toHaveBeenLastCalledWith(
      trigger,
      content,
      expect.objectContaining({ offset: 8 }),
    );
  });

  it("closes on a second click and returns focus to the trigger", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    click(trigger);
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(content.dataset.popover).toBeUndefined();
    expect(document.activeElement).toBe(trigger);
  });

  it("opens immediately on click even when hover delays are set", async () => {
    const { trigger, content } = setup({ openOnHover: true, openDelay: 500 });

    click(trigger);
    await flush();

    expect(content.dataset.state).toBe("open");
    expect(create).toHaveBeenCalledTimes(1);
  });

  it("opens on hover after the open delay and closes after the close delay", async () => {
    vi.useFakeTimers();
    const { trigger, content } = setup({
      openOnHover: true,
      openDelay: 200,
      closeDelay: 100,
    });

    pointer(trigger, "pointerenter");
    await vi.advanceTimersByTimeAsync(199);
    expect(content.dataset.state).toBe("closed");

    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("open");

    pointer(trigger, "pointerleave");
    await vi.advanceTimersByTimeAsync(99);
    expect(content.dataset.state).toBe("open");

    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("closed");
  });

  it("cancels a pending hover open when the pointer leaves first", async () => {
    vi.useFakeTimers();
    const { trigger, content } = setup({ openOnHover: true, openDelay: 200 });

    pointer(trigger, "pointerenter");
    await vi.advanceTimersByTimeAsync(100);
    pointer(trigger, "pointerleave");
    await vi.advanceTimersByTimeAsync(300);

    expect(content.dataset.state).toBe("closed");
    expect(create).not.toHaveBeenCalled();
  });

  it("keeps a hover popover open while the pointer moves into the content", async () => {
    vi.useFakeTimers();
    const { trigger, content } = setup({
      openOnHover: true,
      openDelay: 0,
      closeDelay: 100,
    });

    pointer(trigger, "pointerenter");
    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("open");

    pointer(trigger, "pointerleave", { relatedTarget: content });
    await vi.advanceTimersByTimeAsync(200);

    expect(content.dataset.state).toBe("open");
  });

  it("pins a hover-opened popover on click and focuses the content", async () => {
    vi.useFakeTimers();
    const { trigger, content } = setup({ openOnHover: true });

    pointer(trigger, "pointerenter");
    await vi.advanceTimersByTimeAsync(1);
    expect(content.dataset.state).toBe("open");

    click(trigger);
    expect(content.dataset.state).toBe("open");
    expect(document.activeElement).toBe(document.getElementById("inside"));
  });

  it("ignores non-mouse hover pointers", async () => {
    vi.useFakeTimers();
    const { trigger, content } = setup({ openOnHover: true });

    pointer(trigger, "pointerenter", { pointerType: "touch" });
    await vi.advanceTimersByTimeAsync(1);

    expect(content.dataset.state).toBe("closed");
  });

  it("closes on an outside pointer down", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    outsidePointerDown();

    expect(content.dataset.state).toBe("closed");
  });

  it("closes on Escape and returns focus to the trigger", async () => {
    const { trigger, content } = setup();

    click(trigger);
    await flush();
    (document.getElementById("inside") as HTMLElement).focus();
    key("Escape");

    expect(content.dataset.state).toBe("closed");
    expect(document.activeElement).toBe(trigger);
  });

  it("does not dismiss a non-dismissible popover", async () => {
    const { trigger, content } = setup({ dismissible: false });

    click(trigger);
    await flush();
    outsidePointerDown();
    key("Escape");

    expect(content.dataset.state).toBe("open");
  });

  it("resolves portalled content by its derived id", async () => {
    const { trigger, content, arrowElement } = setup({ portal: true });

    expect(content.parentElement).toBe(document.body);

    click(trigger);
    await flush();

    expect(content.dataset.state).toBe("open");
    expect(create).toHaveBeenCalledWith(
      trigger,
      content,
      expect.objectContaining({ arrow: arrowElement }),
    );
  });

  it("opens an initially opened popover without stealing focus", async () => {
    const { content } = setup({ opened: true });
    await flush();

    expect(content.dataset.state).toBe("open");
    expect(content.dataset.popover).toBe("open");
    expect(document.activeElement).not.toBe(document.getElementById("inside"));
  });

  it("applies a changed opened value from the server", async () => {
    const { el, content, hook } = setup();

    el.dataset.opened = "true";
    hook.updated();
    await flush();
    expect(content.dataset.state).toBe("open");

    el.dataset.opened = "false";
    hook.updated();
    await flush();
    expect(content.dataset.state).toBe("closed");
  });

  it("does not reopen when an unchanged opened value is patched after a user close", async () => {
    const { el, trigger, content, hook } = setup({ opened: true });
    await flush();

    click(trigger);
    await flush();
    expect(content.dataset.state).toBe("closed");

    // The server still renders the original initial value.
    expect(el.dataset.opened).toBe("true");
    hook.updated();
    await flush();

    expect(content.dataset.state).toBe("closed");
  });

  it("reopens with replacement content while open", async () => {
    const { trigger, hook, content } = setup();

    click(trigger);
    await flush();
    expect(create).toHaveBeenCalledTimes(1);

    const replacement = document.createElement("div");
    replacement.id = content.id;
    replacement.setAttribute("data-part", "content");
    replacement.setAttribute("data-popover-content", "");
    replacement.setAttribute("popover", "manual");
    replacement.setAttribute("data-state", "closed");
    replacement.innerHTML = '<button id="inside-2">Inside</button>';
    content.replaceWith(replacement);

    hook.updated();
    await flush();

    expect(create).toHaveBeenCalledTimes(2);
    expect(replacement.dataset.state).toBe("open");
  });

  it("follows a generated id that changed on the server", async () => {
    const { el, trigger, content } = setup();

    click(trigger);
    await flush();
    expect(content.dataset.state).toBe("open");

    // A generated id changes on every render, so LiveView re-keys the hook and
    // never calls `updated/0`; the page update is the only notification.
    const replacementId = "pop-2-content";
    const replacement = document.createElement("div");
    replacement.id = replacementId;
    replacement.setAttribute("data-part", "content");
    replacement.setAttribute("data-popover-content", "");
    replacement.setAttribute("popover", "manual");
    replacement.setAttribute("data-state", "closed");
    replacement.innerHTML = '<button id="inside-2">Inside</button>';
    content.replaceWith(replacement);
    el.id = "pop-2";

    document.dispatchEvent(new CustomEvent("phx:update"));
    await flush();

    expect(replacement.dataset.state).toBe("open");
    expect(trigger.getAttribute("aria-controls")).toBe(replacementId);
  });

  it("pushes configured server events on open and close", async () => {
    const { trigger, hook } = setup({
      openEvent: "opened",
      closeEvent: "closed",
      toggleEvent: "toggled",
    });
    const push = vi.spyOn(hook, "pushEvent").mockImplementation(async () => {});

    click(trigger);
    await flush();
    click(trigger);
    await flush();

    expect(push).toHaveBeenCalledWith("opened", { id: "pop", open: true });
    expect(push).toHaveBeenCalledWith("closed", { id: "pop", open: false });
    expect(push).toHaveBeenCalledWith("toggled", { id: "pop", open: true });
    expect(push).toHaveBeenCalledWith("toggled", { id: "pop", open: false });
  });

  it("emits a change event on the root", async () => {
    const { el, trigger } = setup();
    const changed = vi.fn();
    el.addEventListener("fl:popover:change", changed);

    click(trigger);
    await flush();
    click(trigger);
    await flush();

    expect(changed).toHaveBeenCalledTimes(2);
    expect(changed.mock.calls[0]![0].detail).toEqual({ state: "open" });
    expect(changed.mock.calls[1]![0].detail).toEqual({ state: "closed" });
  });

  it("responds to open, close, and toggle commands", async () => {
    const { el, content } = setup();

    el.dispatchEvent(new CustomEvent("fl:popover:open"));
    await flush();
    expect(content.dataset.state).toBe("open");

    el.dispatchEvent(new CustomEvent("fl:popover:close"));
    await flush();
    expect(content.dataset.state).toBe("closed");

    el.dispatchEvent(new CustomEvent("fl:popover:toggle"));
    await flush();
    expect(content.dataset.state).toBe("open");
  });

  it("stops tracking when destroyed", async () => {
    const { trigger, content, hook } = setup();

    click(trigger);
    await flush();
    hook.destroyed();

    expect(positioner.stop).toHaveBeenCalled();
    expect(content.dataset.popover).toBeUndefined();
  });

  it("ignores a nested trigger inside the content", async () => {
    const { el, trigger, content } = setup();
    const nested = document.createElement("button");
    nested.setAttribute("data-part", "trigger");
    content.appendChild(nested);

    const hook = mounted[mounted.length - 1]!;
    hook.updated();

    expect(trigger.getAttribute("aria-controls")).toBe(content.id);
    expect(nested.hasAttribute("aria-controls")).toBe(false);
    expect(el.querySelectorAll('[data-part="trigger"]').length).toBe(2);
  });
});
