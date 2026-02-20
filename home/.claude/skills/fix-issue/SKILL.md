# /fix-issue

Fix a bug from error output, logs, or user description.

## Usage

```
/fix-issue <error message or bug description>
```

## Workflow

1. **Find or create issue (MANDATORY — do this BEFORE reading code or editing anything)**: Search open beads issues for a match. If none found, create one with `bd create --title="[Bug] ..." --type=bug --priority=2`. Claim it with `bd update <id> --status=in_progress`. **Do NOT proceed to step 2 without an in_progress issue.**

2. **Search closed issues for context**: Use a sub-agent to search closed beads issues for prior fixes to similar problems:
   ```
   Task(subagent_type="Explore", prompt="Search closed beads issues for context about <error/bug>.
   Run: bd list --status=closed | grep -i <keyword>
   Then bd show each relevant match.
   Return concise summary: relevant files, patterns, key decisions.")
   ```

3. **Locate the problem**: Use error messages, stack traces, and closed issue context to find the relevant source files. Read them to understand the bug.

4. **Implement the fix**: Make the minimal change needed. Follow project conventions (error wrapping, slog logging, constructor injection).

5. **Run tests**: Execute `make test` to verify the fix doesn't break anything. If the fix area lacks test coverage, add a test case.

6. **Close the issue**: `bd close <id> --reason="Fixed: <what was wrong and what was changed>"`
