# Generate Blog Post

You are writing a blog post about a software project. The user has provided the following:

**Project or topic:** $ARGUMENTS

---

## Phase 1: Research (parallel subagents)

Launch these agents in parallel to gather context. Each agent should return a concise summary — key decisions, struggles, breakthroughs, and interesting details.

### Agent 1: Chat History Explorer
```
Search for Claude Code conversation histories related to this project.

Check these locations for conversation logs, transcripts, or session data:
- ~/.claude/projects/ (look for directories matching the project name or path)
- ~/.claude/ (any conversation export files)
- The project directory itself for any .claude/ session artifacts

Also search for any work harness artifacts:
- .work/ directories with state.json, handoff prompts, checkpoints
- docs/ directories with feature specs or research notes

Read through what you find and extract:
- What problems were solved and how
- Key architectural decisions and why they were made
- Dead ends, pivots, and "aha" moments
- Struggles and breakthroughs
- Interesting technical details or surprising findings

Return a structured summary organized chronologically. Quote specific interesting passages where relevant.
```

### Agent 2: Git History & Code Explorer
```
Explore the git history and current codebase for this project.

Run:
- git log --oneline -50 (recent commit history)
- git log --all --oneline --grep="<relevant keywords>" (topic-specific commits)
- Look at the README, CLAUDE.md, and any docs/ for project context
- Browse the codebase structure to understand what was built

Also check beads issue history:
- bd list --status=closed (completed work)
- bd search "<relevant keywords>"
- bd show on any relevant issues

Extract:
- The evolution of the project (what was built in what order)
- Commit messages that tell a story
- Closed issues that document decisions and outcomes
- The current state of what exists

Return a chronological narrative of the project's development with key technical details.
```

### Agent 3: External Context (if applicable)
```
If the project uses notable libraries, frameworks, or techniques, briefly search for:
- How others have written about similar projects or approaches
- Any community discussion about the tools/techniques used
- Context that would help a reader understand why this project matters

Keep this brief — 5-10 bullet points of relevant external context, not a research paper.
If the project is purely personal with no notable external context, just say so.
```

---

## Phase 2: Synthesize & Choose a Pattern

Once all agents report back, synthesize the findings and choose the best blog post pattern:

| Pattern | Use when... |
|---------|------------|
| **Bug Hunt** | There's a great debugging story — a mystery with a satisfying resolution |
| **How I Built It** | The architecture or approach is novel and worth walking through |
| **Lessons Learned** | The project taught you something transferable |
| **We Rewrote It in X** | There was a meaningful technology migration |
| **Benchmarks** | You have compelling performance data or comparisons |

Present the user with:
1. A recommended pattern with reasoning
2. The single central idea for the post (one idea only — if there are two, propose two posts)
3. The target audience (default: "past me before I built this")
4. 3-5 candidate titles
5. A proposed outline (H2 sections with 1-2 sentence descriptions)

**Wait for user approval before proceeding to Phase 3.**

---

## Phase 3: Draft

Write the blog post following these principles:

### Structure
- Open with the problem or situation that motivated the project — make the reader care in the first 2-3 sentences
- Include the "why" behind decisions, not just the "what"
- Show dead ends and what didn't work — these are often the most valuable parts
- Use real code from the project (messy is fine — show it, then explain it)
- End with what you'd do differently or what's next — not a generic conclusion

### Voice
- Write in first person, conversational tone
- Keep rough edges — sentence fragments, casual asides, and strong opinions are good
- Do NOT use these phrases: "In conclusion", "It's important to note", "Let's dive in", "In today's fast-paced world", "without further ado"
- Avoid hedging and filler. Say what you mean directly
- If a Voice DNA document exists at .claude/writing-style.md, follow it

### Technical content
- Code blocks should use the project's actual code, not sanitized examples
- Explain jargon on first use but don't over-explain basics
- Link to relevant documentation or tools when mentioning them
- Include specific versions, error messages, and concrete details — specificity is what makes technical writing valuable

### Format
- Target 1,000-2,000 words (adjust based on content density)
- Use H2 for major sections, H3 sparingly
- Code blocks with language tags for syntax highlighting
- No hero image placeholder — leave that for later

---

## Phase 4: Self-Review

After drafting, review your own post against these criteria:

1. **Central idea test:** Can you state the one thing this post is about in one sentence? If not, it needs tightening.
2. **"So what?" test:** Would a reader learn something actionable or gain a useful perspective? If it reads like documentation, add more opinion and experience.
3. **Genericness check:** Could this post have been written by someone who didn't build the project? If yes, it needs more specific details, personal decisions, and real code.
4. **Energy check:** Where does the post lose momentum? Cut or restructure those sections.
5. **Opening test:** Do the first 3 sentences make you want to keep reading? If they're setup/context, move the hook earlier.
6. **Code test:** Is every code block from the actual project? Are they explained but not over-explained?

Apply fixes based on the review, then present the final draft.

---

## Output

Write the post as a Markdown file with proper Astro frontmatter:

```yaml
---
title: "<title>"
description: "<1-2 sentence description for SEO/social>"
pubDate: <today's date>
draft: true
tags: [<relevant tags>]
---
```

Save to `./<slug>.md` in the project root directory, where slug is a URL-friendly version of the title.

Tell the user what you wrote and where, and ask if they want revisions.
