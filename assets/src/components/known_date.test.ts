import { afterEach, describe, expect, it } from "vitest";
import { KnownDate } from "./known_date";

const mounted: KnownDate[] = [];

interface SetupOptions {
  day?: string;
  month?: string;
  year?: string;
  min?: string;
  max?: string;
  disabled?: boolean;
}

function setup(options: SetupOptions = {}) {
  const { day = "", month = "", year = "", min, max, disabled = false } = options;

  document.body.innerHTML = `
    <fieldset
      id="known-date"
      data-element="known_date"
      data-known_date
      data-part="root"
      ${disabled ? "disabled" : ""}
      ${min ? `data-min="${min}"` : ""}
      ${max ? `data-max="${max}"` : ""}
    >
      <div data-part="fields">
        <div data-part="field" data-field="day">
          <label data-part="field_label" for="known-date-day">Day</label>
          <input data-part="control" data-field="day" id="known-date-day" value="${day}" />
        </div>
        <div data-part="field" data-field="month">
          <label data-part="field_label" for="known-date-month">Month</label>
          <input data-part="control" data-field="month" id="known-date-month" value="${month}" />
        </div>
        <div data-part="field" data-field="year">
          <label data-part="field_label" for="known-date-year">Year</label>
          <input data-part="control" data-field="year" id="known-date-year" value="${year}" />
        </div>
      </div>
      <input data-part="value" type="hidden" name="date_of_birth" />
    </fieldset>
  `;

  const el = document.getElementById("known-date") as HTMLFieldSetElement;
  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: () => undefined } },
  };

  const hook = new KnownDate(view as never, el);
  hook.mounted();
  mounted.push(hook);

  return {
    el,
    hook,
    hidden: el.querySelector<HTMLInputElement>('[data-part="value"]')!,
    fields: {
      day: el.querySelector<HTMLInputElement>('[data-field="day"][data-part="control"]')!,
      month: el.querySelector<HTMLInputElement>('[data-field="month"][data-part="control"]')!,
      year: el.querySelector<HTMLInputElement>('[data-field="year"][data-part="control"]')!,
    },
  };
}

function type(input: HTMLInputElement, value: string): void {
  input.value = value;
  input.dispatchEvent(new Event("input", { bubbles: true }));
}

afterEach(() => {
  mounted.splice(0).forEach((hook) => hook.destroyed());
  document.body.innerHTML = "";
});

describe("known date", () => {
  it("composes a complete date into the canonical ISO hidden value", () => {
    const { fields, hidden } = setup();

    type(fields.day, "27");
    type(fields.month, "3");
    type(fields.year, "2007");

    expect(hidden.value).toBe("2007-03-27");
    expect(hidden.disabled).toBe(false);
  });

  it("keeps the hidden value disabled while the date is partial", () => {
    const { fields, hidden } = setup();

    type(fields.day, "27");
    type(fields.month, "3");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
  });

  it("rejects an impossible date and exposes it through constraint validation", () => {
    const { fields, hidden } = setup();

    type(fields.day, "30");
    type(fields.month, "2");
    type(fields.year, "2007");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Enter a valid date.");
  });

  it("accepts a leap day", () => {
    const { fields, hidden } = setup();

    type(fields.day, "29");
    type(fields.month, "2");
    type(fields.year, "2008");

    expect(hidden.value).toBe("2008-02-29");
  });

  it("rejects a month outside 1-12", () => {
    const { fields, hidden } = setup();

    type(fields.day, "1");
    type(fields.month, "13");
    type(fields.year, "2007");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Enter a valid date.");
  });

  it("rejects day zero", () => {
    const { fields, hidden } = setup();

    type(fields.day, "0");
    type(fields.month, "1");
    type(fields.year, "2007");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Enter a valid date.");
  });

  it("rejects a day that the month does not have", () => {
    const { fields, hidden } = setup();

    type(fields.day, "31");
    type(fields.month, "4");
    type(fields.year, "2007");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Enter a valid date.");
  });

  it("rejects February 29 outside a leap year", () => {
    const { fields, hidden } = setup();

    type(fields.day, "29");
    type(fields.month, "2");
    type(fields.year, "2007");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Enter a valid date.");
  });

  it("rejects non-digit input", () => {
    const { fields, hidden } = setup();

    type(fields.day, "3a");
    type(fields.month, "3");
    type(fields.year, "2007");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Enter a valid date.");
  });

  it("clears the validation message when the date is corrected", () => {
    const { fields, hidden } = setup();

    type(fields.day, "30");
    type(fields.month, "2");
    type(fields.year, "2007");

    expect(fields.day.validationMessage).toBe("Enter a valid date.");

    type(fields.day, "28");

    expect(hidden.value).toBe("2007-02-28");
    expect(hidden.disabled).toBe(false);
    expect(fields.day.validationMessage).toBe("");
  });

  it("rejects a two-digit year", () => {
    const { fields, hidden } = setup();

    type(fields.day, "1");
    type(fields.month, "1");
    type(fields.year, "07");

    expect(hidden.value).toBe("");
    expect(hidden.disabled).toBe(true);
  });

  it("enforces min and max", () => {
    const { fields, hidden } = setup({ min: "2000-01-01", max: "2010-12-31" });

    type(fields.day, "1");
    type(fields.month, "1");
    type(fields.year, "1999");

    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Date must be on or after 2000-01-01.");

    type(fields.year, "2011");

    expect(hidden.disabled).toBe(true);
    expect(fields.day.validationMessage).toBe("Date must be on or before 2010-12-31.");

    type(fields.year, "2005");

    expect(hidden.value).toBe("2005-01-01");
    expect(hidden.disabled).toBe(false);
    expect(fields.day.validationMessage).toBe("");
  });

  it("keeps a disabled group out of the submission", () => {
    const { fields, hidden } = setup({ disabled: true, day: "27", month: "3", year: "2007" });

    type(fields.day, "28");

    expect(hidden.disabled).toBe(true);
  });

  it("re-captures the parts after a server update", () => {
    const { el, hook, hidden } = setup({ day: "27", month: "3", year: "2007" });

    const day = el.querySelector<HTMLInputElement>('[data-field="day"][data-part="control"]')!;
    day.value = "28";

    hook.updated();

    expect(hidden.value).toBe("2007-03-28");
  });
});
