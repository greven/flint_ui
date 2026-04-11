/**
 * Await the completion of all animations on the given element before invoking the callback.
 *
 * @param el - The element to check for animations.
 * @param callback - The function to call once all animations have completed.
 */
export function awaitAnimations(el: HTMLElement, callback: () => void): void {
  requestAnimationFrame(() => {
    const animations = el.getAnimations();
    if (animations.length === 0) {
      callback();
      return;
    }
    Promise.all(animations.map((a) => a.finished))
      .then(callback)
      .catch(callback);
  });
}
