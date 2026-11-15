// jsdom does not implement these browser APIs used by the tooltip and the
// presence engine.

if (typeof Element !== "undefined" && !Element.prototype.getAnimations) {
  Element.prototype.getAnimations = () => [];
}

if (typeof globalThis.requestAnimationFrame !== "function") {
  globalThis.requestAnimationFrame = ((cb: FrameRequestCallback) =>
    setTimeout(
      () => cb(performance.now()),
      0,
    ) as unknown as number) as typeof requestAnimationFrame;
}

// jsdom has no Popover API. These stubs mirror the part the tooltip relies on:
// an element can be shown and hidden, and the test can observe the transition.
if (typeof HTMLElement !== "undefined" && !HTMLElement.prototype.showPopover) {
  HTMLElement.prototype.showPopover = function showPopover(this: HTMLElement) {
    this.dataset.popover = "open";
  };

  HTMLElement.prototype.hidePopover = function hidePopover(this: HTMLElement) {
    delete this.dataset.popover;
  };
}
