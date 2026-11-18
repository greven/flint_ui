import { afterEach, describe, expect, it } from "vitest";
import { lockScroll, resetScrollLock, unlockScroll } from "./scroll-lock";

afterEach(() => {
  resetScrollLock();
});

describe("scroll lock", () => {
  it("locks and restores the page", () => {
    const root = document.documentElement;

    lockScroll();
    expect(root.style.overflow).toBe("hidden");

    unlockScroll();
    expect(root.style.overflow).toBe("");
  });

  it("stays locked until the last holder releases it", () => {
    const root = document.documentElement;

    lockScroll();
    lockScroll();

    unlockScroll();
    expect(root.style.overflow).toBe("hidden");

    unlockScroll();
    expect(root.style.overflow).toBe("");
  });

  it("restores the previous inline styles", () => {
    const root = document.documentElement;
    root.style.overflow = "scroll";
    root.style.paddingRight = "4px";

    lockScroll();
    unlockScroll();

    expect(root.style.overflow).toBe("scroll");
    expect(root.style.paddingRight).toBe("4px");
  });

  it("ignores an unlock without a matching lock", () => {
    const root = document.documentElement;

    unlockScroll();

    expect(root.style.overflow).toBe("");
  });
});
