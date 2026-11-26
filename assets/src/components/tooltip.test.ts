import { afterEach, beforeEach, describe, expect, it, vi, type Mock } from "vitest";
import { createPositioner } from "../lib/position";
import { Tooltip } from "./tooltip";

vi.mock("../lib/position", () => ({ createPositioner: vi.fn() }));

const create = vi.mocked(createPositioner);

interface SetupOptions {
  delay?: number;
  disabled?: boolean;
  placement?: string;
  align?: string;
  arrow?: boolean;
  describedBy?: string;
  triggerAttrs?: string;
}

interface PositionerMock {
  start: Mock;
  stop: Mock;
}

let positioner: PositionerMock;

// Hooks register a document-level listener, so every test unmounts what it
// mounted to keep one test's updates out of the next.
const mounted: Tooltip[] = [];

function makePositioner(start?: Mock): PositionerMock {
  positioner = {
    start: start ?? vi.fn(() => Promise.resolve()),
    stop: vi.fn(),
  };

  return positioner;
}

function setup(options: SetupOptions = {}) {
  const {
    delay = 0,
    disabled = false,
    placement = "top",
    align = "center",
    arrow = true,
    describedBy,
    triggerAttrs = "",
  } = options;

  document.body.innerHTML = `
    <div
      id="tip"
      data-element="tooltip"
      data-placement="${placement}"
      data-align="${align}"
      data-offset="6"
      data-delay="${delay}"
      ${disabled ? "data-disabled" : ""}
    >
      <button ${describedBy ? `aria-describedby="${describedBy}"` : ""} ${triggerAttrs}>Save</button>
      <span
        id="tip-content"
        data-part="content"
        role="tooltip"
        popover="manual"
        data-state="closed"
      >
        ${arrow ? '<span data-part="arrow"></span>' : ""}
        Saved
      </span>
    </div>
  `;

  const el = document.getElementById("tip") as HTMLElement;
  const initialTrigger = el.querySelector("button") as HTMLElement;
  const triggerWasUnwired = !initialTrigger.hasAttribute("data-part");
  const view = { isDead: false, liveSocket: { transitions: { addAsyncTransition: vi.fn() } } };
  const hook = new Tooltip(view as never, el);

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  hook.mounted();

  mounted.push(hook);

  const trigger = el.querySelector<HTMLElement>("[data-tooltip-trigger]")!;
  const content = el.querySelector<HTMLElement>('[data-part="content"]')!;
  const arrowElement = el.querySelector<HTMLElement>('[data-part="arrow"]');

  return {
    el,
    trigger,
    initialTrigger,
    triggerWasUnwired,
    content,
    arrowElement,
    hook,
    js,
    view,
  };
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 20));

function pointer(
  trigger: HTMLElement,
  type: "pointerenter" | "pointerleave",
  pointerType?: string,
) {
  const event = new MouseEvent(type);
  if (pointerType) Object.defineProperty(event, "pointerType", { value: pointerType });
  trigger.dispatchEvent(event);
}

