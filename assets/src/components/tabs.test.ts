import { afterEach, describe, expect, it, vi } from "vitest";
import { Tabs } from "./tabs";

interface TabOptions {
  value: string;
  disabled?: boolean;
  kind?: "button" | "link" | "div";
  active?: boolean;
  part?: string;
}

interface SetupOptions {
  value?: string;
  orientation?: "horizontal" | "vertical";
  activation?: "automatic" | "manual";
  loop?: boolean;
  disabled?: boolean;
  findable?: boolean;
  scrollable?: boolean;
  fadable?: boolean;
  changeEvent?: string;
  tabs?: TabOptions[];
  panels?: string[];
}

const defaultTabs: TabOptions[] = [{ value: "a", active: true }, { value: "b" }, { value: "c" }];

function tabMarkup(tab: TabOptions, active: string) {
  const selected = tab.value === active;
  const disabled = tab.disabled ? " disabled data-disabled" : "";
  const attrs = `data-part="${tab.part ?? "tab"}" data-tabs-trigger data-value="${tab.value}" data-state="${selected ? "active" : "inactive"}" aria-selected="${selected}" tabindex="${selected ? "0" : "-1"}"${disabled}`;

  switch (tab.kind) {
    case "link":
      return `<a ${attrs} data-phx-link="patch">${tab.value}</a>`;
    case "div":
      return `<div ${attrs}>${tab.value}</div>`;
    default:
      return `<button ${attrs}>${tab.value}</button>`;
  }
}

function setup(options: SetupOptions = {}) {
  const {
    value = "a",
    orientation = "horizontal",
    activation = "automatic",
    loop = true,
    disabled = false,
    findable = false,
    scrollable = false,
    fadable = false,
    changeEvent,
    tabs = defaultTabs,
    panels = tabs.map((tab) => tab.value),
  } = options;

  const active = value;

  document.body.innerHTML = `
    <div
      id="test"
      data-element="tabs"
      data-part="root"
      data-value="${active}"
      data-orientation="${orientation}"
      data-activation="${activation}"
      data-loop="${loop}"
      ${disabled ? "data-disabled" : ""}
      ${findable ? "data-findable" : ""}
      ${scrollable ? "data-scrollable" : ""}
      ${fadable ? "data-fadable" : ""}
      ${changeEvent ? `data-change-event="${changeEvent}"` : ""}
    >
      <div data-part="tablist" role="tablist">
        ${tabs.map((tab) => tabMarkup(tab, active)).join("")}
      </div>
      ${panels
        .map(
          (panel) => `
        <div data-part="panel" data-value="${panel}" data-state="${
          panel === active ? "active" : "inactive"
        }" ${panel === active ? "" : findable ? 'hidden="until-found"' : "hidden"}>${panel}</div>
      `,
        )
        .join("")}
    </div>
  `;

  const el = document.getElementById("test") as HTMLElement;
  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: vi.fn() } },
    pushHookEvent: vi.fn(() => Promise.resolve({ reply: null, ref: 0 })),
  };

  const hook = new Tabs(view as never, el);

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  hook.mounted();

  const tablist = el.querySelector<HTMLElement>('[data-part="tablist"]')!;
  const tabsByValue = new Map(
    Array.from(el.querySelectorAll<HTMLElement>("[data-tabs-trigger]")).map((tab) => [
      tab.dataset.value!,
      tab,
    ]),
  );
  const panelsByValue = new Map(
    Array.from(el.querySelectorAll<HTMLElement>('[data-part="panel"]')).map((panel) => [
      panel.dataset.value!,
      panel,
    ]),
  );

  return { el, hook, view, js, tablist, tabs: tabsByValue, panels: panelsByValue };
}

function tab(el: HTMLElement, value: string): HTMLElement {
  return el.querySelector(`[data-tabs-trigger][data-value="${value}"]`) as HTMLElement;
}

function state(el: HTMLElement, value: string) {
  return tab(el, value).getAttribute("data-state");
}

const focus = (el: HTMLElement, value: string) => tab(el, value).focus();

const rect = (left: number, right: number) =>
  ({
    left,
    right,
    top: 0,
    bottom: 0,
    width: right - left,
    height: 0,
    x: left,
    y: 0,
    toJSON: () => ({}),
  }) as DOMRect;

afterEach(() => {
  document.body.innerHTML = "";
  vi.restoreAllMocks();
});

