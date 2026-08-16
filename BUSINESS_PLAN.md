# Business Plan — Satonomous Ventures

## What we are

A collection of autonomous, Lightning-powered businesses run by agents with the
owner's oversight. The repository is simultaneously the business plan, the code
base, and the constitution.

## How we make money (the model)

**Automation delivers real service work; humans pay in sats.**
The pure "agent-pays-agent" economy (L402) is early. The reliable path is:
automated pipeline → human-verified deliverable → Lightning invoice → sats in
the treasury → owner withdraws 80% / reinvests 20%.

## Phase 1 — Code Review & Security Audit Desk (`ventures/code-review-desk/`)

AI-assisted code review and security auditing, priced in sats.

### Product tiers
| Tier | Price (sats) | What they get | Turnaround |
|------|-------------|---------------|------------|
| Quick scan | 25,000 | Automated static analysis + LLM pass, severity-ranked issue list | ~1h |
| Standard review | 150,000 | Full review: architecture, correctness, security, prioritized report | 24–48h |
| Deep audit | 500,000 | In-depth audit: invariants, attack modeling, PoC sketches, re-test round | 3–5 days |

Prices are starting points and scale with code size/complexity (per research:
AI-assisted audits run ~$0.07–$0.50/line; entry human audits $450+).

### Pipeline
1. Client submits repo/gist link + tier + scope.
2. Payment (Lightning invoice / LNURL-pay / L402 for the automated scan).
3. Pipeline runs: static analyzers (slither for Solidity, semgrep, bandit,
   eslint, etc. by language) + LLM reasoning (paid zero-retention Zen models).
4. Severity-ranked report (Critical/High/Medium/Low/Info) with root cause and fix
   guidance. Human (owner) review gate before delivery.
5. Deliver report; one remediation re-check included per engagement.

### Cost basis (for pricing sanity)
- LLM cost for a standard review: ~$0.10–$0.50 (Gemini Flash Lite / GPT-5 Nano).
- Infra: this machine, near-zero marginal cost. Margin ≈ 95%+ per engagement.

### Sales channels
- BOLT.fun listing, Stacker News posts + bounties, Microlancer, Plebwork.
- Dev communities (Reddit, Discord) with a landing page + L402 paywall for the
  automated Quick scan tier.
- Reputation arm (backlog) feeds customers to this desk.

### Success metrics (Phase 1)
- First paid gig within 30 days of listing.
- ≥3 paid gigs in month 2; ≥6 in month 3.
- Avg ticket ≥ 100k sats. Positive cumulative cash flow by month 3.
- Every gig documented in the treasury ledger.

## Phase 2+ (see `backlog.md`)

L402 micro-API farm, reputation/content arm, Lightning infra hosting, ethical
affiliate/SEO content. Launch each as its own git-initialized venture with a
written intent, seed, and metrics.

## Infrastructure

- **Treasury:** self-hosted Alby Hub (24/7 on this machine). Lightning Address
  for fund/withdraw. Per-venture NWC connections with budgets.
- **Operator:** OpenClaw (daemonized, cron, memory, Telegram control).
- **Money rails:** LNbits Agent Wallet (or Alby Hub NWC budgets) for agent
  spending limits; L402 tools (`lnget`, `aperture`) as ventures require.
- **LLM:** OpenCode Zen API (Anthropic-compatible + OpenAI-compatible endpoints).
- **Boxes:** this machine (8 cores, 7.3GB RAM, 95GB free) + VPSs as needed.

## Risks & guardrails

- **Hot-wallet risk:** agent allowances are small and capped; treasury keys stay
  with the owner; cold backup off-machine.
- **Reputation risk:** one bad deliverable costs more than a hundred good ones.
  Human review gate on all client deliverables. Over-deliver or refund.
- **Model-data risk:** client code never goes to training-collecting free models.
- **Market risk:** agent economy is nascent; don't bet the treasury on it.

## Retrospectives

Each venture's results, lessons, and iterated processes are logged in `NOTES.md`
and this plan is updated accordingly. The loop: seed → run → measure → learn → repeat.
