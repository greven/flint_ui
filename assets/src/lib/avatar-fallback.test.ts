import { afterEach, beforeAll, describe, expect, it, vi } from "vitest";
import { installAvatarFallback } from "./avatar-fallback";

function setup(label?: string) {
  document.body.innerHTML = `
    <div data-element="avatar" data-status="loading">
      <img data-part="image" src="https://example.com/avatar.jpg" alt="${label ?? ""}" />
      <span
        data-part="fallback"
        ${label ? `aria-label="${label}"` : ""}
        aria-hidden="true"
        hidden
      >JD</span>
    </div>
  `;

  return {
    root: document.querySelector<HTMLElement>('[data-element="avatar"]')!,
    image: document.querySelector<HTMLImageElement>('[data-part="image"]')!,
    fallback: document.querySelector<HTMLElement>('[data-part="fallback"]')!,
  };
}

beforeAll(() => {
  installAvatarFallback();
});

afterEach(() => {
  document.body.innerHTML = "";
});

describe("avatar fallback", () => {
  it("reveals the fallback when the image fails", () => {
    const { root, image, fallback } = setup("Jane Doe");

    image.dispatchEvent(new Event("error"));

    expect(root.getAttribute("data-status")).toBe("error");
    expect(image.hidden).toBe(true);
    expect(image.getAttribute("aria-hidden")).toBe("true");
    expect(fallback.hidden).toBe(false);
    expect(fallback.getAttribute("aria-hidden")).toBeNull();
  });

  it("keeps an unlabeled fallback out of the accessibility tree", () => {
    const { image, fallback } = setup();

    image.dispatchEvent(new Event("error"));

    expect(fallback.hidden).toBe(false);
    expect(fallback.getAttribute("aria-hidden")).toBe("true");
  });

  it("restores the image when a new source loads", () => {
    const { root, image, fallback } = setup("Jane Doe");

    image.dispatchEvent(new Event("error"));
    image.dispatchEvent(new Event("load"));

    expect(root.getAttribute("data-status")).toBe("loaded");
    expect(image.hidden).toBe(false);
    expect(image.getAttribute("aria-hidden")).toBeNull();
    expect(fallback.hidden).toBe(true);
    expect(fallback.getAttribute("aria-hidden")).toBe("true");
  });

  it("hides the loading placeholder when the image loads", () => {
    const { fallback, image } = setup("Jane Doe");

    fallback.hidden = false;
    image.dispatchEvent(new Event("load"));

    expect(fallback.hidden).toBe(true);
    expect(fallback.getAttribute("aria-hidden")).toBe("true");
  });

  it("ignores images outside an avatar", () => {
    document.body.innerHTML = `<img data-part="image" />`;
    const image = document.querySelector<HTMLImageElement>("img")!;

    image.dispatchEvent(new Event("error"));

    expect(image.hidden).toBe(false);
  });
});

describe("avatar fallback scan", () => {
  it("marks images that failed before the bundle loaded", async () => {
    vi.resetModules();

    document.body.innerHTML = `
      <div data-element="avatar" data-status="loading">
        <img data-part="image" src="https://example.com/broken.jpg" />
        <span data-part="fallback" aria-label="Jane" aria-hidden="true" hidden>JD</span>
      </div>
    `;

    const image = document.querySelector<HTMLImageElement>('[data-part="image"]')!;
    Object.defineProperty(image, "complete", { value: true });
    Object.defineProperty(image, "naturalWidth", { value: 0 });

    const { installAvatarFallback: install } = await import("./avatar-fallback");
    install();

    expect(document.querySelector('[data-element="avatar"]')!.getAttribute("data-status")).toBe(
      "error",
    );
    expect(document.querySelector<HTMLElement>('[data-part="fallback"]')!.hidden).toBe(false);
  });
});
