---
description: "Fix lint/build issues and update PR title/description — intelligent fixer using code-quality rules"
user_invocable: true
skills: [code-quality]
---

# /pr-prep $ARGUMENTS

Intelligent lint/build fixer and PR description updater for branches with active PRs. Fixes code issues that need reasoning, then ensures the PR title and description accurately reflect what the branch actually does.

## Step 1: Run Lint and Capture Output

```bash
make lint 2>&1
```

If lint passes cleanly, skip to Step 4.

## Step 2: Analyze and Fix Errors

Parse lint errors by category and fix each one:

| Category | Fix Strategy |
|----------|-------------|
| **Unused functions** | Use `mcp__serena__find_referencing_symbols` to check callers. If truly dead code, delete the function. |
| **Unused variables** | Remove the variable, or use it if the intent is clear from context. |
| **Missing error checks** | Add error handling per `fmt.Errorf("context: %w", err)` pattern. |
| **Ineffectual assignments** | Remove or restructure the assignment. |
| **Shadow declarations** | Rename the inner variable. |
| **Other lint issues** | Apply code-quality skill judgment. Read the relevant code, understand intent, fix correctly. |

For each fix:
1. Read the symbol containing the error using Serena tools
2. Understand the intent of the code
3. Apply the minimal correct fix — don't refactor surrounding code
4. Move to the next error

## Step 3: Verify Fixes

Run lint again:
```bash
make lint 2>&1
```

If errors remain, repeat Step 2 for remaining issues. After 2 failed attempts at the same error, stop and report it to the user.

## Step 4: Build Check

```bash
make build 2>&1
```

If the build fails, analyze the error and fix. Build errors take priority over any remaining lint warnings.

## Step 5: Optional Tests

If `$ARGUMENTS` contains `--test` or `--full`:
```bash
make test 2>&1
```

Fix any test failures. Otherwise, skip — tests run in CI.

## Step 6: Stage and Commit Code Fixes

If any code was changed in Steps 1-5, stage only the modified files and commit:
```
fix: resolve lint issues for PR
```

If no code changes were needed, skip this step.

## Step 7: Review PR Title and Description

Skip this step if `$ARGUMENTS` contains `--no-pr`.

1. Fetch the current PR metadata:
```bash
gh pr view --json title,body,baseRefName -q '{title: .title, body: .body, base: .baseRefName}'
```

2. Fetch the full diff against the base branch:
```bash
git log $(gh pr view --json baseRefName -q '.baseRefName')..HEAD --oneline
git diff $(gh pr view --json baseRefName -q '.baseRefName')...HEAD --stat
```

3. **Evaluate accuracy** — compare the current title and body against what the commits actually do:
   - Does the title accurately describe the change? (under 70 chars, focuses on the "what")
   - Does the body cover the key changes? Are there commits not reflected in the description?
   - Are there claims in the body that are no longer true (e.g., referencing removed code)?

4. **If the title and body are already accurate**, report "PR description is up to date" and skip to Step 8. Do NOT rewrite for style — only update when the content is materially wrong or incomplete.

5. **If updates are needed**, draft the new title and/or body and show the diff to the user:
   ```
   Current title: <old>
   Proposed title: <new>

   Body changes: <summary of what changed and why>
   ```

   Wait for user approval, then apply:
   ```bash
   gh pr edit --title "..." --body "$(cat <<'EOF'
   ...
   EOF
   )"
   ```

## Step 8: Report

Report to the user:
- Number of code issues fixed, by category (if any)
- Whether PR title/description was updated (and what changed)
- Any issues that could not be auto-fixed
- "Ready to push." if all clear
