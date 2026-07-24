# Global agent skills — vendoring manifest

Canonical store: `home/.agents/skills/`. This manifest is the single tracking
mechanism for vendored skills (the old `npx skills` lock is retired). Refresh
only via `scripts/refresh-agent-skills.sh` — staged and reviewed, never by
mutating the live store directly.

## mattpocock/skills

- Upstream: https://github.com/mattpocock/skills
- Pinned SHA: `ed37663cc5fbef691ddfecd080dff42f7e7e350d`
- Last refresh: 2026-07-24
- Cadence: quarterly, or when a consuming repo needs a newer skill. The
  Claude SessionStart nudge fires when the last-refresh date is >90 days old.

| Skill | Upstream path |
|---|---|
| ask-matt | skills/engineering/ask-matt |
| code-review | skills/engineering/code-review |
| codebase-design | skills/engineering/codebase-design |
| diagnosing-bugs | skills/engineering/diagnosing-bugs |
| domain-modeling | skills/engineering/domain-modeling |
| edit-article | skills/personal/edit-article |
| git-guardrails-claude-code | skills/misc/git-guardrails-claude-code |
| grill-me | skills/productivity/grill-me |
| grill-with-docs | skills/engineering/grill-with-docs |
| grilling | skills/productivity/grilling |
| handoff | skills/productivity/handoff |
| implement | skills/engineering/implement |
| improve-codebase-architecture | skills/engineering/improve-codebase-architecture |
| loop-me | skills/in-progress/loop-me |
| migrate-to-shoehorn | skills/misc/migrate-to-shoehorn |
| prototype | skills/engineering/prototype |
| research | skills/engineering/research |
| resolving-merge-conflicts | skills/engineering/resolving-merge-conflicts |
| scaffold-exercises | skills/misc/scaffold-exercises |
| setup-matt-pocock-skills | skills/engineering/setup-matt-pocock-skills |
| tdd | skills/engineering/tdd |
| teach | skills/productivity/teach |
| to-spec | skills/engineering/to-spec |
| to-tickets | skills/engineering/to-tickets |
| triage | skills/engineering/triage |
| wayfinder | skills/engineering/wayfinder |
| wizard | skills/in-progress/wizard |
| writing-beats | skills/in-progress/writing-beats |
| writing-fragments | skills/in-progress/writing-fragments |
| writing-great-skills | skills/productivity/writing-great-skills |
| writing-shape | skills/in-progress/writing-shape |

Skills under upstream `skills/in-progress/` are unfinished upstream; they are
kept deliberately and reviewed at each refresh (drop them if upstream deletes
them or they stop earning their place).

## Other vendors (refreshed ad hoc, tracked here for provenance)

| Skill | Upstream |
|---|---|
| cmux, cmux-browser, cmux-custom-sidebar, cmux-customization, cmux-keyboard-shortcuts, cmux-markdown, cmux-settings, cmux-workspace | manaflow-ai/cmux |
| herdr | ogulcancelik/herdr |
| notion-cli | makenotion/skills |
| plannotator-annotate, plannotator-review | backnotprop/plannotator |

## Local (hand-written, never overwritten by refresh)

`cmux-orchestration`, `plannotator-last`, `spec-package`, `work-mandates`.
