---
name: improve-documentation
description: Audit the documentation and skill surface for tier mismatches, squirreled-away anti-patterns, CLAUDE.md bloat, vocabulary drift, skill-shape conformance, citation rot, slot-reservation accuracy, module integrity, and language-discipline violations. Sibling to `/improve-codebase-architecture` but for docs + skills + commands. Use when the user wants to clean up doc rot, audit skill conformance, tighten CLAUDE.md, or verify the canonical-doc + skill surface stayed healthy after a major change.
---

# Improve Documentation

Primitive-driver. Audits the documentation and skill surface and proposes promotions, demotions, absorptions, modularizations, and conformance fixes.

Standalone audit. For per-PR ripple checks, walk `FINDINGS.md` (root) before merge or invoke `/to-docs` / `/to-agent` for promotion candidates as you find them.

## When to invoke

- The user wants to clean up doc rot, audit skill conformance, or verify the canonical-doc set stayed healthy after a major change.
- After a doc-restructure or skill-restructure session: confirm the surface stayed coherent.
- When `CLAUDE.md` feels heavy or contributors are skipping sections.
- When new contributors keep asking "where do I find X?" — that's a coverage / entry-point gap.

## Inputs

- Project's full doc and skill surface, read in parallel via Explore agents:
  - Root CAPS docs: `CLAUDE.md`, `ARCHITECTURE.md`, `CONTEXT.md`, `DESIGN.md`, `DEVELOPMENT.md`
  - Deep docs: `docs/**`
  - ADRs: `docs/architecture/adr/*`
  - `docs/agents/*` substrate
  - All skills: `.claude/skills/**/*.md`
  - Commands: `.claude/commands/*.md`

## Glossary

Use these terms exactly:

- **CAPS doc** — root-level uppercase canonical file.
- **Deep doc** — content-bearing file under `docs/`.
- **Tier** — every doc is *baseline* (load-bearing, slow-changing) or *detail* (churn-prone, sub-system-specific). A fact lives in baseline if a reader who knows nothing about the project must learn it before any deep doc makes sense.
- **Squirreled-away anti-pattern** — a deep doc owns load-bearing content but is buried where no CAPS doc points at it, OR a CAPS doc points at exactly one deep file (single-target pointer).
- **Citation rot** — a cross-skill citation resolves to a missing path or stale anchor.

## Process

### 1. Explore

Read the surface in parallel. Build a mental map: which CAPS doc points where, which deep docs are referenced, which deep docs are orphaned, which terms appear in multiple places, which skill modules get cited from elsewhere.

### 2. Apply lenses

Walk the surface through each lens. Note friction; do not chase rigid heuristics.

**Doc-architecture lenses**:

1. **Tier mismatch** — baseline content in a deep doc, or detail content in a CAPS doc.
2. **Squirreled-away** — load-bearing deep doc with no CAPS pointer, or CAPS pointer to a single deep file.
3. **CLAUDE.md bloat** — sections drifting toward detail; auto-load cost of every line.
4. **Vocabulary drift** — same concept named differently across files.
5. **Skill-config coverage** — `docs/agents/*` mappings still match reality.

**Skill-surface lenses**:

6. **Shape conformance** — every skill body conforms to its claimed shape per `docs/agents/skill-authoring.md`. Distillers do not commit; drivers preflight; substrate routers are read-only.
7. **Description discipline** — every SKILL.md description ≤ 1024 chars, starts with a verb form, names what the skill does NOT own.
8. **Citation rot** — cross-skill links resolve to existing files and valid anchors.
9. **Language discipline** — scan citing skills for `should`/`may`/`might`/`typically`/`usually`/`deviations are allowed`/`if needed`/`as appropriate`. These are forbidden in skills that promise behavior.
10. **Coverage and entry points** — a newcomer can reach every deep doc in three clicks from `README.md`. Walk the routing graph; surface dead ends, broken links, and circular routes that don't terminate at content.

### 3. Surface findings

Report findings as a table:

| Target | Type | Source | Recommendation |
|---|---|---|---|
| `CLAUDE.md` §State-transitions | tier mismatch | drift toward detail | demote to `docs/architecture/state-transitions.md`; replace section with one-line pointer |
| `/drive-issues` | vocabulary drift | hardcoded tracker path in prose | replace with "the issue tracker" |
| `local-tracker` | citation rot | links to a deleted skill | replace with the surviving substrate doc |

Group by severity: **load-bearing** (chain breaks) > **drift** (silently misleading) > **bloat** (cost without value).

### 4. Hand off

The user picks which findings to act on. Routing:

- Deep docs / ADRs → `/to-docs`
- CAPS docs / skill bodies / commands / `docs/agents/*` → `/to-agent`
- Trivial typos / link fixes → user does it manually

Each promotion / demotion / fix is its own commit.

## Prevention rules

1. **Deletion test for new pointer files.** Don't add a CAPS doc that points at exactly one deep file — absorb up or skip.
2. **Baseline + routing, not just routing.** Every CAPS doc carries substantive content of its own; pure-routing files become navigation overhead.
3. **Single source of truth per fact.** A given fact lives in exactly one tier — the other tier routes.

## Don't

- Auto-apply moves. Each side effect is approved + committed separately.
- Re-litigate ADRs. If a candidate contradicts one, flag and stop unless the user reopens.
- Treat the audit as exhaustive on first pass — expect 3–5 candidates per pass, not thirty.
- Propose new CAPS docs without checking whether the content fits in an existing one.