describe("Tabs hook", () => {
  it("reflects the server-rendered active tab and panels", () => {
    const { el, panels } = setup();

    expect(state(el, "a")).toBe("active");
    expect(tab(el, "a").getAttribute("aria-selected")).toBe("true");
    expect(tab(el, "a").getAttribute("tabindex")).toBe("0");
    expect(panels.get("a")!.hasAttribute("hidden")).toBe(false);
    expect(panels.get("b")!.hasAttribute("hidden")).toBe(true);
  });

  it("activates a tab on click and updates ARIA, panels, and tabindex", () => {
    const { el, view, panels } = setup({ changeEvent: "tab_changed" });
    const change = vi.fn();
    el.addEventListener("fl:tabs:change", change);

    tab(el, "b").dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(state(el, "a")).toBe("inactive");
    expect(state(el, "b")).toBe("active");
    expect(tab(el, "b").getAttribute("aria-selected")).toBe("true");
    expect(tab(el, "b").getAttribute("tabindex")).toBe("0");
    expect(tab(el, "a").getAttribute("tabindex")).toBe("-1");
    expect(panels.get("a")!.hasAttribute("hidden")).toBe(true);
    expect(panels.get("b")!.hasAttribute("hidden")).toBe(false);
    expect(change).toHaveBeenCalledTimes(1);
    expect(view.pushHookEvent).toHaveBeenCalledWith(el, null, "tab_changed", {
      id: "test",
      value: "b",
    });
  });

  it("finds a composed trigger that keeps its own data-part", () => {
    const { el, panels } = setup({
      value: "b",
      tabs: [{ value: "a" }, { value: "b", part: "root" }, { value: "c" }],
    });

    expect(tab(el, "b").getAttribute("data-part")).toBe("root");
    expect(state(el, "b")).toBe("active");
    expect(panels.get("b")!.hasAttribute("hidden")).toBe(false);
    expect(panels.get("a")!.hasAttribute("hidden")).toBe(true);

    tab(el, "c").dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(state(el, "c")).toBe("active");
    expect(panels.get("c")!.hasAttribute("hidden")).toBe(false);
  });

  it("does not change when the click lands on the active tab", () => {
    const { el, view } = setup();

    tab(el, "a").dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(state(el, "a")).toBe("active");
    expect(view.pushHookEvent).not.toHaveBeenCalled();
  });

  it("emits a cancelable before-change event", () => {
    const { el, view } = setup({ changeEvent: "tab_changed" });
    const change = vi.fn();
    el.addEventListener("fl:tabs:change", change);
    el.addEventListener("fl:tabs:before-change", (event) => event.preventDefault());

    tab(el, "b").dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(state(el, "a")).toBe("active");
    expect(state(el, "b")).toBe("inactive");
    expect(change).not.toHaveBeenCalled();
    expect(view.pushHookEvent).not.toHaveBeenCalled();
  });

  it("continues past a cancelled guard with the select command", () => {
    const { el } = setup();
    el.addEventListener("fl:tabs:before-change", (event) => event.preventDefault());

    el.dispatchEvent(
      new CustomEvent("fl:tabs:select", {
        bubbles: true,
        detail: { value: "c" },
      }),
    );

    expect(state(el, "c")).toBe("active");
  });

  it("ignores a disabled tab and prevents a disabled link from navigating", () => {
    const { el } = setup({
      tabs: [
        { value: "a", active: true },
        { value: "b", disabled: true, kind: "link" },
      ],
    });

    const click = new MouseEvent("click", { bubbles: true, cancelable: true });
    const notCanceled = tab(el, "b").dispatchEvent(click);

    expect(notCanceled).toBe(false);
    expect(click.defaultPrevented).toBe(true);
    expect(state(el, "a")).toBe("active");
  });

  it("ignores the whole component while disabled", () => {
    const { el } = setup({ disabled: true });

    tab(el, "b").dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(state(el, "a")).toBe("active");
    expect(state(el, "b")).toBe("inactive");
  });

  it("selects the next tab with ArrowRight in automatic mode", () => {
    const { el } = setup();
    focus(el, "a");

    tab(el, "a").dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }));

    expect(state(el, "b")).toBe("active");
    expect(document.activeElement).toBe(tab(el, "b"));
  });

  it("wraps with the arrow keys and does not wrap when loop is false", () => {
    const wrapped = setup();
    focus(wrapped.el, "c");
    tab(wrapped.el, "c").dispatchEvent(
      new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }),
    );
    expect(state(wrapped.el, "a")).toBe("active");

    const clamped = setup({ loop: false });
    focus(clamped.el, "c");
    tab(clamped.el, "c").dispatchEvent(
      new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }),
    );
    expect(state(clamped.el, "c")).toBe("active");
  });

  it("uses the vertical axis for arrow keys", () => {
    const { el } = setup({ orientation: "vertical" });
    focus(el, "a");

    tab(el, "a").dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown", bubbles: true }));
    expect(state(el, "b")).toBe("active");

    tab(el, "b").dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowUp", bubbles: true }));
    expect(state(el, "a")).toBe("active");
  });

  it("moves focus without selecting in manual mode", () => {
    const { el } = setup({ activation: "manual" });
    focus(el, "a");

    tab(el, "a").dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true }));

    expect(state(el, "a")).toBe("active");
    expect(tab(el, "b").getAttribute("tabindex")).toBe("0");
    expect(document.activeElement).toBe(tab(el, "b"));

    tab(el, "b").dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", bubbles: true }));
    expect(state(el, "b")).toBe("active");
  });

  it("moves to the first and last enabled tabs with Home and End", () => {
    const { el } = setup();
    focus(el, "b");

    tab(el, "b").dispatchEvent(new KeyboardEvent("keydown", { key: "End", bubbles: true }));
    expect(state(el, "c")).toBe("active");

    tab(el, "c").dispatchEvent(new KeyboardEvent("keydown", { key: "Home", bubbles: true }));
    expect(state(el, "a")).toBe("active");
  });

  it("activates a synthetic trigger with Enter", () => {
    const { el } = setup({
      tabs: [
        { value: "a", active: true, kind: "div" },
        { value: "b", kind: "div" },
      ],
    });
    focus(el, "b");

    tab(el, "b").dispatchEvent(new KeyboardEvent("keydown", { key: "Enter", bubbles: true }));
    expect(state(el, "b")).toBe("active");
  });

  it("leaves a link to navigation instead of activating locally", () => {
    const { el, view } = setup({
      changeEvent: "tab_changed",
      tabs: [
        { value: "a", active: true },
        { value: "b", kind: "link" },
      ],
    });
    const guard = vi.fn();
    el.addEventListener("fl:tabs:before-change", guard);

    const click = new MouseEvent("click", { bubbles: true, cancelable: true });
    const notCanceled = tab(el, "b").dispatchEvent(click);

    expect(notCanceled).toBe(true);
    expect(click.defaultPrevented).toBe(false);
    expect(guard).not.toHaveBeenCalled();
    expect(state(el, "a")).toBe("active");
    expect(state(el, "b")).toBe("inactive");
    expect(view.pushHookEvent).not.toHaveBeenCalled();
  });

  it("leaves modified clicks on a link alone", () => {
    const { el } = setup({
      tabs: [
        { value: "a", active: true },
        { value: "b", kind: "link" },
      ],
    });

    const click = new MouseEvent("click", {
      bubbles: true,
      cancelable: true,
      ctrlKey: true,
    });
    const notCanceled = tab(el, "b").dispatchEvent(click);

    expect(notCanceled).toBe(true);
    expect(click.defaultPrevented).toBe(false);
    expect(state(el, "a")).toBe("active");
  });

  it("uses the link click when the select command targets a link", () => {
    const { el } = setup({
      tabs: [
        { value: "a", active: true },
        { value: "b", kind: "link" },
      ],
    });
    const click = vi.spyOn(tab(el, "b"), "click").mockImplementation(() => {});

    el.dispatchEvent(
      new CustomEvent("fl:tabs:select", {
        bubbles: true,
        detail: { value: "b" },
      }),
    );

    expect(click).toHaveBeenCalledTimes(1);
    expect(state(el, "a")).toBe("active");
  });

  it("keeps a local selection across a patch with the same server value", () => {
    const { el, hook } = setup();

    tab(el, "b").dispatchEvent(new MouseEvent("click", { bubbles: true }));
    hook.updated();

    expect(state(el, "b")).toBe("active");
  });

  it("applies a changed server value", () => {
    const { el, hook } = setup();

    tab(el, "b").dispatchEvent(new MouseEvent("click", { bubbles: true }));
    el.setAttribute("data-value", "c");
    hook.updated();

    expect(state(el, "c")).toBe("active");
    expect(state(el, "b")).toBe("inactive");
  });

  it("rebinds after the server replaces the tab list", () => {
    const { el, hook } = setup();
    const tablist = el.querySelector('[data-part="tablist"]')!;
    const replacement = tablist.cloneNode(true) as HTMLElement;
    tablist.replaceWith(replacement);

    hook.updated();
    replacement
      .querySelector('[data-tabs-trigger][data-value="c"]')!
      .dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(state(el, "c")).toBe("active");
  });

  it("selects the matching tab when find-in-page reveals a findable panel", () => {
    const { el, view, panels } = setup({ findable: true, changeEvent: "tab_changed" });
    const change = vi.fn();
    el.addEventListener("fl:tabs:change", change);

    expect(panels.get("b")!.getAttribute("hidden")).toBe("until-found");

    panels.get("b")!.dispatchEvent(new Event("beforematch"));

    expect(state(el, "b")).toBe("active");
    expect(panels.get("b")!.hasAttribute("hidden")).toBe(false);
    expect(change).toHaveBeenCalledTimes(1);
    expect(view.pushHookEvent).toHaveBeenCalledWith(el, null, "tab_changed", {
      id: "test",
      value: "b",
    });
  });

  it("sets the fade flags from the scroll position when fadable", () => {
    const { el, hook } = setup({ fadable: true });
    const tablist = el.querySelector<HTMLElement>('[data-part="tablist"]')!;

    Object.defineProperty(tablist, "scrollWidth", { configurable: true, value: 500 });
    Object.defineProperty(tablist, "clientWidth", { configurable: true, value: 200 });
    Object.defineProperty(tablist, "scrollLeft", {
      configurable: true,
      writable: true,
      value: 0,
    });

    hook.updated();
    expect(tablist.hasAttribute("data-fade-end")).toBe(true);
    expect(tablist.hasAttribute("data-fade-start")).toBe(false);

    tablist.scrollLeft = 150;
    tablist.dispatchEvent(new Event("scroll"));
    expect(tablist.hasAttribute("data-fade-start")).toBe(true);
    expect(tablist.hasAttribute("data-fade-end")).toBe(true);

    tablist.scrollLeft = 300;
    tablist.dispatchEvent(new Event("scroll"));
    expect(tablist.hasAttribute("data-fade-start")).toBe(true);
    expect(tablist.hasAttribute("data-fade-end")).toBe(false);
  });

  it("scrolls an overflowing tab into view when it becomes active", () => {
    const { el } = setup({ scrollable: true });
    const tablist = el.querySelector<HTMLElement>('[data-part="tablist"]')!;

    Object.defineProperty(tablist, "scrollWidth", { configurable: true, value: 300 });
    Object.defineProperty(tablist, "clientWidth", { configurable: true, value: 100 });
    Object.defineProperty(tablist, "scrollLeft", {
      configurable: true,
      writable: true,
      value: 0,
    });
    tablist.getBoundingClientRect = () => rect(0, 100);
    tab(el, "b").getBoundingClientRect = () => rect(150, 200);

    tab(el, "b").dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(tablist.scrollLeft).toBe(100);
    expect(state(el, "b")).toBe("active");
  });

  it("does not react to a nested tabs select command", () => {
    const { el } = setup();
    const panel = el.querySelector('[data-part="panel"][data-value="b"]') as HTMLElement;
    panel.innerHTML = `
      <div id="inner" data-element="tabs" data-part="root" data-value="x" data-orientation="horizontal" data-activation="automatic" data-loop="true">
        <div data-part="tablist" role="tablist">
          <button data-part="tab" data-tabs-trigger data-value="x" data-state="active" aria-selected="true" tabindex="0">x</button>
          <button data-part="tab" data-tabs-trigger data-value="y" data-state="inactive" aria-selected="false" tabindex="-1">y</button>
        </div>
      </div>
    `;
    const inner = document.getElementById("inner") as HTMLElement;

    inner.dispatchEvent(
      new CustomEvent("fl:tabs:select", {
        bubbles: true,
        detail: { value: "y" },
      }),
    );

    expect(state(el, "a")).toBe("active");
  });
});
