import { FlintHook } from "../lib/core";

const FIELDS = ["day", "month", "year"] as const;

type FieldName = (typeof FIELDS)[number];

function twoDigits(value: number): string {
  return String(value).padStart(2, "0");
}

function daysInMonth(year: number, month: number): number {
  if (month === 2) {
    const leap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
    return leap ? 29 : 28;
  }

  return [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1] ?? 0;
}

/**
 * Composes the three visible parts into the canonical ISO date the hidden
 * input submits. Returns `null` while the value is incomplete or invalid.
 */
function compose(parts: Record<FieldName, string>): string | null {
  if (!FIELDS.every((name) => /^\d+$/.test(parts[name]))) return null;

  // A two-digit year is almost always a typo in a known date, not a shorthand.
  if (parts.year.length !== 4) return null;

  const day = Number(parts.day);
  const month = Number(parts.month);
  const year = Number(parts.year);

  if (year < 1 || year > 9999) return null;
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > daysInMonth(year, month)) return null;

  return `${String(year).padStart(4, "0")}-${twoDigits(month)}-${twoDigits(day)}`;
}

/**
 * Keeps the hidden canonical ISO value in sync with the three visible part
 * inputs. The parts carry no names, so this hidden input is the only date
 * parameter the form submits.
 */
export class KnownDate extends FlintHook {
  private hidden: HTMLInputElement | null = null;
  private inputs = new Map<FieldName, HTMLInputElement>();
  private controller: AbortController | null = null;

  mounted(): void {
    super.mounted();

    this.controller = new AbortController();
    const options = { signal: this.controller.signal };

    this.el.addEventListener("input", this.handleInput, options);
    this.el.addEventListener("change", this.handleInput, options);

    this.capture();
  }

  updated(): void {
    this.capture();
  }

  destroyed(): void {
    this.controller?.abort();
    this.controller = null;
  }

  private capture(): void {
    this.refreshParts();

    this.hidden = this.el.querySelector<HTMLInputElement>('[data-part="value"]');
    this.inputs.clear();

    for (const name of FIELDS) {
      const input = this.el.querySelector<HTMLInputElement>(
        `[data-part="control"][data-field="${name}"]`,
      );

      if (input) this.inputs.set(name, input);
    }

    // Seed the hidden value from the server-rendered parts without surfacing a
    // validation bubble for a value that was already out of range on load.
    this.sync(false);
  }

  private readonly handleInput = (): void => {
    this.sync(true);
  };

  private sync(validate: boolean): void {
    const hidden = this.hidden;
    if (!hidden) return;

    for (const input of this.inputs.values()) input.setCustomValidity("");

    if (this.el.hasAttribute("disabled") || this.el.hasAttribute("data-disabled")) {
      hidden.disabled = true;
      return;
    }

    const parts = {} as Record<FieldName, string>;

    for (const name of FIELDS) {
      parts[name] = this.inputs.get(name)?.value.trim() ?? "";
    }

    if (!FIELDS.every((name) => parts[name] !== "")) {
      hidden.value = "";
      hidden.disabled = true;
      return;
    }

    const iso = compose(parts);

    if (!iso) {
      hidden.value = "";
      hidden.disabled = true;
      if (validate) this.firstInput()?.setCustomValidity("Enter a valid date.");
      return;
    }

    const min = this.el.getAttribute("data-min");
    const max = this.el.getAttribute("data-max");

    if (min && iso < min) {
      hidden.value = "";
      hidden.disabled = true;
      if (validate) this.firstInput()?.setCustomValidity(`Date must be on or after ${min}.`);
      return;
    }

    if (max && iso > max) {
      hidden.value = "";
      hidden.disabled = true;
      if (validate) this.firstInput()?.setCustomValidity(`Date must be on or before ${max}.`);
      return;
    }

    hidden.value = iso;
    hidden.disabled = false;
  }

  private firstInput(): HTMLInputElement | undefined {
    return this.inputs.values().next().value;
  }
}
