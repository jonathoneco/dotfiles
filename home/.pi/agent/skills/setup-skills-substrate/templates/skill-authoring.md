# Skill Authoring

The discipline `.claude/skills/` is built on. Cited by `/write-a-skill`. Distilled from [mattpocock/skills](https://github.com/mattpocock/skills) and grilled into this repo's shape.

Read this once. The rules are short on purpose — if you can't hold them in mind, the skill body will perform compliance instead of being the prompt.

## Core rules

**Body IS the prompt.** Write to the agent in second-person imperative ("you are doing X"; "refuse if Y"; "ask the user…"). No `## Process` heading pretending to be machinery. No "**This is the skill.**" decorations. No third-person narration of what the skill is. The body is what runs.

**Description is the API.** Max 1024 chars. First sentence: what it does (concrete verb + object). Second sentence: `Use when [specific triggers]`. Two sentences, third person OR imperative. The description is the only thing the routing model sees when picking the skill.

> Good: `Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.`
>
> Bad: `Helps with documents.`

**Hard 100-line cap on every SKILL.md, no exceptions.** Bodies that exceed split into siblings. If you can't fit the operation in 100 lines, scope is wrong — not the writing.

**References one level deep.** SKILL.md → SIBLING.md only. No SIBLING.md → DEEPER.md required-reading hops. Substrate cross-citation for vocabulary is fine; required-content depth is the ban.

**No time-sensitive info.** No "currently", "as of 2026", "the new X". Those rot.

**When to add a sibling file.** Body would exceed 100 lines after honest cuts; OR distinct content domains (artifact format, output template, sub-protocol); OR advanced features rarely needed inline.

**When to add a script.** Operation is deterministic, repeated, and needs explicit error handling. Concrete local example: `ralph/next-afk-context.sh` (loads issues + commits via `gh` for sealed sub-agent context).

**Recommend, don't just ask.** For grilling-shaped skills (`/grill-me`, `/grill-with-docs`): every question carries a recommended answer. Explore the codebase when the answer is there; only ask the user when code can't answer.

**Distillers don't interview.** Distillers (`/to-prd`, `/to-issues`, `/to-pr`, `/to-agent`, `/to-docs`, `/to-plan`) synthesize from conversation context. If interrogation is needed, the distiller is the wrong shape — call `/grill-me` first. Distillers may pause once for a focused calibration check before publishing; not free-form grilling.

**Autonomy yields to safety.** Autonomous-mode skills (`/drive-issues`, `/next-afk`) explicitly list the contexts where autonomy yields to the user: secrets, external writes, irreversible operations, production deploys. The body demonstrates the yield.

**State invariants firmly.** MUST / NEVER / ONLY for predicates that must hold. Plain imperatives are fine for routine instructions; lift to MUST/NEVER/ONLY when the invariant is load-bearing and a violation would be a real bug. Autonomous-mode skills running unattended use MANDATORY / MUST / NEVER liberally — no mid-flight oversight, strong language is the only guardrail.

**Silent prohibitions are bugs.** If a skill must not do X, the body says NEVER X. Relying on omission to forbid is how a prior track-mode skill shipped a destructive bug — its spec listed allowed writes and stayed silent on the rest, so the skill mass-edited substrate the gap looked like permission. Explicit NEVER beats omission.

**Cite substrate, don't paraphrase it.** When a rule lives in `CLAUDE.md`, a `docs/agents/*.md` substrate doc, or another skill, point at it. Two homes per topic guarantees drift. The canonical home stays canonical; the citing skill stays thin.

## Shape vocabulary (light)

Pick one shape per skill. If two fit, the skill is two skills.

- **Distiller** — read context → produce one structured artifact. Examples: `/to-prd`, `/to-issues`, `/to-pr`, `/to-agent`, `/to-docs`, `/to-plan`.
- **Driver** — loops or orchestrates other skills; mutates state. Examples: `/drive-issues`, `/merge-pr`, `/from-pr`.
- **Primitive-driver** — small session, drops in anywhere; no orchestration. Examples: `/next-afk`, `/next-hitl`, `/grill-me`, `/teammate`.
- **Substrate-router** — thin pointer at a `docs/agents/*.md` data file. Examples: `/work-mandates`, `/worktrees`.
- **User-voice** — first-person prompt the user types as shorthand; `disable-model-invocation: true`. Examples: `/zoom-out`, `/caveman`.

## Anti-patterns

The drift these rules exist to prevent:

- **Performing compliance.** Body documents what discipline it follows instead of doing the operation. Symptom: "**This is the skill.**" / "Authoring discipline: …" footers / "Anti-pattern" sections that explain rather than forbid.
- **Cross-skill narration.** Body says "like `/grill-me` and `/to-prd`, this skill takes what it has." That belongs in a discipline doc, not a prompt.
- **Decorative emphasis.** Three different ways to say the same rule (**MANDATORY** + **NEVER** + bold prose). Pick one.
- **Process steps with explanatory prose.** Numbered steps that narrate themselves are bloated; just give the instruction.
- **Vocabulary leaks.** Body uses old shape's terms ("teammate") even after the spec changed shape. Fix at the spec level: search-replace ALL terminology when changing shape. Vocabulary leaks become behavior bugs.
- **Restating substrate.** Skill body paraphrases a rule that lives in `CLAUDE.md` or another skill. Cite it; don't paraphrase it.
- **Inline-template bloat.** Long output templates / progress files / module tables inlined into the body. Extract to a sibling file the body cites. Bodies that cross 100 lines almost always have inlined substrate that wants its own file.

## Meta-rules

About the discipline doc itself, not about any one skill body:

- **Authoritative is short.** A long discipline doc becomes reference material the agent skims rather than authority it holds. The 176→55 line cut on this doc was the inflection — skill bodies followed by ~50% within hours of the doc cut. If this doc grows back past ~80 lines, prune.
- **Meta compounds.** Meta about the chain (`chain.md`) plus meta about skill bodies (this doc) plus skill bodies citing both becomes meta about meta. Cut the layer below before adding to the layer above.
- **The mechanism that catches violations becomes its own bloat surface.** A 12-item review checklist built to catch over-cap skills becomes a checklist-length problem of its own. Don't conflate "discipline" with "checklist length."
- **Body-IS-the-prompt is the apex rule.** Every other rule, applied as boilerplate, ends up violating it. If this doc has 10 rules, the agent reads and only the load-bearing ones land. If it has 53, the agent skims and applies them all as decoration.
- **Audit-fix loops compound.** Every audit pass finds things the prior pass missed. The discipline is *two* audit passes per substantive change, not one.
