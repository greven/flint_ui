/**
 * Reads a public CSS length input from the element's computed style.
 *
 * Supports unitless values plus the `px`, `rem`, and `em` units. A computed
 * `calc()` that cannot be reduced to one length, or a missing property, falls
 * back to `fallback`.
 */
export function readCssLength(el: HTMLElement, property: string, fallback = 0): number {
  const raw = getComputedStyle(el).getPropertyValue(property).trim();
  const value = Number.parseFloat(raw);

  if (!Number.isFinite(value)) return fallback;

  if (raw.endsWith("rem")) {
    const rootSize = Number.parseFloat(getComputedStyle(document.documentElement).fontSize);

    return Number.isFinite(rootSize) ? value * rootSize : value * 16;
  }

  if (raw.endsWith("em")) {
    const localSize = Number.parseFloat(getComputedStyle(el).fontSize);

    return Number.isFinite(localSize) ? value * localSize : value * 16;
  }

  return value;
}

/**
 * Await the completion of all animations on the given element before invoking the callback.
 *
 * @param el - The element to check for animations.
 * @param callback - The function to call once all animations have completed.
 */
export function awaitAnimations(el: HTMLElement, callback: () => void): void {
  awaitAnimationsPromise(el).then(callback).catch(callback);
}

/**
 * Returns a Promise that resolves when all animations on the element have completed.
 * Uses the Web Animations API (`el.getAnimations()`) to detect both CSS transitions
 * and CSS animations.
 *
 * If no animations are running, the Promise resolves immediately on the next frame.
 * A maximum timeout of `maxTimeout` ms prevents the Promise from hanging indefinitely.
 *
 * @param el - The element to check for animations.
 * @param maxTimeout - Maximum time in ms to wait before forcing resolution. Default 5000.
 */
export function awaitAnimationsPromise(el: HTMLElement, maxTimeout = 5000): Promise<void> {
  return new Promise<void>((resolve) => {
    requestAnimationFrame(() => {
      const animations = el.getAnimations();
      if (animations.length === 0) {
        resolve();
        return;
      }

      const timeout = setTimeout(() => resolve(), maxTimeout);

      Promise.all(animations.map((a) => a.finished))
        .then(() => {
          clearTimeout(timeout);
          resolve();
        })
        .catch(() => {
          clearTimeout(timeout);
          resolve();
        });
    });
  });
}
