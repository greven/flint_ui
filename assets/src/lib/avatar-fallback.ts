type AvatarStatus = "loaded" | "error";

let installed = false;

function directPart(root: HTMLElement, name: string): HTMLElement | null {
  for (const child of Array.from(root.children)) {
    if (child.getAttribute("data-part") === name) return child as HTMLElement;
  }
  return null;
}

function hasLabel(fallback: HTMLElement): boolean {
  const label = fallback.getAttribute("aria-label") ?? "";
  return label.trim() !== "";
}

function setState(image: HTMLImageElement, status: AvatarStatus): void {
  const root = image.closest<HTMLElement>('[data-element="avatar"]');
  if (!root || image.getAttribute("data-part") !== "image") return;

  const fallback = directPart(root, "fallback");
  root.setAttribute("data-status", status);

  if (status === "error") {
    image.hidden = true;
    image.setAttribute("aria-hidden", "true");

    if (fallback) {
      fallback.hidden = false;

      if (hasLabel(fallback)) {
        fallback.removeAttribute("aria-hidden");
      } else {
        fallback.setAttribute("aria-hidden", "true");
      }
    }
  } else {
    image.hidden = false;
    image.removeAttribute("aria-hidden");

    if (fallback) {
      fallback.hidden = true;
      fallback.setAttribute("aria-hidden", "true");
    }
  }
}

function handleState(event: Event, status: AvatarStatus): void {
  const target = event.target;
  if (!(target instanceof HTMLImageElement)) return;
  setState(target, status);
}

function scanCompleteImages(): void {
  document
    .querySelectorAll<HTMLImageElement>('img[data-part="image"]')
    .forEach((image) => {
      if (!image.closest('[data-element="avatar"]')) return;
      if (!image.complete) return;

      setState(image, image.naturalWidth === 0 ? "error" : "loaded");
    });
}

/**
 * Reveals an avatar's fallback when its image fails to load, and restores the
 * image when a later `src` loads. A document-level capture listener is used
 * instead of a hook so avatars do not need a unique DOM id.
 */
export function installAvatarFallback(): void {
  if (installed) return;
  installed = true;

  document.addEventListener(
    "error",
    (event) => handleState(event, "error"),
    true,
  );
  document.addEventListener(
    "load",
    (event) => handleState(event, "loaded"),
    true,
  );

  scanCompleteImages();
}
