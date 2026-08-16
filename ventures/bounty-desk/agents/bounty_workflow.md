# Bounty Desk Workflow (Satonomous Ventures)

SOP for turning open-source bounty tasks into sats in the treasury. Follow this
exact sequence. This desk complements the Code Review desk — the static-analysis
pipeline (`run_review.py`) is reused whenever a task touches security.

## 0. Scout (run first, usually on schedule)
```bash
python3 /home/berto/Code/ventures/bounty-desk/services/scout.py \
  --outdir /home/berto/Code/ventures/bounty-desk/deliverables
```
- Read `deliverables/latest.md` (and the matching `scout_<date>.json` for full
  issue bodies).
- Filter by: open, eligible, reward >= floor, language fit (Python/JS/TS first),
  and rewarder trust (`LOW-TRUST` flag = review carefully before engaging).
- **Repo health gates (scout already applies these — respect them):**
  - `repo_archived` / archived repos skipped → archived = read-only = can never
    merge. Dead on arrival.
  - `contested` flag → open PRs already reference the issue; platform pays only
    the first merged PR. Treat as skip unless the owner sees a real edge.
  - `gh_state` not "open" on GitHub → skip (platform feed can be stale).
- **Prefer fresh/uncontested bounties.** Visible, well-funded bounties are
  usually already raced (measured: Primal#133 had 10 PRs, lnbits#2581 had 3
  attempts). Speed on new bounties (`ALERTS.md`) is the real edge.
- **Negotiated lanes (Alby program, `negotiated` flag)** = no escrow, no fixed
  reward. Payout is agreed up front with Alby; for complex items they want a
  concept first. Treat as contact-first opportunities — engage only with the
  owner's go-ahead and scope agreed before writing code.

## 1. Candidate selection (owner review gate)
- Present the top 3–5 candidates with: reward, unlocked/locked status, repo
  health, task type, and the risk flags (archived/contested/low-trust).
- **Do not start work until the owner picks a target.** Selection is a human
  decision (constitution: human gate before paid work ships).

## 2. Intake
- Create work dir: `deliverables/<repo>-<issue>/` in the bounty desk.
- Log the task in the ledger: `treasury/ledger/ledger.jsonl` (entry:
  `bounty_attempt`, 0 sats, task metadata).
- **Verify the repo is live before cloning:** not archived, not empty/abandoned
  (check last push), and the issue is uncontested on GitHub (open PRs). The
  scout's filters run at scan time — re-check the day you start.
- Confirm the repo's contribution rules: `CONTRIBUTING.md`, lint/test commands,
  license, and whether the bounty platform requires a specific PR description
  (e.g. Lightning Bounties: PR must reference the issue, `close #NNN`).

## 3. Implement
- Clone under the owner's GitHub identity (SSH/PAT the owner provisioned).
  Never commit as anyone else or with the owner's credentials held by us.
- Create a branch, implement the fix, add tests. Follow repo conventions and
  run their linter/tests (e.g. Stacker News: `./sndev lint`, JS Standard Style).
- If the change is security-relevant, run the review pipeline on the diff:
  `python3 /home/berto/Code/ventures/code-review-desk/services/run_review.py <workdir>`
- **Keep PRs in draft until ready for review** (Stacker rule 3: no award
  reduction for questions before requesting review).

## 4. Submit PR (owner review gate #2)
- Push the branch, open the PR, `close #NNN` in the body, mark draft until
  self-review is done.
- Present the PR + summary to the owner for approval **before** marking it ready
  for review. Only the owner submits/marks-ready if they prefer to control the
  account.
- **Gotcha:** pushing changes under `.github/workflows/` requires the `workflow`
  scope on the GitHub PAT (beyond `public_repo`). Check the scope before
  planning a CI-infra PR, or the push will be rejected at the remote.

## 5. Claim & collect
- Once the PR is merged, claim the reward on the platform:
  - **Lightning Bounties**: sign in at app.lightningbounties.com with the
    owner's GitHub → Claim Reward → funds land in the LB account balance.
  - **Stacker News repo**: award is issued by SN engineers after merge; they
    pay on their schedule.
- Withdraw the balance to the treasury: `npx -y @getalby/cli receive` with the
  platform's withdrawal address, or direct to a bolt11 we generate.
- Log the ledger entry (`bounty_earned`, sats in).

## 6. Retro
- Append to `deliverables/<workdir>/retro.md`: what we learned, actual time/cost
  vs reward, whether the bounty was worth it (reward-to-effort ratio).
- Keep this in the daily NOTES.md log.

## Ethics gate (never skip)
- Only public OSS tasks the owner approves. No gray-hat, no active exploitation,
  no touching funds/assets we don't own.
- Security findings are reported through the project's responsible-disclosure
  channel (e.g. stacker.news security@), never dumped publicly first.
- We never create or use accounts the owner didn't provision. The agent holds
  only scoped, expiring tokens; the owner holds the GitHub identity.
- All earnings settle into the Satonomous treasury ledger; no private wallets.
