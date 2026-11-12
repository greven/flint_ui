import { afterEach, describe, expect, it, vi } from "vitest";
import { Accordion } from "./accordion";
import { Collapsible } from "./collapsible";

interface SetupOptions {
  states?: Array<"open" | "closed">;
  disabledItems?: number[];
  multiple?: boolean;
  requireOpen?: boolean;
  disabled?: boolean;
}

function setup(options: SetupOptions = {}) {
  const {
    states = ["closed", "closed", "closed"],
    disabledItems = [],
    multiple = false,
    requireOpen = false,
    disabled = false,
  } = options;

  const items = states
    .map(
      (state, index) => `
      <div
        id="item-${index}"
        data-element="accordion_item"
        data-part="root"
        data-state="${state}"
        ${disabledItems.includes(index) ? "data-disabled" : ""}
      >
        <h3 data-part="heading">
          <button data-part="trigger" type="button" aria-expanded="${state === "open"}">
            Item ${index}
          </button>
        </h3>
        <div data-part="content" ${state === "open" ? "" : "hidden"}>
          <div data-part="panel">Body ${index}</div>
        </div>
      </div>
    `,
    )
    .join("");

  document.body.innerHTML = `
    <div
      id="accordion"
      data-element="accordion"
      data-part="root"
      ${multiple ? "data-multiple" : ""}
      ${requireOpen ? "data-require-open" : ""}
      ${disabled ? "data-disabled" : ""}
    >
      ${items}
    </div>
  `;

  const root = document.getElementById("accordion") as HTMLElement;
  const itemEls = Array.from(root.querySelectorAll<HTMLElement>('[data-element="accordion_item"]'));
  const headers = itemEls.map(
    (item) => item.querySelector<HTMLButtonElement>('[data-part="trigger"]')!,
  );
  const contents = itemEls.map((item) => item.querySelector<HTMLElement>('[data-part="content"]')!);

  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: vi.fn() } },
    pushHookEvent: vi.fn(() => Promise.resolve({ reply: null, ref: 0 })),
  };

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };

  const collapsibles = itemEls.map((item) => {
    const hook = new Collapsible(view as never, item);
    vi.spyOn(hook, "js").mockReturnValue(js as never);
    hook.mounted();
    return hook;
  });

  const accordion = new Accordion(view as never, root);
  accordion.mounted();

  return { root, itemEls, headers, contents, accordion, collapsibles, view };
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 20));

const click = (element: HTMLElement) =>
  element.dispatchEvent(new MouseEvent("click", { bubbles: true }));

const key = (element: HTMLElement, key: string) =>
  element.dispatchEvent(new KeyboardEvent("keydown", { key, bubbles: true }));

afterEach(() => {
  document.body.innerHTML = "";
  vi.restoreAllMocks();
});

