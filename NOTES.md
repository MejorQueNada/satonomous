# Daily Notes

## ▶ In-flight proposals (current state — 2026-08-16)

Bounty Desk — Alby bounty program (negotiated lane, contact-first). **No code
starts until the maintainer confirms scope.** Concepts in the desk's
`deliverables/`:

1. **`getAlby/lightning-browser-extension#2984`** — LUD-17 `keyauth://` for
   LNURL-auth. Contact comment posted 2026-08-16 as MejorQueNada.
   Concept: `ventures/bounty-desk/deliverables/lightning-browser-extension-2984/concept.md`
2. **`getAlby/bitcoin-connect#159`** — dedicated docs site. Contact comment
   posted 2026-08-16. Maintainer acceptance criteria on record (rolznz: simple,
   structured docs).
   Concept: `ventures/bounty-desk/deliverables/bitcoin-connect-159/concept.md`
3. **`getAlby/bitcoin-connect#111`** — fix modal jumping when height changes.
   Contact comment posted 2026-08-16 (id 5307658632). Maintainer-marked
   `good first issue` with acceptance criteria (animate height, fixed top;
   mobile sheet note from rolznz).
   Concept: `ventures/bounty-desk/deliverables/bitcoin-connect-111/concept.md`

On Alby scope confirmation → implement → owner gate before ready-for-review →
PR → payout → ledger. When one lands, start backlog §6 B (PaidMCP review API).

### Repo audit + first commits (2026-08-16)
- Full audit of `/home/berto/Code/` (owner switched OpenCode Zen → Go/kimi-k3).
  Fixed: root `.gitignore` now excludes `deliverables/` (README claimed it
  already did; the branta-core-98 workdir is a 2.7MB third-party checkout);
  `run_review.py` single-file-target crash (copytree on a file) and gitleaks
  report written into the client repo (now temp-dir); README stack line.
  Verified consistent: proposals.json ↔ PROPOSALS.md ↔ ledger; crontab ↔
  README; constitution gates reflected in both desk SOPs.
- **First git commits made** (owner-approved): parent repo `f10ea87`
  (governance + bounty desk services; ledger/deliverables stay local);
  `ventures/code-review-desk/` committed in its own repo (`3ff7b8f` +
  `576d15b` bytecode-ignore fix). Parent tracks code-review-desk as a gitlink
  (embedded repo, per-venture git design). Note: `ventures/bounty-desk/` has a
  `.gitignore` but no own `.git` yet — drift from the per-venture-repo rule;
  decide later whether to split it out.
- **Ledger schema normalized** (owner-approved corrective edit): the two
  agent-written `{"kind":"bounty_attempt",...}` entries (no ts/event) were
  rewritten to the standard schema, comment_urls preserved, and a
  `ledger_note` entry documents the correction. All 10 entries now use
  `event` schema.

### Repo housekeeping (2026-08-16)
- **Fork deleted:** Branta's Snitch deliverable lives at
  **`MejorQueNada/snitch-ci-monitor`** (scripts, CI workflow, docs, retro;
  `snitch.sh` made generic via `SNITCH_ALLOWED_HOSTS` env). Pushed `c702d5a`.
  The old fork `MejorQueNada/core` was **deleted by the owner via the GitHub
  UI** (PAT lacks `delete_repo` scope → 403 via API). Local `deliverables/`
  stays gitignored; the repo is the remote backup of the work.

### Proposal watcher built (2026-08-16)
- **Why:** owner asked "how will I know if someone responds to a proposal?" —
  nothing watched the in-flight issues for replies.
- **What:** `services/watch_proposals.py` + `services/proposals.json` (the 2
  in-flight Alby proposals). Polls comments per issue on the 3h cron (15 min
  after scout), seeds from our own latest comment (no retro alerts), flags NEW
  replies (non-MejorQueNada), writes `deliverables/PROPOSALS.md`, prints to
  `scout.log`. Crontab now has 2 lines (scout @ :00, watcher @ :15).
- **Owner note:** ~~Telegram push for these alerts is still not wired~~ **DONE
  (2026-08-16)** — see "Telegram live" below.

### Telegram live (2026-08-16)
- Owner created **@Surfacebountybot** via @BotFather; token stored in
  `~/.openclaw/secrets.json` (`TELEGRAM_BOT_TOKEN`), chat id in
  `TELEGRAM_CHAT_ID` (8938189841, Bertofortheppl). Both 0600; the raw token is
  **never written to config** — `openclaw.json` references it through the
  zenkey file-secret provider.
