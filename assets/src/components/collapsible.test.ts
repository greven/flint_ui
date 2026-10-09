import { afterEach, describe, expect, it, vi } from "vitest";
import { Collapsible } from "./collapsible";

interface SetupOptions {
  state?: "open" | "closed";
  disabled?: boolean;
  hiddenUntilFound?: boolean;
  openEvent?: string;
  closeEvent?: string;
  toggleEvent?: string;
}

function setup(options: SetupOptions = {}) {
  const {
    state = "closed",
    disabled = false,
    hiddenUntilFound = false,
    openEvent,
    closeEvent,
    toggleEvent,
  } = options;

  document.body.innerHTML = `
    <div
      id="test"
      data-state="${state}"
      ${disabled ? "data-disabled" : ""}
      ${hiddenUntilFound ? "data-hidden-until-found" : ""}
      ${openEvent ? `data-open-event="${openEvent}"` : ""}
      ${closeEvent ? `data-close-event="${closeEvent}"` : ""}
      ${toggleEvent ? `data-toggle-event="${toggleEvent}"` : ""}
    >
      <button data-part="trigger"></button>
      <div data-part="content"></div>
    </div>
  `;

  const el = document.getElementById("test") as HTMLElement;
  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: vi.fn() } },
    pushHookEvent: vi.fn(() => Promise.resolve({ reply: null, ref: 0 })),
  };

  const hook = new Collapsible(view as never, el);

  // Simulate the LiveView hook DOM commands synchronously against the DOM.
  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  hook.mounted();

  const trigger = el.querySelector<HTMLElement>('[data-part="trigger"]')!;
  const content = el.querySelector<HTMLElement>('[data-part="content"]')!;

  return { el, trigger, content, hook, view, js };
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 20));

afterEach(() => {
  document.body.innerHTML = "";
  vi.restoreAllMocks();
});

describe("Collapsible hook", () => {
  it("toggles on trigger click and reflects state in ARIA", () => {
    const { el, trigger } = setup();

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("open");
    expect(trigger.getAttribute("data-state")).toBe("open");
    expect(trigger.getAttribute("aria-expanded")).toBe("true");

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("closed");
    expect(trigger.getAttribute("aria-expanded")).toBe("false");
  });

  it("toggles in response to the fl:collapsible:toggle command", () => {
    const { el } = setup();

    el.dispatchEvent(new CustomEvent("fl:collapsible:toggle", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("open");
  });

  it("removes hidden immediately when opening", () => {
    const { trigger, content } = setup();
    content.setAttribute("hidden", "");

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(content.hasAttribute("hidden")).toBe(false);
  });

  it("re-applies hidden after the close animation settles", async () => {
    const { trigger, content } = setup({ state: "open" });

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    expect(content.hasAttribute("hidden")).toBe(false);

    await flush();

    expect(content.getAttribute("hidden")).toBe("");
  });

  it("ignores interactions while disabled", () => {
    const { el, trigger } = setup({ disabled: true });

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    expect(el.getAttribute("data-state")).toBe("closed");

    el.dispatchEvent(new CustomEvent("fl:collapsible:toggle", { bubbles: true }));
    expect(el.getAttribute("data-state")).toBe("closed");
  });

  it("pushes server events for user-initiated changes", async () => {
    const { el, trigger, view } = setup({
      openEvent: "opened",
      toggleEvent: "toggled",
    });

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));
    await Promise.resolve();

    expect(view.pushHookEvent).toHaveBeenCalledWith(el, null, "opened", {
      id: "test",
      open: true,
    });
    expect(view.pushHookEvent).toHaveBeenCalledWith(el, null, "toggled", {
      id: "test",
      open: true,
    });
  });

  it("applies server-driven state without pushing events", () => {
    const { el, hook, view } = setup({ openEvent: "opened" });

    el.setAttribute("data-state", "open");
    hook.updated();

    expect(el.getAttribute("data-state")).toBe("open");
    expect(view.pushHookEvent).not.toHaveBeenCalled();
  });

  it("re-measures the content while open when the server patches it", () => {
    const { content, hook } = setup({ state: "open" });

    Object.defineProperty(content, "scrollHeight", { configurable: true, value: 240 });
    hook.updated();

    expect(content.style.getPropertyValue("--fl-collapsible-height")).toBe("240px");
  });

  it("does not re-measure the content while closed", () => {
    const { content, hook } = setup({ state: "closed" });

    Object.defineProperty(content, "scrollHeight", { configurable: true, value: 240 });
    hook.updated();

    expect(content.style.getPropertyValue("--fl-collapsible-height")).not.toBe("240px");
  });

  it("dispatches a change event on state changes", () => {
    const { el, trigger } = setup();
    const listener = vi.fn();
    el.addEventListener("fl:collapsible:change", listener);

    trigger.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(listener).toHaveBeenCalledTimes(1);
    const event = listener.mock.calls[0]![0] as CustomEvent;
    expect(event.detail).toEqual({ state: "open" });
  });

  it("rebinds the trigger when the server replaces it", () => {
    const { el, hook, trigger } = setup();

    const replacement = document.createElement("button");
    replacement.setAttribute("data-part", "trigger");
    trigger.replaceWith(replacement);

    hook.updated();
    replacement.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("open");
  });

  it("activates the beforematch listener when hidden_until_found is enabled by the server", () => {
    const { el, content, hook } = setup();

    el.setAttribute("data-hidden-until-found", "");
    hook.updated();
    content.dispatchEvent(new Event("beforematch"));

    expect(el.getAttribute("data-state")).toBe("open");
  });

  it("deactivates the beforematch listener when hidden_until_found is disabled by the server", () => {
    const { el, content, hook } = setup({ hiddenUntilFound: true });

    el.dispatchEvent(new CustomEvent("fl:collapsible:close", { bubbles: true }));
    expect(el.getAttribute("data-state")).toBe("closed");

    el.removeAttribute("data-hidden-until-found");
    hook.updated();
    content.dispatchEvent(new Event("beforematch"));

    expect(el.getAttribute("data-state")).toBe("closed");
  });
});
