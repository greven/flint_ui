import { afterEach, beforeAll, describe, expect, it } from "vitest";
import { installIndeterminate } from "./indeterminate";

const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

beforeAll(() => {
  installIndeterminate();
});

afterEach(() => {
  document.body.innerHTML = "";
});

function checkbox(attributes = ""): HTMLInputElement {
  document.body.innerHTML = `<input type="checkbox" ${attributes} />`;
  return document.querySelector<HTMLInputElement>("input")!;
}

describe("indeterminate form state", () => {
  it("mirrors the data hook onto the native property", async () => {
    const input = checkbox('data-indeterminate="true"');

    await tick();

    expect(input.indeterminate).toBe(true);
  });

  it("ignores an explicit false hook", async () => {
    const input = checkbox('data-indeterminate="false"');

    await tick();

    expect(input.indeterminate).toBe(false);
  });

  it("updates when the hook is added or removed", async () => {
    const input = checkbox();

    await tick();
    expect(input.indeterminate).toBe(false);

    input.setAttribute("data-indeterminate", "true");
    await tick();
    expect(input.indeterminate).toBe(true);

    input.removeAttribute("data-indeterminate");
    await tick();
    expect(input.indeterminate).toBe(false);
  });

  it("syncs checkboxes inside an added subtree", async () => {
    document.body.innerHTML = `<div id="container"></div>`;
    const container = document.getElementById("container")!;

    container.innerHTML = `
      <label>
        <input type="checkbox" data-indeterminate="true" />
      </label>
    `;

    await tick();

    expect(container.querySelector("input")!.indeterminate).toBe(true);
  });

  it("ignores inputs that are not checkboxes", async () => {
    document.body.innerHTML = `<input type="text" data-indeterminate="true" />`;
    const input = document.querySelector<HTMLInputElement>("input")!;

    await tick();

    expect(input.indeterminate).toBe(false);
  });
});
