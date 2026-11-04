import { afterEach, describe, expect, it } from "vitest";
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
});
