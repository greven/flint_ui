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
  transitions: TransitionSet;
}

interface PresenceOptions {
  present: boolean;
  liveSocket: LiveSocketLike;
  mountPrevented?: boolean;
  cssVarPrefix?: string;
}

interface PresenceResult {
  done: Promise<void>;
}

/**
 * Orchestrates the enter/leave animation lifecycle for an element.
 *
 * Implements the freeze → measure → set CSS vars → unfreeze → reflow pattern
 * required for smooth CSS-based show/hide transitions.
 *
 * Uses `this.liveSocket.transitions.addAsyncTransition()` to integrate with
 * Phoenix LiveView's animation lock, preventing server DOM patches from
 * interfering with running animations.
 *
 * Sets CSS custom properties on the element:
 * - `--fl-{prefix}-height`: natural scroll height in pixels
 * - `--fl-{prefix}-width`: natural scroll width in pixels
 *
 * The prefix defaults to `"presence"` and can be customized via `cssVarPrefix`.
 * For example, `cssVarPrefix: "collapsible"` produces `--fl-collapsible-height`
 * and `--fl-collapsible-width`.
 *
 * @param el - The element to animate.
 * @param opts - Animation options.
 * @returns An object with a `done` Promise that resolves when the animation completes.
 */
export function animatePresence(
  el: HTMLElement,
  opts: PresenceOptions,
): PresenceResult {
  const {
    present,
    liveSocket,
    mountPrevented = false,
    cssVarPrefix = "presence",
  } = opts;

  // Freeze animations to get an accurate measurement of natural size
  const origTransition = el.style.transitionDuration;
  const origAnimation = el.style.animationName;
  el.style.transitionDuration = "0s";
  el.style.animationName = "none";

  // Measure size and set CSS custom properties
  el.style.setProperty(`--fl-${cssVarPrefix}-height`, `${el.offsetHeight}px`);
  el.style.setProperty(`--fl-${cssVarPrefix}-width`, `${el.offsetWidth}px`);

  // Restore animations (skip on initial mount to prevent a flash)
  if (!mountPrevented) {
    el.style.transitionDuration = origTransition;
    el.style.animationName = origAnimation;
  }

  // Force synchronous reflow on show so the browser picks up the CSS var
  // values before the data-state switch triggers the transition
  if (present) {
    // eslint-disable-next-line @typescript-eslint/no-unused-expressions
    el.offsetHeight;
  }

  // Wait for all running animations/transitions to finish, with a timeout fallback.
  // Integrate with Phoenix's TransitionSet so server DOM patches queue behind us.
  const done = awaitAnimationsPromise(el);
  liveSocket.transitions.addAsyncTransition(done);

  return { done };
}
