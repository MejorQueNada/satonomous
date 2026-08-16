# Backlog — Future Ventures

> Each of these becomes its own git-initialized project with a written intent,
> seed, metrics, and retrospective. Nothing here launches without a conscious
> decision and an entry in `NOTES.md`.

## 1. L402 Micro-API Farm (experimental / recurring revenue)
- Host 2–3 pay-per-request agent APIs (summarize, extract, code-review scan)
  at ~10–25 sats/request via `aperture` (L402 reverse proxy).
- List on AgentX.Market; exposed as MCP tools for agent discovery.
- Status: agent economy is early — treat as optional experiment, not a revenue
  bet. Fund-as-we-go, capped spend.
- Source of truth: Lightning Labs Agent Tools (`lnget`, `aperture`, bakery).

## 2. Reputation / Content Arm (flywheel)
- Agent publishes research + education to Stacker News and Nostr; earns zaps;
  builds the audience that feeds the Code Review Desk.
- Low capital; costs only LLM tokens (paid models).
- Launch trigger: once the review desk has repeat customers and content topics
  are clear from real client questions.

## 3. Lightning Infra / Hosting (service venture)
- LNbits / wallet-as-a-service for other plebs: hosted wallets, paywalls,
  payment pages, node setup help.
- Heavier ops and support burden; needs reputation first.
- Candidate model: per-user LNbits wallets on our node with a sats subscription.

## 4. Ethical Affiliate / SEO Content
- Only legitimate affiliate/educational content, disclosed automation, no
  gray-hat. Lower alignment with "autonomous + ethical"; lowest priority.

## 5. Education / Learn-to-Earn
- Bitcoin/Lightning education content or courses priced in sats. Delivered via
  the content arm's audience. Consider a sats-reward learning site later.

## 6. Bounty Desk Extensions / Alby AI Ecosystem (brainstormed 2026-08-16)
All options noted for later consideration; none launched without a conscious
decision and a `NOTES.md` entry. Context: crawled getalby.com/ai; we already
run Alby Hub + NWC, the payments skill, the review pipeline, and the scout.

- **A. Alby as a scout source** ✅ DONE (option 1): getAlby org `good first
  issue` issues (negotiated, contact-first) added to `scout.py`; README/policy/
  workflow updated. First real payout is most likely from this lane.
- **B. PaidMCP review API (recurring revenue)** — ✅ **LAUNCHED 2026-08-16 as
  "ReviewDesk MCP" (V1)** — `ventures/code-review-desk/services/mcp/`. Wraps
  `run_review.py` as `@getalby/paidmcp` server: `registerPaidTool("review_scan",
  1500 sats/scan)`. Input = public repo URL; server clones (shallow, size-capped),
  runs semgrep/bandit/ruff/gitleaks, redacts secret matches, returns ranked
  findings + optional LLM summary (findings-only, paid zero-retention Zen model).
  Receives via dedicated NWC app "ReviewDesk" (make_invoice+lookup_invoice only,
  isolated budget). Metrics: first paid call ≤30d, ≥3 in month 2, ≥10 in month 3.
  Decision + build log: `NOTES.md` (2026-08-16 V1 entry).
  **Status: LIVE 2026-08-16** — deployed https://reviewdesk-mcp.fly.dev/ (fly.dev,
  iad), full paid flow + `llm_summary` verified against prod (treasury as test
  client, ledger txn 23). Redeploy: `scripts/fly-deploy.sh` (flyctl SSO session
  on the box). Repo: `MejorQueNada/code-review-desk`.
- **C. Bounty-alert product** — package first-mover detection as a paid MCP
  tool (`check_fresh_bounties`) or a Nostr/Discord alert subscription. Tiny
  build on scout.py + PaidMCP. Small market; could be free reputation first.
- **D. NWC payments MCP wiring** — add `@getalby/mcp` to OpenClaw so the agent
  can pay MCP tool fees itself; unblocks B/C. Small one-off.
- **E. Snitch as a product** — package the Electron CI network monitor as a
  GitHub Action/npx tool, list on BOLT.fun. Reputation play, low priority.
- **F. Builder-skill demo app** — a small paid bitcoin app (e.g. pay-for-review
  demo) that doubles as a storefront for B. Portfolio value.

**Recommended order:** A (done) → B MVP after one real payout proves the lane,
C rides on B's rails, D any time, E/F optional.

---
**Selection rule (from the constitution):** a venture launches only if it is
legal, ethical, efficient, and plausibly profitable — and the owner signs off.
