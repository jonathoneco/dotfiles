---
argument-hint: "<issue#>"
---

Run `bash ralph/next-afk-context.sh $ARGUMENTS` to load the body of the assigned GitHub issue plus the last 5 commits. The output is your input — parse it.

You have been assigned ONE specific issue to work AFK. The caller (`/drive-issues` or `/next-afk`) already picked it; the issue carries the `ready-for-agent` state-bearing label. You do not pick from a queue, scan adjacent issues, or work anything else.

# WORK MANDATES

**MANDATORY — NON-NEGOTIABLE**: Your first action after reading this prompt is to invoke `/work-mandates`. Follow every mandate within for the entire session. TDD IS MANDATORY: invoke `/tdd` before implementation or bug-fix work, write the red test first, then implement. DO NOT SKIP TDD.

# THE ISSUE

The issue body is provided as context above. Re-read it carefully — title, category, what to build, acceptance criteria, anything else. The recent commits show what's already shipped — confirm the assigned issue isn't already covered before starting.

If the issue is already closed, already covered by recent commits, or no longer applicable, output `<promise>NO MORE TASKS</promise>` and stop.

# APPROACH

You are not picking among issues, but you ARE deciding how to slice this one. Within the issue, prioritize:

1. **Critical safety / correctness first.** If the acceptance criteria include a guard (auth, schema, validator), land that before the happy path.
2. **Development infrastructure as a precursor.** Tests, types, dev scripts, fixtures — get these in shape before feature code if the issue requires them.
3. **Tracer bullet through the layers.** Build a tiny end-to-end slice through every layer the issue touches (schema → engine → ritual → UI → tests) before fattening any one layer. Many small slices beat a few thick ones.
4. **Polish + quick wins.** After the tracer lands, fill in the obvious gaps before refactoring.
5. **Refactors last.** Only if the acceptance criteria explicitly demand them.

# EXPLORATION

Before touching code, explore the relevant surfaces. Read the files referenced in the issue body, the cited modules, the existing tests for related code paths. Skill routing: invoke `/wrangle-architecture`, `/wrangle-convex`, `/wrangle-design`, or `/wrangle-domain` if the issue touches their surface.

# IMPLEMENTATION

Use `/tdd` to complete the task. **Invoking `/tdd` is mandatory.** Vertical-slice red-green cycles, not horizontal "all tests then all code." If `/tdd` cannot be invoked or followed for any reason, stop and surface the blocker; do not implement.

# FEEDBACK LOOPS

Before committing, run the project's feedback loops:

- `npm run test` — must pass green
- `npm run typecheck` — must pass green

Both pass green or there is no commit. If either fails, fix the underlying issue (do not bypass with `--no-verify` or comment out tests).

# COMMIT

Make a git commit per work-mandates commit-hygiene rules. Conventional commit type (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `infra:`). The commit message body must include:

1. **Key decisions made** — design calls, tradeoffs, alternatives considered.
2. **Files changed** — names and the user-visible or system-visible behavior change in each.
3. **Blockers or notes for next iteration** — anything the next iteration needs to know.

Reference the issue by `#NN` in the commit body.

# FINDINGS

If during the issue you observed anything out-of-scope worth surfacing — a bug in adjacent code, a doc gap, a refactor opportunity, a missing test, a stale ADR, a flaky neighbor — append it to `FINDINGS.md` at the repo root BEFORE close-out. Append (do not overwrite); create the file if it doesn't exist. Format:

```markdown
## From #<issue#> — <short label>

<one-paragraph description: what you saw, where (file:line), why it matters, suggested action>
```

Findings accumulate across drive-issues iterations. They are the input for `/to-docs` / `/to-agent` promotion or for follow-up issues. Do not promote them yourself; just capture.

# CLOSE-OUT

If the task is complete (every acceptance criterion green, tests green, typecheck green), close the GitHub issue:

```sh
gh issue close <NN> --comment "Closed by <commit-sha>"
```

If the task is incomplete (partial progress, blockers surfaced, or a sub-task remains), comment on the issue with what was done and what's blocking:

```sh
gh issue comment <NN> --body "Partial progress: ..."
```

Do not close the issue if any acceptance criterion is unverified.

# FINAL RULES

ONLY WORK ON THE ASSIGNED ISSUE. No queue scanning. No scope walking. No adjacent fixes. No drive-by refactors of code you happen to read. If you find a problem outside the issue's scope, capture it in `FINDINGS.md` per the FINDINGS section above and let the next iteration handle it.
