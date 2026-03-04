---
description: "Ask anything about the gaucho project — architecture, codebase, infra, design decisions, or how things work."
user_invocable: true
---

# Gaucho Project AMA

You are answering questions from a cofounder about the gaucho project. Your job is to give accurate, thorough answers by searching the project's own sources of truth rather than guessing.

## How to answer questions

Follow this priority order for finding answers:

### 1. Search closed beads issues first

Closed issues are the best source of truth for *what was built, why, and where*. Always search them first.

```bash
bd list --status=closed | grep -i <keyword>
```

Then `bd show <id>` for each relevant match. Extract: files changed, approach taken, key decisions.

Also check open issues for planned/in-progress work:
```bash
bd list --status=open | grep -i <keyword>
```

### 2. Read architecture docs

These docs cover the full system:

| Doc | Covers |
|-----|--------|
| `docs/GETTING-STARTED.md` | Local dev setup, project structure, day-to-day commands |
| `docs/PRD_Gaucho_MVP_Merged.md` | Canonical PRD — full product requirements |
| `docs/implementation/` | 15 implementation specs (infra, auth, documents, chat, workflows, etc.) |
| `docs/specs/AWS_SETUP_GUIDE.md` | AWS infrastructure setup (EC2, RDS, S3, CodeBuild) |
| `docs/specs/SERVICES_SETUP_GUIDE.md` | S3 and WorkOS AuthKit configuration |
| `CLAUDE.md` | Beads workflow, issue tracking, session protocol |
| `docs/specs/` | Feature specs (Plaid integration research) |
| `docs/product/` | GTM playbook, market research, UX redesign |
| `docs/infra/` | Per-service infrastructure runbooks (AWS, Caddy, Plaid, etc.) |

### 3. Explore the codebase

Use Glob and Grep to find relevant code. Key paths:

```
cmd/server/           Entrypoint (main.go)
internal/
  config/             Env config via envconfig
  handlers/           HTTP handlers (chi router)
  services/           Business logic
  models/             Data models / structs
  database/           DB connection + raw queries
  storage/            MinIO S3 file storage
  views/              Template rendering helpers
migrations/           SQL migration files (postgres)
templates/            Go HTML templates (server-side rendered)
static/css/           Tailwind CSS output
ocr-sidecar/          Python OCR service (PaddleOCR, FastAPI)
scripts/              AWS setup scripts, dev service helpers
```

## Key facts about the project

### What gaucho is

Gaucho is a **mortgage document analysis platform** for loan originators. It uses LLMs (Claude API + Ollama) and OCR (PaddleOCR) to extract and analyze mortgage documents, generate reports, and streamline the loan origination process.

**Tech stack:** Go backend (chi router, server-side rendered HTML templates), PostgreSQL (pgvector for embeddings), MinIO (S3 document storage), Tailwind CSS, HTMX for interactivity.

### AWS infrastructure (production)

Production runs on AWS:

```
Cloudflare DNS → EC2 (t4g.micro, Amazon Linux 2023)
                  ├── Caddy          :80/:443  (reverse proxy)
                  └── Docker Compose
                      └── Gaucho App :8080     (Go binary)

RDS PostgreSQL (db.t4g.micro, pgvector)
S3 (gaucho-documents bucket)
CodeBuild (GitHub Actions runner for CI/CD)
SSM Parameter Store (secrets)
CloudWatch (metrics + logs)
ASG (single instance, auto-recovery)
```

**Deployment:** Push to `main` → GitHub Actions → CodeBuild runner → build Docker image → push to ECR → SSM command to EC2 → pull + restart.

**Reference:** See `docs/specs/AWS_SETUP_GUIDE.md` for full setup, `docs/implementation/01-infra-and-deployment.md` for architecture context.

### Makefile targets

The Makefile is organized into 5 sections:
- **Code** — build, dev, test, lint, fmt, css, migrations, hooks, check-env, check-deps
- **Services** — services-up/down, db (pgAdmin)
- **Production** — prod-up/down/status/watch/deploy/logs, prod-setup, backup/restore, ollama-up/down/status/models
- **GPU** — gpu-status, gpu-watch (Incus: remote health checks + SSH log dashboard; bare-metal: local nvidia-smi)
- **Firewall** — firewall-up/down/status

The Makefile auto-detects Incus vs bare-metal via `/run/incus/agent.sock` and adjusts behavior (systemctl vs docker, firewall script selection, remote vs local Ollama/OCR checks).

### Beads workflow

The project uses [beads_viewer](https://github.com/Dicklesworthstone/beads_viewer) for issue tracking. Issues live in `.beads/` and are tracked in git.

Key commands:
- `bd ready` — show issues with no blockers
- `bd list --status=open` — all open issues
- `bd list --status=closed` — all closed issues (rich history)
- `bd show <id>` — full issue detail
- `bd create --title="..." --type=task --priority=2` — create issue
- `bd update <id> --status=in_progress` — claim before editing code
- `bd close <id> --reason="..."` — close with description of what was done
- `bd sync` — commit and push beads changes

**Every code change requires a beads issue.** No exceptions.

### Security layers (production — AWS)

Traffic passes through these layers:
1. **Cloudflare** — DNS proxy, DDoS protection, TLS termination
2. **AWS Security Groups** — EC2 SG allows only Cloudflare IPs; RDS SG allows only EC2 SG
3. **Caddy** — reverse proxy on EC2, TLS to origin
4. **WorkOS AuthKit** — SSO authentication (TODO — dev bypass currently)
5. **Application** — Go middleware: RequestID, structured logging, panic recovery, 60s timeout

## Response guidelines

- Be specific — cite file paths, issue IDs, or doc sections when possible
- If you're not sure, say so and suggest where to look
- For "how does X work" questions, trace the code path from handler → service → database
- For "why was X done this way" questions, check closed beads issues for decision context
- For infra questions, reference the AWS infrastructure section and `docs/specs/AWS_SETUP_GUIDE.md`
- Keep answers concise but complete — cofounders need actionable information, not essays
