const SELECTOR = 'input[type="checkbox"][data-indeterminate]';

let installed = false;

function isCheckbox(node: Node | null): node is HTMLInputElement {
  return node instanceof HTMLInputElement && node.type === "checkbox";
}

/**
 * Mirrors the server-rendered `data-indeterminate` hook onto the native
 * `indeterminate` DOM property. The property is not an HTML attribute and
 * cannot be set from HEEx, but it is what exposes the mixed state to assistive
 * technology. CSS already paints the dash from the data hook, so this is
 * progressive enhancement.
 */
function sync(input: HTMLInputElement): void {
  const indeterminate = input.getAttribute("data-indeterminate") === "true";
  if (input.indeterminate !== indeterminate) input.indeterminate = indeterminate;
}

function syncTree(root: ParentNode): void {
  if (root instanceof HTMLInputElement) {
    if (root.matches(SELECTOR)) sync(root);
    return;
  }

  root.querySelectorAll<HTMLInputElement>(SELECTOR).forEach(sync);
}

function handleMutations(records: MutationRecord[]): void {
  for (const record of records) {
    if (record.type === "attributes") {
      if (isCheckbox(record.target)) sync(record.target);
      continue;
    }

    record.addedNodes.forEach((node) => {
      if (node instanceof Element) syncTree(node);
    });
  }
}

/**
 * Keeps native checkbox indeterminate state in sync with FlintUI's
 * `data-indeterminate` hook, including LiveView patches. Installed once by the
 * core bundle, so the checkbox needs no hook or unique DOM id.
 */
export function installIndeterminate(): void {
  if (installed || typeof document === "undefined") return;
  installed = true;

  syncTree(document);

  if (typeof MutationObserver === "undefined") return;

  new MutationObserver(handleMutations).observe(document, {
    subtree: true,
    childList: true,
    attributes: true,
    attributeFilter: ["data-indeterminate", "type"],
  });
}
