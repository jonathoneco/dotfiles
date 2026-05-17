# PLAN.md section shape

PLAN.md has a fixed section order. Each section answers a specific question; the order is load-bearing — later sections depend on earlier ones being named.

Target length: **250–400 lines.** Tighter is better. Over 400 means scope leaked from V2 or door-open into V1. Under 200 means sections are too thin and the grill will spend its bandwidth re-deriving operational frame instead of pushing on real choices.

## 1. `# <Layer or feature name>` + one-line description

The H1 + a single line. No subtitle, no provenance.

## 2. `## Why this exists`

2–3 paragraphs grounding the design in **operational pressure on what's currently in main**. Name today's modules. Name today's costs. Name what doesn't generalize. End with one sentence stating what the plan describes:

> This plan describes the **<thing>**: <one-line>.

The reader must understand the pain before the design.

## 3. `## The shape`

The architectural primitives — categorical layers, prose-form. **Bold load-bearing terms** on first use; reuse them as nouns. No bullet lists unless they earn the format. The shape paragraph is where the design earns its categorical claim.

## 4. `## <The central abstraction>`

The seam that justifies the layer. Code block with the type signature. One paragraph explaining what's pure / impure. One paragraph explaining what calls it. This is where the test surface gets named — _the interface is the test surface_.

## 5. `## <Inputs / Producers>` (if applicable)

Where work comes in. Map existing modules to the new contract by name. Don't invent new files unless required by the design.

## 6. `## <Domain mapping>`

Table or prose mapping the layer's primitives onto Wrangle's operational entities (Flag, Outbound, Artifact, file, borrower, etc.). **Use the existing names. Never rename.**

## 7. `## Operational invariants`

2–3 numbered invariants the design holds across all flows. Lint-enforceable where possible. These are the rules the design _cannot_ violate without breaking.

## 8. `## V1 scope`

Two sub-sections:

- **`In:`** — bulleted list of what ships in V1.
- **`Door-open, not built today:`** — bulleted list of things deferred. For each, name the smallest add that lights it up later: _"Lands as <X column> + <Y rule clause>; deferred until <real signal>."_

The "door-open" framing is critical — it commits the design to _not_ paint a corner without committing to _build_ the deferred thing.

## 9. `## Open architectural questions`

Prose-form. 3–5 honest open questions. Each as 2–3 sentences naming the load-bearing tradeoff. End with one sentence:

> These get sharper under V1 implementation pressure.

**Do NOT**:
- Number them as B1–BN.
- Frame them as "binaries the next session must resolve."
- Pre-resolve them in the section above.

Each question is a real architectural choice the design hasn't yet pinned. Not a punt — a binary the implementation surfaces evidence for.

The numbered binary list is a _grilling output format_. The PLAN.md is the _strawman input_ to grilling. Different artifact, different shape.

## 10. `## What success looks like`

5–7 bulleted concrete acceptance criteria. Each one describes **observable end state, not process**. The lint passes. The test runs. The end-to-end chain completes. The regulator-export query returns coherent output. After V1, the door-open items become 1–3 week features each.