describe("Accordion hook", () => {
  it("keeps only one item open by default", () => {
    const { itemEls, headers } = setup();

    click(headers[0]!);
    expect(itemEls[0]!.getAttribute("data-state")).toBe("open");

    click(headers[1]!);
    expect(itemEls[1]!.getAttribute("data-state")).toBe("open");
    expect(itemEls[0]!.getAttribute("data-state")).toBe("closed");
  });

  it("keeps several items open with multiple", () => {
    const { itemEls, headers } = setup({ multiple: true });

    click(headers[0]!);
    click(headers[1]!);

    expect(itemEls[0]!.getAttribute("data-state")).toBe("open");
    expect(itemEls[1]!.getAttribute("data-state")).toBe("open");
  });

  it("refuses to close the last open item with require_open", () => {
    const { itemEls, headers } = setup({
      states: ["open", "closed", "closed"],
      requireOpen: true,
    });

    click(headers[0]!);
    expect(itemEls[0]!.getAttribute("data-state")).toBe("open");

    click(headers[1]!);
    expect(itemEls[1]!.getAttribute("data-state")).toBe("open");
    expect(itemEls[0]!.getAttribute("data-state")).toBe("closed");

    click(headers[1]!);
    expect(itemEls[1]!.getAttribute("data-state")).toBe("open");
  });

  it("allows a close that leaves another item open", () => {
    const { itemEls, headers } = setup({
      states: ["open", "open", "closed"],
      multiple: true,
      requireOpen: true,
    });

    click(headers[0]!);

    expect(itemEls[0]!.getAttribute("data-state")).toBe("closed");
    expect(itemEls[1]!.getAttribute("data-state")).toBe("open");
  });

  it("guards JS command closes too", () => {
    const { itemEls } = setup({
      states: ["open", "closed", "closed"],
      requireOpen: true,
    });

    itemEls[0]!.dispatchEvent(new CustomEvent("fl:collapsible:close"));

    expect(itemEls[0]!.getAttribute("data-state")).toBe("open");
  });

  it("lets server-driven state close the last open item", async () => {
    const { itemEls, collapsibles } = setup({
      states: ["open", "closed", "closed"],
      requireOpen: true,
    });

    itemEls[0]!.setAttribute("data-state", "closed");
    collapsibles[0]!.updated();
    await flush();

    expect(itemEls[0]!.getAttribute("data-state")).toBe("closed");
  });

  it("moves focus with the arrow keys and skips disabled items", () => {
    const { headers } = setup({ disabledItems: [1] });

    headers[0]!.focus();
    key(headers[0]!, "ArrowDown");
    expect(document.activeElement).toBe(headers[2]);

    key(headers[2]!, "ArrowUp");
    expect(document.activeElement).toBe(headers[0]);

    key(headers[0]!, "End");
    expect(document.activeElement).toBe(headers[2]);

    key(headers[2]!, "Home");
    expect(document.activeElement).toBe(headers[0]);
  });

  it("wraps focus at the ends", () => {
    const { headers } = setup();

    headers[0]!.focus();
    key(headers[0]!, "ArrowUp");
    expect(document.activeElement).toBe(headers[2]);

    key(headers[2]!, "ArrowDown");
    expect(document.activeElement).toBe(headers[0]);
  });

  it("suppresses header interaction while the root is disabled", () => {
    const { itemEls, headers } = setup({ disabled: true });

    expect(headers[0]!.disabled).toBe(true);

    click(headers[0]!);
    expect(itemEls[0]!.getAttribute("data-state")).toBe("closed");
  });

  it("restores item-level disabled state when the root is re-enabled", () => {
    const { root, headers, accordion } = setup({ disabledItems: [1] });

    root.setAttribute("data-disabled", "");
    accordion.updated();
    expect(headers[0]!.disabled).toBe(true);
    expect(headers[1]!.disabled).toBe(true);

    root.removeAttribute("data-disabled");
    accordion.updated();

    expect(headers[0]!.disabled).toBe(false);
    expect(headers[1]!.disabled).toBe(true);
  });

  it("ignores items that belong to a nested accordion", () => {
    const { itemEls } = setup();

    const nestedRoot = document.createElement("div");
    nestedRoot.setAttribute("data-element", "accordion");
    nestedRoot.innerHTML = `
      <div id="nested-item" data-element="accordion_item" data-part="root" data-state="closed">
        <button data-part="trigger" type="button">Nested</button>
        <div data-part="content" hidden></div>
      </div>
    `;
    itemEls[0]!.querySelector('[data-part="content"]')!.appendChild(nestedRoot);

    const nestedItem = nestedRoot.querySelector<HTMLElement>('[data-element="accordion_item"]')!;
    nestedItem.setAttribute("data-state", "open");
    nestedItem.dispatchEvent(
      new CustomEvent("fl:collapsible:change", {
        bubbles: true,
        detail: { state: "open" },
      }),
    );

    expect(itemEls[0]!.getAttribute("data-state")).toBe("closed");
    expect(itemEls[1]!.getAttribute("data-state")).toBe("closed");
  });
});