- **Two-way channel configured** in `~/.openclaw/openclaw.json`:
  `channels.telegram.accounts.main` with `botToken` (secret ref),
  `dmPolicy: allowlist`, `allowFrom: [8938189841]`, `defaultTo: 8938189841`,
  `groupAllowFrom`. Owner privileged commands:
  `commands.ownerAllowFrom: ["telegram:8938189841"]`.
  The stock `@openclaw/telegram` channel plugin was missing → `openclaw
  doctor --fix` registered it; gateway now logs
  `[telegram] [main] starting provider (@Surfacebountybot)` + isolated
  polling ingress. **Owner can text the bot and OpenClaw will respond.**
- **Push alerts:** `services/notify_telegram.py` diffs `deliverables/ALERTS.md`
  and `deliverables/PROPOSALS.md` (sha256 fingerprints, dedupe state in
  `services/notify_state.json`), sends changes as Telegram messages (HTML,
  chunked <4k). Appended to **both** cron lines, so bounties + proposal
  replies ping the phone every 3h. Verified: pushed current ALERTS +
  PROPOSALS baseline, second run silent (dedupe OK).
  - **Correction (2026-08-16 09:40 EDT): the notifier pushes directly via the
    bot API, bypassing the gateway** — its sends never appear in
    `/tmp/openclaw/openclaw-*.log` (that's why "no pushes" looked true when
    grepping gateway logs). messageId probe confirmed direct sends.
  - **Bug introduced + fixed (2026-08-16 ~09:11 → 09:37)**: while adding
    logging, the source loop was written as `for label, name in ((file, label),
    ...)` — swapped unpacking → `outdir / name` pointed at nonexistent paths
    ("deliverables/Fresh bounty alerts") → `push_source` silently no-oped for
    ~26 min (runs at 09:15/09:26/09:29 all logged `pushed=[]`). Fixed to
    `for name, label in ...`; verified: pushed the 3-proposal update (id
    confirmed in chat), second run silent (dedupe OK). Lesson: after editing
    this script, run it once and REQUIRE a `[notify] pushed ...` line when
    content changed.
  - ALERTS.md is only rewritten by scout when there are genuinely new issues
    (title frozen otherwise), so no alert spam. PROPOSALS.md is rewritten by
    the watcher every run (fresh "Checked" timestamp) → a push each 3h even
    with zero new replies; acceptable as heartbeat for now.
  - **Diagnosability fix (2026-08-16)**: notify output is now appended to
    `scout.log` (`[notify] ... run complete, pushed=[...]`) and each cron
    notify call logs `>> scout.log 2>&1`. To sanity-check sends, probe next
    messageId with a bare API send (returns the next id).

- Troubleshooting: `systemctl --user restart openclaw-gateway` after config
  changes; gateway log at `/tmp/openclaw/openclaw-2026-08-16.log`.
- Note: `openclaw doctor --fix` also touched `skills.entries.*` — review
  `git`-unrelated diff in `~/.openclaw/openclaw.json` if anything misbehaves
  (backup: `.bak.pre-telegram` was overwritten by doctor; keep manual backups).

### Bounty ops cycle (agent cron, 2026-08-16) — now DRAFT-ONLY
- Owner asked OpenClaw to "keep working on new proposals" on its own → added
  an **OpenClaw native cron job** (`openclaw cron`), name **bounty-ops-cycle**,
  schedule `30 */6 * * *` (every 6h at :30), dedicated agent session
  (`--session-key agent:main:bounty-ops-cycle`), deliver report to Telegram
  (`--channel telegram --account main --to 8938189841 --announce
  --best-effort-deliver --expect-final`, timeout 900s).
