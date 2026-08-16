# Bounty Desk Policy

Eligibility and risk rules for the tasks the desk will take on. The scout flags
risks; the owner makes the final call.

## What we take
- **Public, open-source, non-exploitative work**: bug fixes, features, tests,
  docs, code reviews, responsible security disclosure. Nothing that exploits,
  circumvents, or monetizes harm.
- **Paid in sats** (Lightning Bounties, Stacker News repo, or similar). If a
  platform pays in USD/crypto that needs new rails, it needs owner approval.
- **Language fit first**: Python, JavaScript, TypeScript. Rust/Go/Kotlin/Swift
  are allowed but the bar is higher (less tooling, more unfamiliarity risk).
- Reward should justify effort: prefer >= 20,000 sats except for trivially
  scoped `good-first-issue`-class tasks. Small tasks are fine for warm-up and
  reputation only if they are genuinely quick.

## Strategy (market reality, measured 2026-08-16)
- **Visible bounties are usually already raced.** Every currently-live LB
  candidate had 1–10 open PRs referencing it. Big rewards attract PRs within
  days; small ones go stale on archived/dead repos.
- **The edge is speed and lanes**: hit fresh bounties first (cron + `ALERTS.md`
  first-mover detection) and work uncrowded lanes (Stacker responsible
  disclosure, code reviews — no open-PR race).
- Don't grind a visible bounty hoping to out-race it unless the existing PRs
  are demonstrably broken and the maintainer is responsive.

## Risk filters (from the scout)
- **Locked rewards**: `unlocked_sats == 0` means the sats are still in escrow /
  pre-unlock. They are only claimable after the lock expires and only if the
  maintainer merges. Prefer unlocked funds; treat locked funds at ~0.6x value.
- **LOW-TRUST rewarder**: a rewarder account that is new, followerless, and
  minimal activity. Common in spam bounty posts. Reject unless the project
  owner is also on the platform / the issue is clearly legitimate.
- **Winner already exists**: skip anything with a winner; reward is gone.
- **Archived repo**: if the repo is archived (read-only), PRs can never merge —
  the bounty is dead regardless of what the platform feed says. Skip. The scout
  now flags/skips these (learned the hard way: BrantaOps/core#98 was archived).
- **Contested**: an issue with open PRs already referencing it is a race — the
  platform pays only the first merged PR. Treat as skip unless we have a clear
  edge (e.g. their PR is broken and we can do better fast). The scout reports a
  `contest` column (open PR count). Note: mention-based, may under-count.
- **Suspicious bodies**: payment requests, "email me for payout", cross-promo
  spam, impossible promises — flag for owner review, never engage automatically.

## Financial guardrails
- Work only within the current model budget; if estimated cost to complete a
  task approaches its reward, stop and tell the owner.
- All payouts go to the Satonomous treasury (Alby Hub), never a personal wallet.
- Ledger entry for every task started and every sat earned
  (`treasury/ledger/ledger.jsonl`).

## Identity
- GitHub account: owned and controlled by the human owner. The agent uses only
  tokens/PATs the owner provisioned, scoped to the repos we work in, and never
  stores them outside `~/.openclaw/secrets.json` / the ops secrets pattern.
- No signing up for platforms with the owner's identity without asking.

## Review gates
1. Owner picks the candidate.
2. Owner approves the PR before it is marked ready for review.
3. Any security-disclosure report is reviewed by the owner before sending.

## Lessons learned (case log)
- **BrantaOps/core#98 (2026-08-16)** — 2,063 sats, archived repo. Platform feed
  listed it open; repo was read-only. Wasted a full warm-up session before the
  403 on an issue comment revealed the archive. → Scout now skips archived
  repos (`gh_repo_archived`); workflow requires a repo-health check at intake.
  Full write-up: `deliverables/branta-core-98/retro.md`.
- **lnbits#2581 (2026-08-16)** — 20k sats, looked ideal (Python, sats-native).
  Deep-dive found 3 prior attempts (#3663 open 6 months, #4077 with CI blocked
  `action_required`, #4038 gone) and maintainers assigned. → Scout now flags
  contested issues (`contest` column).
