# Roadmap-triage — Reference

Detailed workflow for the multi-phase loop. The lean entry is `SKILL.md`.

## Phase 0 — Locate the active roadmap dir

The roadmap dir is dated (`roadmap-YYYY-MM-DD/`). Each cluster-shape pass produces a new dated dir; this skill never hard-codes a date.

```bash
ACTIVE_DIR=$(ls -d docs/operations/roadmap-*/ 2>/dev/null | sort | tail -1)
echo "Active: $ACTIVE_DIR"
```

If no `roadmap-*/` dir exists, **stop and escalate** — the cluster-shape pass hasn't been run; this skill can't operate without an active surface. Don't create a new dir yourself; that's a separate full-session task.

If the most-recent dir is older than ~30 days, surface that to the user before editing — the cluster shape may have drifted enough that a re-cluster is appropriate.

Use `ACTIVE_DIR` for the rest of the phases; every file path below is relative to it (`$ACTIVE_DIR/roadmap.md`, `$ACTIVE_DIR/jon-working-notes.md`, `$ACTIVE_DIR/cluster-NN-*.md`).

## Phase 1 — Detect the delta

Inputs:

- Issues the user named directly ("there's an update to #159", "I just closed #X").
- Issues the user did not name. Probe with `gh issue list --search "updated:>$(git log -1 --format=%cI -- docs/operations/roadmap-*/)"` against the last roadmap-touching commit timestamp.

For each issue in scope, fetch:

```bash
gh issue view <N> --json number,title,state,labels,body,comments,updatedAt
```

Read the body + recent comments. Look for:

- **Label transitions** (state changes — `needs-triage` → `ready-for-agent`, etc.).
- **Closures** with reason (`wontfix` / `completed` / superseded-by-another-issue).
- **Supersession chains** named in comments (X is gated on Y; X closes when Y resolves a specific branch).
- **Kind-label additions** (`bug` / `feature` / `infra` / `prd`).

## Phase 2 — Decide band + tier per issue

### Band predicates (one owner per issue, no multi-assignment)

**Source of truth:** `$ACTIVE_DIR/jon-working-notes.md` § "Band predicates". Read it at decision time — this skill doesn't restate the table to avoid drift. The table covers seven rows mapping label state + tech complexity + product-content density to one of {Jon, Dan, Richard}, with overlaps defaulting to Jon.

If the working-notes file is missing the band-predicates table, stop and ask — the table is load-bearing for routing decisions.

### Tier definitions (waterfall, primary sort)

- **Critical** — must land before first pilot LO touches the system. Under Posture A (minimum-viable core loop), only items that gate one of the 7 core-loop stages from happening at all.
- **Adjacent** — earlier the better, doesn't gate pilot launch. DocuSign (LOs sign manually for first few), most loop-polish work.
- **Post-pilot** — explicit deferral. Most architectural cleanup, CI guards, observability, channel expansion.

### Core-loop stages (1–7)

1. Intake
2. Document analysis
3. Flag generation
4. Borrower back-and-forth
5. Flag resolution
6. LOEs
7. File ready

### Where does the issue go?

- **Owner = Jon AND state is plan/grilling/triage AND core-loop relevant** → **Jon's pile** (the numbered list in `roadmap.md`). Work-type tag prefix: `Grill` / `Build` / `Build+Grill` / `Ops` / `Cleanup`.
- **Owner = Jon AND state is plan/grilling AND core-loop relevant only post-pilot** → **stretch grilling pile** in `jon-working-notes.md`, not Jon's pile.
- **Owner = Dan AND R4A/R4H AND core-loop relevant** → **Dan's pile** (numbered list) OR **next-up** (bulleted prose under the pile). Promote next-up → pile when the pile drops below 4 items.
- **Owner = Richard AND tech-L + product-content-density-high** → **Richard's slot**. Often empty during pilot push; chat-input items listed instead.
- **Soft-blocked R4A** (R4A but native parent is plan-state) → **Waiting on Jon's grills** bulleted list under Dan's pile. Name the gate plan explicitly.
- **Closed wontfix** → remove from pile if present; if it was load-bearing, note the closure in `jon-working-notes.md` § "Open user-judgment items" with one-line rationale + link to `.out-of-scope/` if a doc was created.
- **Superseded by another issue** → both go to "Waiting on..." with the explicit gate naming both resolution branches (deletion path / keep path).

