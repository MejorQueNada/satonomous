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
  client, ledger txn 23). Hardened 2026-08-16 (Sprint A+B): secret redaction now
  covers every output path incl. LLM input (verified paid E2E, ledger txns
  31–51); pre-clone size gate, per-IP rate limit, SSE session hardening, /tmp
  leak fix, invoice TTL. Repos current (`MejorQueNada/code-review-desk`, commits
  a2d8a9f redaction + 97d2641 hardening). Prod has NOT been redeployed since the
  fixes — the fly.dev instance still runs the original build. Redeploy:
  `scripts/fly-deploy.sh` (flyctl SSO session on the box).
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

## 7. OpenVault — Obsidian × opencode sidebar chat (reviewed + planned 2026-08-16)
- Fork of `Bertofortheppl/openvault` (v0.1.0, MIT). Goal: claudian-style
  sidebar agent for Obsidian, but backend-agnostic — opencode as the aggregator
  so ANY provider works (OpenRouter, Anthropic, local) and the **free models**
  (Zen `*-free`, OpenRouter `:free`) are first-class.
- Location: `ventures/openvault/` (fork `MejorQueNada/openvault`, branch
  `improvements` off `main`), gitlink-tracked from parent.
- **Review findings (verified against opencode 1.18.18):** SSE parser targets the
  old `message.part.delta`/`properties.field` schema; current opencode emits
  `message.part.updated` + `properties.part.type` + `properties.delta` — so
  streaming is broken (responses render "(empty response)"). Plus: no
  idle-vs-drop distinction, skills never retried on failure, OpenRouter-only
  auth gated auto-start, no model picker/free-model default, plan mode is an
  injected system prompt (native `agent: 'plan'` exists), no permission
  approval UX, no session persistence/markdown/abort, no tsconfig (zero
  typechecking), no LICENSE/versions.json.
- **Sprint 1 (✅ DONE 2026-08-16 — correctness on current opencode):** SSE
  parser rewritten for `message.part.updated`/`part.type`/`part.text` with
  `step-start` gating (was listening for dead `message.part.delta` events →
  all replies rendered "(empty response)"), native plan/build via `agent`
  field, drop-vs-idle distinction, skills retry on reconnect, `tsconfig` +
  `npm run typecheck` (16 latent type errors fixed), E2E smoke test
  (`scripts/e2e-test.mjs`, PASS vs live 1.18.18). Committed `54578f8` +
  pushed (`improvements`).
- **Sprint 2 (✅ DONE 2026-08-16 — any-provider + free models):** settings are
  provider-agnostic (opencode's own auth by default, optional `KEY=VALUE` env
  injection, legacy OpenRouter key auto-migrates), auto-start no longer gated
  on an API key, opencode binary auto-detect (PATH → common locations), model
  picker in chat footer from `GET /provider` (`{ all: [...] }`) with free =
  zero-cost + authenticated default and a "free" quick button, per-message
  `model` override on `prompt_async`, optional `OPENCODE_SERVER_PASSWORD`
  basic auth on spawn + all requests/SSE. E2E test extended (auth, provider,
  free-model override) — PASS both auth paths vs 1.18.18. **Note:** opencode
  1.18 removed `GET /skill` — skills slash-menu can't populate; file-based
  skill discovery deferred.
- **Sprint 3 (✅ DONE 2026-08-16 — vault UX):** real markdown rendering via
  Obsidian `MarkdownRenderer.render` (replaces the regex wiki-link hack; code
  blocks/embeds/clickable `[[links]]`), `@`-mention picker → `file://`
  FileParts sent on `prompt_async` (removable chips), **＋sel** button captures
  the active note's selection into a context part naming the source note,
  **Stop** button → `POST /session/{id}/abort` + SSE cancel (partial text kept,
  shows `(stopped)`), session switcher (`GET /session` dropdown + New/Del),
  persistence via `lastSessionId` in `data.json` with history resumed through
  `GET /session/{id}/message?limit=50`, and a "new chat" command for
  multi-tab. E2E extended with session list/history/abort checks — PASS both
  auth paths vs 1.18.18. Skills endpoint still dead in 1.18 (deferred to S5).
- **Backlog sprints (all planned, none started):** S4 agent UX + release
  (permission approval UI, session fork, slash-command passthrough,
  LICENSE/versions.json/release workflow); S5 parity polish (inline edit w/
  word-level diff, tool-progress, reasoning toggle, file-based skills).
- Launch/milestone rule: nothing ships (releases/plugin-store submission)
  without a conscious owner decision + `NOTES.md` entry. This is a free/open
  tool, not a revenue bet — value is dogfooding opencode as a free-model hub.

---
**Selection rule (from the constitution):** a venture launches only if it is
legal, ethical, efficient, and plausibly profitable — and the owner signs off.
