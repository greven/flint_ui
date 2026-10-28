# Pending implementations

This file records decisions that are settled but not fully shipped. It is a
contributor reference, not user documentation, and is not included in the Hex
package.

When an entry ships, move its settled contract into the component moduledoc and
the docs page, then delete the entry here. Keep open questions here; keep API
contracts near the code.

Status values: `deferred`, `in progress`, `shipped`.

## Pending state for actions and forms

Status: `in progress`. The Button contract and the browser guard are implemented;
the forms guide, focus restoration, and the Form/Status components are deferred.

### Decision

`loading` is a pending state, not a second disabled state.

- Pending controls stay focusable and keep their accessible name.
- Pending controls are non-activatable in the browser (via the guard) and ignored
  by the server.
- The native `disabled` attribute is reserved for the hard-disabled state.
- `aria-disabled` is only useful when activation is actually ignored. Do not set
  it without the guard.
- Progress is announced through a persistent live region or an explicit
  accessible-name change; `aria-busy` alone is not an announcement.

### Rejected alternatives

- **`disabled={@loading}`** — drops focus, removes the control from the tab
  order, and keeps the focus loss for the whole async operation. LiveView already
  disables form buttons during `phx-submit`; adding the prop only extends it.
- **`aria-disabled` without a guard** — inert. Clicks, Enter submission, and
  `requestSubmit()` still go through.
- **`aria-live="assertive"` as the default** — interrupts. We use a persistent
  `role="status"` (polite) for routine progress. React Aria announces the
  focused pending transition assertively, so assertive is defensible when the
  user just triggered the action; pick one approach and avoid double
  announcements.
- **`aria-label="Loading"`** — replaces the action name and loses context; with
  `aria-busy` the update may not be announced.
- **`phx-disable-with` as the pending pattern** — swaps text and renders the
  native `disabled` attribute. Keep it for simple cases, not where focus matters.

### Contract

**Button (`FlintUI.Base.Button`).**

- `loading` sets `aria-busy="true"`, `aria-disabled="true"`, and `data-loading`.
- `loading` never renders the native `disabled` attribute.
- `loading` on a link drops `href`/`navigate`/`patch` and keeps the link
  focusable (`role="link"`, `tabindex="0"`).
- `disabled` remains the hard state: native `disabled` on an action button,
  `aria-disabled` + no destination on a link.
- A control can be both pending and disabled; the native `disabled` wins.

**Browser guard (`flint.js`).**

- Installed once when the core bundle loads; no hook or DOM id needed.
- Capture-phase `click` and `submit` on `document`; only targets
  `[data-element="button"][data-loading]`.
- Cancels activation with `preventDefault()` + `stopImmediatePropagation()` so
  LiveView's window listeners and Phoenix HTML handlers do not run.
- For submits, checks `SubmitEvent.submitter`; falls back to a pending submit
  button in the form when the submitter is absent.
- Progressive enhancement: without the bundle, pending is advisory and the
  server guard is mandatory.

**Server.**

- Every pending action needs a guard clause, e.g.
  `def handle_event("save", _, %{assigns: %{saving: true}} = socket), do: {:noreply, socket}`.
- The server guard is the only complete guard: it covers Enter submissions,
  `requestSubmit()`, multiple tabs, scripted requests, and a missing JS bundle.

**Announcements.**

- Use a persistent `role="status"` region outside the form/button; toggle its
  text, not the region itself.
- Keep the control's accessible name stable ("Save"); let the region say
  "Saving…", "Saved", or the error.
- Prefer `role="status"` (polite) for routine progress. An assertive
  announcement is defensible for the focused pending transition (React Aria),
  but do not announce the same change twice.
- Do not rely on `aria-busy` to announce; some AT defers updates inside it.

### LiveView 1.1.28 notes

- `phx-click` pushes an event, sets a ref on the clicked element, and ignores
  repeat clicks on that element until the reply (`bindClick` checks
  `PHX_REF_SRC`). It adds `phx-click-loading` but does not disable the element
  unless `phx-disable-with` is present.
