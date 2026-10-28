import { afterEach, beforeAll, describe, expect, it, vi } from "vitest";
import { installPendingGuard } from "./pending";

beforeAll(() => installPendingGuard());

afterEach(() => {
  document.body.innerHTML = "";
  vi.restoreAllMocks();
});

function click(target: Element): MouseEvent {
  const event = new MouseEvent("click", { bubbles: true, cancelable: true });
  target.dispatchEvent(event);
  return event;
}

function submit(form: HTMLFormElement, submitter?: HTMLButtonElement): SubmitEvent {
  const event = new SubmitEvent("submit", {
    bubbles: true,
    cancelable: true,
    submitter,
  });
  form.dispatchEvent(event);
  return event;
}

function listen(target: EventTarget, type: string) {
  const spy = vi.fn();
  const controller = new AbortController();
  target.addEventListener(type, spy, { signal: controller.signal });
  return { spy, controller };
}

describe("pending guard", () => {
  it("cancels a click on a pending button", () => {
    document.body.innerHTML = `
      <button data-element="button" data-loading>
        <span id="label">Save</span>
      </button>
    `;
    const { spy, controller } = listen(document, "click");

    const event = click(document.getElementById("label")!);

    expect(event.defaultPrevented).toBe(true);
    expect(spy).not.toHaveBeenCalled();
    controller.abort();
  });

  it("allows a click on an active button", () => {
    document.body.innerHTML = `<button data-element="button">Save</button>`;
    const { spy, controller } = listen(document, "click");

    const event = click(document.querySelector("button")!);

    expect(event.defaultPrevented).toBe(false);
    expect(spy).toHaveBeenCalledTimes(1);
    controller.abort();
  });

  it("cancels a click on a pending link", () => {
    document.body.innerHTML = `<a data-element="button" data-loading href="/x">Save</a>`;

    const event = click(document.querySelector("a")!);

    expect(event.defaultPrevented).toBe(true);
  });

  it("cancels a submit whose submitter is pending", () => {
    document.body.innerHTML = `
      <form id="form">
        <button id="submit" type="submit" data-element="button" data-loading>Save</button>
      </form>
    `;
    const form = document.getElementById("form") as HTMLFormElement;
    const submitter = document.getElementById("submit") as HTMLButtonElement;
    const { spy, controller } = listen(form, "submit");

    const event = submit(form, submitter);

    expect(event.defaultPrevented).toBe(true);
    expect(spy).not.toHaveBeenCalled();
    controller.abort();
  });

  it("allows a submit whose submitter is active", () => {
    document.body.innerHTML = `
      <form id="form">
        <button id="submit" type="submit" data-element="button">Save</button>
      </form>
    `;
    const form = document.getElementById("form") as HTMLFormElement;
    const submitter = document.getElementById("submit") as HTMLButtonElement;
    const { spy, controller } = listen(form, "submit");

    const event = submit(form, submitter);

    expect(event.defaultPrevented).toBe(false);
    expect(spy).toHaveBeenCalledTimes(1);
    controller.abort();
  });

  it("cancels a submit without a submitter when the form has a pending submit button", () => {
    document.body.innerHTML = `
      <form id="form">
        <button type="submit" data-element="button" data-loading>Save</button>
      </form>
    `;
    const form = document.getElementById("form") as HTMLFormElement;

    const event = submit(form);

    expect(event.defaultPrevented).toBe(true);
  });

  it("does not block a submit for a pending non-submit button", () => {
    document.body.innerHTML = `
      <form id="form">
        <button type="button" data-element="button" data-loading>Cancel</button>
      </form>
    `;
    const form = document.getElementById("form") as HTMLFormElement;

    const event = submit(form);

    expect(event.defaultPrevented).toBe(false);
  });
});
