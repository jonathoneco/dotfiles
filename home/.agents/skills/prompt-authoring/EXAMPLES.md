# Prompt Authoring — Examples

Concrete templates for the 5 prompt types. Each has: structure, when each section is required, anti-patterns, and a worked example.

---

## 1. Session-handoff prompt

**Use when:** ending a session before work is done; another fresh session needs to pick up. Single-project handoffs (vs cross-project).

### Required structure

```markdown
# Handoff Prompt — <Concise topic>

Use this prompt to start a fresh Claude Code session. Self-contained — the new session does not need this conversation's transcript.

---

<role>
[Who the agent is in the new session, what project, what overall job, what authority/permissions, what discipline applies to THIS session specifically.]
</role>

<inputs-to-read-at-session-start>
[Ordered list of files/docs the new session reads before doing anything. Order matters — first-read inputs frame later ones.]
</inputs-to-read-at-session-start>

<state-of-work>
[Bullet list with explicit ✅ done / 🔲 remaining markers. Per-item notes when context matters. No vague "we made progress on X".]
</state-of-work>

<remaining-work>
[Numbered list of remaining tasks in suggested execution order. Per-task: what to do + what NOT to do + key decisions already made.]
</remaining-work>

<discipline>
[What's permitted vs forbidden THIS session. Auto-mode? Subagent dispatch? Destructive ops? Notion writes? Editorial drafting? Cross-repo writes?]
</discipline>

<acceptance>
[What marks the session's work complete. Concrete: which files updated, which issues moved to done, what verifies success, what the commit message looks like.]
</acceptance>

<basic-security-defaults>
[Restate sensitive-domain rules, write-gates, credentials handling — DO NOT assume auto-loaded doctrine is in new session's context.]
</basic-security-defaults>

---

[Optional: explicit "Start by:" closing instruction that gives the reader the first action.]
```

### Required vs optional sections

| Section | Required? |
|---|---|
| `<role>` | Always |
| `<inputs-to-read-at-session-start>` | Always (even if just one file) |
| `<state-of-work>` | When picking up paused work; skip for net-new session |
| `<remaining-work>` | Always |
| `<discipline>` | Always when project has explicit discipline (build-discipline, wiki-guardrails, etc.) |
| `<acceptance>` | Always |
| `<basic-security-defaults>` | When project has sensitive domains and doctrine isn't auto-loaded |

### Anti-patterns

- "You'll find context in our previous chat" — fresh session has none
- "Continue where we left off" — without explicit state, fresh session guesses
- Prose paragraphs instead of bullet lists for state — harder to scan
- Missing acceptance — fresh session doesn't know when to stop
- Restating decisions as "open questions" — looks neutral but invites re-litigation

### Worked example

`~/src/openbrain/.work/2026-04-30-x0c-handoff-prompt.md` — full session-handoff prompt for continuing the OpenBrain doctrine reinstall across context boundary. ~280 lines, every required section present, includes lived-experience corrections from PRD and per-task notes for 7 remaining editorial pieces + 1 reinstall step.

---

## 2. Vertical-loop kickoff prompt

**Use when:** starting `/grill-me` scoped to one vertical or version of an extension, per a per-vertical loop discipline.

### Required structure

```markdown
# Vertical Loop Kickoff — <Vertical name>

<role>
You are running the (P_x.0a) Phase A grill for vertical <X>. Scope: ONLY this vertical, not the broader project. Output of this grill becomes input to (P_x.0b) PRD authoring (`/to-prd` scoped to vertical X). After this session, the next session runs PRD authoring; do NOT do that here.
</role>

<context>
Read the parent PRD at `<path>` to understand:
- The architectural anchor this vertical fits within
- Cross-cutting disciplines that apply (D.1 event-handler shape, D.2 cadence, D.3 watchdog, etc.)
- The companion-artifact menu
- The maturation framework
</context>

<design-tree-to-walk>
- **Purpose** — what problem does this vertical solve?
- **Schema** — does it mirror an existing typed surface? What fields?
- **Companion artifacts** — for each from menu (schema / server / recipes / skills / commands / rules / integrations / renderer), decide ship-v1 / defer-v2 / skip
- **Triggers** — manual / cadence / event-handler shape
- **Watchdog notes** — invoke `/watchdog` for automation candidates
- **Success criteria** — testable v1 completion bar
- **Dependencies** — what must exist first
- **Deferrals** — explicit not-in-v1
- **Sensitive-domain considerations** — per wiki-guardrails §2 (or equivalent)
- **Tool-budget impact** — per OB1 audit-doc thresholds (or equivalent)
- **Maturation triggers** — for any new bootstrap-mode rules
- **human_gate consideration** — does this vertical produce AFK work whose downstream consumers depend on Jon's validation/decision/pattern-correctness? If yes, gate it.
</design-tree-to-walk>

<acceptance>
Grill produces enough material to author a vertical PRD via `/to-prd`. Output is a structured conversation transcript or interim notes; the PRD itself is the next session's deliverable.
</acceptance>
```

