# Bounty Desk

Phase 2 venture. Scouts sats-paying open-source bounty tasks and runs them
through the desk so merged PRs earn sats for the treasury.

## Status (2026-08-16)
- Scout v4 running on a 3h cron with **first-mover detection**, **archived-repo
  skip**, and **contest detection** (open-PR search).
- Warm-up #1 (BrantaOps/core#98 "Snitch CI") implemented, validated, and pushed
  to a fork — **abandoned with 0 sats** when the repo turned out to be
  **archived** (read-only; PRs can never merge). See
  `deliverables/branta-core-98/retro.md`.
- Market reality (measured): every currently-visible LB bounty is **contested**
  (1–10 open PRs each) — the desk's edge is speed on fresh bounties, not
  grinding visible ones. Uncrowded lane: Stacker responsible disclosure.
- No sats earned yet; pipeline is built and proven end-to-end except a
  successful merge → claim → withdraw.

## Sources
- **Lightning Bounties** — public feed of GitHub-issue bounties escrowed in
  sats; payout on merged PR.
- **Stacker News repo** — `stackernews/stacker.news` pays sats for PRs closing
  issues tagged `difficulty:*` (20k–1M sats, `priority:*` multipliers), for
  code reviews, issue specs, and responsible disclosures.
- **Alby bounty program** — getAlby org issues labeled `good first issue`
  (bounty-eligible on request). **Negotiated, not escrowed**: payout agreed
  with Alby (contact-first, concept-first for complex ones) via
  `guides.getalby.com/developer-guide/bounties`. Less contested than LB because
  it's off the visible marketplaces.

## Pipeline
1. `services/scout.py` polls the sources (cron every 3h), normalizes, scores
   fit, and applies risk filters (**skips archived repos**, **flags contested**
   issues, LOW-TRUST rewarders, locked funds; Alby entries are marked
   `negotiated`) plus **first-mover detection** → `deliverables/latest.md` +
   `scout_<date>.json`, and `ALERTS.md` when new eligible bounties appear.
2. Agent presents top candidates; **owner picks** (gate 1).
3. Agent implements in a workdir under `deliverables/`, using the Code Review
   desk's `run_review.py` for security-relevant changes.
4. Agent opens a draft PR; **owner approves before ready-for-review** (gate 2).
5. On merge → claim reward → withdraw to treasury → ledger.

## Rules
- Only public OSS, non-exploitative tasks (see `docs/bounty_policy.md`).
- No gray-hat, no accounts the owner didn't provision, no private wallets.
- Every sat earned logged in `treasury/ledger/ledger.jsonl`.

## Layout
- `services/scout.py` — poll + normalize + score + risk filters (LB feed needs
  no auth; GitHub API calls authenticate with GITHUB_TOKEN from `~/.openclaw/secrets.json`)
- `agents/bounty_workflow.md` — desk SOP for the OpenClaw operator
- `docs/bounty_policy.md` — eligibility and risk rules
- `deliverables/` — scout reports and per-task workdirs (gitignored)

## Requirements
- Python 3.10+ (stdlib only). GitHub API reads are cached to
  `~/.cache/satonomous/gh_cache.json` to respect rate limits. The GitHub PAT
  needs `public_repo` (+ `workflow` to push `.github/workflows/` changes).

## Field notes (lessons learned)
- **The LB feed lies by omission**: it shows issues as open even when the repo
  is archived or the issue is closed on GitHub. Always cross-check live GitHub
  state before engaging (scout does).
- **Big bounties get swarmed within days** (Primal web-app#133: 10+ PRs;
  lnbits#2581: 3 attempts in 2 years). Visible bounty = usually already raced.
- **Warm-ups cost more than they seem**: a 2k-sat warm-up burned a full session
  (see retro). Only do them when the payout path is verified.
- **The workflow-scope gotcha**: pushing `.github/workflows/*` requires the
  `workflow` scope on the PAT beyond `public_repo`.
- Full risk rules: `docs/bounty_policy.md`. SOP: `agents/bounty_workflow.md`.
