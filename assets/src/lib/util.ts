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
export function awaitAnimationsPromise(
  el: HTMLElement,
  maxTimeout = 5000,
): Promise<void> {
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
