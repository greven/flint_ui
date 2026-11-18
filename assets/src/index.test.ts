import { afterEach, describe, expect, it, vi } from "vitest";
import "./index";

afterEach(() => {
  document.body.innerHTML = "";
});

describe("core bundle", () => {
  it("installs the pending guard on import", () => {
    document.body.innerHTML = `<button data-element="button" data-loading>Save</button>`;

    const event = new MouseEvent("click", { bubbles: true, cancelable: true });
    document.querySelector("button")!.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
  });

  it("installs the copy behavior on import", async () => {
    Object.defineProperty(navigator, "clipboard", {
      value: { writeText: vi.fn(async () => undefined) },
      configurable: true,
    });

    document.body.innerHTML = `<button data-copy data-copy-value="hello">Copy</button>`;
    const button = document.querySelector("button")!;

    button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    for (let i = 0; i < 5; i++) await Promise.resolve();

    expect(button.getAttribute("data-state")).toBe("success");
  });
});
