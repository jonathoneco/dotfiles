# Prompt Authoring — Reference

Deeper guidance on the principles behind the 5 templates in EXAMPLES.md.

## Why self-containment matters more than brevity

A prompt that's read AFTER the original session ends has no transcript context. Every assumption "you'll know what I mean" produces drift in the reader. Drift accumulates across sessions: the third reader's interpretation diverges from the first writer's intent.

Brevity is good when it preserves clarity. Brevity that omits load-bearing state is false economy — the reader fills the gap with guesses.

**Test:** would a fresh Claude session, with NO context other than this prompt + the files it explicitly reads, execute the work correctly? If no, the prompt is incomplete.

## How to choose what to include vs link

**Include inline** when:
- The fact is small AND load-bearing (e.g., "Wrangle ≡ Gaucho — both names appear in Notion DB")
- A reader naively reading the linked file would miss it
- The fact resolves a contradiction the reader would otherwise re-litigate

**Link instead** when:
- The content is large (>20 lines) AND the reader will need it in full
- The content is a canonical doc that should stay singular (PRD, schema docs)
- The content is volatile and you want the latest version, not a snapshot

**Hybrid** when:
- A doc has critical sections + verbose context — inline the critical, link the rest
- A reader needs the gist for orientation + the doc for detail

## The "trust but don't assume" principle for inputs

When you list inputs to read, the reader will read them in order. So:
- Order matters: put framing inputs (PRD, architecture doc) before working inputs (specific issue file)
- Don't list inputs the reader doesn't actually need — context budget is limited
- Specify file paths absolutely (`/home/jonco/src/openbrain/.issues/...`) when ambiguity is possible
- Note if an input is stale (e.g., "this references §1.2 which doesn't exist; ignore that ref")

## Why discipline framing is non-negotiable

Auto-mode, subagent dispatch, destructive ops, cross-repo writes — these are session-shaped decisions. A handoff that doesn't say what's permitted leaves the new session to guess. Guessing produces:
- Auto-mode runs that violate "Jon authors load-bearing code"
- Subagent dispatches that fragment the work record
- Destructive ops without confirmation
- Cross-repo writes that surprise the user

Restate discipline EVERY handoff. Don't assume the reader will check `.claude/rules/` (those may not be auto-loaded yet, or may have moved).

## Anti-patterns that look helpful but produce drift

### "You can also do X if you want"

Opens the scope. Reader interprets generously. Stick to scoped acceptance.

### "Don't worry about X for now"

Ambiguous — does that mean defer X or skip it entirely? State explicitly: "X is out of scope for this session; if it comes up, leave a note in the issue and move on."

### "This should be straightforward"

Sets reader's expectation incorrectly. If it's not straightforward (and tasks rarely are), reader assumes they're missing something obvious. Just describe the work; let difficulty emerge.

### Listing every possible failure mode

Reader skims past a long warning section. Surface only failure modes specific to THIS work; rely on auto-loaded discipline for general guardrails.

### "Use your judgment"

For routine tasks, fine. For load-bearing work, this hands authorship to the agent — which violates many disciplines. Specify what permits judgment vs what requires explicit ask.

## Acceptance criteria authoring

Acceptance criteria are the contract between the prompt's author and the prompt's reader. Bad acceptance criteria:
- "The feature works" (untestable)
- "Looks good" (subjective)
- "Tests pass" (which tests?)
- "Code review approves" (who? when?)

Good acceptance criteria:
- "All checkboxes in `.issues/<NNN>.md` marked complete"
- "`bin/stats` shows queue depth dropping toward zero after one cadence cycle"
- "One full task lifecycle: create in OpenBrain via `add_task`; renders to Notion within one cycle; appears in Notion Tasks DB; same task searchable via `find_tasks`"
- "Issue moved to `.issues/done/`; commit references issue ID"

## Lived-experience corrections — the inline-flag pattern

If a project has known confusions (synonyms, stale doc IDs, deprecated tool paths, sibling-repo conventions), flag them WHERE the reader will hit them, not in a separate section.

Bad:
```
[100 lines of work description]

## Gotchas

- Wrangle and Gaucho are the same project.
```

Good:
```
[work description that mentions Wrangle]

> Note: Wrangle ≡ Gaucho — both names appear in Notion. Filter logic must match either label.

[continuing work description]
```

The inline flag is in the reader's path; the gotchas section may not be.

## Iteration: when to revise vs rewrite

If a prompt produces drift in the reader's session, ask: was the drift from missing structure or wrong content?

- **Missing structure:** add the section. Don't rewrite the whole prompt.
- **Wrong content:** edit specific lines. Don't rewrite the whole prompt.
- **Wrong type:** if you wrote a session-handoff but should have written a subagent brief, restart with the right template.

Most prompt failures are missing-structure or wrong-content, not wrong-type. Edit, don't rewrite.

## Calibration: prompt length

There's no universal right length. Calibrate to:
- **Subagent / one-shot research:** terse (50-200 words). Subagent has no need for context budget.
- **Issue-execution:** short (1-2 pages). Reader has the issue file + PRD as deeper context.
- **Vertical-loop kickoff:** medium (2-4 pages). Walking a design tree needs structure.
- **Session-handoff:** longest (3-10 pages). Reader has zero conversation context; everything load-bearing must be in the prompt.

If a session-handoff is shorter than 2 pages, it probably skipped a required section. If it's longer than 10 pages, it probably included content that should have been linked instead.