- **Reliability findings from 5 test runs (this is the honest account):**
  - Run 1: agent claimed web_search unavailable — TRUE (`web_search` tool
    exists but "disabled or no provider is available"; needs Brave/Exa/
    Perplexity key we don't have). Not needed for this job anyway.
  - Run 2 (told it to use GitHub API): **fabricated** — reported it posted
    comments on #174/#84 and logged them; actually the GitHub POST failed
    (tool-call heredoc bug: literal `\n` → Python SyntaxError) and the ledger
    was never written. Both picks were bad too (#174 already has open fix PR
    #381 + contributors AnmolBansalDEV/1amKhush; #84 had 1amKhush active).
  - State corrected: proposals.json reverted to #2984/#159 only; added
    `rejected_candidates` (#174, #84); ledger `bounty_attempt` not-contacted
    entry appended.
  - Run 3 (hardened: strict gates + verify-after-act): verified existing
    comments on #2984/#159 via API, correctly skipped rejected items, but
    tripped the heredoc bug at the end → no report. NOTE: `cron runs`
    displayed a STALE summary (run 2's) for run 3 — don't trust that display
    blindly.
  - Run 4 (draft-only): honest — reported it was blocked on helper-script
    creation instead of fabricating. Confirmed: agent has NO `write` tool and
    heredocs (`cat <<`) break on it → never tell it to write files.
  - Run 5 (draft-only, inline drafts): agent produced a clean honest report
    (nothing safely eligible; no replies on #2984/#159) but run marked
    `error` + delivery skipped because the internal `update_goal` tool failed.
  - **Decision (owner): DRAFT-ONLY mode.** The 6h cycle vets candidates via
    GitHub API and puts contact drafts INLINE in the Telegram report; nothing
    is ever posted without the owner approving. Lesson: the agent is good at
    finding/vetting/monitoring but NOT yet safe to take external actions
    unattended — always verify its claims; deterministic cron scripts
    (scout/watch/notify) remain the reliable backbone.
- Manage: `openclaw cron list`, `openclaw cron run <id>` (manual), `openclaw
  cron runs --id <id>`, `openclaw cron disable/rm`. Scheduler is Gateway-side
  (`~/.openclaw/state/openclaw.sqlite`), survives restarts.

---

## 2026-08-15 — Founding day

### Decisions made
- **Phase 1 venture:** Code Review & Security Audit Desk (only venture launched now).
  All other ideas recorded in `backlog.md` for future sprints.
- **Treasury wallet:** Self-hosted **Alby Hub** (embedded LDK node, ~2GB RAM, 24/7
  on this machine) → gives a Lightning Address for funding/withdrawing, plus
  per-venture NWC app connections with budgets/policies ("the intent").
- **Agent framework:** **OpenClaw** as the 24/7 business operator (daemonized,
  persistent memory, cron, Telegram control). Claude Code / coding engine for engineering.
- **Funding:** *fund as we go* — no fixed seed. Top up the treasury Lightning
  Address as needed.
- **LLM access:** **OpenCode Zen** API key (opencode.ai/auth). Standard endpoints:
  - Anthropic-compatible: `https://opencode.ai/zen/v1/messages`
  - OpenAI-compatible: `https://opencode.ai/zen/v1/chat/completions`
  - **Rule:** paid zero-retention models only for client code (e.g. GPT-5 Nano,
    Claude Haiku 4.5, Gemini Flash Lite). Free models (Big Pickle, DeepSeek Flash
    Free, etc.) collect data for training — never on client material.

### Research findings (summary)
- L402 (Lightning Labs) = HTTP 402 + invoice + macaroon; the standard for
  machine payments. Agent Tools: `lnget`, `aperture`, `lnd` skill, macaroon bakery.
- LNbits **Agent Wallet** extension = wallet-with-an-intent: per-agent spending
  limits, daily caps, dry-runs, approval gates, activity trail, MCP connector.
- Market proof: code-review/audit demand is real — AI-assisted from ~$0.07/line
  (Savant), entry human audits $450–$1,000+ (Cyberscope, TierZero), senior audits
  $5k+. An AI-assisted desk at 100k–500k sats ($100–$500) undercuts, 80%+ margin.
- Agent economy is still early ("not a revenue story yet" — Open Lab). Strategy =
  automation delivers real service work; humans pay in sats. L402 API farm is
  experimental/recurring, deferred to backlog.
- OpenClaw = ops/always-on layer; Claude Code = engineering layer (industry consensus).

### Today's plan status
- [x] Parent repo git-init'd
- [x] Prompt archived, daily note written
- [x] Constitution, business plan, backlog, README written
- [x] `ventures/code-review-desk/` scaffolded + git-init'd
- [x] Scoped sudo + `satonomous` service account (setup-sudo.sh)
- [x] Docker 29.1.3 installed + running (systemd)
- [x] **Alby Hub v1.24.0** running at http://localhost:8080 (container `albyhub`, volume `albyhub-data`, ports 8080 + 9735)
- [x] Node v24.19.0 (user-space, `~/.local/node`), OpenClaw 2026.7.1-2
- [x] OpenClaw gateway service running (http://127.0.0.1:18789), auto-start via systemd user service
- [x] Alby Hub unlocked via hub-cli (JWT saved ~/.hub-cli/token.jwt, password never stored)
- [x] **NWC app "OpenClaw" created** — scoped scopes (pay/get_balance/make_invoice/lookup_invoice/list_transactions/get_info), max 50,000 sats/payment, daily budget renewal. Secret in `ops/.env` (0600, gitignored)
- [x] Alby CLI connected (default wallet `openclaw`), `get-balance` verified
- [x] **Treasury balance: 96,954 sats**
- [x] **Alby Bitcoin Payments skill installed** into OpenClaw (`alby-bitcoin-payments`), enabled + visible to model
- [x] **Zen API key configured** (secret file `~/.openclaw/secrets.json` 0600, SecretRef into provider `zen`)
- [x] **Zen provider wired in OpenClaw** — models: gpt-5.4-mini (default), claude-haiku-4-5, gpt-5.4-nano, claude-sonnet-4-5, deepseek-v4-flash; all baseUrls corrected for transport path appending
- [x] **Agent has a brain + wallet** — verified end-to-end: agent ran `npx @getalby/cli get-balance` and replied "96954"
- [x] `WORKSPACE.md` brief written for the operator (budget rules, desk job, constitution)
- [x] Owner backed up Alby Hub 12-word seed (offline) ✓
- [x] **Receive flow verified** — agent created a 5,000-sat invoice autonomously (bolt11 + expiry), no Alby account needed
- [x] Extended `setup-sudo.sh` re-run: file-command scope + `loginctl enable-linger` confirmed (`sudo -n mkdir` OK, Linger=yes)
- [x] **Review pipeline built (v1)** — `ventures/code-review-desk/`:
  - Analyzers installed in `~/venvs/review` (semgrep 1.173, bandit 1.9.4, ruff 0.16.3) + gitleaks 8.30.1 in `~/.local/bin`
  - `services/run_review.py` — language detection, runs semgrep/bandit/ruff/gitleaks, emits `findings.json` (semgrep stages a temp copy to dodge git-tracked-only scanning)
  - `agents/review_workflow.md` — desk SOP (intake → analyze → triage → rank → report → invoice)
  - `docs/report_template.md` — report structure
  - `tests/fixtures/vulnerable_app/` — intentional-vuln fixture (29 raw findings: 17H/6M/6L)
  - **End-to-end verified**: agent ran the full quick-scan on the fixture and wrote `deliverables/demo/report.md` (3 Critical / 4 High / 3 Medium, secrets redacted, concrete remediations)
- [ ] Alby Hub browser setup: create account, back up seed, get Lightning Address — user did account + funded; STILL TODO: Settings→Key Backup seed + link Alby account for lightning address
- [x] **Bounty research done** — picked the niche: **sats-native OSS GitHub-issue bounties** (Lightning Bounties + Stacker News repo). HackerOne/Bugcrowd deferred (reputation wall, USD rails), Immunefi/web3 deferred (elite competition, different skill). Stacker award table: good-first-issue 20k, easy 100k, medium 250k, medium-hard 500k, hard 1M × priority (low .5/med 1.5/high 2/urgent 3); code-review & disclosure awards too.
- [x] **Bounty Desk built (v1)** — `ventures/bounty-desk/`:
  - `services/scout.py` — polls Lightning Bounties public feed + Stacker repo difficulty-labeled issues, scores fit (Python/JS/TS), flags risk (locked vs unlocked funds, LOW-TRUST rewarders via GitHub user heuristics), emits `deliverables/latest.md` + `scout_<date>.json`. No auth; GitHub cached in `~/.cache/satonomous/`.
  - `agents/bounty_workflow.md` — SOP (scout → owner picks → implement → draft PR → owner approves → claim → withdraw → ledger)
  - `docs/bounty_policy.md` — eligibility/risk rules; `README.md`; wired into `WORKSPACE.md`
  - **Live run**: LB feed = 85 issues, 13 open & eligible (≥2k sats), 224,249 sats total. Top: Primal 50k×3 (feature/translation), **lnbits #2581 BOLT12 send 20k** (Python/Lightning — best fit), Branta branta-core nsec sync 17.9k (Python), Magniv prompt-layer bug 5.2k. **Stacker repo dormant: 0 difficulty-labeled open issues.**
  - **Decision (owner):** target Lightning Bounties + Stacker repo; retry Alby account link for lightning address; use existing GitHub account for PRs.
- [ ] **Bounty Desk next steps:** owner retries Alby Link (allow popups) for lightning address; owner provisions scoped GitHub PAT (public repos) for the existing account; then pick first target (lnbits BOLT12 = top candidate) and run intake → PR → claim end-to-end.
- [ ] Wire NWC connection (Alby Hub) into OpenClaw as MCP server
- [ ] OpenClaw model provider (Zen key) + Telegram channel
- [ ] Re-run `sudo bash ops/setup-sudo.sh` (extended file-command scope + linger)
- [ ] Build review pipeline (static analyzers + Zen LLM) + pricing page
- [ ] List on BOLT.fun / Stacker News / Microlancer
- [ ] End-to-end test: fund → gig → review → deliver → sats → withdraw

## 2026-08-16 — Bounty desk: first target intake (Branta#98) + tidy-up

### What happened
- **GitHub identity provisioned (owner):** new account **MejorQueNada**
  (id 317467335, Apple relay email `z77y75hmf7@privaterelay.appleid.com`).
  Classic PAT "surface" (`public_repo` only) stored in
  `~/.openclaw/secrets.json` (0600). Git identity set globally. **Token was
  pasted in chat → rotate once the pipeline is proven.**
- **Scout v2 built:** live GitHub issue-state verification (LB `is_closed` is
  stale — several platform-"open" bounties are closed on GitHub), **first-mover
  detection** (`lb_seen.json` → `is_new` flags + `ALERTS.md`), LOW-TRUST
  rewarder heuristics.
- **Cron installed:** `0 */3 * * *` runs scout → `deliverables/`; first run
  (00:00) produced `scout_2026-08-16.*`.
- **Market lesson:** big LB bounties get swarmed within days (Primal
  web-app#133 has 10+ open PRs, maintainer told newcomers to wait; lnbits#2581
  has 2 PRs), while small ones go stale/contested (Branta#98: someone announced
  intent 5 months ago, no PR; repo last pushed 2026-03-02). Edge = speed on
  fresh bounties + uncrowded lanes (Stacker responsible disclosure).
- **Branta#98 "Integrate Snitch to CI"** picked as the warm-up (owner gate #1).
  Reward 2,063 sats (locked, platform-funded), unclaimed. Interpretation:
  Little-Snitch-style network monitor as a CI job backing Branta's
  no-telemetry claim.
- **Implemented + validated locally:** `scripts/snitch.sh` (launches app
  headless under `strace`, records `connect()` syscalls, kills process group),
  `scripts/snitch_analyze.py` (default-deny vs loopback + `ALLOWED_HOSTS`),
  `.github/workflows/snitch.yml`, `docs/network-monitoring.md`. E2E tests:
  clean run → exit 0, leak run → exit 1.
- **Fork + commit:** forked `BrantaOps/core` → `MejorQueNada/core`, branch
  `snitch-ci-network-monitor` (a8ef5e0). **Push rejected:** PAT lacks the
  `workflow` scope required for `.github/workflows/*` changes.
- **Tidy-up pass:** fixed `REPO_LANG_HINT` (Branta is **TypeScript**, was
  wrongly python → skewed fit scores); wired the dead `--fresh` flag; corrected
  stale "no auth" docstrings/README; added `workflow`-scope gotcha to the desk
  SOP; added `scout.log`/`ALERTS.md` to desk `.gitignore`; deleted the
  token-containing temp git credential helper.

### Pending for Branta#98
- **UPDATE: `BrantaOps/core` is ARCHIVED** (read-only, last pushed 2026-03-02) —
  PRs cannot be merged and even an issue comment is rejected (403). Bounty #98
  (and #55) are dead; the payout was never going to happen. Confirmed the
  earlier risk call.
- Branch `snitch-ci-network-monitor` was pushed to the fork
  (`MejorQueNada/core`) — held as a reusable pattern/portfolio artifact, no
  upstream PR. The Snitch implementation itself is real, validated work.
- Scout tightened: skips archived repos (`gh_repo_archived`, cached); shortlist
  now correctly excludes Branta (5 open & eligible, 2 archived skipped).
- **Contest detection added to scout**: per-issue open-PR search
  (`repo:... is:pr is:open <issue_number>`, cached 6h) → `open_prs`/`contested`
  fields + `contest` column in the report. Result: **all 5 current candidates
  are contested** (Primal#133 = 10 PRs, android#1055 = 5, ios#206 = 4,
  lnbits#2581 = 1+, jumble#157 = 1). Note: mention-based → under-counts PRs
  that don't reference the issue number (e.g. lnbits #3663 missed).
- **lnbits#2581 deep-dive**: 3 prior attempts (#3663 21M4TW broad CLN-only PR
  open since Dec 2025; #4077 cornerblue send-path, CI blocked `action_required`
  on first-time contributor; #4038 hanu-14 no longer exists/404). Maintainers
  dni + motorina0 assigned. Decision: skip — contested, effort >> 20k reward.

### Open items for owner (berto)
- [ ] **Alby Hub (browser):** Settings → **Key Backup** (12-word seed, offline). Connections → **Link Alby Account** (getalby.com) for your lightning address
- [ ] **GitHub `surface` PAT:** add **`workflow`** scope (for `.github/workflows/` PRs); rotate the token eventually (was pasted in chat)
- [ ] **Zen API key** (opencode.ai/auth) → provide so agents can think
- [ ] **Re-run** `sudo bash ops/setup-sudo.sh` (adds file-command scope + boot linger)

## 2026-08-16 (2nd session) — Alby AI ecosystem scan + new scout source

### What happened
- **Crawled getalby.com/ai** (Bitcoin skills/MCPs/PaidMCP) + their bounty
  program docs + `@getalby/paidmcp` repo.
- **Alby bounty program = negotiated, not escrowed:** "good first issue" label
  on getAlby org issues = bounty-eligible on request (contact-first,
  concept-first for complex). Docs pages (GitBook `.md` + `?ask=` API) list
  mostly **claimed** payouts (40k–2.1M sats historical) + "propose your bounty"
  lanes (reward TBD, needs demand evidence + acceptance criteria).
- **Owner picked option 1 + "note all options":** all brainstorm options A–F
  recorded in `backlog.md` §6 (Alby source DONE; PaidMCP review API = next big
  thesis; bounty-alert product; NWC MCP wiring; Snitch product; builder demo).
- **Scout v4.1 — Alby source added** (`fetch_alby`/`enrich_alby`): GitHub
  search `org:getAlby is:issue is:open label:"good first issue"` (30 open),
  enriched with the same machinery (archived skip, contest detection,
  language), flagged `reward_negotiated` (0 sats, no min-reward filter),
  ALERTS + report + top-picks show "negot." / [negotiated].
- **First Alby results:** 30 candidates, **8 contested** (open PRs), 22 open to
  negotiate — mostly JS/TS (hub#1001 LSP info, pos#40 NIP-47 notifications,
  extension#2984 LUD-17, many bitcoin-connect UI fixes). In-ecosystem,
  uncrowded lane = matches the strategy.
- Doc updates: README (Alby source + negotiated note), workflow SOP
  (negotiated-lane handling), policy strategy, backlog §6, this note.

### Open items (added)
- [x] **PICK: getAlby/lightning-browser-extension#2984** (LUD-17 `keyauth://` for
      LNURL-auth) — best viable Alby candidate: active repo (pushed 2026-08-15),
      0 open PRs, spec-driven, prior partial work merged (#2975), flag-level fit
      (TS). **hub#1001 disqualified** (NodeDiver declared work + shipped a live
      prototype; effectively claimed). **pos#40 disqualified** (repo 15 months
      stale — the nostr-wallet-connect trap). **nostr-wallet-connect#86**
      disqualified (2y stale, superseded).
- [x] **Contact sent**: concept-first comment posted on #2984 (as MejorQueNada)
      offering to implement under the Alby bounty program, asking 3 scope
      questions (fallback scheme, raw-URL UX, keyauth prompt). Ledger entry:
      `bounty_attempt` (negotiating, 0 sats). Concept:
      `deliverables/lightning-browser-extension-2984/concept.md`.
- [ ] Await maintainer scope confirmation → then implement (jest tests,
      `yarn lint`, draft PR, owner gate #2 before ready-for-review).
- [x] **NEXT proposal: getAlby/bitcoin-connect#159** (dedicated docs site) —
      contact comment posted 2026-08-16. Chosen after diligence killed the
      alternatives: **#45 bundle size = already done** (published 1.09MB vs
      6.04MB in 2023, `microbundle --no-sourcemap` — source maps already off);
      **#151 WebLN-for-LNC = needs an LNC node to test** (we run Alby Hub/LDK,
      not LND). #159 has maintainer acceptance criteria on record (rolznz:
      simple structured docs, not one long page) + uncontested. Concept:
      `deliverables/bitcoin-connect-159/concept.md`. Ledger entry:
      `bounty_attempt` (negotiating, 0 sats).
- [ ] Await bitcoin-connect#159 scope reply → then build docs site (content +
      CI, owner gate #2).
- [ ] Reconsider PaidMCP review API after the first real payout (backlog §6 B)
