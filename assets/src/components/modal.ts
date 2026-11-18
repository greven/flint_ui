import { FlintHook } from "../lib/core";
import { focusFirst } from "../lib/focus";
import { lockScroll, unlockScroll } from "../lib/scroll-lock";
import { awaitAnimationsPromise } from "../lib/util";

enum Events {
  Open = "fl:modal:open",
  Close = "fl:modal:close",
  Toggle = "fl:modal:toggle",
  Change = "fl:modal:change",
}

type ModalState = "open" | "closed";

interface ShowOptions {
  emit?: boolean;
}

interface HideOptions {
  emit?: boolean;
}

/**
 * Owns the client-side half of a modal.
 *
 * The root is a native `<dialog>`, so the browser provides the top layer,
 * background inertness, focus containment, focus restoration, and the
 * `cancel` event. This hook adds the parts the browser leaves to the author:
 * server-driven open state, scroll locking, backdrop dismissal, exit
 * animation, and the FlintUI state and server events.
 */
export class Modal extends FlintHook {
  private state: ModalState = "closed";
  private closeOnEsc = true;
  private closeOnBackdrop = true;
  private lockScroll = true;

  private scrollLocked = false;
  private opener: HTMLElement | null = null;
  private pointerDownOnBackdrop = false;

  private syncedOpened = false;
  private generation = 0;

  // --- Config and state ---

  private readConfig(): void {
    this.closeOnEsc = this.el.hasAttribute("data-close-on-esc");
    this.closeOnBackdrop = this.el.hasAttribute("data-close-on-backdrop");
    this.lockScroll = this.el.hasAttribute("data-lock-scroll");
  }

  private serverOpened(): boolean {
    return this.el.getAttribute("data-opened") === "true";
  }

  private dialog(): HTMLDialogElement {
    return this.el as HTMLDialogElement;
  }

  private setState(state: ModalState): void {
    this.js().setAttribute(this.el, "data-state", state);
  }

  private dispatch(event: Events, detail?: Record<string, unknown>): void {
    this.el.dispatchEvent(new CustomEvent(event, { bubbles: true, detail }));
  }

  private emitChange(state: ModalState): void {
    this.dispatch(Events.Change, { state });
  }

  private pushStateEvents(state: ModalState, emit: boolean): void {
    if (!emit) return;

    const isOpen = state === "open";
    const payload = { id: this.el.id, open: isOpen };
    const { openEvent, closeEvent, toggleEvent } = this.el.dataset;

    if (isOpen && openEvent) this.pushEvent(openEvent, payload);
    if (!isOpen && closeEvent) this.pushEvent(closeEvent, payload);
    if (toggleEvent) this.pushEvent(toggleEvent, payload);
  }

  // --- Scroll lock ---

  private syncScrollLock(): void {
    if (this.lockScroll && !this.scrollLocked) {
      lockScroll();
      this.scrollLocked = true;
      return;
    }

    if (!this.lockScroll && this.scrollLocked) {
      unlockScroll();
      this.scrollLocked = false;
    }
  }

  private releaseScroll(): void {
    if (!this.scrollLocked) return;

    unlockScroll();
    this.scrollLocked = false;
  }

  // --- Focus ---

  private rememberOpener(): void {
    const active = document.activeElement;

    if (!(active instanceof HTMLElement)) return;
    if (active === document.body || this.el.contains(active)) return;

    this.opener = active;
  }

  private restoreFocus(): void {
    const opener = this.opener;
    this.opener = null;

    if (!opener?.isConnected) return;

    try {
      opener.focus();
    } catch {
      // The element may have become unavailable between the check and the call.
    }
  }

  private focusInitial(): void {
    const content = this.parts.content;
    if (!content) return;

    focusFirst(content, content);
  }

  // --- Opening and closing ---

  private show(options: ShowOptions = {}): void {
    const { emit = true } = options;

    if (this.state === "open") return;

    this.rememberOpener();

    try {
      // The dialog may still be open from a previous close animation or from a
      // server-rendered `open` attribute. Resetting first keeps `showModal()`
      // from throwing on a non-modal or already-open dialog.
      if (this.el.hasAttribute("open")) this.dialog().close();
      this.dialog().showModal();
    } catch {
      return;
    }

    this.generation += 1;
    this.state = "open";
    this.setState("open");
    this.syncScrollLock();
    this.focusInitial();
    this.emitChange("open");
    this.pushStateEvents("open", emit);
  }

