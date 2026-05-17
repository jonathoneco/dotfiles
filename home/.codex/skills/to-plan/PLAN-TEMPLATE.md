# PLAN.md inline template

Use this verbatim as the starting structure. Custom tag is `<plan-template>`; render the contents, drop the wrapper tag in the actual file.

<plan-template>

# <Layer or feature name> — the layer that <one-line description>

## Why this exists

<Wrangle's job is …>. Today's code does this through <pattern>, with
<load-bearing reference to existing modules>. <What works at small
scale.> <What doesn't generalize.>

<New requirements that multiply cost across N entities under today's
shape.>

This plan describes the **<thing>**: <one-line>.

## The shape

<Categorical primitives, prose-form. Bold load-bearing terms.>

**<Term 1>** — <definition>.

**<Term 2>** — <definition>. <Three kinds: **<A>**, **<B>**, **<C>**.>

**<Term 3>** — <definition>.

The **<central abstraction>** ties them together: <one-line>.

## <The central abstraction>

```ts
// Type signature
```

<One paragraph: what's pure / impure. What calls it. What's the test
surface.>

## <Inputs / Producers>

<Existing modules absorbed under the contract.>

1. <First>.
2. <Second>.
3. <Third>.

## <Domain kinds — table>

| Kind | States | Composition | Sole writer |
|---|---|---|---|
| `<a>` | `<states>` | <field or "none"> | `<file path>` |

<Asymmetry callouts.>

## Operational invariants

1. **<Invariant 1>** — <description>. <How it's enforced (lint, etc.).>
2. **<Invariant 2>** — <description>.

## Audit and provenance

<What the model gives for free. Bulleted list referencing existing
audit / apiCalls / citations infrastructure.>

## V1 scope

**In:**
- <…>

**Door-open, not built today:**
- <Feature>. Lands as <smallest add>; deferred until <real signal>.

## Open architectural questions

<Prose-form. 3–5 questions. Each 2–3 sentences naming tradeoff.>

These get sharper under V1 implementation pressure.

## What success looks like

V1 ships when:

- <Acceptance criterion 1, observable end state>
- <Acceptance criterion 2>
- <…>

After V1, the door-open items become 1–3 week features each, not
multi-month migrations.

</plan-template>
