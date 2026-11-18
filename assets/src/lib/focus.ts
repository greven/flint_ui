const FOCUSABLE = [
  "a[href]",
  "area[href]",
  "button:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  "iframe",
  "object",
  "embed",
  "[contenteditable]",
  "[tabindex]:not([tabindex='-1'])",
].join(",");

/**
 * Returns the focusable elements inside `root` in DOM order.
 *
 * Disabled controls, elements hidden from assistive technology, and elements
 * inside an inert subtree are skipped.
 */
export function focusable(root: HTMLElement): HTMLElement[] {
  return Array.from(root.querySelectorAll<HTMLElement>(FOCUSABLE)).filter(
    (element) =>
      !element.hasAttribute("disabled") &&
      element.getAttribute("aria-hidden") !== "true" &&
      !element.closest("[inert]"),
  );
}

/**
 * Moves focus to the first `[autofocus]` element, then the first focusable
 * element, then `fallback`.
 */
export function focusFirst(root: HTMLElement, fallback: HTMLElement): void {
  const autofocus = root.querySelector<HTMLElement>("[autofocus]");
  const target = autofocus ?? focusable(root)[0] ?? fallback;

  try {
    target.focus();
  } catch {
    fallback.focus();
  }
}
