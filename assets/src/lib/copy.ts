/**
 * Copy behavior for `[data-copy]` triggers.
 *
 * The behavior is installed once by the core bundle and delegated from the
 * document, so a copy button needs no hook or unique DOM id. The same contract
 * can be attached to any button-like element. The trigger is never prevented
 * from handling the click, so a LiveView `phx-click` can run alongside it.
 *
 * State is client-only: `data-state="success"` or `"error"` is added for
 * `data-copy-duration` milliseconds, then removed. The result is announced
 * through one shared status region, so the trigger's accessible name never
 * changes.
 */

const TRIGGER = "[data-copy]";
const STATUS_ID = "flint-copy-status";
const DEFAULT_DURATION = 2000;
const DEFAULT_SUCCESS_LABEL = "Copied";
const DEFAULT_ERROR_LABEL = "Copy failed";

const timers = new WeakMap<Element, ReturnType<typeof setTimeout>>();
let installed = false;

interface CopySource {
  value: string | undefined;
  from: string | undefined;
  attribute: string | undefined;
  property: string | undefined;
  duration: number;
  successLabel: string;
  errorLabel: string;
}

function sourceFor(el: HTMLElement): CopySource {
  const duration = Number.parseInt(el.dataset.copyDuration ?? "", 10);

  return {
    value: el.dataset.copyValue,
    from: el.dataset.copyFrom,
    attribute: el.dataset.copyAttribute,
    property: el.dataset.copyProperty,
    duration: Number.isFinite(duration) && duration >= 0 ? duration : DEFAULT_DURATION,
    successLabel: el.dataset.copySuccessLabel || DEFAULT_SUCCESS_LABEL,
    errorLabel: el.dataset.copyErrorLabel || DEFAULT_ERROR_LABEL,
  };
}

/**
 * Resolves the text to copy. `from` wins over `value`; `property` wins over
 * `attribute`; text content is the fallback. A missing target or an absent
 * attribute resolves to the empty string, which the caller treats as an error.
 */
function resolveText(source: CopySource): string {
  if (!source.from) return source.value ?? "";

  const target = document.getElementById(source.from);
  if (!target) return "";

  if (source.property) {
    const value = (target as unknown as Record<string, unknown>)[source.property];
    return value === null || value === undefined ? "" : String(value);
  }

  if (source.attribute) return target.getAttribute(source.attribute) ?? "";

  return target.textContent ?? "";
}

function fallbackCopy(text: string): boolean {
  if (typeof document.execCommand !== "function") return false;

  const active = document.activeElement;
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "fixed";
  textarea.style.top = "-9999px";
  textarea.style.opacity = "0";
  document.body.appendChild(textarea);
  textarea.select();

  let copied = false;

  try {
    copied = document.execCommand("copy");
  } catch {
    copied = false;
  }

  textarea.remove();
  if (active instanceof HTMLElement) active.focus();

  return copied;
}

async function writeText(text: string): Promise<void> {
  if (navigator.clipboard && typeof navigator.clipboard.writeText === "function") {
    try {
      await navigator.clipboard.writeText(text);
      return;
    } catch (error) {
      if (fallbackCopy(text)) return;
      throw error;
    }
  }

  if (fallbackCopy(text)) return;
  throw new Error("Clipboard is unavailable");
}

function statusRegion(): HTMLElement | null {
  if (!document.body) return null;

  const existing = document.getElementById(STATUS_ID);
  if (existing) return existing;

  const region = document.createElement("div");
  region.id = STATUS_ID;
  region.setAttribute("role", "status");
  region.setAttribute("aria-live", "polite");
  region.setAttribute("aria-atomic", "true");
  region.style.cssText =
    "position:fixed;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0 0 0 0);clip-path:inset(50%);white-space:nowrap;border:0;";
  document.body.appendChild(region);

  return region;
}

/**
 * Replaces the status text. Clearing first and writing on the next microtask
 * makes a repeated message announce again.
 */
function announce(message: string): void {
  const region = statusRegion();
  if (!region) return;

  region.textContent = "";
  queueMicrotask(() => {
    region.textContent = message;
  });
}

function clearTimer(el: Element): void {
  const timer = timers.get(el);
  if (timer === undefined) return;

  clearTimeout(timer);
  timers.delete(el);
}

function setState(el: HTMLElement, state: "success" | "error", source: CopySource): void {
  clearTimer(el);
  el.setAttribute("data-state", state);
  announce(state === "success" ? source.successLabel : source.errorLabel);

  const timer = setTimeout(() => {
    el.removeAttribute("data-state");
    timers.delete(el);
  }, source.duration);

  timers.set(el, timer);
}

function triggerFor(target: EventTarget | null): HTMLElement | null {
  if (!(target instanceof Element)) return null;

  const trigger = target.closest<HTMLElement>(TRIGGER);
  if (!trigger) return null;

  return trigger;
}

function isDisabled(el: HTMLElement): boolean {
  if (el.hasAttribute("data-disabled")) return true;
  if (el.getAttribute("aria-disabled") === "true") return true;

  return (el instanceof HTMLButtonElement || el instanceof HTMLInputElement) && el.disabled;
}

async function copy(el: HTMLElement, source: CopySource): Promise<void> {
  clearTimer(el);

  try {
    const text = resolveText(source);
    if (text === "") throw new Error("Nothing to copy");

    await writeText(text);
    setState(el, "success", source);
  } catch {
    setState(el, "error", source);
  }
}

function handleClick(event: MouseEvent): void {
  const el = triggerFor(event.target);
  if (!el || isDisabled(el)) return;

  void copy(el, sourceFor(el));
}

/**
 * Installs the delegated copy behavior. It is idempotent and safe to call from
 * more than one bundle entry.
 */
export function installCopy(): void {
  if (installed || typeof document === "undefined") return;
  installed = true;

  statusRegion();
  document.addEventListener("click", handleClick);
}
