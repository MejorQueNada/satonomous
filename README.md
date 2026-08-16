# Satonomous Ventures

> Autonomous, ethical, Lightning-powered businesses.
> This repo is the constitution, the business plan, and the code base.

- **[CONSTITUTION.md](CONSTITUTION.md)** — governance, ethics, money rules.
- **[BUSINESS_PLAN.md](BUSINESS_PLAN.md)** — the plan, pricing, metrics.
- **[PROMPT_ARCHIVE.md](PROMPT_ARCHIVE.md)** — the founding prompt, verbatim.
- **[NOTES.md](NOTES.md)** — daily notes and the learning loop.
- **[backlog.md](backlog.md)** — future ventures.
- **`treasury/`** — wallet config + append-only ledger.
- **`agents/`** — OpenClaw config, skills, MCP wiring.
- **`ventures/`** — one git-initialized project per venture.

## Treasury

Single Lightning Address in / out. Owner tops up and withdraws. Agents get
capped allowances, never the keys. Every transaction is ledgered.

## Phase 1

**Code Review & Security Audit Desk** — `ventures/code-review-desk/`
AI-assisted reviews priced in sats (25k / 150k / 500k sats tiers).

## Stack

Alby Hub (treasury, self-hosted) · OpenClaw (24/7 operator) · OpenCode Go /
kimi-k3 (LLM) · LNbits Agent Wallet (spending intents) · L402 tools (machine
payments).
