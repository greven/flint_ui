import { afterEach, beforeAll, beforeEach, describe, expect, it, vi } from "vitest";
import { installCopy } from "./copy";

const STATUS_ID = "flint-copy-status";

beforeAll(() => {
  installCopy();
});

beforeEach(() => {
  vi.useFakeTimers();
  document.body.innerHTML = `
    <span id="install-command">mix flint.add copy_button</span>
    <a id="profile-link" href="/profile">Profile</a>
    <input id="email-input" value="hello@example.com" />
  `;
});

afterEach(() => {
  vi.useRealTimers();
  vi.restoreAllMocks();
  document.body.innerHTML = "";
  setClipboard(undefined);
  setExecCommand(undefined);
});

function setClipboard(writeText: ((text: string) => Promise<void>) | undefined): void {
  Object.defineProperty(navigator, "clipboard", {
    value: writeText ? { writeText } : undefined,
    configurable: true,
  });
}

function setExecCommand(command: (() => boolean) | undefined): void {
  Object.defineProperty(document, "execCommand", {
    value: command,
    configurable: true,
  });
}

function trigger(markup: string): HTMLButtonElement {
  const wrapper = document.createElement("div");
  wrapper.innerHTML = markup;
  document.body.appendChild(wrapper);
  return wrapper.querySelector("button") as HTMLButtonElement;
}

async function flush(): Promise<void> {
  for (let i = 0; i < 5; i++) await Promise.resolve();
}

async function click(el: HTMLElement): Promise<MouseEvent> {
  const event = new MouseEvent("click", { bubbles: true, cancelable: true });
  el.dispatchEvent(event);
  await flush();
  return event;
}

function status(): string {
  return document.getElementById(STATUS_ID)?.textContent ?? "";
}

describe("copy behavior", () => {
  it("copies a literal value and reports success", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);
    const el = trigger(`<button data-copy data-copy-value="hello">Copy</button>`);

    await click(el);

    expect(writeText).toHaveBeenCalledWith("hello");
    expect(el.getAttribute("data-state")).toBe("success");
    expect(status()).toBe("Copied");
  });

  it("copies the target text content", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);
    const el = trigger(`<button data-copy data-copy-from="install-command">Copy</button>`);

    await click(el);

    expect(writeText).toHaveBeenCalledWith("mix flint.add copy_button");
  });

  it("copies an attribute from the target", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);

    const el = trigger(
      `<button data-copy data-copy-from="profile-link" data-copy-attribute="href">Copy</button>`,
    );

    await click(el);

    expect(writeText).toHaveBeenCalledWith("/profile");
  });

  it("copies a property from the target", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);

    const el = trigger(
      `<button data-copy data-copy-from="email-input" data-copy-property="value">Copy</button>`,
    );

    await click(el);

    expect(writeText).toHaveBeenCalledWith("hello@example.com");
  });

  it("prefers from over value", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);

    const el = trigger(
      `<button data-copy data-copy-value="literal" data-copy-from="install-command">Copy</button>`,
    );

    await click(el);

    expect(writeText).toHaveBeenCalledWith("mix flint.add copy_button");
  });

  it("announces and marks a failure when the target is missing", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);
    const el = trigger(`<button data-copy data-copy-from="nope">Copy</button>`);

    await click(el);

    expect(writeText).not.toHaveBeenCalled();
    expect(el.getAttribute("data-state")).toBe("error");
    expect(status()).toBe("Copy failed");
  });

  it("treats an empty source as an error", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);
    const el = trigger(`<button data-copy data-copy-value="">Copy</button>`);

    await click(el);

    expect(writeText).not.toHaveBeenCalled();
    expect(el.getAttribute("data-state")).toBe("error");
  });

  it("reports a clipboard rejection", async () => {
    setClipboard(vi.fn(async () => Promise.reject(new Error("Denied"))));
    const el = trigger(`<button data-copy data-copy-value="hello">Copy</button>`);

    await click(el);

    expect(el.getAttribute("data-state")).toBe("error");
  });

  it("falls back to execCommand when the Clipboard API is unavailable", async () => {
    setClipboard(undefined);
    const execCommand = vi.fn(() => true);
    setExecCommand(execCommand);
    const el = trigger(`<button data-copy data-copy-value="hello">Copy</button>`);

    await click(el);

    expect(execCommand).toHaveBeenCalledWith("copy");
    expect(el.getAttribute("data-state")).toBe("success");
  });

  it("uses the configured labels and duration", async () => {
    setClipboard(vi.fn(async () => undefined));

    const el = trigger(`
      <button
        data-copy
        data-copy-value="hello"
        data-copy-duration="500"
        data-copy-success-label="Link copied"
      >Copy</button>
    `);

    await click(el);

    expect(status()).toBe("Link copied");

    vi.advanceTimersByTime(499);
    expect(el.getAttribute("data-state")).toBe("success");

    vi.advanceTimersByTime(1);
    expect(el.getAttribute("data-state")).toBeNull();
  });

  it("resets the feedback timer on repeated clicks", async () => {
    setClipboard(vi.fn(async () => undefined));
    const el = trigger(`<button data-copy data-copy-value="hello">Copy</button>`);

    await click(el);
    vi.advanceTimersByTime(1000);

    await click(el);
    vi.advanceTimersByTime(1999);

    expect(el.getAttribute("data-state")).toBe("success");

    vi.advanceTimersByTime(1);
    expect(el.getAttribute("data-state")).toBeNull();
  });

  it("ignores a disabled trigger", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);
    const el = trigger(`<button data-copy data-copy-value="hello" data-disabled>Copy</button>`);

    await click(el);

    expect(writeText).not.toHaveBeenCalled();
    expect(el.getAttribute("data-state")).toBeNull();
  });

  it("ignores an aria-disabled trigger", async () => {
    const writeText = vi.fn(async () => undefined);
    setClipboard(writeText);
    const el = trigger(
      `<button data-copy data-copy-value="hello" aria-disabled="true">Copy</button>`,
    );

    await click(el);

    expect(writeText).not.toHaveBeenCalled();
  });

  it("does not prevent the click from reaching other handlers", async () => {
    setClipboard(vi.fn(async () => undefined));
    const el = trigger(`<button data-copy data-copy-value="hello">Copy</button>`);
    const listener = vi.fn();
    el.addEventListener("click", listener);

    const event = await click(el);

    expect(listener).toHaveBeenCalledTimes(1);
    expect(event.defaultPrevented).toBe(false);
  });

  it("creates one shared status region", async () => {
    setClipboard(vi.fn(async () => undefined));

    const first = trigger(`<button data-copy data-copy-value="one">Copy</button>`);
    const second = trigger(`<button data-copy data-copy-value="two">Copy</button>`);

    await click(first);
    await click(second);

    expect(document.querySelectorAll(`#${STATUS_ID}`).length).toBe(1);
  });

  it("re-announces the same message", async () => {
    setClipboard(vi.fn(async () => undefined));
    const el = trigger(`<button data-copy data-copy-value="hello">Copy</button>`);

    await click(el);
    const region = document.getElementById(STATUS_ID) as HTMLElement;
    region.textContent = "";

    await click(el);

    expect(region.textContent).toBe("Copied");
  });
});
