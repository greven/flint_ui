import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { resetScrollLock } from "../lib/scroll-lock";
import { Modal } from "./modal";

interface SetupOptions {
  opened?: boolean;
  closeOnEsc?: boolean;
  closeOnBackdrop?: boolean;
  lockScroll?: boolean;
  openEvent?: string;
  closeEvent?: string;
  toggleEvent?: string;
  autofocus?: boolean;
  focusable?: boolean;
}

const mounted: Modal[] = [];

function setup(options: SetupOptions = {}) {
  const {
    opened = false,
    closeOnEsc = true,
    closeOnBackdrop = true,
    lockScroll = true,
    openEvent,
    closeEvent,
    toggleEvent,
    autofocus = false,
    focusable = true,
  } = options;

  document.body.innerHTML = `
    <button id="opener">Open</button>
    <dialog
      id="modal"
      data-element="modal"
      data-part="root"
      data-opened="${opened}"
      data-state="closed"
      ${closeOnEsc ? "data-close-on-esc" : ""}
      ${closeOnBackdrop ? "data-close-on-backdrop" : ""}
      ${lockScroll ? "data-lock-scroll" : ""}
      ${openEvent ? `data-open-event="${openEvent}"` : ""}
      ${closeEvent ? `data-close-event="${closeEvent}"` : ""}
      ${toggleEvent ? `data-toggle-event="${toggleEvent}"` : ""}
    >
      <div data-part="content" tabindex="-1">
        <header data-part="header">
          <h2 data-part="title" id="modal-title">Title</h2>
        </header>
        <div data-part="body">
          ${focusable ? `<button id="inside" ${autofocus ? "autofocus" : ""}>Inside</button>` : ""}
        </div>
        <footer data-part="footer">
          <button id="cancel">Cancel</button>
        </footer>
        <button data-part="close" aria-label="Close">x</button>
      </div>
    </dialog>
  `;

  const el = document.getElementById("modal") as unknown as HTMLDialogElement;
  const opener = document.getElementById("opener") as HTMLButtonElement;
  const view = {
    isDead: false,
    liveSocket: { transitions: { addAsyncTransition: vi.fn() } },
  };

  const hook = new Modal(view as never, el as unknown as HTMLElement);

  const js = {
    setAttribute: vi.fn((node: HTMLElement, name: string, value: string) =>
      node.setAttribute(name, value),
    ),
    removeAttribute: vi.fn((node: HTMLElement, name: string) => node.removeAttribute(name)),
  };
  vi.spyOn(hook, "js").mockReturnValue(js as never);

  const pushEvent = vi.spyOn(hook, "pushEvent").mockImplementation(async () => {});

  hook.mounted();
  mounted.push(hook);

  return { el, opener, hook, js, pushEvent, view };
}

const flush = () => new Promise((resolve) => setTimeout(resolve, 20));

function command(element: HTMLElement, name: string) {
  element.dispatchEvent(new CustomEvent(name, { bubbles: true }));
}

function escape(element: HTMLElement) {
  return element.dispatchEvent(new Event("cancel", { cancelable: true, bubbles: true }));
}

function backdrop(element: HTMLElement) {
  element.dispatchEvent(new MouseEvent("pointerdown", { bubbles: true }));
  element.dispatchEvent(new MouseEvent("click", { bubbles: true }));
}

beforeEach(() => {
  resetScrollLock();
});

afterEach(() => {
  mounted.splice(0).forEach((hook) => hook.destroyed());
  document.body.innerHTML = "";
  resetScrollLock();
  vi.restoreAllMocks();
});

