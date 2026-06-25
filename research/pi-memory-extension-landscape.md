# Research: Pi coding agent memory-extension landscape beyond `@samfp/pi-memory` and `jo-inc/pi-mem`

## Summary

The strongest non-excluded candidates are `pi-hermes-memory`, `pi-observational-memory`, `pi-memctx`, `pi-memory-md`, `@cortexkit/pi-magic-context`, and `pi-memory` by jayzeng. Public reception is mostly visible through pi.dev/npm download velocity and GitHub stars/activity; I found little indexed Reddit/HN discussion for these packages, but some third-party docs/blog coverage exists.

## Ranked candidates

### 1. `pi-hermes-memory` — persistent memory + session search + secret scanning

- **Links:** [pi.dev](https://pi.dev/packages/pi-hermes-memory), [GitHub](https://github.com/chandra447/pi-hermes-memory), [Libraries.io](https://libraries.io/npm/pi-hermes-memory)
- **Adoption/activity:** pi.dev search result showed roughly **6,184 downloads/mo · 2,525/wk** for v0.7.8; GitHub search showed **43 stars, 5 forks, 2 open issues, 4 contributors, 5 releases, last push May 14 2026**. [pi.dev](https://pi.dev/packages/pi-hermes-memory), [GitHub](https://github.com/chandra447/pi-hermes-memory)
- **Positive reception evidence:** High Pi-gallery downloads for a memory package; README emphasizes mature surface area: SQLite FTS5 session search, memory categories, secret scanning, auto-consolidation, procedural skills, onboarding, and “368 tests.” [pi.dev](https://pi.dev/packages/pi-hermes-memory)
- **Complaints/risks:** Background review costs extra LLM calls; session history requires indexing; older Markdown memories may need backfill; core Markdown memory remains capped; `§` delimiter can split unusual entries. [pi.dev](https://pi.dev/packages/pi-hermes-memory)
- **Confidence:** **High** — best combined evidence of downloads, stars, recency, and depth.

### 2. `pi-observational-memory` — compaction/continuity memory for long sessions

- **Links:** [pi.dev](https://pi.dev/packages/pi-observational-memory), [GitHub](https://github.com/elpapi42/pi-observational-memory), [npm registry](https://registry.npmjs.org/pi-observational-memory), [Mastra OM research](https://mastra.ai/research/observational-memory)
- **Adoption/activity:** GitHub search showed **57 stars, 5 forks, 2 open issues, 2 contributors, releases, active pushes into May 2026**; npm registry shows latest **2.4.3** published May 15 2026. [GitHub](https://github.com/elpapi42/pi-observational-memory), [npm](https://registry.npmjs.org/pi-observational-memory)
- **Positive reception evidence:** Highest star count among Pi-specific memory extensions found, excluding the user’s baselines. The concept also rides strong external validation from Mastra’s observational-memory research, although this package is an independent Pi implementation. [GitHub](https://github.com/elpapi42/pi-observational-memory), [Mastra](https://mastra.ai/research/observational-memory)
- **Complaints/risks:** This is primarily **compaction continuity**, not broad semantic/project RAG. It adds background observer/reflector/pruner model calls; config changed between v1 and v2 and old keys are silently ignored; recall is by stored IDs rather than a general search UX. [pi.dev](https://pi.dev/packages/pi-observational-memory)
- **Confidence:** **High** for long-session continuity; **medium** if the desired feature is general searchable long-term memory.

### 3. `pi-memctx` — local Markdown memory gateway with benchmarks

- **Links:** [npm](https://registry.npmjs.org/pi-memctx), [GitHub](https://github.com/weauratech/pi-memctx), [Libraries.io](https://libraries.io/npm/pi-memctx)
- **Adoption/activity:** npm search showed about **3.1K weekly downloads** and **30 versions**; GitHub search showed low stars (**3**) but multiple contributors and recent May 2026 release/activity. [npm](https://registry.npmjs.org/pi-memctx), [GitHub](https://github.com/weauratech/pi-memctx)
- **Positive reception evidence:** High npm velocity; README includes reproducible/local benchmarks claiming major reductions in latency, provider tokens, and tool calls, with local-first Markdown/Obsidian-style memory packs. [pi.dev/package content](https://pi.dev/packages/pi-memctx)
- **Complaints/risks:** Download count is much stronger than GitHub social proof. qmd is optional but needed for better retrieval; benchmarks are self-reported; memory-pack setup may be heavier than simple `MEMORY.md` tools. [pi.dev/package content](https://pi.dev/packages/pi-memctx)
- **Confidence:** **Medium-high** — strong usage signal, weaker independent sentiment.

### 4. `pi-memory-md` — Letta-like Git-backed Markdown memory

- **Links:** [pi.dev](https://pi.dev/packages/pi-memory-md), [GitHub](https://github.com/VandeeFeng/pi-memory-md), [npm](https://registry.npmjs.org/pi-memory-md), [LazyPi docs](https://lazypi.org/docs/packages/memory.html)
- **Adoption/activity:** npm search showed **815 weekly downloads**, **20 versions**, and **1 dependent**; GitHub search showed **23 stars, 2 forks, 0 open issues**. [npm](https://registry.npmjs.org/pi-memory-md), [GitHub](https://github.com/VandeeFeng/pi-memory-md)
- **Positive reception evidence:** Third-party LazyPi docs recommend/describe it as durable external memory backed by a GitHub repo, emphasizing auditable, reversible Markdown memory. [LazyPi](https://lazypi.org/docs/packages/memory.html)
- **Complaints/risks:** Requires configuring a private Git repo; docs explicitly warn not to let project settings override memory repo/path/sync hooks; experimental “tape mode” may consume more tokens and can change behavior. [pi.dev](https://pi.dev/packages/pi-memory-md)
- **Confidence:** **Medium-high** — good downloads plus a third-party recommendation.

### 5. `@cortexkit/pi-magic-context` — cross-harness memory/context engine

- **Links:** [pi.dev](https://pi.dev/packages/@cortexkit/pi-magic-context), [GitHub monorepo](https://github.com/cortexkit/magic-context), [npm](https://registry.npmjs.org/@cortexkit/pi-magic-context)
- **Adoption/activity:** GitHub monorepo search showed **~593 stars, 32 forks, 11 open issues**; npm search showed **399 weekly downloads** for the Pi package and **2.4K weekly downloads** for the OpenCode sibling package. [GitHub](https://github.com/cortexkit/magic-context), [npm](https://registry.npmjs.org/@cortexkit/pi-magic-context)
- **Positive reception evidence:** Strongest general repo popularity in the set and useful cross-harness story: memories/embeddings/dreamer state shared between Pi and OpenCode. [pi.dev](https://pi.dev/packages/@cortexkit/pi-magic-context)
- **Complaints/risks:** Pi extension is explicitly **beta**; package is large; requires Pi/TUI >= 0.71.0; embedding-model mismatches can make cross-harness search return zero results; storage failures are fatal by design. [pi.dev](https://pi.dev/packages/@cortexkit/pi-magic-context)
- **Confidence:** **Medium-high** — popular project, but Pi adapter is newer/beta.

### 6. `pi-memory` by jayzeng — qmd-powered Markdown memory/search

- **Links:** [pi.dev](https://pi.dev/packages/pi-memory), [GitHub](https://github.com/jayzeng/pi-memory), [npm](https://registry.npmjs.org/pi-memory)
- **Adoption/activity:** pi.dev showed **1,211 downloads/mo · 200/wk**; GitHub search showed **26 stars, 2 forks, 0 open issues, 2 contributors**; search also surfaced merged PRs from another contributor. [pi.dev](https://pi.dev/packages/pi-memory), [GitHub](https://github.com/jayzeng/pi-memory)
- **Positive reception evidence:** Solid mid-tier downloads/stars; simple plain-Markdown model with optional qmd keyword/semantic/deep search, scratchpad, daily logs, and selective prompt injection. [pi.dev](https://pi.dev/packages/pi-memory)
- **Complaints/risks:** Semantic/deep search needs qmd + embeddings and sometimes a manual `qmd embed`; selective injection can add prompt tokens; last indexed push was April 2026. [pi.dev](https://pi.dev/packages/pi-memory)
- **Confidence:** **Medium-high** — straightforward, used, and not overcomplicated.

### 7. `@zhafron/pi-memory` — basic identity/user/MEMORY/daily-log layer

- **Links:** [pi.dev](https://pi.dev/packages/@zhafron/pi-memory), [GitHub](https://github.com/tickernelz/pi-memory), [npm](https://registry.npmjs.org/@zhafron/pi-memory)
- **Adoption/activity:** pi.dev showed **1,139 downloads/mo · 327/wk**; GitHub search showed **6 stars, 0 forks, 0 open issues**, created/last pushed Feb 18 2026. [pi.dev](https://pi.dev/packages/@zhafron/pi-memory), [GitHub](https://github.com/tickernelz/pi-memory)
- **Positive reception evidence:** Surprisingly good pi.dev downloads for a minimal memory extension; simple cross-platform setup and first-run bootstrap. [pi.dev](https://pi.dev/packages/@zhafron/pi-memory)
- **Complaints/risks:** Low GitHub activity and only 2 versions; injects MEMORY/IDENTITY/USER into the system prompt, which is simple but token- and prompt-contamination-prone compared with retrieval/policy approaches. [pi.dev](https://pi.dev/packages/@zhafron/pi-memory)
- **Confidence:** **Medium** — download signal is good, maintenance signal is weak.

### 8. `@p8n.ai/pi-remembers` — Cloudflare AI Search-backed memory/project search

- **Links:** [pi.dev](https://pi.dev/packages/@p8n.ai/pi-remembers), [npm](https://registry.npmjs.org/@p8n.ai/pi-remembers), [Libraries.io](https://libraries.io/npm/@p8n.ai%2Fpi-remembers)
- **Adoption/activity:** npm search showed **218 weekly downloads**, **3 versions**. I did not find reliable GitHub star metrics in indexed search. [npm](https://registry.npmjs.org/@p8n.ai/pi-remembers)
- **Positive reception evidence:** Distinctive feature set: Cloudflare AI Search, project-file indexing, cross-project recall, synthesis sub-process, and local pipeline observability dashboard. [pi.dev](https://pi.dev/packages/@p8n.ai/pi-remembers)
- **Complaints/risks:** Requires Cloudflare account/API token and external service; automatic recall/ingest hooks are off by default; less public star/discussion evidence than local-first alternatives. [pi.dev](https://pi.dev/packages/@p8n.ai/pi-remembers)
- **Confidence:** **Medium** — promising but lower public reception signal.

### 9. `@e9n/pi-memory` — memory package inside espennilsen/pi extension suite

- **Links:** [GitHub package dir](https://github.com/espennilsen/pi/tree/main/extensions/pi-memory), [Libraries.io](https://libraries.io/npm/@e9n%2Fpi-memory), [npm profile](https://www.npmjs.com/~e9n)
- **Adoption/activity:** Parent repo search showed **71 stars**; package itself is v0.1.0 and Libraries.io lists it as a persistent memory system for Pi. [GitHub](https://github.com/espennilsen/pi/tree/main/extensions/pi-memory), [Libraries.io](https://libraries.io/npm/@e9n%2Fpi-memory)
- **Positive reception evidence:** The broader extension suite has some GitHub attention; memory package offers plain Markdown, daily logs, full-text search, and prompt injection. [GitHub](https://github.com/espennilsen/pi/tree/main/extensions/pi-memory)
- **Complaints/risks:** Package-specific adoption/download signal is weak or unavailable; v0.1.0 only; parent-repo stars may reflect the suite rather than memory. [Libraries.io](https://libraries.io/npm/@e9n%2Fpi-memory)
- **Confidence:** **Low-medium**.

### 10. `pi-brain` — versioned Git-like memory/branching

- **Links:** [pi.dev](https://pi.dev/packages/pi-brain), [GitHub](https://github.com/Whamp/pi-brain), [npm](https://registry.npmjs.org/pi-brain)
- **Adoption/activity:** pi.dev showed **200 downloads/mo · 21/wk**; GitHub search showed **10 stars, 4 forks, 1 open issue, 6 releases**, latest release Mar 1 2026. [pi.dev](https://pi.dev/packages/pi-brain), [GitHub](https://github.com/Whamp/pi-brain)
- **Positive reception evidence:** Interesting differentiated design: `.memory/` commits/branches/merges, prompt-cache safety, and regression-tested static prompt behavior. [pi.dev](https://pi.dev/packages/pi-brain)
- **Complaints/risks:** Low download velocity; more a versioned project-memory protocol than a general searchable assistant memory; activity looks older than top candidates. [pi.dev](https://pi.dev/packages/pi-brain)
- **Confidence:** **Low-medium**.

### 11. `@ryan_nookpi/pi-extension-memory-layer` — Markdown memory with overlay UI

- **Links:** [pi.dev](https://pi.dev/packages/@ryan_nookpi/pi-extension-memory-layer), [GitHub monorepo](https://github.com/Jonghakseo/pi-extension/tree/main/packages/memory-layer), [npm](https://registry.npmjs.org/@ryan_nookpi/pi-extension-memory-layer)
- **Adoption/activity:** pi.dev showed **146 downloads/mo · 9/wk**; npm search showed **123 weekly downloads** in a separate index. [pi.dev](https://pi.dev/packages/@ryan_nookpi/pi-extension-memory-layer), [npm](https://registry.npmjs.org/@ryan_nookpi/pi-extension-memory-layer)
- **Positive reception evidence:** Nice UX surface: `/remember`, `/memory` overlay browser, scoped user/project memories, no runtime dependencies. [pi.dev](https://pi.dev/packages/@ryan_nookpi/pi-extension-memory-layer)
- **Complaints/risks:** Low adoption; injects memory index each turn; monorepo/package-specific stars not obvious. [pi.dev](https://pi.dev/packages/@ryan_nookpi/pi-extension-memory-layer)
- **Confidence:** **Low-medium**.

### 12. `pi-mem` by georgebashi — observation capture + LanceDB search

- **Links:** [pi.dev](https://pi.dev/packages/pi-mem), [GitHub](https://github.com/georgebashi/pi-mem), [npm](https://registry.npmjs.org/pi-mem)
- **Adoption/activity:** pi.dev showed **46 downloads/mo · 14/wk**; GitHub search showed **1 star, 0 forks, 0 open issues**. [pi.dev](https://pi.dev/packages/pi-mem), [GitHub](https://github.com/georgebashi/pi-mem)
- **Positive reception evidence:** Featureful despite low adoption: captures tool results, summarizes observations, LanceDB vector/full-text search, privacy tags, project scoping. [pi.dev](https://pi.dev/packages/pi-mem)
- **Complaints/risks:** Very low public reception; name collides with the user-excluded `jo-inc/pi-mem`/plain-md ecosystem; embedding provider setup required for semantic search. [pi.dev](https://pi.dev/packages/pi-mem)
- **Confidence:** **Low**.

## Not ranked / dropped

- **`@samfp/pi-memory`** — excluded by task despite high downloads and stars. [pi.dev](https://pi.dev/packages/@samfp/pi-memory)
- **`jo-inc/pi-mem`** — excluded by task despite high stars and blog coverage. [GitHub](https://github.com/jo-inc/pi-mem)
- **`pi-total-recall`** — meta-package around `@samfp/pi-memory`, so not a separate beyond-`@samfp` memory candidate. [GitHub](https://github.com/samfoy/pi-total-recall)
- **`ArtemisAI/pi-mem`** — only ~6 stars surfaced and no clear npm/pi.dev package adoption in searches; maybe worth revisiting if you specifically want claude-mem integration. [GitHub](https://github.com/ArtemisAI/pi-mem/blob/main/pi-agent/README.md)
- **`k1lgor/pi-memoir`** — has a DEV post, but GitHub search showed 0 stars/0 forks and no strong package adoption signal. [GitHub](https://github.com/k1lgor/pi-memoir), [DEV](https://dev.to/k1lgor/i-taught-my-ai-assistant-to-remember-and-saved-99-of-its-brain-4n7l)
- **`GitHubFoxy/pi-observational-memory` / `pi-extension-observational-memory`** — older/alternative observational-memory implementation with 12 stars, but `elpapi42/pi-observational-memory` appears more active and more adopted. [GitHub](https://github.com/GitHubFoxy/pi-observational-memory), [Libraries.io](https://libraries.io/npm/pi-extension-observational-memory)
- **`@db0-ai/pi`** — npm showed 336 weekly downloads, but pi.dev package did not exist and GitHub signal was weak/indirect via the broader db0 repo. [npm](https://registry.npmjs.org/%40db0-ai%2Fpi), [db0](https://db0.ai/)

## Gaps

- I found little/no indexed Reddit or Hacker News discussion for these specific Pi memory packages; reception is mostly package-gallery/npm/GitHub evidence.
- npm weekly downloads came from indexed npm/registry snippets, not a live npm downloads API call, so treat them as approximate.
- GitHub star counts varied slightly across indexed snippets for fast-moving repos; rankings use broad signal rather than exact point-in-time values.
- Best next step before installing: read source for the top 3–5 packages because Pi packages execute code and can influence agent behavior.