  private hide(options: HideOptions = {}): void {
    const { emit = true } = options;

    if (this.state !== "open") {
      this.releaseScroll();
      return;
    }

    this.state = "closed";
    this.setState("closed");
    this.emitChange("closed");
    this.pushStateEvents("closed", emit);

    const generation = ++this.generation;

    awaitAnimationsPromise(this.el).then(() => {
      if (generation !== this.generation || this.state !== "closed") return;

      try {
        if (this.el.hasAttribute("open")) this.dialog().close();
      } catch {
        // Already hidden or detached.
      }

      this.releaseScroll();
      this.restoreFocus();
    });
  }

  // --- Event handlers ---

  private handleCancel = (event: Event): void => {
    // The browser would close immediately. Take over the close so the exit
    // animation, state hooks, and server events stay in one path.
    event.preventDefault();

    if (this.closeOnEsc) this.hide({ emit: true });
  };

  private handleNativeClose = (): void => {
    if (this.state === "open") {
      // The dialog was closed outside the hook, for example by a form with
      // `method="dialog"` or by application code calling `close()`.
      this.state = "closed";
      this.setState("closed");
      this.emitChange("closed");
      this.pushStateEvents("closed", true);
      this.releaseScroll();
      this.restoreFocus();
      return;
    }

    this.releaseScroll();
  };

  private handlePointerDown = (event: PointerEvent): void => {
    this.pointerDownOnBackdrop = event.target === this.el;
  };

  private handleClick = (event: MouseEvent): void => {
    const startedOnBackdrop = this.pointerDownOnBackdrop;
    this.pointerDownOnBackdrop = false;

    if (this.state !== "open" || !this.closeOnBackdrop) return;
    if (!startedOnBackdrop || event.target !== this.el) return;

    this.hide({ emit: true });
  };

  private handleOpenCommand = (): void => {
    this.show({ emit: true });
  };

  private handleCloseCommand = (): void => {
    this.hide({ emit: true });
  };

  private handleToggleCommand = (): void => {
    if (this.state === "open") {
      this.hide({ emit: true });
    } else {
      this.show({ emit: true });
    }
  };

  // --- Lifecycle ---

  mounted() {
    super.mounted();

    this.readConfig();
    this.syncedOpened = this.serverOpened();
    this.setState("closed");

    this.el.addEventListener("cancel", this.handleCancel);
    this.el.addEventListener("close", this.handleNativeClose);
    this.el.addEventListener("pointerdown", this.handlePointerDown);
    this.el.addEventListener("click", this.handleClick);

    this.el.addEventListener(Events.Open, this.handleOpenCommand);
    this.el.addEventListener(Events.Close, this.handleCloseCommand);
    this.el.addEventListener(Events.Toggle, this.handleToggleCommand);

    if (this.syncedOpened) this.show({ emit: false });
  }

  updated() {
    this.refreshParts();
    this.readConfig();

    const nextOpened = this.serverOpened();
    const openedChanged = nextOpened !== this.syncedOpened;

    this.syncedOpened = nextOpened;

    if (this.state === "open" && !this.el.hasAttribute("open")) {
      this.state = "closed";
      this.setState("closed");
      this.releaseScroll();
    }

    if (openedChanged) {
      if (nextOpened) {
        this.show({ emit: false });
      } else {
        this.hide({ emit: false });
      }
    }

    if (this.state === "open") this.syncScrollLock();
  }

  destroyed() {
    this.generation += 1;

    this.el.removeEventListener("cancel", this.handleCancel);
    this.el.removeEventListener("close", this.handleNativeClose);
    this.el.removeEventListener("pointerdown", this.handlePointerDown);
    this.el.removeEventListener("click", this.handleClick);

    this.el.removeEventListener(Events.Open, this.handleOpenCommand);
    this.el.removeEventListener(Events.Close, this.handleCloseCommand);
    this.el.removeEventListener(Events.Toggle, this.handleToggleCommand);

    this.releaseScroll();
    this.opener = null;

    try {
      if (this.el.hasAttribute("open")) this.dialog().close();
    } catch {
      // Already hidden or detached.
    }
  }
}
