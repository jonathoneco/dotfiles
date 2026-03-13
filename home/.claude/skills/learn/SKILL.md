---
name: learn
description: >
  Manage learning roadmaps and study sessions. Start a learning session on a topic,
  track progress, get lesson plans, and review what you've learned. Use when the user
  wants to study, learn, or review a topic from their learning roadmaps.
allowed-tools: "Read,Write,Edit,Glob,Grep,Bash(ls:*),Bash(mkdir:*),WebFetch"
---

# Learn - Learning Session Manager

Interactive learning companion that manages roadmaps, tracks progress, and runs teaching sessions.

## Commands

The user invokes `/learn` with an optional subcommand and arguments:

- `/learn` — Show all active roadmaps and current progress summary
- `/learn status` — Detailed progress for current roadmap
- `/learn start <topic>` — Begin a learning session on a specific topic from the roadmap
- `/learn new <subject>` — Create a new learning roadmap (fetches from roadmap.sh or builds custom)
- `/learn done <topic>` — Mark a topic as completed
- `/learn next` — Suggest the next topic to study based on progress
- `/learn review` — Quiz/review recently completed topics
- `/learn notes <topic>` — Show or add notes for a topic
- `/learn session` — Resume the most recent in-progress session
- `/learn switch <subject>` — Switch active roadmap to a different subject (e.g., `devops`, `golang`, `k8s`)
- `/learn subjects` — List all available roadmaps/subjects with progress summaries

## Behavior

### Showing Status (`/learn`, `/learn status`)

1. Read all roadmap files from `/Users/david/learning/*/roadmap.md`
2. Read corresponding `progress.json` files
3. Display a concise summary: roadmap name, current phase, % complete, next suggested topic
4. For `status`, show per-phase breakdown with completed/total counts

### Starting a Session (`/learn start <topic>`)

1. Find the topic in the active roadmap's `roadmap.md`
2. Mark it as `[~]` (in progress) in the roadmap
3. Update `progress.json` with `current_topic` and add a session entry
4. **Teach the topic** by:
   - Giving a structured explanation (what it is, why it matters in the DevOps/subject context, key concepts)
   - Providing practical examples and commands where applicable
   - Suggesting hands-on exercises the user can try
   - Linking to quality resources for deeper learning
5. After teaching, ask if the user wants to:
   - Continue with follow-up questions
   - Try a hands-on exercise
   - Mark as done and move to the next topic
   - Save notes and come back later

### Creating a New Roadmap (`/learn new <subject>`)

1. Check if a roadmap already exists at `/Users/david/learning/<subject>/`
2. If a roadmap.sh URL is available, fetch it for structure
3. Otherwise, create a reasonable roadmap based on the subject
4. Create `roadmap.md` with checkbox tracking and `progress.json`
5. Show the user the generated roadmap for approval

### Marking Complete (`/learn done <topic>`)

1. Find the topic in `roadmap.md`, change `[ ]` or `[~]` to `[x]`
2. Update `progress.json` counters
3. Log completion in `sessions` array with date
4. Suggest the next logical topic

### Next Topic (`/learn next`)

1. Read `progress.json` to find current phase and section
2. Find the first uncompleted `(rec)` topic in the current section
3. If section is done, move to next section/phase
4. Show the suggestion with a brief preview of what it covers

### Review (`/learn review`)

1. Gather all `[x]` completed topics from the last 5 sessions
2. Ask 3-5 quick questions to test retention
3. Provide feedback and note any areas needing revisit

### Switching Subjects (`/learn switch <subject>`, `/learn subjects`)

#### `/learn subjects`
1. Glob all directories under `/Users/david/learning/*/progress.json`
2. For each, read `progress.json` and compute overall % complete
3. Display a table: subject name, current phase, % complete, last session date
4. Highlight the currently active subject (if any)

#### `/learn switch <subject>`
1. Verify `/Users/david/learning/<subject>/progress.json` exists
2. Show a brief status of where the user left off in that subject
3. Set it as the active roadmap context for subsequent `/learn` commands
4. If subject doesn't exist, suggest `/learn new <subject>` instead

### Notes (`/learn notes <topic>`)

1. Read/create a note file at `/Users/david/learning/<roadmap>/notes/<topic-slug>.md`
2. If the user provides content, append it
3. If no content, display existing notes

## File Structure

```
/Users/david/learning/
  <roadmap-name>/
    roadmap.md        # Checkbox-based progress tracker
    progress.json     # Machine-readable state
    notes/            # Per-topic study notes
      <topic-slug>.md
```

## Session Logging

When a session starts or ends, append to `progress.json`'s `sessions` array:

```json
{
  "date": "2026-03-10",
  "topic": "Docker",
  "action": "started|completed|reviewed",
  "duration_approx": "30min",
  "notes": "optional summary"
}
```

## Guidelines

- Be a patient, thorough teacher — explain concepts clearly with real-world analogies
- Tailor depth to the user's apparent experience level
- Prefer practical examples over pure theory
- When teaching CLI tools, show actual commands the user can run
- Connect topics to each other — show how they fit in the bigger picture
- Keep the tracker updated after every session