- `phx-submit` calls `disableForm/3`, which disables every button in the form,
  makes inputs readonly, and adds `phx-submit-loading`; it restores them after
  the reply.
- Async work after the reply releases the form lock but keeps the server
  `@saving` assign true. That is the window the pending state covers.
- Focus is lost when LiveView disables a focused submit button. The status
  region keeps the user informed; restoring focus after a non-navigating submit
  is still deferred.
- `phx-disable-with` also replaces the element's `textContent` with plain text
  during the request. It therefore removes the pending indicator and cannot
  preserve focus; do not combine it with `loading` when either matters.

### Prior art

- **React Aria / React Spectrum Button `isPending`** — the closest match. It
  sets `aria-disabled="true"` and `data-pending`, clears activation handlers
  while preserving focus and hover/pointer enter-leave, removes `href`/`target`
  from pending links, changes a pending submit button's type to `button` to stop
  implicit submission, and announces through a labelled `ProgressBar`. The
  control stays focusable.
- **Base UI Button `focusableWhenDisabled`** — the same soft-disabled model,
  recommended in its loading guidance. It renders `aria-disabled` instead of the
  native `disabled` attribute, keeps the element focusable, blocks keyboard
  activation except `Tab`, and recommends `aria-labelledby` so the changing text
  becomes the explicit accessible name.
- **WAI-ARIA Authoring Practices, Button pattern** — "When the action associated
  with a button is unavailable, the button has `aria-disabled` set to true." The
  specification also requires authors to suppress the functionality themselves;
  the browser guard and server guard are that work.
- **Native-disabled camp** — MUI, Mantine, Nuxt UI, Radix Themes, HTMX
  (`hx-disabled-elt`), and LiveView (`phx-disable-with` / `disableForm`) use the
  native `disabled` attribute during loading. The pending pattern is
  accessibility-forward, not the ecosystem default.

### Shipped

- [x] Button pending semantics (`aria-busy`, `aria-disabled`, `data-loading`).
- [x] Loading links drop navigation and stay focusable.
- [x] Browser click/submit guard in `flint.js` with Vitest coverage.
- [x] Button docs, moduledoc, and metadata.
- [x] Sound guide dogfoods `loading={@saving}`.

### Deferred

- [ ] Forms guide: server guard, `phx-submit` vs `phx-click`, status region,
  focus-loss trade-off.
- [ ] Focus restoration after a non-navigating `phx-submit`.
- [ ] Announce the client-known in-flight window (`phx-click-loading` /
  `phx-submit-loading`) before the server reply; only the server-known
  `loading` state is announced today.
- [ ] Consider React Aria's `type="button"` swap for pending submit buttons so
  implicit form submission is blocked even without the guard.
- [ ] Consider `aria-labelledby` with a labelled spinner (Base UI / React Aria)
  as an alternative to the external status region; it depends on the spinner
  exposing progress semantics.
- [ ] A `Status`/live-region component so the region is not hand-written.
- [ ] A `Form`/`Field` pending contract: form-level `aria-busy`, status slot,
  submit guard, and how `loading` composes with validation errors.
- [ ] Decide whether the spinner (`FlintUI.loading`) should expose
  `role="progressbar"` when it has a label instead of `role="img"`.
- [ ] Decide whether a `data-pending` alias is worth adding to `data-loading`.

### Open questions

- Should a pending link keep its `href` for context and rely on the guard, or
  drop it like a disabled link? Current choice: drop it, so it is safe without
  JS. Revisit if link pending states become common.
- Should the form itself carry `aria-busy` while pending? It can help for
  region-level updates, but it may defer updates inside the form. The status
  region must stay outside it.
- Should the form guard live in a Form component or stay a documented
  convention until the Input/Field work lands?

### References

- React Aria Button `isPending`: retains focusability, disables press/hover,
  announces the pending state.
- WAI-ARIA Authoring Practices; MDN `aria-busy`, `aria-disabled`, `role=status`.
- LiveView 1.1.28: `assets/js/phoenix_live_view/view.js` (`disableForm/3`,
  `putRef/4`), `live_socket.js` (`bindClicks/0`, `bindForms/0`),
  `element_ref.js` (`undoLoading/2`).
