import { FlintHook } from "../lib/core";

const NAVIGATION_KEYS = new Set([
  "ArrowLeft",
  "ArrowRight",
  "ArrowUp",
  "ArrowDown",
  "Home",
  "End",
  "PageUp",
  "PageDown",
]);

export class Slider extends FlintHook {
  private inputs: HTMLInputElement[] = [];
  private tooltips: HTMLElement[] = [];
  private committed = new Map<HTMLInputElement, string>();
  private controller: AbortController | null = null;

  mounted(): void {
    super.mounted();

    this.controller = new AbortController();
    const options = { signal: this.controller.signal };

    // Listen on the root so server-rendered replacements of the inputs keep
    // working without another bind pass.
    this.el.addEventListener("input", this.handleInput, options);
    this.el.addEventListener("keydown", this.handleKeydown, options);
    this.el.addEventListener("pointerdown", this.handlePointerDown, options);
    window.addEventListener("pointerup", this.handlePointerUp, options);
    window.addEventListener("pointercancel", this.handlePointerUp, options);

    this.capture();
  }

  updated(): void {
    this.capture();
  }

  destroyed(): void {
    this.controller?.abort();
    this.controller = null;
  }

  private get readonly(): boolean {
    return this.el.hasAttribute("data-readonly");
  }

  private get disabled(): boolean {
    return this.el.hasAttribute("data-disabled");
  }

  private get vertical(): boolean {
    return this.el.getAttribute("data-orientation") === "vertical";
  }

  /**
   * Re-reads the parts after a server patch, records the server values, and
   * redraws the fill and tooltips.
   */
  private capture(): void {
    this.refreshParts();

    this.inputs = Array.from(this.el.querySelectorAll<HTMLInputElement>('[data-part="input"]'));
    this.tooltips = Array.from(this.el.querySelectorAll<HTMLElement>('[data-part="tooltip"]'));

    this.rememberValues();
    this.render();
  }

  private rememberValues(): void {
    for (const input of this.inputs) {
      this.committed.set(input, input.value);
    }
  }

  private numberAttribute(input: HTMLInputElement, name: string, fallback: number): number {
    const value = Number.parseFloat(input.getAttribute(name) ?? "");
    return Number.isFinite(value) ? value : fallback;
  }

  private bounds(): { min: number; max: number } {
    const input = this.inputs[0];
    if (!input) return { min: 0, max: 100 };

    return {
      min: this.numberAttribute(input, "min", 0),
      max: this.numberAttribute(input, "max", 100),
    };
  }

  private fraction(value: string): number {
    const { min, max } = this.bounds();
    const span = max - min;
    if (!(span > 0)) return 0;

    const numeric = Number.parseFloat(value);
    if (!Number.isFinite(numeric)) return 0;

    return Math.min(1, Math.max(0, (numeric - min) / span));
  }

  private render(): void {
    const control = this.parts.control;
    const [first, second] = this.inputs;
    if (!control || !first) return;

    const start = second ? this.fraction(first.value) : 0;
    const end = second ? this.fraction(second.value) : this.fraction(first.value);

    control.style.setProperty("--_fl-slider-start", String(start));
    control.style.setProperty("--_fl-slider-end", String(end));

    if (second) {
      this.updateTooltip(this.tooltips[0], first.value, start);
      this.updateTooltip(this.tooltips[1], second.value, end);
    } else {
      this.updateTooltip(this.tooltips[0], first.value, end);
    }
  }

  private updateTooltip(tooltip: HTMLElement | undefined, value: string, offset: number): void {
    if (!tooltip) return;

    tooltip.textContent = value;
    tooltip.style.setProperty("--_fl-slider-offset", String(offset));
  }

  /**
   * Keeps the lower thumb at or below the upper thumb. The input that moved is
   * clamped to the other thumb, so neither can cross the other.
   */
  private clamp(input: HTMLInputElement): void {
    const [minInput, maxInput] = this.inputs;
    if (!minInput || !maxInput) return;

    const min = Number.parseFloat(minInput.value);
    const max = Number.parseFloat(maxInput.value);

    if (input === minInput && min > max) {
      minInput.value = maxInput.value;
    } else if (input === maxInput && max < min) {
      maxInput.value = minInput.value;
    }
  }

  private setDragging(active: boolean): void {
    if (active) {
      this.el.setAttribute("data-dragging", "");
    } else {
      this.el.removeAttribute("data-dragging");
    }
  }

  private nearestInput(value: number): HTMLInputElement | null {
    const [first, second] = this.inputs;
    if (!first) return null;
    if (!second) return first;

    const firstValue = Number.parseFloat(first.value);
    const secondValue = Number.parseFloat(second.value);
    const firstDistance = Math.abs(firstValue - value);
    const secondDistance = Math.abs(secondValue - value);

    if (firstDistance === secondDistance) {
      // Coincident thumbs: a click to the right grows the upper thumb, so the
      // lower thumb does not immediately clamp back into place.
      return value >= firstValue ? second : first;
    }

    return secondDistance < firstDistance ? second : first;
  }

  private valueAt(ratio: number): number {
    const input = this.inputs[0];
    if (!input) return 0;

    const { min, max } = this.bounds();
    const step = this.numberAttribute(input, "step", 1);
    const clamped = Math.min(1, Math.max(0, ratio));
    const raw = min + clamped * (max - min);
    const stepped = step > 0 ? min + Math.round((raw - min) / step) * step : raw;

    return Math.min(max, Math.max(min, Number(stepped.toFixed(6))));
  }

  /**
   * Moves the closest thumb to a click on the rail. Thumbs themselves receive
   * the pointer directly, so this only runs for the empty part of the track.
   */
  private jumpTo(event: PointerEvent): void {
    const track = this.parts.track;
    if (!track) return;

    const rect = track.getBoundingClientRect();
    if (rect.width === 0 && rect.height === 0) return;

    const horizontal = (event.clientX - rect.left) / rect.width;
    const rtl = getComputedStyle(this.el).direction === "rtl";
    const ratio = this.vertical
      ? (rect.bottom - event.clientY) / rect.height
      : rtl
        ? 1 - horizontal
        : horizontal;

    const value = this.valueAt(ratio);
    const input = this.nearestInput(value);
    if (!input) return;

    input.value = String(value);
    input.focus();
    input.dispatchEvent(new Event("input", { bubbles: true }));
  }

  private handleInput = (event: Event): void => {
    const input = event.target;
    if (!(input instanceof HTMLInputElement) || !this.inputs.includes(input)) return;

    if (this.readonly) {
      input.value = this.committed.get(input) ?? input.value;
      this.render();
      return;
    }

    this.clamp(input);
    this.rememberValues();
    this.render();
  };

  private handleKeydown = (event: KeyboardEvent): void => {
    if (!this.readonly || !NAVIGATION_KEYS.has(event.key)) return;

    // The native range would change on these keys. The value is captured on
    // mount and restored if a change still slips through.
    event.preventDefault();
  };

  private handlePointerDown = (event: PointerEvent): void => {
    // Pointer events elsewhere in the field, such as the label or the errors,
    // must not move a thumb or mark the slider as dragging.
    const control = this.parts.control;
    if (!control || !control.contains(event.target as Node)) return;
    if (this.disabled) return;

    this.setDragging(true);

    if (this.readonly) return;
    if (event.target instanceof HTMLInputElement) return;

    this.jumpTo(event);
  };

  private handlePointerUp = (): void => {
    this.setDragging(false);
  };
}