### Anti-patterns

- Skipping the companion-menu walk — produces under-scoped verticals
- Letting the grill bleed into adjacent verticals — context bleeds, no PRD coheres
- Forgetting the watchdog invocation — automation candidates get lost

---

## 3. Issue-execution prompt

**Use when:** starting a build session against one specific `.issues/` ticket.

### Required structure

```markdown
# Issue Execution — <Issue ID> <Title>

<role>
You are executing `.issues/<NNN>-<slug>.md`. Read it in full first. Honor build-discipline (Jon authors load-bearing code) and wiki-guardrails (auto-loaded from `.claude/rules/`).
</role>

<context-to-read>
1. `.issues/<NNN>-<slug>.md` — this issue (definitive)
2. `.issues/PRD-openbrain-v1.md` — parent PRD (architectural anchor)
3. `.issues/<vertical-loop-PRD>.md` — vertical PRD if exists (per-vertical context)
4. Any files referenced in the issue's "Touches" or "Notes" sections
</context-to-read>

<acceptance>
Per the issue's "Acceptance criteria" checklist. Mark each as you complete it.

Terminal state per build-discipline:
- If issue has `human_gate`: move to `.issues/awaiting-review/` after producing deliverable; do NOT move to done/
- Otherwise if all AC mechanically satisfied: move to `.issues/done/`
- If not complete: leave in `.issues/`, append status note

Commit message: conventional commit referencing issue ID; key decisions; files changed; blockers if any.
</acceptance>

<discipline>
- Auto-mode: <on/off per session intent>
- Subagent dispatch: <permitted/discouraged>
- Destructive ops: <require explicit confirmation>
- Cross-repo writes: <forbidden unless explicit ask>
</discipline>
```

### Anti-patterns

- Starting work without reading the issue file — produces wrong scope
- Marking issue done when `human_gate` field present — bypasses review
- Skipping vertical PRD when one exists — loses architectural grounding

---

## 4. Subagent brief

**Use when:** dispatching a subagent via the `Agent` tool for an isolated task.

### Required structure

Brief, directive, scoped. Subagent has zero conversation context.

```
[1-sentence scope statement]

[What's IN scope: specific files, specific question, specific change]

[What's OUT of scope: things another agent handles, things the lead is doing inline]

[What to report back: format, length cap, what to include vs omit]

[Constraints: read-only? write-permitted? destructive forbidden?]
```

### Required vs optional

- Scope statement: ALWAYS
- In-scope list: ALWAYS
- Out-of-scope list: when ambiguity exists or other agents are working in parallel
- Report-back format: ALWAYS for research; optional for execution
- Constraints: when destructive ops are nearby

### Anti-patterns

- "Just figure out X" — subagent has no judgment context
- Including the whole project history — subagent context budget wasted
- No report-back format — subagent's output won't slot into lead's workflow
- Forgetting to specify read-only — subagent might write things you didn't expect

### Worked example

```
Audit migration 0042_user_schema.sql for safety.

Context: we're adding a NOT NULL column to a 50M-row table. Existing rows get a backfill default. I've checked locking behavior; want independent verification.

Report: is this safe under concurrent writes? If not, what specifically breaks?

Read-only. Under 200 words.
```

---

## 5. One-shot research prompt

**Use when:** a fork or fresh agent needs to answer one focused question; output is narrow.

### Required structure

```
[Exact question — one sentence]

[Scope bounds — what to look at, what to skip]

[Report length cap]

[What NOT to do — speculation? recommendations? alternatives?]
```

### Anti-patterns

- Open-ended phrasing ("tell me about X") — produces verbose dumps
- No length cap — output bloats
- No scope bounds — agent searches wide, returns shallow

### Worked example

```
What's left on this branch before we can ship?

Check: uncommitted changes, commits ahead of main, whether tests exist for new code, whether feature flag is wired in build_flags.yaml, whether CI-relevant files changed.

Report a punch list — done vs missing. Under 200 words. No recommendations.
```

---

## Cross-cutting tips

### Use XML tags for structure

`<role>`, `<state>`, `<acceptance>` etc. Tags help the reader scan; nested content stays grouped. Anthropic's recommended structure for complex prompts.

### Order inputs deliberately

If reading order matters (early inputs frame later ones), say so. Numbered lists imply order; bullets don't.

### Restate, don't reference

"Per the discussion above" fails when there's no above. "Per `<file:line>`" works always.

### Lived-experience corrections inline

If a reader could naively get something wrong (synonyms, deprecated tools, stale paths), flag it RIGHT WHERE they'd hit it. Don't assume a separate "gotchas" section will be read first.

### Acceptance criteria are testable

"Looks good" is not an acceptance criterion. "Returns rows X, Y, Z" / "All checkboxes in #042 marked" / "Renders to Notion within one cycle" are.