describe("Modal hook", () => {
  it("starts closed", () => {
    const { el } = setup();

    expect(el.dataset.state).toBe("closed");
    expect(el.hasAttribute("open")).toBe(false);
    expect(document.documentElement.style.overflow).toBe("");
  });

  it("opens on the command, focuses into the dialog, and locks scroll", () => {
    const { el, opener } = setup();

    opener.focus();
    command(el, "fl:modal:open");

    expect(el.dataset.state).toBe("open");
    expect(el.hasAttribute("open")).toBe(true);
    expect(document.activeElement?.id).toBe("inside");
    expect(document.documentElement.style.overflow).toBe("hidden");
  });

  it("opens from the initial server state without pushing a server event", () => {
    const { el, pushEvent } = setup({ opened: true });

    expect(el.dataset.state).toBe("open");
    expect(el.hasAttribute("open")).toBe(true);
    expect(document.activeElement?.id).toBe("inside");
    expect(pushEvent).not.toHaveBeenCalled();
  });

  it("prefers an autofocus element over the first focusable control", () => {
    const { el } = setup({ autofocus: true });

    command(el, "fl:modal:open");

    expect(document.activeElement?.id).toBe("inside");
  });

  it("focuses the content container when there is no focusable child", () => {
    const { el } = setup({ focusable: false });

    el.querySelectorAll("button").forEach((button) => button.remove());
    command(el, "fl:modal:open");

    expect(document.activeElement).toBe(el.querySelector('[data-part="content"]'));
  });

  it("closes on the command, restores scroll, and returns focus", async () => {
    const { el, opener } = setup();

    opener.focus();
    command(el, "fl:modal:open");
    command(el, "fl:modal:close");
    await flush();

    expect(el.dataset.state).toBe("closed");
    expect(el.hasAttribute("open")).toBe(false);
    expect(document.documentElement.style.overflow).toBe("");
    expect(document.activeElement).toBe(opener);
  });

  it("closes on Escape", async () => {
    const { el } = setup();

    command(el, "fl:modal:open");
    const prevented = !escape(el);
    await flush();

    expect(prevented).toBe(true);
    expect(el.dataset.state).toBe("closed");
    expect(el.hasAttribute("open")).toBe(false);
  });

  it("keeps the dialog open on Escape when close_on_esc is false", async () => {
    const { el } = setup({ closeOnEsc: false });

    command(el, "fl:modal:open");
    escape(el);
    await flush();

    expect(el.dataset.state).toBe("open");
    expect(el.hasAttribute("open")).toBe(true);
  });

  it("closes on a backdrop pointer sequence", async () => {
    const { el } = setup();

    command(el, "fl:modal:open");
    backdrop(el);
    await flush();

    expect(el.dataset.state).toBe("closed");
  });

  it("does not close on a backdrop click when close_on_backdrop is false", async () => {
    const { el } = setup({ closeOnBackdrop: false });

    command(el, "fl:modal:open");
    backdrop(el);
    await flush();

    expect(el.dataset.state).toBe("open");
  });

  it("syncs a native close event and pushes close", async () => {
    const { el, pushEvent } = setup({ closeEvent: "modal_closed" });

    command(el, "fl:modal:open");
    el.close();

    expect(el.dataset.state).toBe("closed");
    expect(document.documentElement.style.overflow).toBe("");
    expect(pushEvent).toHaveBeenCalledWith("modal_closed", {
      id: "modal",
      open: false,
    });
  });

  it("pushes open, toggle, and close server events for user changes", async () => {
    const { el, pushEvent } = setup({
      openEvent: "opened",
      closeEvent: "closed",
      toggleEvent: "toggled",
    });

    command(el, "fl:modal:open");
    command(el, "fl:modal:close");
    await flush();

    expect(pushEvent).toHaveBeenCalledWith("opened", {
      id: "modal",
      open: true,
    });
    expect(pushEvent).toHaveBeenCalledWith("toggled", {
      id: "modal",
      open: true,
    });
    expect(pushEvent).toHaveBeenCalledWith("closed", {
      id: "modal",
      open: false,
    });
    expect(pushEvent).toHaveBeenCalledWith("toggled", {
      id: "modal",
      open: false,
    });
  });

  it("toggles between open and closed", async () => {
    const { el } = setup();

    command(el, "fl:modal:toggle");
    expect(el.dataset.state).toBe("open");

    command(el, "fl:modal:toggle");
    await flush();
    expect(el.dataset.state).toBe("closed");
  });

  it("applies a changed opened input on update without pushing events", async () => {
    const { el, hook, pushEvent } = setup({
      openEvent: "opened",
      closeEvent: "closed",
    });

    el.dataset.opened = "true";
    hook.updated();

    expect(el.dataset.state).toBe("open");
    expect(pushEvent).not.toHaveBeenCalled();

    el.dataset.opened = "false";
    hook.updated();
    await flush();

    expect(el.dataset.state).toBe("closed");
    expect(pushEvent).not.toHaveBeenCalled();
  });

  it("does not lock scroll when lock_scroll is false", () => {
    const { el } = setup({ lockScroll: false });

    command(el, "fl:modal:open");

    expect(document.documentElement.style.overflow).toBe("");
  });

  it("releases the lock and closes the dialog when destroyed", () => {
    const { el, hook } = setup();

    command(el, "fl:modal:open");
    hook.destroyed();
    mounted.splice(mounted.indexOf(hook), 1);

    expect(document.documentElement.style.overflow).toBe("");
    expect(el.hasAttribute("open")).toBe(false);
  });
});
