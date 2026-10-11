import { awaitAnimationsPromise } from "./util";

/**
 * Minimal interface for the `TransitionSet` on `LiveSocket`.
 * The public `LiveSocketInstanceInterface` type does not expose `transitions`,
 * but the runtime object has it and hooks access it via `this.liveSocket.transitions`.
 */
interface TransitionSet {
  addAsyncTransition(promise: Promise<void>): void;
}

interface LiveSocketLike {
  transitions?: TransitionSet;
}

interface PresenceOptions {
  liveSocket: LiveSocketLike;
  cssVarPrefix?: string;
  /**
   * Called synchronously while animations are frozen, after the natural size has
   * been measured and published as CSS variables. Flip `data-state` here so the
   * enter/leave keyframes run from the freshly measured size.
   */
  applyState?: () => void;
}

interface PresenceResult {
  done: Promise<void>;
}

/**
 * Orchestrates a CSS keyframe enter/leave transition.
 *
 * Follows the Radix/Ark model: freeze the element's animations, measure its
 * natural size into `--fl-{prefix}-height` / `--fl-{prefix}-width`, let the
 * caller apply `data-state`, then release the keyframes for that state and wait
 * for them to finish.
 *
 * When available, uses `liveSocket.transitions.addAsyncTransition()` to integrate
 * with Phoenix LiveView's animation lock, preventing server DOM patches from
 * interfering with running animations. This is a private LiveView API, so it is
 * feature-detected and skipped when absent.
 *
 * @param el - The element to animate.
 * @param opts - Animation options.
 * @returns An object with a `done` Promise that resolves when the animation completes.
 */
export function animatePresence(el: HTMLElement, opts: PresenceOptions): PresenceResult {
  const { liveSocket, cssVarPrefix = "presence", applyState } = opts;

  // Freeze animations so the measuring reflow cannot start the wrong keyframes,
  // and so a re-measure of async/patched content reads the natural size.
  el.style.animationName = "none";

  // `scrollHeight`/`scrollWidth` describe the natural content size even when the
  // element is clipped to `height: 0`.
  el.style.setProperty(`--fl-${cssVarPrefix}-height`, `${el.scrollHeight}px`);
  el.style.setProperty(`--fl-${cssVarPrefix}-width`, `${el.scrollWidth}px`);

  // Apply the target state while frozen, then release the keyframes for it.
  applyState?.();
  el.style.animationName = "";

  // Wait for all running animations to finish, with a timeout fallback.
  const done = awaitAnimationsPromise(el);

  const transitions = liveSocket.transitions;
  if (transitions && typeof transitions.addAsyncTransition === "function") {
    transitions.addAsyncTransition(done);
  }

  return { done };
}
