import { afterEach, describe, expect, it, vi } from "vitest";
import { Header } from "./header";

interface SetupOptions {
  state?: "open" | "closed";
  mobile?: boolean;
}

function setup(options: SetupOptions = {}) {
  const { state = "closed", mobile = false } = options;

  document.body.innerHTML = `
    <header
      id="site-header"
      data-element="header"
      data-part="root"
      data-state="${state}"
      ${mobile ? "data-mobile" : ""}
    >
      <div data-part="bar">
        <div data-part="brand">Acme</div>
        <button
          id="toggle"
          data-part="toggle"
          aria-expanded="${state === "open"}"
          aria-controls="${mobile ? "site-header-mobile" : "site-header-nav"}"
          aria-label="Menu"
        ></button>
        <div id="site-header-nav" data-part="nav" data-state="${state}">
          <a id="nav-link" href="/docs">Docs</a>
        </div>
        <div data-part="actions"></div>
        ${
          mobile
            ? `<div id="site-header-mobile" data-part="mobile" data-state="${state}">
                 <a id="mobile-link" href="/mobile">Mobile</a>
               </div>`
            : ""
        }
      </div>
    </header>
  `;

  const el = document.getElementById("site-header") as HTMLElement;
  const view = { isDead: false, liveSocket: {} };
  const hook = new Header(view as never, el);

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  hook.mounted();

  const toggle = document.getElementById("toggle") as HTMLElement;
  const nav = document.getElementById("site-header-nav") as HTMLElement;
  const mobilePanel = mobile
    ? (document.getElementById("site-header-mobile") as HTMLElement)
    : null;

  return { el, toggle, nav, mobilePanel, hook, js };
}

afterEach(() => {
  document.body.innerHTML = "";
  vi.restoreAllMocks();
});

describe("Header hook", () => {
  it("toggles the nav panel and reflects the state in ARIA", () => {
    const { el, toggle, nav } = setup();

    toggle.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("open");
    expect(nav.getAttribute("data-state")).toBe("open");
    expect(toggle.getAttribute("aria-expanded")).toBe("true");

    toggle.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("closed");
    expect(nav.getAttribute("data-state")).toBe("closed");
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
  });

  it("targets the custom mobile panel when one is present", () => {
    const { el, toggle, nav, mobilePanel } = setup({ mobile: true });

    toggle.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("open");
    expect(mobilePanel?.getAttribute("data-state")).toBe("open");
    expect(nav.getAttribute("data-state")).toBe("closed");
    expect(toggle.getAttribute("aria-expanded")).toBe("true");
  });

  it("closes on Escape and returns focus to the toggle", () => {
    const { el, toggle } = setup({ state: "open" });

    toggle.focus();
    toggle.dispatchEvent(
      new KeyboardEvent("keydown", { key: "Escape", bubbles: true }),
    );

    expect(el.getAttribute("data-state")).toBe("closed");
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(toggle);
  });

  it("closes on an outside pointerdown", () => {
    const { el } = setup({ state: "open" });

    document.body.dispatchEvent(new Event("pointerdown", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("closed");
  });

  it("stays open on a pointerdown inside the header", () => {
    const { el, toggle } = setup({ state: "open" });

    toggle.dispatchEvent(new Event("pointerdown", { bubbles: true }));

    expect(el.getAttribute("data-state")).toBe("open");
  });

  it("closes after following a link inside the panel", () => {
    const { el } = setup({ state: "open" });
    const link = document.getElementById("nav-link") as HTMLElement;

    link.addEventListener("click", (event) => event.preventDefault(), { once: true });
    link.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true }));

    expect(el.getAttribute("data-state")).toBe("closed");
  });

  it("closes on live navigation", () => {
    const { el } = setup({ state: "open" });

    document.dispatchEvent(new Event("phx:page-loading-start"));

    expect(el.getAttribute("data-state")).toBe("closed");
  });

  it("closes when a resize leaves the mobile layout", () => {
    const { el, toggle } = setup({ state: "open" });

    toggle.style.display = "none";
    window.dispatchEvent(new Event("resize"));

    expect(el.getAttribute("data-state")).toBe("closed");
  });

  it("syncs the server state on update", () => {
    const { el, toggle, hook } = setup({ state: "open" });

    el.setAttribute("data-state", "closed");
    hook.updated();

    expect(el.getAttribute("data-state")).toBe("closed");
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
  });
});
