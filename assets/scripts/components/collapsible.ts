export function bindHookElement(hook, hookName, elementName) {
  const element = hook.el.querySelector(`[data-${hookName}-${elementName}]`);

  if (element) {
    hook[`${elementName}El`] = element;
  }
}

// ----------------------------------------------------------------

const ELEMENTS = ["trigger", "content"];
const TOGGLE_EVENT = "fl:collapsible:toggle";

export const Collapsible = {
  mounted() {
    // State
    this.isOpen = false;

    // Elements
    ELEMENTS.forEach((elementName) => {
      bindHookElement(this, "collapsible", elementName);
    });

    // Events
    this.el.addEventListener(TOGGLE_EVENT, this.toggle.bind(this));
  },

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  },

  open() {
    this.isOpen = true;

    this.el.setAttribute("data-state", "open");
    this.triggerEl.setAttribute("data-state", "open");
    this.triggerEl.setAttribute("aria-expanded", this.isOpen);
    this.contentEl.setAttribute("aria-hidden", !this.isOpen);
    this.contentEl.hidden = !this.isOpen;
  },

  close() {
    this.isOpen = false;

    this.el.setAttribute("data-state", "closed");
    this.triggerEl.setAttribute("data-state", "closed");
    this.triggerEl.setAttribute("aria-expanded", this.isOpen);
    this.contentEl.setAttribute("aria-hidden", !this.isOpen);
    this.contentEl.hidden = !this.isOpen;
  },
};
