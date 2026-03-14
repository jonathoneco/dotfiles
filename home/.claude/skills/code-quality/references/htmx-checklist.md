# HTMX Correctness Checklist

## Target/Swap Matching

- `hx-target` must reference an existing element ID in the DOM. If the target doesn't exist, the swap silently fails.
- `hx-swap` mode determines replacement behavior:
  - `innerHTML` — replaces the target element's **children** (target element remains)
  - `outerHTML` — replaces the **target element itself** (target is removed from DOM)
- After mutations (POST/DELETE/PUT), return the updated content that the target expects. Never return an empty 200.
- If `hx-target` is omitted, the swap targets the element that triggered the request — verify this is intentional.

## Handler Response Rules

- Check the `HX-Request` header to distinguish HTMX requests from full page loads.
- HTMX requests (`HX-Request: true`): return a **partial HTML fragment** matching the target element's expected content.
- Non-HTMX requests: return the **full page** with layout wrapper.
- Never return empty 200 after a mutation — always return content to swap. The client needs updated markup to reflect the change.
- After DELETE operations, return the **updated list content** (with the deleted item removed), not just a success status.

## Vertical Tracing

Every change must be traced across the full stack. A fix at one layer that doesn't propagate to adjacent layers is incomplete.

```
handler → service → template → HTMX attributes
```

- **Handler response shape changes** require template verification — if the handler returns different data fields, the template consuming them must be updated.
- **Service return type changes** require handler verification — if a service method changes its return signature, all handlers calling it must adapt.
- **Template structure changes** require HTMX attribute verification — if a template changes element IDs or nesting, `hx-target` and `hx-swap` attributes referencing those elements must be updated.
- **HTMX attribute changes** require handler verification — if `hx-target` or `hx-swap` changes, verify the handler returns the expected fragment for the new target/swap combination.

## Common Failure Modes

**UI doesn't update after an action:**
- Check that `hx-target` ID matches an existing element in the DOM
- Check that `hx-swap` mode matches intent (`innerHTML` vs `outerHTML`)
- Check that the handler returns a partial HTML fragment, not a full page

**Double rendering (page-within-page):**
- Handler returns a full page with layout to an HTMX request
- Fix: check for `HX-Request` header and return only the partial fragment

**Stale content after mutation:**
- Handler returns old data (query before mutation committed) or empty response
- Fix: query after mutation, return the updated content to swap in

**Broken layout after swap:**
- `outerHTML` swap replaced the target element itself — subsequent requests targeting that ID fail because the element no longer exists
- Fix: use `innerHTML` to preserve the container, or ensure the swapped-in HTML includes a new element with the same ID