function focus(trigger: HTMLElement) {
  trigger.dispatchEvent(new FocusEvent("focusin", { bubbles: true }));
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

describe("Tooltip hook", () => {
  it("marks the first element in the default slot as the trigger", () => {
    const { initialTrigger, triggerWasUnwired, trigger, content } = setup();

    expect(triggerWasUnwired).toBe(true);
    expect(trigger).toBe(initialTrigger);
    expect(trigger.getAttribute("data-part")).toBe("trigger");
    expect(trigger.getAttribute("data-tooltip-trigger")).toBe("");
    expect(trigger.getAttribute("data-tooltip-state")).toBe("closed");
    expect(trigger.hasAttribute("data-state")).toBe(false);
    expect(trigger.getAttribute("aria-describedby")).toBe(content.id);
  });

  it("keeps the trigger's own part and state markers", () => {
    const { trigger } = setup({ triggerAttrs: `data-part="root" data-state="success"` });

    expect(trigger.getAttribute("data-part")).toBe("root");
    expect(trigger.getAttribute("data-state")).toBe("success");
    expect(trigger.getAttribute("data-tooltip-trigger")).toBe("");
    expect(trigger.getAttribute("data-tooltip-state")).toBe("closed");
  });

  it("mirrors the open state onto data-tooltip-state", async () => {
    const { trigger } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    expect(trigger.getAttribute("data-tooltip-state")).toBe("open");

    pointer(trigger, "pointerleave");
    await flush();
    expect(trigger.getAttribute("data-tooltip-state")).toBe("closed");
  });

  it("keeps a description the trigger already had", () => {
    const { trigger } = setup({ describedBy: "field-hint" });

    expect(trigger.getAttribute("aria-describedby")).toBe("field-hint tip-content");
  });

  it("drops only its own description when disabled", () => {
    const { trigger, content } = setup({ disabled: true, describedBy: "field-hint" });

    expect(trigger.getAttribute("data-tooltip-disabled")).toBe("");
    expect(trigger.getAttribute("aria-describedby")).toBe("field-hint");
    expect(content.getAttribute("data-state")).toBe("closed");
  });

  it("swaps the published description when the server regenerates the ids", () => {
    const { el, trigger, content } = setup({ describedBy: "field-hint" });

    // LiveView keys hook updates by the id the element had before the patch, so
    // a changed id means it never calls `updated/0` for that patch.
    el.id = "tip-2";
    content.id = "tip-2-content";

    document.dispatchEvent(new Event("phx:update"));

    expect(trigger.getAttribute("aria-describedby")).toBe("field-hint tip-2-content");
  });

  it("keeps one description across repeated regenerated ids", () => {
    const { el, trigger, content } = setup();

    el.id = "tip-2";
    content.id = "tip-2-content";
    document.dispatchEvent(new Event("phx:update"));

    el.id = "tip-3";
    content.id = "tip-3-content";
    document.dispatchEvent(new Event("phx:update"));

    expect(trigger.getAttribute("aria-describedby")).toBe("tip-3-content");
  });

  it("binds the trigger listeners once across updates", () => {
    const { trigger, hook } = setup();
    const add = vi.spyOn(trigger, "addEventListener");

    hook.updated();
    hook.updated();

    expect(add).not.toHaveBeenCalled();
  });

  it("ignores page updates that did not touch the tooltip", () => {
    const { js } = setup();
    js.setAttribute.mockClear();

    document.dispatchEvent(new Event("phx:update"));

    expect(js.setAttribute).not.toHaveBeenCalled();
  });

  it("picks up new options after a patch that skipped updated/0", async () => {
    const { el, content, trigger } = setup();

    el.id = "tip-2";
    content.id = "tip-2-content";
    el.dataset.placement = "bottom";
    document.dispatchEvent(new Event("phx:update"));

    pointer(trigger, "pointerenter");
    await flush();

    expect(create).toHaveBeenCalledWith(
      trigger,
      content,
      expect.objectContaining({ placement: "bottom" }),
    );
  });

  it("opens on pointer enter once the delay elapses", async () => {
    vi.useFakeTimers();
    const { el, trigger, content } = setup({ delay: 200 });

    pointer(trigger, "pointerenter");

    await vi.advanceTimersByTimeAsync(199);
    expect(content.dataset.state).toBe("closed");

    await vi.advanceTimersByTimeAsync(1);
    expect(el.dataset.state).toBe("open");
    expect(content.dataset.state).toBe("open");
  });

  it("opens immediately when the delay is zero", async () => {
    const { el, trigger, content } = setup();

    pointer(trigger, "pointerenter");
    await flush();

    expect(el.dataset.state).toBe("open");
    expect(content.dataset.state).toBe("open");
    expect(content.dataset.popover).toBe("open");
  });

  it("cancels a pending open when the pointer leaves first", async () => {
    vi.useFakeTimers();
    const { el, trigger, content } = setup({ delay: 200 });

    pointer(trigger, "pointerenter");
    await vi.advanceTimersByTimeAsync(100);
    pointer(trigger, "pointerleave");
    await vi.advanceTimersByTimeAsync(300);

    expect(el.dataset.state).toBe("closed");
    expect(content.dataset.state).toBe("closed");
    expect(create).not.toHaveBeenCalled();
  });

  it("opens on keyboard focus", async () => {
    const { trigger, content } = setup();

    focus(trigger);
    await flush();

    expect(content.dataset.state).toBe("open");
  });

  it("ignores focus that follows a pointer press", async () => {
    const { trigger, content } = setup();

    trigger.dispatchEvent(new Event("pointerdown"));
    focus(trigger);
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(create).not.toHaveBeenCalled();
  });

  it("ignores touch pointers", async () => {
    vi.useFakeTimers();
    const { trigger, content } = setup({ delay: 0 });

    pointer(trigger, "pointerenter", "touch");
    await vi.advanceTimersByTimeAsync(10);

    expect(content.dataset.state).toBe("closed");
  });

  it("hides on Escape without moving focus", async () => {
    const { trigger, content } = setup();

    focus(trigger);
    await flush();

    const escape = new KeyboardEvent("keydown", {
      key: "Escape",
      bubbles: true,
      cancelable: true,
    });
    trigger.dispatchEvent(escape);
    await flush();

    expect(escape.defaultPrevented).toBe(true);
    expect(content.dataset.state).toBe("closed");
    expect(content.dataset.popover).toBeUndefined();
  });

  it("hides on pointer leave", async () => {
    const { el, trigger, content } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    pointer(trigger, "pointerleave");
    await flush();

    expect(el.dataset.state).toBe("closed");
    expect(content.dataset.state).toBe("closed");
    expect(content.dataset.popover).toBeUndefined();
  });

  it("hides when the window loses focus", async () => {
    const { trigger, content } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    window.dispatchEvent(new Event("blur"));
    await flush();

    expect(content.dataset.state).toBe("closed");
  });

  it("never opens while disabled", async () => {
    const { trigger, content } = setup({ disabled: true });

    pointer(trigger, "pointerenter");
    focus(trigger);
    await flush();

    expect(content.dataset.state).toBe("closed");
    expect(create).not.toHaveBeenCalled();
  });

  it("reveals the content only after the positioner has placed it", async () => {
    let resolveStart!: () => void;
    const deferred = vi.fn(
      () =>
        new Promise<void>((resolve) => {
          resolveStart = resolve;
        }),
    );
    create.mockImplementation(() => makePositioner(deferred) as never);

    const { el, trigger, content } = setup();

    pointer(trigger, "pointerenter");
    await flush();

    expect(el.dataset.state).toBe("open");
    expect(content.dataset.state).toBe("closed");

    resolveStart();
    await flush();

    expect(content.dataset.state).toBe("open");
  });

  it("positions with the configured placement, alignment, and arrow", async () => {
    const { trigger, content, arrowElement } = setup({ placement: "bottom", align: "end" });

    pointer(trigger, "pointerenter");
    await flush();

    expect(create).toHaveBeenCalledWith(
      trigger,
      content,
      expect.objectContaining({
        placement: "bottom",
        align: "end",
        offset: 6,
        arrow: arrowElement,
        arrowVarPrefix: "tooltip",
      }),
    );
  });

  it("adds the stylesheet's arrow gap to the offset when an arrow is rendered", async () => {
    const { el, trigger, content } = setup();
    el.style.setProperty("--fl-tooltip-arrow-gap", "2px");

    pointer(trigger, "pointerenter");
    await flush();

    expect(create).toHaveBeenLastCalledWith(
      trigger,
      content,
      expect.objectContaining({ offset: 8 }),
    );
  });

  it("ignores the arrow gap without an arrow", async () => {
    const { el, trigger, content } = setup({ arrow: false });
    el.style.setProperty("--fl-tooltip-arrow-gap", "2px");

    pointer(trigger, "pointerenter");
    await flush();

    expect(create).toHaveBeenLastCalledWith(
      trigger,
      content,
      expect.objectContaining({ offset: 6 }),
    );
  });

  it("reuses one positioner across opens and stops tracking when hidden", async () => {
    const { trigger } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    pointer(trigger, "pointerleave");
    await flush();
    pointer(trigger, "pointerenter");
    await flush();

    expect(create).toHaveBeenCalledTimes(1);
    expect(positioner.start).toHaveBeenCalledTimes(2);
    expect(positioner.stop).toHaveBeenCalledTimes(1);
  });

  it("recreates the positioner after the server replaces the content", async () => {
    const { el, trigger, hook, content } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    expect(create).toHaveBeenCalledTimes(1);

    const replacement = document.createElement("span");
    replacement.setAttribute("data-part", "content");
    replacement.setAttribute("popover", "manual");
    replacement.setAttribute("data-state", "closed");
    replacement.textContent = "Updated";
    content.replaceWith(replacement);

    hook.updated();

    expect(el.dataset.state).toBe("closed");

    pointer(trigger, "pointerenter");
    await flush();

    expect(create).toHaveBeenCalledTimes(2);
  });

  it("emits open and close events on the root", async () => {
    const { el, trigger } = setup();

    const opened = vi.fn();
    const closed = vi.fn();
    el.addEventListener("fl:tooltip:open", opened);
    el.addEventListener("fl:tooltip:close", closed);

    pointer(trigger, "pointerenter");
    await flush();
    expect(opened).toHaveBeenCalledTimes(1);

    pointer(trigger, "pointerleave");
    await flush();
    expect(closed).toHaveBeenCalledTimes(1);
  });

  it("closes when the server replaces the trigger", async () => {
    const { trigger, content, hook } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    expect(content.dataset.state).toBe("open");

    const replacement = document.createElement("button");
    replacement.setAttribute("data-part", "trigger");
    trigger.replaceWith(replacement);

    hook.updated();
    await flush();

    expect(content.dataset.state).toBe("closed");
  });

  it("stops listening when destroyed", async () => {
    const { trigger, content, hook } = setup();

    pointer(trigger, "pointerenter");
    await flush();
    hook.destroyed();

    pointer(trigger, "pointerleave");
    expect(positioner.stop).toHaveBeenCalled();
    expect(content.dataset.popover).toBeUndefined();
  });
});
