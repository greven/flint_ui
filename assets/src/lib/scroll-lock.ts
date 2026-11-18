let locks = 0;
let previousOverflow = "";
let previousPaddingRight = "";

/**
 * Locks page scroll. The lock is reference-counted so nested modals keep the
 * page locked until the last one closes.
 *
 * The scrollbar width is compensated with inline padding on the root element so
 * the page does not shift horizontally when the scrollbar disappears.
 */
export function lockScroll(): void {
  if (typeof document === "undefined") return;

  if (locks === 0) {
    const root = document.documentElement;
    const scrollbar = window.innerWidth - root.clientWidth;

    previousOverflow = root.style.overflow;
    previousPaddingRight = root.style.paddingRight;

    root.style.overflow = "hidden";

    if (scrollbar > 0) {
      root.style.paddingRight = `${scrollbar}px`;
    }
  }

  locks += 1;
}

/**
 * Releases one scroll lock. The page unlocks when the last holder releases it.
 */
export function unlockScroll(): void {
  if (locks === 0) return;

  locks -= 1;

  if (locks > 0) return;

  const root = document.documentElement;

  root.style.overflow = previousOverflow;
  root.style.paddingRight = previousPaddingRight;
}

/**
 * Drops every lock and restores the page. Intended for tests and teardown.
 */
export function resetScrollLock(): void {
  locks = 0;
  previousOverflow = "";
  previousPaddingRight = "";

  if (typeof document === "undefined") return;

  const root = document.documentElement;
  root.style.overflow = "";
  root.style.paddingRight = "";
}
