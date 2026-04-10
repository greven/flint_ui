import { ViewHook } from "phoenix_live_view";

export abstract class FlintHook extends ViewHook {
  parts = {} as Record<string, HTMLElement>;

  mounted() {
    this.parts = getParts(this.el);
  }
}

/**
 * Utility function to extract data parts for a given element.
 * This function is used inside Hooks to get the elements corresponding to the `data-part` attributes.
 *
 * @param el - The root element to extract parts from.
 *
 * @returns An object where the keys are the values of the `data-part` attributes and the values are the corresponding elements.
 *
 * @example
 * Given the following HTML structure:
 * <div id="my-component" phx-hook="MyHook">
 *   <button data-part="trigger">Toggle</button>
 *   <div data-part="content">Content</div>
 * </div>
 * `data-part` attributes.
 *
 * Calling `getParts(document.getElementById("my-component"))` would return:
 * {
 *   trigger: HTMLButtonElement,
 *   content: HTMLDivElement
 * }
 */
export function getParts(el: HTMLElement): Record<string, HTMLElement> {
  const parts: Record<string, HTMLElement> = {};
  el.querySelectorAll("[data-part]").forEach((partEl) => {
    const partName = partEl.getAttribute("data-part");
    if (partName) {
      parts[partName] = partEl as HTMLElement;
    }
  });
  return parts;
}
