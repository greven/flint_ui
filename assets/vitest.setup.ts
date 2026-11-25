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

// jsdom does not implement the dialog methods the modal hook calls. Mirror the
// observable part: `showModal()` sets the `open` attribute, and `close()`
// clears it and fires the native `close` event.
if (typeof HTMLElement !== "undefined") {
  const dialog =
    typeof HTMLDialogElement !== "undefined" ? HTMLDialogElement.prototype : HTMLElement.prototype;

  if (!dialog.showModal) {
    dialog.showModal = function showModal(this: HTMLElement) {
      this.setAttribute("open", "");
    };
  }

  if (!dialog.close) {
    dialog.close = function close(this: HTMLElement) {
      this.removeAttribute("open");
      this.dispatchEvent(new Event("close"));
    };
  }
}

// jsdom's default stylesheet hides `[popover]` elements that are not in the
// `:popover-open` state. The stub cannot enter that state, so keep the content
// visible for focus and layout assertions.
if (typeof document !== "undefined") {
  const style = document.createElement("style");
  style.textContent = "[popover] { display: block !important; }";
  document.head.appendChild(style);
}
