/**
 * Pending FlintUI controls stay focusable, but must not activate. Disabled
 * links also keep their click handlers in the markup, so the guard blocks them
 * too. Buttons and toggles are the activation controls: a toggle updates its
 * own `aria-pressed`/`data-state` client-side, so a pending toggle must have
 * that click cancelled as well.
 *
 * The guard is installed once when the core bundle loads. It is progressive
 * enhancement: server handlers must still guard, because requests can bypass
 * the button and the bundle can be absent.
 */

const CONTROL_SELECTOR = ':is([data-element="button"], [data-element="toggle"])';
const PENDING_SELECTOR = `${CONTROL_SELECTOR}[data-loading]`;
const DISABLED_SELECTOR = `${CONTROL_SELECTOR}[data-disabled]`;
const CLICK_SELECTOR = `${PENDING_SELECTOR}, ${DISABLED_SELECTOR}`;

const PENDING_SUBMIT_SELECTOR = [
  `${PENDING_SELECTOR}[type="submit"]`,
  `${PENDING_SELECTOR}:not([type])`,
  `${PENDING_SELECTOR}[data-pending-submit]`,
].join(",");

let installed = false;

function closestFor(target: EventTarget | null, selector: string): Element | null {
  if (!(target instanceof Element)) return null;
  return target.closest(selector);
}

function pendingFor(target: EventTarget | null): Element | null {
  return closestFor(target, PENDING_SELECTOR);
}

function handleClick(event: MouseEvent): void {
  if (!closestFor(event.target, CLICK_SELECTOR)) return;
  event.preventDefault();
  event.stopImmediatePropagation();
}

function pendingSubmitter(event: SubmitEvent): Element | null {
  const submitter = event.submitter;
  if (submitter) return pendingFor(submitter);

  // Some synthetic submits omit the submitter. In that case, only block when
  // the form contains a pending submit button, including one that rendered
  // with `type="button"` while pending.
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