### Inline-tag shape

Each item carries an inline tag in backticks: `[Tier · Stage · State]`.

- **Tier** ∈ {Critical, Adjacent, Post}
- **Stage** ∈ {1, 2, 3, 4, 5, 6, 7} — core-loop stage, OR "Stages 1–7" for cross-stage verification, OR "internal" / "cleanup" / "LO surface" for off-loop work
- **State** ∈ {R4A, R4H, plan, needs-grilling, needs-info}

Jon's pile items additionally prefix a work-type tag inside the brackets: `[Grill · Critical · Stage 3 · needs-grilling]` or `[Build · Critical · Stage 7 · plan]`.

## Phase 2.5 — Confirm ambiguous tier

If the issue body doesn't pin the tier (no `Pilot materiality:` header AND the core-loop relevance isn't unambiguous from title + body), surface the candidate tier with the user before applying:

> "I'm placing #NN in Jon's pile at tier `Adjacent` because it's outage-cleanup that doesn't gate Stages 1-7 directly. Override?"

Wait for ack or override. Tier mistakes are easy to make and propagate to the Notion mirror.

Same rule for ambiguous band-decisions: per `SKILL.md` § "Anti-patterns", overlap defaults to Jon's pile, but if even that doesn't fit (e.g., R4H that's neither verification-against-spec, ops-with-credentials, nor product-content-density-high), surface the question instead of defaulting silently.

## Phase 3 — Apply to up to four surfaces

### Surface 1 — `roadmap.md`

Edit the relevant list. Common patterns:

- **Promote a next-up item to pile slot N:** Edit the numbered list to add a new line at slot N; remove the next-up bullet from the prose paragraph below the pile.
- **Drop a pile item:** Edit the numbered list to remove the line. If the pile drops below 4, consider promoting from next-up.
- **Add to "Waiting on Jon's grills":** Find the existing bulleted list under Dan's pile. Add a new bullet naming the gate.
- **Add to Jon's pile:** Edit the numbered list. Determine insertion point by priority — Critical items above Adjacent items, Ops items grouped, Cleanup at the bottom.
- **Update the cluster-index footer:** Rare; only when a cluster's frame changes or a new cluster surfaces.

### Surface 2 — `jon-working-notes.md`

- **Snapshot counts** at top: refresh open issue count, `needs-triage`, `needs-grilling`, `plan`, R4A, R4H counts. Use `gh issue list --label <label> --state open --json number --jq length`.
- **Stretch grilling pile:** for post-pilot plan-state items.
- **Open user-judgment items:** add new items when a decision is deferred; remove items that have resolved.

### Surface 3 — Cluster files (conditional)

If the issue belongs to a named cluster (per the cluster-index table in `$ACTIVE_DIR/roadmap.md`), edit the matching `cluster-NN-*.md` file in the same dir. The cluster files are issue-inventory references — when a new issue surfaces in a cluster's domain, it should appear in that file's member list with one-line frame.

When this skill applies:

- Cluster file gets a new entry if the issue maps cleanly to one named cluster.
- Multiple-cluster issues (rare): pick the cluster where the work primarily lands; leave a cross-reference in the others if needed.
- Off-cluster issues (no clear cluster home): skip this surface. Note in the open-judgment items in `jon-working-notes.md` if the issue is structurally homeless.

### Surface 4 — Notion mirror

The Notion page lives at id `363884ec-3621-81e8-9487-c59835d411a1`. Always GET the page's children first to find target block IDs.

**Approval discipline** (per `SKILL.md` § "Notion approval"): routine in-place edits on this single named mirror page are authorized by the user's invocation; show a one-line preview per block edit before the batched write. New pages, structural reorders, or schema changes return to full `wrangle-notion-capture` Phase 4 approval — surface the page-level proposal and wait for explicit confirm.

**Block-type alphabet (per `wrangle-notion-capture` HOUSE-STYLE):** `heading_2`, `paragraph`, `bulleted_list_item`, `numbered_list_item`, `code`, `divider`. Never `callout`, `toggle`, `mention`-typed rich text.

**Issue-reference links:** use Notion `text.link.url` annotations pointing at `https://github.com/jonathoneco/wrangle/issues/NN`. Never `mention`-typed.

**Common Notion ops** (helpers in `scripts/notion_helpers.py`):

- `patch_block_rich_text(block_id, block_type, new_rt)` — replace a block's `rich_text` array.
- `insert_after(parent_id, after_block_id, new_blocks)` — insert child blocks after a specific sibling.
- `delete_block(block_id)` — drop a block entirely.
- Rich-text builders: `plain()`, `linked(text, url)`, `bold_link(text, url)`, `code()`, `bold()`, `gh_url(n)`.

### Surface 5 — Commit + push

- Stage explicit paths: `git add $ACTIVE_DIR/roadmap.md $ACTIVE_DIR/jon-working-notes.md` (plus any cluster-NN files touched).
- Run `git status --short` immediately before `git commit`. The pre-commit hook (`lint-staged`) only runs on `*.{ts,tsx}` so markdown commits should pass clean — but verify nothing unrelated is staged.
- Conventional commit: `docs(roadmap): <one-line delta>` with a body listing the specific issue numbers, what moved, what was added.
- `git commit` and `git push origin main`.

If the hook misfires and the commit picks up unrelated files: **stop and surface to the user.** Don't bypass the hook with `git commit-tree` or `--no-verify` autonomously — that path requires explicit user approval for the force-push-to-main consequences (see commit `c348693f` precedent for the authorized version).

## Sanity tests

Each invocation must end with:

- [ ] **Local files staged are exactly the roadmap files.** `git status --short` shows only `roadmap.md` + `jon-working-notes.md` (or a subset).
- [ ] **Notion blocks reflect the local edits.** After the writes, GET the page children and grep for the changed text. If a line wasn't found, the mirror is out of sync.
- [ ] **Commit message names the issue delta** (issue numbers, what moved, what was added, supersession chains).
- [ ] **No secrets touched.** No printed token, no token-in-output, `.mcp.json` not staged.
- [ ] **Push succeeded.** `origin/main` is at the new commit.

## Worked example (the 2026-05-17 #299 / #308 chain)

Trigger: user said "There's been an update to issue 159 and new issues surfaced, update the roadmaps."

Phase 1 — delta detection:

```bash
gh issue view 159 --json state,labels,comments  # closed wontfix
gh issue list --state open --json number --jq '[.[] | select(.number > 305)]'  # finds #306, #307, #308
gh issue view 306 --json body,labels  # ready-for-human, feature
gh issue view 307 --json body,labels  # needs-grilling, feature
gh issue view 308 --json body,labels  # needs-grilling, infra
```

Phase 2 — band + tier decisions:

- **#306** (R4H feature, LO surface, outage-surfaced) → Jon's pile (overlap default — design decisions). Tier: Critical. Tag: `[Build · Critical · LO surface · R4H feature]`. Insert at slot 5 (after #265).
- **#307** (needs-grilling, post-pilot capability) → stretch grilling pile in `jon-working-notes.md`. Not main pile.
- **#308** (needs-grilling, cleanup) → Jon's pile. Tier: Adjacent. Tag: `[Grill · Adjacent · cleanup · needs-grilling]`. Insert at slot 10 (after #297).
- **#299 supersession:** #308 deletes the kind #299's renderer was fixing. Mark #299 with supersession note.

Phase 3 — applies:

- `roadmap.md`: add #306 at Jon slot 5, add #308 at Jon slot 10, annotate #299 with supersession note.
- `jon-working-notes.md`: add #307 to stretch list, refresh snapshot counts, add new open-judgment item for the #299/#308 supersession question.
- Notion: GET children, find Jon's pile after-anchors (#265 and #297), insert two new `numbered_list_item` blocks, patch #299's `numbered_list_item` rich_text.
- Commit: `docs(roadmap): surface #306 + #308 in Jon's pile; #299 supersession; #307 to stretch`. Push.

Then on the user's follow-up ("#299 is now bug,needs-info..."), a second pass: drop #299 from Dan's pile, promote #82 from next-up to slot 4, reshape "Waiting on Jon's grills" from inline prose to bulleted list with #299 added. Mirror to Notion. Commit + push.

## Anti-patterns (expanded)

- **Don't pre-assign by name.** The band predicates are predicates over issue shape (state label, kind label, tech complexity, product-content density), not name-on-issue. Per the project's plot-don't-assign discipline.
- **Don't sweep unrelated working-tree changes.** Stage explicit paths only. Run `git status --short` immediately before `git commit`; the pre-commit hook does not protect against staged non-`.md` files getting through.
- **Don't bypass the pre-commit hook without explicit approval.** If `git commit` somehow picks up unrelated files (the hook misfires), surface to the user. `git reset HEAD~1` + `git commit-tree` is the recovery path *when force-push to main is authorized* — not a routine bypass.
- **Don't echo the Notion token** to shell, commit messages, or chat. Load via `notion_helpers.client()`; never `cat .mcp.json`. The rotation incident in commit `4d29a4e4` traces back to a token sitting in a committable file.
- **Don't write secret values to Notion or to committed files.** `.mcp.json` is gitignored; keep it that way.
- **Don't hard-code the mirror page id across roadmap directories.** Today's mirror is `363884ec-...` for `roadmap-2026-05-17/`. When the active dir rolls forward (`roadmap-YYYY-MM-DD/` changes), create a sibling Notion page under parent `354884ec-...` and update SKILL.md + `scripts/notion_helpers.py` in the same commit.
- **Don't paraphrase a `wontfix` rationale into the roadmap.** The roadmap is operational; the rationale lives in the closing comment + `.out-of-scope/<topic>.md` if applicable.
- **Don't fold an ambiguous band-decision.** Overlap defaults to Jon's pile, but if even Jon's default doesn't fit, stop and ask before writing. Same for ambiguous tier — surface the candidate to the user.
- **Don't refresh snapshot counts manually if you didn't query.** Always run the `gh issue list --label X --state open --json number --jq length` queries; don't extrapolate from the deltas.
- **Don't lose the inline-tag shape.** Every item in Dan's pile or Jon's pile must carry `[Tier · Stage · State]` (Jon's items prefix with a work-type). Skipping the tag breaks the doc's grammar.
- **Don't restate the band-predicates table here.** It lives in `$ACTIVE_DIR/jon-working-notes.md` § "Band predicates". This skill cites it; duplicating drifts.

## Cross-references

- Band predicates source: `$ACTIVE_DIR/jon-working-notes.md` § "Band predicates".
- Notion house style: `.claude/skills/wrangle-notion-capture/HOUSE-STYLE.md`.
- Notion taxonomy / canonical guides: `.claude/skills/wrangle-notion-capture/SKILL.md` § "Read first".
- Issue-tracker conventions: `docs/agents/issue-tracker.md` + `docs/agents/triage-labels.md`.
- Force-push-with-amend pattern: commit `c348693f` precedent.
- Linkification pattern (issue refs + internal `.md` links): commit `c348693f`.
- `.mcp.json` token + rotation incident history: commit `4d29a4e4`.
