---
name: write-a-skill
description: Author a new skill, refactor an existing one, or audit a skill against the discipline. Use when authoring a new SKILL.md, editing one, or auditing an existing skill against the authoring discipline.
---

# Write a Skill

You are authoring or auditing a skill against the discipline in `docs/agents/skill-authoring.md`. Read the discipline first; it is short on purpose.

## Process

1. **Frame the skill in one verb.** Inputs, outputs, and any sibling skills you should match in shape.
2. **Pick the shape** from the table below. If two shapes fit, the skill is two skills — split before drafting.
3. **Draft against the discipline.** Body IS the prompt; second-person imperative; ≤100 lines; description ≤1024 chars and verb-led.
4. **Show the draft, audit against the checklist, land it.**

## Shapes

| Shape | When | Local examples |
|---|---|---|
| **Distiller** | Read context → produce one structured artifact | `/to-prd`, `/to-issues`, `/to-pr`, `/to-agent`, `/to-docs`, `/to-plan` |
| **Driver** | Loop or orchestrate other skills; mutates state | `/drive-issues`, `/merge-pr`, `/from-pr` |
| **Primitive-driver** | Small session that drops in anywhere; no orchestration | `/next-afk`, `/next-hitl`, `/grill-me`, `/teammate` |
| **Substrate-router** | Thin pointer at a `docs/agents/*.md` data file | `/work-mandates`, `/worktrees`, `/local-tracker` |
| **User-voice** | First-person prompt the user types as shorthand; `disable-model-invocation: true` | `/zoom-out`, `/caveman` |

## Description (the API)

The description is the only thing the routing model sees when picking which skill to load. Format is prescribed:

- Max 1024 chars. Third person OR imperative.
- First sentence: what it does (concrete verb + object).
- Second sentence: `Use when [specific triggers]` — keywords, contexts, file types.

Good: `Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when user mentions PDFs, forms, or document extraction.`

Bad: `Helps with documents.`

## When to add a sibling file

- Body would exceed 100 lines after honest cuts.
- Distinct content domain (artifact format, output template, sub-protocol).
- Advanced features rarely needed inline.

Sibling files carry artifact specs (e.g. `CONTEXT-FORMAT.md`) or output templates. The SKILL.md cites them; the SKILL.md never depends on hop-of-a-hop.

## When to add a script

Operation is deterministic, repeated, and needs explicit error handling. Concrete local example: `ralph/next-afk-context.sh` (loads issues + commits via `gh` for sealed sub-agent context).

## Audit checklist

```
[ ] Description: ≤1024 chars, verb-led first sentence + "Use when [triggers]" second
[ ] Body ≤100 lines, second-person imperative, no identity narration
[ ] One shape only — if two fit, split
[ ] References one level deep (SKILL.md → SIBLING.md, no further hops)
[ ] No time-sensitive info ("currently", "as of", "the new X")
[ ] Distillers do not interview
[ ] Autonomous-mode skills declare safety yields explicitly
[ ] No "**This is the skill.**" decoration, "Authoring discipline:" footers, or compliance-narration sections
```

## Don't

- Inline the discipline rules into this body. They live in `skill-authoring.md`. Cite, don't duplicate.
- Write a driver above 100 lines. Cap is hard. Extract to siblings or shrink scope.
- Invent a new shape. Five shapes cover the surface. If a candidate fits none, the skill is probably two skills.
- Write a Process section for a user-voice skill. The body IS the user's request.
