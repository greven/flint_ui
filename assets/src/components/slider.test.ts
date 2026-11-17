import { afterEach, describe, expect, it } from "vitest";
import { Slider } from "./slider";

interface SetupOptions {
  range?: boolean;
  readonly?: boolean;
  disabled?: boolean;
  vertical?: boolean;
  tooltip?: boolean;
  minValue?: number;
  maxValue?: number;
  value?: number;
}

const mounted: Slider[] = [];

function setup(options: SetupOptions = {}) {
  const {
    range = false,
    readonly = false,
    disabled = false,
    vertical = false,
    tooltip = false,
    minValue = 20,
    maxValue = 80,
    value = 40,
  } = options;

  const tooltipPart = (thumb?: string, offset = 0) => `
    ${
      tooltip
        ? `<span data-part="tooltip" ${thumb ? `data-thumb="${thumb}"` : ""} style="--_fl-slider-offset: ${offset}"></span>`
        : ""
    }
  `;

  document.body.innerHTML = `
    <div
      id="slider"
      data-element="slider"
      data-part="root"
      data-orientation="${vertical ? "vertical" : "horizontal"}"
      ${range ? "data-range" : ""}
      ${readonly ? "data-readonly" : ""}
      ${disabled ? "data-disabled" : ""}
      ${tooltip ? "data-show-tooltip" : ""}
    >
      <span data-part="label">Volume</span>
      <div data-part="control" style="--_fl-slider-start: 0; --_fl-slider-end: 0">
        <div data-part="track">
          <div data-part="indicator"></div>
        </div>
        ${
          range
            ? `
              <input data-part="input" type="range" data-thumb="min" min="0" max="100" step="1" value="${minValue}" />
              <input data-part="input" type="range" data-thumb="max" min="0" max="100" step="1" value="${maxValue}" />
              ${tooltipPart("min", minValue / 100)}
              ${tooltipPart("max", maxValue / 100)}
            `
            : `
              <input data-part="input" type="range" min="0" max="100" step="1" value="${value}" />
              ${tooltipPart(undefined, value / 100)}
            `
        }
      </div>
    </div>
  `;

  const el = document.getElementById("slider") as HTMLElement;
  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: () => undefined } },
  };
  const hook = new Slider(view as never, el);
  hook.mounted();
  mounted.push(hook);

  return {
    el,
    hook,
    inputs: Array.from(el.querySelectorAll<HTMLInputElement>('[data-part="input"]')),
    tooltips: Array.from(el.querySelectorAll<HTMLElement>('[data-part="tooltip"]')),
    control: el.querySelector<HTMLElement>('[data-part="control"]') as HTMLElement,
  };
}

function fill(control: HTMLElement): { start: string; end: string } {
  return {
    start: control.style.getPropertyValue("--_fl-slider-start"),
    end: control.style.getPropertyValue("--_fl-slider-end"),
  };
}

afterEach(() => {
  for (const hook of mounted.splice(0)) hook.destroyed();
  document.body.innerHTML = "";
});

describe("Slider", () => {
  it("draws the single thumb position and tooltip from the server value", () => {
    const { control, tooltips } = setup({ value: 40, tooltip: true });

    expect(fill(control)).toEqual({ start: "0", end: "0.4" });
    expect(tooltips[0]?.textContent).toBe("40");
    expect(tooltips[0]?.style.getPropertyValue("--_fl-slider-offset")).toBe("0.4");
  });

  it("draws the fill between the two thumbs of a range", () => {
    const { control } = setup({ range: true, minValue: 20, maxValue: 80 });

    expect(fill(control)).toEqual({ start: "0.2", end: "0.8" });
  });

  it("updates the fill and tooltips while dragging", () => {
    const { control, inputs, tooltips } = setup({ value: 40, tooltip: true });
    const input = inputs[0];
    if (!input) throw new Error("missing input");

    input.value = "65";
    input.dispatchEvent(new Event("input", { bubbles: true }));

    expect(fill(control).end).toBe("0.65");
    expect(tooltips[0]?.textContent).toBe("65");
  });

  it("clamps the lower thumb to the upper thumb", () => {
    const { control, inputs } = setup({ range: true, minValue: 20, maxValue: 80 });
    const [minInput, maxInput] = inputs;
    if (!minInput || !maxInput) throw new Error("missing inputs");

    minInput.value = "90";
    minInput.dispatchEvent(new Event("input", { bubbles: true }));

    expect(minInput.value).toBe("80");
    expect(fill(control).start).toBe("0.8");
  });

  it("clamps the upper thumb to the lower thumb", () => {
    const { inputs } = setup({ range: true, minValue: 20, maxValue: 80 });
    const [minInput, maxInput] = inputs;
    if (!minInput || !maxInput) throw new Error("missing inputs");

    maxInput.value = "10";
    maxInput.dispatchEvent(new Event("input", { bubbles: true }));

    expect(maxInput.value).toBe("20");
    expect(minInput.value).toBe("20");
  });

  it("restores a read-only value after an input event", () => {
    const { control, inputs } = setup({ value: 40, readonly: true });
    const input = inputs[0];
    if (!input) throw new Error("missing input");

    input.value = "90";
    input.dispatchEvent(new Event("input", { bubbles: true }));

    expect(input.value).toBe("40");
    expect(fill(control).end).toBe("0.4");
  });

  it("blocks keyboard changes while read-only", () => {
    const { inputs } = setup({ value: 40, readonly: true });
    const input = inputs[0];
    if (!input) throw new Error("missing input");

    const event = new KeyboardEvent("keydown", { key: "ArrowRight", bubbles: true, cancelable: true });
    input.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
  });

  it("re-reads the server value on update", () => {
    const { hook, control, inputs } = setup({ value: 40 });
    const input = inputs[0];
    if (!input) throw new Error("missing input");

    input.value = "70";
    hook.updated();

    expect(fill(control).end).toBe("0.7");
  });

  it("marks the root while dragging and clears it on pointer up", () => {
    const { el, inputs } = setup({ value: 40 });
    const input = inputs[0];
    if (!input) throw new Error("missing input");

    input.dispatchEvent(new Event("pointerdown", { bubbles: true }));
    expect(el.hasAttribute("data-dragging")).toBe(true);

    window.dispatchEvent(new Event("pointerup"));
    expect(el.hasAttribute("data-dragging")).toBe(false);
  });

  it("does not mark a disabled slider as dragging", () => {
    const { el, inputs } = setup({ value: 40, disabled: true });
    const input = inputs[0];
    if (!input) throw new Error("missing input");

    input.dispatchEvent(new Event("pointerdown", { bubbles: true }));

    expect(el.hasAttribute("data-dragging")).toBe(false);
  });

  it("ignores pointer downs outside the control", () => {
    const { el } = setup({ value: 40 });
    const label = el.querySelector('[data-part="label"]');
    if (!label) throw new Error("missing label");

    label.dispatchEvent(new Event("pointerdown", { bubbles: true }));

    expect(el.hasAttribute("data-dragging")).toBe(false);
  });
});
