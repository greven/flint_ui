# Pending implementations

Contributor reference for settled decisions not yet shipped (excluded from Hex). Once an entry ships, move its contract to `@moduledoc` and the docs page, then delete it here.

## Pending state for forms & status (`in progress`)

**Shipped (contracts now live in `FlintUI.Base.Button`, `FlintUI.Base.Toggle`, `flint.js`):**

- `loading` sets `aria-busy="true"`, `aria-disabled="true"`, `data-loading` (never native `disabled`), drops link destinations (`role="link"`, `tabindex="0"`), swaps submit buttons/toggles to `type="button"` + `data-pending-submit`, and blocks activation in `flint.js` capture-phase listeners.

**Settled decisions for remaining work:**

- **Server guard is mandatory:** Every pending event needs a guard clause (`def handle_event("save", _, %{assigns: %{saving: true}} = socket), do: {:noreply, socket}`).
- **Announcements:** Use a persistent `role="status"` (polite) region _outside_ the form/button and toggle its text (`"Saving…"`, `"Saved"`). Keep the control's accessible name stable; never rely on `aria-busy` alone to announce.
- **LiveView compatibility:** Never combine `phx-disable-with` with `loading` (it sets native `disabled` and replaces `textContent`). Note that `phx-submit` locks the form only until the server reply; `loading` covers async work after the reply.

**Deferred:**

- [ ] **Forms guide:** Document server guard, `phx-submit` vs. `phx-click`, external `role="status"` region, and focus-loss trade-offs.
- [ ] **`Status` live-region component** so users don't hand-write `role="status"`.
- [ ] **`Form`/`Field` pending contract:** How form-level `loading` composes with validation errors and submit guards.
- [ ] **In-flight client window:** Announce `phx-click-loading` / `phx-submit-loading` before the server reply (currently only server `@saving` is announced).
- [ ] **Focus restoration** after a non-navigating `phx-submit`.
- [ ] **Spinner semantics:** Decide if labelled `FlintUI.loading` should use `role="progressbar"` (enabling `aria-labelledby` spinner pattern) vs. `role="img"`.
- [ ] **Alias check:** Decide whether to add `data-pending` alongside `data-loading`.

**Open questions:**

- Should `<form>` carry `aria-busy` while pending (may defer updates inside the form; status region must stay outside)?
- Should the submit guard live in a `Form` component or stay a documented convention?

---

## Group and input groups (`deferred`)

**Settled decisions:**

- **Group stays child-agnostic:** `Group` (`role="group"`) targets direct children (`> *`) and exposes `--fl-control-*` size/radius tokens; it never takes on field anatomy (`<label for>`, `aria-describedby`, `aria-invalid`).
- **Compound input groups belong to `Input`/`Field`:** Prefix/unit addons, leading/trailing icons, clear/visibility buttons, and the shared outer border/focus ring live inside the field component.
- **Field sizing:** Field reuses `--fl-control-*` heights and adds inline padding in its own CSS.
- **Docs copy:** Say "any control" in Group docs rather than naming unshipped controls.

**Open questions:**

- How should a field root join an attached `Group` when the border is on the nested control rather than the wrapper (e.g., `display: contents` breaks the box holding label/hint/errors)?
- Should native `<input>` inherit Group `size`, or only `[data-element="input"]`?
