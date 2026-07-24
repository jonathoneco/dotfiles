---
name: cmux-orchestration
description: "Run reliable orchestrator-owned coding chunks through cmux tabs."
disable-model-invocation: true
---

# cmux Orchestration

Use a tight **chain**: orchestrator → chunk owner. The chunk owner implements a
semantically related issue group directly; the orchestrator owns the independent
review loop. The chain—not the visible cmux layout—is the authority and reporting
path.

## 1. Establish the chain

1. Read [cmux-workspace](../cmux-workspace/SKILL.md) before topology actions; use its caller-workspace anchor and no-focus rules.
2. Read the selected project's current plan, dependencies, and active work before assigning anything.
3. Keep milestones as semantic vertical slices. Assign an owner to a sequential,
   related chunk within a milestone; the owner implements that whole chunk directly.
4. Give every owner one bounded deliverable. The chunk owner reports only to the
   orchestrator; do not fan implementation out into issue-per-session children.
5. State the authority boundary in each launch brief: scope, branch/worktree, acceptance criteria, required checks, callback recipient, and what requires a decision.

Completion: every active owner has an owned chunk, an orchestrator callback target,
and no overlapping implementation ownership.

## 2. Launch bounded work

Launch each session with `--yolo`. Model and reasoning depth follow ownership:

- The main orchestrator uses `gpt-5.6-sol` with high reasoning.
- Chunk owners use `gpt-5.6-sol` with low reasoning and implement their chunk.
- Independent review and verification workers use GPT-5.5 with low reasoning.

- Keep the owner, review, and verification sessions for one
  project in the caller's existing cmux workspace. Create new surfaces/tabs in
  that workspace with `--focus false`; do not create a workspace per issue.
- A separate workspace requires an explicit user instruction. Worktrees and
  branches isolate code; cmux workspaces do not represent git ownership.
- Do not inline long agent briefs through `cmux send`; terminal paste limits can
  truncate the command before its closing quote. Put the complete brief in a
  temporary file outside the repository and send a short launch command that
  reads it.
- After submitting the launch command, read the target surface. The worker is
  active only when the Codex UI shows `Working` or agent tool output. A shell
  prompt containing the launch command, an `OK` from cmux, or a renamed tab is
  not activation proof. Keep the owner active and recover the same surface if
  launch verification fails.

- Chunk owners read project context, milestones, every issue in their chunk,
  adjacent decisions, and the relevant code before implementing.

For code work, give each chunk owner one chunk branch/worktree. The owner lands
scoped commits there as the related issues become coherent, then reports the whole
chunk review-ready.

Completion: each tab has started its assigned work with no overlapping implementation ownership.

## 3. Route callbacks reliably

Use persistent cmux surface UUIDs—not `surface:N` short refs—for every stored callback target. Resolve UUIDs before launch with `cmux --json --id-format both` commands. Keep the UUID with the owner record for the life of the chain.

Send a callback explicitly and submit it:

```sh
cmux send --workspace workspace:<owner-workspace> --surface <OWNER-UUID> \
  '<completed | decision blocker | failed after two approaches>: <concise report>'
cmux send-key --surface <OWNER-UUID> enter
```

`cmux send` only inserts text. A trailing newline in its text is not proof of
submission. After the explicit Enter, read the receiver screen and require
receiver-side evidence that a new turn started, such as `Working` or a response
below the submitted message. If the callback is still shown at the bottom `>`
composer, it is **unsent**. An `OK` from cmux or mere screen visibility is not
delivery verification. Keep the child open and report the delivery failure if
the receiver never starts a turn.

A chunk owner reports only when the chunk is review-ready, reaches a decision
blocker, or fails after two approaches. The orchestrator does not poll or keep an
idle watcher awake. Do not send a callback without the Enter key.

Completion: the child is idle after a submitted callback, and the parent received the report in its own tab.

## 4. Close a chunk

1. The chunk owner confirms every issue's acceptance criteria and required checks,
   then reports a review-ready commit to the orchestrator.
2. The orchestrator launches an independent review for integration correctness,
   scope, simplicity, vocabulary, and duplicate machinery.
3. The orchestrator sends findings back to the same chunk owner for correction,
   then launches a fresh independent final review.
4. The orchestrator integrates and verifies the clean chunk. Only then start the
   next chunk.

At chunk boundaries, reconcile the integration branch with the primary branch deliberately; do not defer all drift to the end.

Completion: the orchestrator has a clean final review, exact evidence, remaining
risks, and no unreviewed chunk work.

## 5. Correct the chain

Apply implementation corrections to the responsible chunk owner. The orchestrator
retains review ownership and keeps corrections within the selected project,
milestone, and chunk.

When work stalls or sessions restart:

1. Inspect the current cmux topology and each owner session's worktree/branch state.
2. Reconstruct the chain from UUID callbacks and reports.
3. Resume dropped work or commission a replacement for the same chunk.
4. Close settled sessions; retain only active implementation, review, or decision work.

Completion: every previously active scope is either resumed, completed, explicitly blocked, or closed.

## Invariants

- The chunk owner owns implementation and correction; the orchestrator owns review,
  integration, and cross-chunk decisions.
- A tab has one active purpose; status watching is not a purpose.
- The repository contains durable product artifacts only. Keep transient issue tracking, proof notes, and work logs in the issue tracker.
- Treat flaky, designated-nonblocking checks as nonblocking; report them honestly without holding unrelated progress.
- Do not use a full dark phase when the approved delivery shape is live functionality behind a flag.
