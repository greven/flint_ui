/**
 * Pending FlintUI controls stay focusable and announced, but must not activate.
 *
 * The guard is installed once when the core bundle loads. It only reacts to
 * elements marked `[data-element="button"][data-loading]`, so it is opt-in per
 * control. It is progressive enhancement: server handlers must still guard,
 * because requests can bypass the button and the bundle can be absent.
 */

const PENDING_SELECTOR = '[data-element="button"][data-loading]';

const PENDING_SUBMIT_SELECTOR = [
  '[data-element="button"][data-loading][type="submit"]',
  '[data-element="button"][data-loading]:not([type])',
].join(",");

let installed = false;

function pendingFor(target: EventTarget | null): Element | null {
  if (!(target instanceof Element)) return null;
  return target.closest(PENDING_SELECTOR);
}

function handleClick(event: MouseEvent): void {
  if (!pendingFor(event.target)) return;
  event.preventDefault();
  event.stopImmediatePropagation();
}

function pendingSubmitter(event: SubmitEvent): Element | null {
  const submitter = event.submitter;
  if (submitter) return pendingFor(submitter);

  // Some synthetic submits omit the submitter. In that case, only block when
  // the form contains a pending submit button.
  return event.target instanceof Element
    ? event.target.querySelector(PENDING_SUBMIT_SELECTOR)
    : null;
}

function handleSubmit(event: SubmitEvent): void {
  if (!pendingSubmitter(event)) return;
  event.preventDefault();
  event.stopImmediatePropagation();
}

export function installPendingGuard(): void {
  if (installed || typeof document === "undefined") return;
  installed = true;
  document.addEventListener("click", handleClick, true);
  document.addEventListener("submit", handleSubmit, true);
}
