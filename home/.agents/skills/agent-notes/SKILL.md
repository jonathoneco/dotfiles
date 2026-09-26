---
name: agent-notes
description: Keep and find the machine-local notes agents write for later sessions in ~/.local/state/agent-notes/. Use when writing a handoff, brief, report, ledger, rulings, or lessons for a later session; when resuming work or looking for what an earlier session found, before mining transcripts; and when wrapping up or running a retrospective.
---

# Agent notes

Agent notes are what one session leaves for the next: where work stands, what was ruled, what was found, what went wrong. They live in `~/.local/state/agent-notes/` (mode 0700, never committed) on the machine where the work ran. The bar: a later session finds the note it needs from `INDEX.md` and the note headers, without mining transcripts.

The shapes inside a note vary with the work, and that is fine. What every note shares is the language below, so notes can be found and gathered.

## Layout

- **One folder per effort**, named by topic in kebab-case (`money-picture-wireframe`, not `orchestration-2026-09-23`). An effort that spans many sessions keeps one folder.
- **`INDEX.md`** at the root has one line per folder: `- <folder>/ — <what the effort is> — <status> — <last touched>`. Add the line when you create the folder, and update it whenever the status changes.
- **`machine/`** holds facts about this machine that outlast any effort: paths, tool quirks, where something is installed.
- **`archive/`** holds folders whose status is done. Their `INDEX.md` lines stay, pointing into `archive/`.

## Shared language

**Kinds.** Name each file by its kind, alone (`HANDOFF.md`, `RULINGS.md`) or as a prefix or folder (`briefs/extract.md`, `reports/latency.md`):

- **handoff:** where the work stands and what the next session does first.
- **brief:** one task handed to a subagent, with its sources and the shape of its report.
- **report:** the answer to one question, from code, production, or sources.
- **rulings:** decisions, numbered, each with the decider's words, the date, the reason, and what was turned down. A reversed ruling stays, marked with the one that replaced it.
- **lessons:** what went wrong or right, and the rule it suggests. A useful entry shape: what happened, what the person said, the rule.
- **ledger:** running state, such as lanes, sessions, or a filing log, one row or dated line per change.
- **draft:** something bound for somewhere else, such as a ticket body or a page.
- **facts:** stable facts, mostly in `machine/`.

**Header.** Every note opens with three lines:

```
Purpose: <who reads this next, and what for>
Status: live | parked | done
Touched: <YYYY-MM-DD>
```

**Evidence tags.** Tag a claim `[obs]` when you saw it (read the code, ran the query, opened the record) and `[hyp]` when you reasoned it, with what would measure it.

## Keeping notes findable

- Edit a note in place. Keep one copy of each draft; an older version worth keeping goes in a `vN/` folder beside it.
- Copy what you need into the effort's folder. `/tmp` is wiped on reboot and is not shared between machines, so a note points only at the folder, a repo path, or a tracker key.
- When two notes disagree, fix the stale one or mark it superseded, naming the note that replaces it.
- Bump `Touched:` whenever you change a note.

## Searching

1. Read `INDEX.md` and pick the folders whose line matches.
2. Read the headers of the notes in those folders.
3. Grep across folders by kind or status (`grep -rl '^Status: live'`), then by subject.
4. Only then mine session transcripts.

Notes are per machine. When the effort may have run elsewhere, say which machines might hold it and read their `INDEX.md` over SSH only after Jon says yes.

## Harvest

At wrap-up or a retrospective, move what the notes taught to where it lasts. Each lesson goes to the repo that owns it: a rule into the skill or doc that governs the work, a case into that repo's record of cases. Mark each harvested entry with where it went. Set the folder's status in its header and `INDEX.md`; when it is done, move it to `archive/`.

Done when every lesson in the folder is either harvested or marked as still open, and `INDEX.md` shows the folder's current status.
