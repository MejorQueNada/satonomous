# Daily Notes

## ▶ Bounty tool consolidation: `bounty-agent` = single source of truth (2026-08-16)

Owner concern: too much overlap between `bounty-scout`, `bounty-agent`, and
`code-review-desk` repos. Audited: `code-review-desk` is a client-facing product
(unrelated, only shares Alby/ledger infra); the real overlap was `bounty-scout`
and `bounty-agent` — one system at two scopes (`scout.py` duplicated). Owner
approved full consolidation.

### What changed
- **`MejorQueNada/bounty-agent`** (public) is now the single source of truth
  for all four scripts (scout / watch / notify / verify) + tests + SETUP.md.
  README notes it supersedes `bounty-scout`.
- **`MejorQueNada/bounty-scout`** — README archived notice + **repo archived on
  GitHub** (`archived=true`). `scout.py` now lives as `services/scout.py` in
  bounty-agent (verified functionally identical, only secrets-path param added).
- **`ventures/bounty-desk`** (private) — **removed its duplicated copies** of
  `verify.py`, `watch_proposals.py`, `notify_telegram.py`, `scripts/run_tests.sh`,
  and `tests/`. Keeps only ops state: `services/proposals.json`,
  `agents/bounty_workflow.md`, `docs/bounty_policy.md`. Consumes the scripts from
  `/home/berto/Code/bounty-agent`. README + workflow doc updated to point there.
- **Parent repo** — `bounty-scout` gitlink replaced with `bounty-agent` gitlink
  (local checkout at `/home/berto/Code/bounty-agent`).
- **Cron updated** — both lines now call `/home/berto/Code/bounty-agent/services/*`
  with `--secrets ~/.openclaw/secrets.json` (+ `--owner MejorQueNada`,
  `--config`/`--state` for the desk's ops paths). Same schedule (scout+notify :00,
  watch+notify :15, 3h).

### Verified
- bounty-agent test suite: 55 tests green from the live checkout.
- `verify.py --root /home/berto/Code --config ventures/bounty-desk/services/proposals.json ...` → rc=0, 0 discrepancies.
- `watch_proposals.py` with desk config/outdir → rc=0, 3 tracked, no new replies.
- `scout.py --outdir deliverables --secrets ~/.openclaw/secrets.json` → rc=0.

### Outcome
Three repos, three distinct jobs, no script duplication:
- `bounty-agent` = the tool (public)
- `bounty-desk` = the ops state (private)
- `code-review-desk` = the client product (public, untouched)

## ▶ Public `bounty-agent` setup repo drafted; chat ID redacted (2026-08-16)

Owner decision: publish the full agent setup (OpenClaw agent + Alby wallet +
Telegram interface that triages open-source bounties) as a public repo so
others can replicate it — but keep operational state private.

- **Repo name:** `MejorQueNada/bounty-agent` (platform-agnostic; NOT
  `openclaw-bounty-agent`, in case we switch agent platforms later).
- **Draft built + verified** in `/tmp/opencode/bounty-agent/` (NOT yet
  pushed): 4 parameterized scripts (`scout`, `watch_proposals`,
  `notify_telegram`, `verify`) + `SETUP.md` (Alby Hub → BotFather → OpenClaw
  channel → cron) + README + MIT LICENSE + `.gitignore` +
  `examples/proposals.example.json` (empty template). 55 hermetic tests, all
  green. Secret scan clean: no chat id, bot name, paths, or tokens.
- **Parameterized vs private originals:** `--secrets`, `--owner`, `--root`
  args + `BOUNTY_*` env overrides; defaults moved off `MejorQueNada`,
  `/home/berto`, `~/.openclaw`, `@Surfacebountybot`.
- **What stays private/local:** `ventures/bounty-desk/services/proposals.json`
  (live in-flight state), ledger, deliverables, notify_state, everything under
  `~/.openclaw`. `proposals.json` + `deliverables/` are gitignored in the
  public repo.
- **Chat ID redacted:** Telegram id + `Bertofortheppl` binding removed from
  `NOTES.md` (4 spots) — the public parent repo was already carrying them.
- **⚠️ FOLLOW-UP (local, owner-agreed): revisit git history for sensitive
  info.** Redacting going forward does NOT remove the chat id from older
  `NOTES.md` commits already on GitHub (public parent `satonomous`). Decide
  later whether to rewrite history (filter-repo) or accept the exposure. This
  note is the reminder to revisit.

### Decisions for owner
- Approve creating + pushing `MejorQueNada/bounty-agent` (public) from the
  draft.
- Approve committing + pushing the `NOTES.md` chat-id redaction in the parent.

## ▶ Bounty desk: trust audit + test suite + verify command (2026-08-16)

Owner session. Motivation: distrust of the Telegram agent's factual claims —
"the scripts are the trustworthy layer; the LLM agent is not." Decided to
develop the tool as a whole, in opencode directly.

### Audit of agent claims vs GitHub reality
- **"#159 maintainer replied"** (bot, 14:49) — **FALSE**. The "replies" it
  cited were the 2024 `vr-varad` thread; no maintainer has replied to us.
  The deterministic watcher (`PROPOSALS.md`) was right all along.
- **"Contacted #174 and #84"** (session `a7311de3`) — **FALSE**. Zero
  MejorQueNada comments on either issue; POST failed (heredoc bug); ledger
  correctly records `not-contacted`.
- **"Posted #2984/#159/#111 contacts"** — **TRUE** (comments verified live:
  ids 5305827448, 5305842674, 5307658632).
- Live state today: **all 3 proposals still awaiting maintainer reply** —
  #2984, #159, #111. Verified directly via GitHub API.

### Deliverables (all committed-ready, uncommitted pending owner review)
- **Test suite, stdlib `unittest`, hermetic, 55 tests total:**
  - `bounty-scout/tests/test_scout.py` (25) — scoring, award math, first-mover
    detection, cache TTLs, enrichment filters (archived/closed/contested/
    negotiated), language detection, markdown renderer.
  - `bounty-desk/tests/test_watch_proposals.py` (7) — seeding, NEW REPLY
    detection, our-own-comments-never-count, fetch-failure handling.
  - `bounty-desk/tests/test_notify_telegram.py` (23) — dedupe fingerprints,
    chunking, HTML escaping, Telegram API calls, --test mode.
  - `bounty-desk/tests/test_verify.py` (7) — verify cross-checks incl. the
    fabrication-detection case (reply on GitHub not in PROPOSALS.md).
- **`bounty verify`** — `ventures/bounty-desk/services/verify.py`: reconciles
  proposals.json ↔ PROPOSALS.md ↔ live GitHub ↔ ledger; exits non-zero on any
  discrepancy (missing ledger entry, rejected-but-contacted, closed-on-GitHub-
  but-tracked, or reply-after-ours not in PROPOSALS.md). Run:
  `python3 services/verify.py --root /home/berto/Code [--json]`.
  Verified against live state: **3 proposals, 0 discrepancies**.
- **Bug found + fixed by tests:** `watch_proposals.py` crashed rendering the
  PROPOSALS.md row when a fetch failed (exception object passed to
  `.get('id')`) — status now renders "check failed" instead of throwing.
- `scripts/run_tests.sh` runs the whole suite. READMEs updated (scout + desk).
- **Deliberately NOT wired to cron yet** — verify canary on cron is a
  side-effect decision for the owner (would ping Telegram on discrepancy).

### Decisions for owner
- Commit + push the two repos (bounty-scout, bounty-desk) when wanted.
- Optionally add `verify.py` to the `:15` cron line (silent, non-zero exit
  logged) as a trust canary.
- Next tooling candidate (not started): `bounty status` unified CLI.

## ▶ Constitution amendment: repo layout (2026-08-16)

Owner-approved amendment to `CONSTITUTION.md` §4 (Governance): `ventures/` is
reserved for Satonomous agent-projects (wallets, tasks, revenue); `plugins/`
is for standalone tools/plugins with their own lineage. Both stay
gitlink-tracked, but only `ventures/` projects count as ventures. This makes
the OpenVault relocation decision a permanent, committed rule (auto-loaded via
AGENTS.md each session).

## ▶ OpenVault relocated from `ventures/` to `plugins/` (2026-08-16)

Owner decision: `ventures/` is reserved for Satonomous agent-projects (wallets,
tasks). OpenVault is a standalone plugin with its own lineage under
`bertofortheppl` — a tool, not a venture. Moved the gitlink from
`ventures/openvault` to `plugins/openvault` (same fork, same `improvements`
branch, same commit). Code, history, and remote are untouched; only the parent
tree placement changed. `backlog.md` §7 updated to reflect this.

## ▶ OpenVault Sprint 3 — vault UX: DONE (2026-08-16)

On `ventures/openvault` branch `improvements`. Typecheck + build clean;
E2E extended to cover `GET /session`, `GET /session/{id}/message`, and
`POST /session/{id}/abort` — **PASS on both auth paths** vs live opencode
1.18.18 (plain + basic-auth, `google/gemma-4-26b-a4b-it`).

- **Real markdown rendering:** assistant + user bubbles now render through
  Obsidian's `MarkdownRenderer.render` (replaces the regex wiki-link hack) —
  code blocks, lists, embeds, and clickable `[[wiki-links]]` all work.
  Streaming still uses a plain-text span; the bubble re-renders as markdown
  on completion.
- **`@`-mention file picker:** typing `@` shows a dropdown of vault notes;
  picking one attaches it as a `file://` FilePart (mime by extension) shown
  as a removable chip. Sent as `type: 'file'` parts on `prompt_async`.
- **Selection context:** the **＋sel** footer button captures the active
  editor's selection into a chip; sent as a prepended text part that names
  the source note (`[[path]]`).
- **Stop button:** while streaming, a red **Stop** button calls
  `POST /session/{id}/abort` and cancels the SSE; the bubble keeps partial
  text and shows `(stopped)` instead of a spurious error.
- **Session persistence + switcher:** header dropdown lists sessions
  (`GET /session`), with **New** / **Del** buttons. The active session is
  persisted to `data.json` (`lastSessionId`) and auto-resumed on reload,
  history loaded via `GET /session/{id}/message?limit=50`. "Open a new
  OpenVault chat" command opens a second chat tab (multi-tab); the new tab
  starts a fresh session.
- **Notes:** the `/skill` endpoint is still dead in opencode 1.18 (deferred
  to S5 file-based discovery). Session resume only applies to the first chat
  tab; extra tabs get fresh sessions.
- **Verified:** `npm run typecheck` + `npm run build` clean; E2E on both
  auth paths covers the new session/history/abort endpoints.
- **Backlog:** `backlog.md` §7 updated; S3 marked done, S4/S5 remain.

## ▶ OpenVault Sprint 2 — any-provider + free-model picker: DONE (2026-08-16)

On `ventures/openvault` branch `improvements`. Verified via live `opencode
serve` (1.18.18): **both auth paths pass** (plain + basic-auth), provider
fetch + free-model default + per-message model override + streaming all
PASS (e2e on `google/gemma-4-26b-a4b-it`, a cost-0 model).

- **Provider-agnostic auth:** settings no longer have an OpenRouter key.
  opencode's own auth (`opencode auth login`) is the default; power users can
  inject `KEY=VALUE` env lines ("Extra environment variables"), merged into
  the spawned server. Old `openrouterApiKey` setting auto-migrates into
  `OPENROUTER_API_KEY=...` on first load.
- **Auto-start decoupled from API keys:** starts whenever enabled.
- **Binary auto-detect:** explicit setting → `which opencode` → common
  locations; cached. Empty default = auto-detect (old hardcoded
  `/home/berto/.opencode/bin/opencode` removed).
- **Model picker:** footer dropdown populated from `GET /provider` (returns
  `{ all: [...] }` — 186 providers / 6623 models here). Free = zero
  input+output cost; default selection = first free model from an
  authenticated provider, with a "free" button to jump back. Per-message
  `model: { providerID, modelID }` sent on `prompt_async`.
- **Optional server auth:** `OPENCODE_SERVER_USERNAME`/`_PASSWORD` set on
  spawn when configured; basic-auth header now sent on all plugin requests
  + SSE. Settings tab has Start/Stop server buttons + status.
- **Skill endpoint dead:** opencode 1.18 removed `GET /skill` (no skill HTTP
  routes in the OpenAPI spec) — the plugin's skills slash-menu can never
  populate. Left graceful (silent empty list); noted for a later sprint
  (likely file-based skill discovery from `.opencode/skill`/config dirs).
- **Verified:** typecheck + build clean; `scripts/e2e-test.mjs` extended to
  cover auth + provider fetch + free-model override (3rd arg = password).
- **Backlog:** `backlog.md` §7 updated. Next: S3 vault UX (markdown
  rendering, @-mentions/FilePart, selection context, stop/abort, session
  persistence + multi-tab) when the owner wants.

## ▶ OpenVault Sprint 1 — correctness on current opencode: DONE (2026-08-16)

All committed-ready on `ventures/openvault` branch `improvements` (fork
`MejorQueNada/openvault`, cloned 2026-08-16). NOT yet committed/pushed —
waiting on owner. Verified via live `opencode serve` (1.18.18).

- **SSE parser rewritten** (`main.ts`): opencode emits `message.part.updated`
  with `properties.part` (`type`, `text`, `id`) — the old code listened for
  `message.part.delta`/`properties.field`, which never fire → every response
  was "(empty response)". New parser: `step-start` gates the model turn (text
  parts before it are the user's echoed prompt, excluded), text parts
  accumulated by part id (`part.text` is cumulative full text; `delta` is
  empty in practice), reasoning/tool parts skipped for now. Verified: reply
  streams correctly (e2e "PONG").
- **Plan mode is now native:** `prompt_async` body sends `agent: 'plan'` /
  `'build'` instead of the injected "you are in plan mode" system prompt.
  Skills still passed via `system`.
- **Drop-vs-done distinguished:** `session.idle` completes a turn; an
  `end`/`close`/`error` before idle now surfaces "connection lost before
  completion" instead of rendering a truncated reply as success.
- **Skills retry:** `skillsFetched` resets on disconnect, refetches on next
  connect (was permanently stuck after one failed fetch).
- **Repo hygiene:** added `tsconfig.json` (strict) + `npm run typecheck` —
  exposed 16 latent type errors, all fixed (null guards, definite assignment,
  dead field removed, cross-class helpers made public). `npm run build` clean.
- **E2E smoke test** `scripts/e2e-test.mjs`: spawns/attaches to `opencode
  serve`, creates session, streams SSE with the plugin's exact parse logic,
  asserts `PONG` + `session.idle`. **PASS against live 1.18.18.**
- **README:** added Development section (typecheck/build/e2e-test).
- **Backlog:** `backlog.md` §7 (review findings, Sprint 1 done, S2–S5
  planned). Parent gitlink for `ventures/openvault` staged, not committed.
- **Next:** S2 any-provider + free-model picker (auto-detect binary, model
  switcher, per-message model, optional server password) when the owner wants.

## ▶ OpenVault venture bootstrapped — review + roadmap, Sprint 1 scoped (2026-08-16)

Owner brought in `Bertofortheppl/openvault` — an Obsidian plugin that embeds
opencode as a sidebar agent — as a new venture. Intent: claudian-style UX but
backend-agnostic via opencode, with **free models** (Zen `*-free`, OpenRouter
`:free`) as first-class. Owner chose: fork on GitHub (now `MejorQueNada/
openvault`), clone + branch locally, Sprint 1 in scope, S2–S5 backlog.

- **Forked + branched:** `ventures/openvault/` on branch `improvements` (off
  `main`, 5 commits). Gitlink added to parent index (160000, no `.gitmodules`,
  matching bounty-desk/code-review-desk convention). **Parent commit of the
  gitlink NOT made** — waiting on owner.
- **Review (verified live against opencode 1.18.18):** the SSE parser targets
  the old `message.part.delta`/`properties.field` events; current opencode
  emits `message.part.updated` with `properties.part.type` + `properties.delta`.
  Confirmed empirically by driving a local `opencode serve` session. Streaming
  therefore never fires → assistant renders "(empty response)". Also: drop-vs-
  idle conflated, skills never retried on failure, OpenRouter-only auth gating
  auto-start, no model picker/free default, plan mode = injected system prompt
  (native `agent: 'plan'` exists), no permission approval UX, no markdown,
  no abort, no session persistence, no tsconfig (zero typechecking), no
  LICENSE/versions.json.
- **Roadmap:** S1 correctness (this session) → S2 any-provider + free-model
  picker → S3 vault UX (markdown, @-mentions, selection, abort, sessions) →
  S4 agent UX + release hygiene → S5 parity polish (inline edit, tool UI).
  Full write-up + status: `backlog.md` §7.
- **Decision:** free/open tool, dogfoods opencode as a free-model hub — not a
  revenue bet. No releases/store submission without owner sign-off.

## ▶ Session wrap-up — sprints A/B/C, docs sweep (2026-08-16)

Owner session: planned and executed a hardening sweep one sprint at a time
(redaction → endpoint hardening → naming; naming cancelled). All committed and
pushed; prod left undeployed per owner ("repos up to date, nothing running").

- **Docs updated:** `ventures/code-review-desk/README.md` (redaction + limits +
  hardening + E2E script documented), `fly.toml` (stale `ZEN_SECRETS_FILE`
  comment corrected — deploy script sets `NWC_CONNECTION_STRING`/`MODE`, Zen key
  is manual), `backlog.md` §6 B (status now reflects Sprint A+B commits and that
  prod is not yet redeployed).
- **Daily note entries:** Sprint A (redaction fix), Sprint B (hardening),
  Sprint C (cancelled), this wrap-up.
- **Open items carried forward:** prod redeploy whenever the owner wants the
  fixes live (`./scripts/fly-deploy.sh`); first real (non-self) paid customer
  still the #1 milestone; bounty-desk proposals still awaiting Alby maintainers.

## ▶ Sprint C — naming rename: CANCELLED (2026-08-16, owner decision)

Owner dropped the proposed rename of `ventures/` (and "Ventures" in prose).
"Ventures is fine for internal jargon" — everything is treated as a project.
**No files renamed.** Noted here so the decision isn't re-litigated.

## ▶ Sprint B — ReviewDesk endpoint hardening (2026-08-16, afternoon session)

**DONE**, verified, committed + pushed (`MejorQueNada/code-review-desk` `97d2641`).
Prod still not redeployed (owner: repos up to date, nothing running).

- **Pre-clone size gate** (`review_scan.ts`): GitHub API repo-size check (TTL
  cached 1h, `checkRepoSizeViaApi`) runs before `git clone` — oversize repos
  are skipped without consuming clone bandwidth. Falls back to the post-clone
  check if the API fails. Verified: `rust-lang/rust` (947 MB) paid → skipped
  pre-clone.
- **Rate limiter** (`rate_limit.ts`, new): per-IP sliding window on `/mcp`
  (default 30 req/min, `RATE_LIMIT_PER_MIN`, no new dependency), 429 +
  `Retry-After`, opportunistic pruning past 10k entries. Verified 429 on
  budget exhaustion.
- **SSE session hardening** (`sse.ts`): client-supplied `sessionId` no longer
  honored (was a session-hijack vector — attacker could overwrite another
  client's transport); sessions capped at 200 and expire after 30 min.
  Verified: `?sessionId=hijack-attempt` → 400.
- **/tmp leak fixed** (`review_scan.ts`): findings.json + clone now live in one
  temp dir removed in `finally`. Before: each scan left 76KB (`findings.json`)
  behind — confirmed by 3 leftovers from Sprint A runs (cleaned).
- **MemoryStorage TTL** (`storage.ts`, new): `TtlMemoryStorage` wraps
  `MemoryStorage`; paid-but-unexecuted hashes expire after 1h instead of
  accumulating. Known limitation (unchanged): restart/scale still loses in-flight
  hashes → re-invoice; that needs a persistent store (out of scope, noted).
- **Regression:** full paid E2E re-run (invoice → pay → 99 findings on
  `gitleaks/gitleaks`) — REDACTION_OK, no /tmp residue.
- **Ledger:** 2 new net-zero self-payment entries (hub txn 49, 51). Balance
  unchanged (96,954 sats).

## ▶ Sprint A — ReviewDesk redaction fix (2026-08-16, afternoon session)

Closed as part of the hardening sweep the owner commissioned (Sprint A: redaction,
Sprint B: endpoint hardening, Sprint C: naming). Sprint A **DONE**, verified through
the paid path, committed + pushed (`MejorQueNada/code-review-desk` `a2d8a9f`).

- **Bug:** `review_scan` redacted gitleaks only in `top_findings`; the raw secret
  match text flowed to the client inside `summary.analyzers` and to the Zen LLM —
  contradicting README/NOTES claims and constitution §2.3. Verified: fixture's
  `.env.example` secrets (AKIA/ghp_) plus bandit echoing `hunter2` leaked.
- **Fix (`services/mcp/src/tools/review_scan.ts`):** redact once at the payload
  level; client result, `analyzers`, and LLM input all built from the redacted
  copy. Value-based, not tool-based: known secret rules (gitleaks, bandit
  B105–107, semgrep `secrets.`, ruff hardcoded-password) blank the whole message
  (regex can't catch short secrets like `hunter2`); a secret-value regex
  (`AKIA…`, `ghp_…`, `sk-…`, private keys) scrubs echoes in unrelated rules.
- **Verified end-to-end via the paid path** (treasury as test client, local
  server on :3100, repo `gitleaks/gitleaks`): invoice → pay → 99 findings →
  **REDACTION_OK** (0 leaks in result or analyzers; 2 gitleaks findings both
  `<redacted secret match>`). Repeatable script committed:
  `services/mcp/scripts/e2e-test.mjs` (SSE-aware, uses hub-cli for the
  self-payment).
- **Ops gotchas hit:** hub-cli defaults to port 8029 but our Alby Hub API is on
  8080 (`-u http://127.0.0.1:8080`). SSE transport needs `Accept: application/
  json, text/event-stream`. The hub container restarted mid-session (node ended
  up `running:false/unlocked:false` → NWC `make_invoice` "reply timeout"); owner
  re-unlocked. `setsid nohup` is required to keep the local MCP server alive
  across shell calls.
- **Ledger:** 6 net-zero self-payment E2E entries appended (hub txn ids
  31/33/35/41/43/45). No balance change (96,954 sats).
- **Not redeployed to fly** — owner wants repos up to date, nothing running.
  Prod `https://reviewdesk-mcp.fly.dev` still runs the pre-fix build; redeploy
  later via `./scripts/fly-deploy.sh` if wanted.

## ▶ V1 BUILD LOG — ReviewDesk MCP (2026-08-16, continued from launch entry)

- **Built & verified locally** (`services/mcp/`): `review_scan(repo_url,
  with_summary?)` + `ping`; HTTP mode on port 3100; NWC app "ReviewDesk"
  (id 3, receive-only) → `NWC_REVIEWDESK_URL` in `ops/.env` (now single-quoted
  — unquoted NWC URLs with `&`/`?` broke shell sourcing).
- **End-to-end verified 2026-08-16** (treasury as test client, repo
  `MejorQueNada/snitch-ci-monitor`): unpaid call → `lnbc15u` (1500 sats)
  invoice + `payment_hash` → hub-cli pay (settled) → scan executes → relative
  paths + severity counts + `llm_summary`. Ledger: 9 entries (txn ids
  4/7/9/11/13/17/19/21 self-payments, net zero; + launch entry).
- **PaidMCP v1.0.3 gotchas learned:** module-level `MemoryStorage` required
  (stateless HTTP); `paidConfig` always injects `outputSchema` → client
  mandates `structuredContent` (solved: `{ result: z.record(z.any()) }`);
  needs `lookup_invoice` scope for `wallet.verifyPayment`.
- **Zen API gotcha (important for future integrations):** the OpenAI-compatible
  `chat/completions` path 403s from this box; GPT-family models (incl.
  `gpt-5.4-nano`) require `POST https://opencode.ai/zen/v1/responses` with
  CLI-identity headers (`User-Agent: opencode-cli/1.0.0`,
  `x-opencode-client: cli`, `x-opencode-project: default` +
  `x-opencode-request`/`-session` UUIDs) — Cloudflare blocks non-CLI requests.
  Responses text lives in `output[].content[].text` (no top-level `output_text`).
  NOTE: existing `llm_summary.ts` rewritten to that pattern and verified.
- **Deploy: DONE — production verified 2026-08-16.** App `reviewdesk-mcp` on
  fly.dev (iad, shared-cpu-2x:1024MB, remote builder — local box has no Docker).
  Endpoint https://reviewdesk-mcp.fly.dev/mcp, health `/health` → `{"ok":true}`.
  Full paid flow re-verified against prod (invoice → hub-cli pay → scan →
  findings + `llm_summary`; ledger txn 23). Owner ran `flyctl auth login` (SSO
  org, PATs blocked — org-scoped tokens only); I drive `./scripts/fly-deploy.sh`
  from the box with their session.
  Deploy gotchas fixed: runtime stage had no node (Dockerfile rewritten:
  node:24-bookworm-slim + python + analyzers, `--break-system-packages` for
  PEP 668); stale `PORT=8080` secret from the first deploy kept 8080 while fly
  proxies 3000 (unset — fly never drops secrets unless explicitly unset).
- README (`ventures/code-review-desk/README.md`) updated with MCP section.
  Committed and pushed to GitHub (MejorQueNada/code-review-desk +
  MejorQueNada/satonomous, public, 2026-08-16). Local test server on :3100
  stopped.

## ▶ In-flight proposals (current state — 2026-08-16)

## ✅ V1 LAUNCHED — ReviewDesk MCP (PaidMCP review API) — 2026-08-16

Owner-approved after first-principles re-derivation + 2026 research pass (see
below). **The different thing from the bounty desk agent**: this venture sells
TO agents (a server with a payment rail) instead of running an LLM agent that
takes external actions — structurally immune to the fabrication failures that
killed `bounty-ops-cycle` runs 2–5.

- **What:** `ventures/code-review-desk/services/mcp/` — TS server using
  `@getalby/paidmcp`; `registerPaidTool("review_scan", 1500 sats)`.
  Input: public repo URL. Flow: shallow clone (size cap) → run
  `run_review.py` (semgrep/bandit/ruff/gitleaks) → redact gitleaks matches →
  return severity-ranked findings + optional LLM summary (findings-only, paid
  zero-retention Zen model via `opencode.ai/zen`).
- **Payments:** dedicated NWC app **ReviewDesk** in Alby Hub (receive-only:
  `make_invoice` + `lookup_invoice`, per-payment budget), secret in
  `ops/.env` (`NWC_REVIEWDESK_URL`, 0600, gitignored) — per-venture intent per
  the constitution.
- **Metrics:** first paid tool call ≤30 days; ≥3 in month 2; ≥10 in month 3.
  Seed: 0 sats (existing infra; ~$0.05/scan model cost vs 1500 sats ≈ $1.50).
- **Deploy:** fly.dev (Alby's documented path for paid MCP; `fly.toml` +
  Dockerfile shipped in the service). Local end-to-end verified (invoice →
  pay → result) using the treasury as test client.
- **Trust notes:** result is analyzer output + ranked summary, NOT a human
  audit — disclosed in the tool description and README (no "compliance
  theater"; constitution §2.1). Client code never leaves the box except
  finding metadata to the paid Zen model.
- **Market evidence (2026):** paid MCP is an established pattern (~100 paid
  servers on mpp.best), Alby `paidmcp-boilerplate` (May 2026), Cloudflare
  `paidTool`/x402 (Jun 2026), MCP 2026-07-28 stateless spec. Agent-commerce
  volume itself is still thin (x402 ~$0.20/txn, much test traffic) — this is
  a distribution bet on the rails maturing, priced as a real service.

### First-principles re-derivation + research (2026-08-16, owner session)
- Lessons with skin in the game: pipeline works / LLM agents don't hold
  actions (draft-only for `bounty-ops-cycle`); escrowed LB lanes exhausted
  (all contested), negotiated contact-first lanes (Alby) are the only live
  negotiations; money flows to vertical services humans/agents pay for.
- Landscape scan (searches, 2026-08-16): Lightning Bounties small (78
  bounties lifetime, 1.2M sats); Stacker News repo bounties still live
  (20k–1M sats/PR, verified 2026-05-18 by gigs.sh, agents tolerated, no KYC);
  L402 rails matured (Lightning Agent Tools, Feb 2026; `lnget`, `aperture`,
  macaroon bakery); new sats-native entrants SatBounty, Bitlance; agent-native
  lane Superteam Earn exists but USDC (off-rail); agent-economy reality = hype
  gap documented ("more Mac Minis than money printers"), revenue in vertical
  agent services ($3k–15k/project) and done-for-you builds.
- Ventures proposed (owner session): V1 ReviewDesk MCP (chosen), V2 Bounty
  Radar (productize first-mover alerts, free TG channel + paid tier), V3
  paid-MCP builder service ($500–2k/project, needs owner sales), V4 Stacker/
  Nostr content arm (zaps + SN repo bounties + review-desk funnel). V2–V4
  remain proposals in `backlog.md`; V1 is the only one earning without owner
  sales effort.

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
  (embedded repo, per-venture git design).
- **Bounty Desk split out (2026-08-16, owner-approved)**: `ventures/bounty-desk/`
  is now its own git repo (`7bc5946` initial commit — README, SOP, policy, the
  three services, proposals.json; its `.gitignore` covers deliverables/, scout
  outputs, logs, `__pycache__/`, and machine-local `notify_state.json`).
  Parent tracks it as a gitlink, same as code-review-desk. Both ventures now
  match the constitution's per-venture-repo rule.
- **Build in public (2026-08-16, owner-approved)**: pushed `bounty-scout`
  to GitHub as `MejorQueNada/bounty-scout` (public, MIT). Standalone copy
  of `scout.py` (stdlib-only) + plain README. Repo lives at
  `/home/berto/Code/bounty-scout`, tracked in the parent as a gitlink.
  Push used a transient token-in-URL (never persisted in git config).
  MejorQueNada public repos now: `2026` (human notes), `snitch-ci-monitor`,
  `bounty-scout`. Next candidates: `run_review.py` as a standalone
  code-review runner, and the satonomous framework itself.
  **Sync note**: the desk still runs `ventures/bounty-desk/services/scout.py`
  (same code, separate copy) — keep the public copy in lockstep if the
  internal one changes.
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
  `TELEGRAM_CHAT_ID` (redacted for privacy; owned by operator). Both 0600; the raw token is
  **never written to config** — `openclaw.json` references it through the
  zenkey file-secret provider.
- **Two-way channel configured** in `~/.openclaw/openclaw.json`:
  `channels.telegram.accounts.main` with `botToken` (secret ref),
  `dmPolicy: allowlist`, `allowFrom: [<redacted>]`, `defaultTo: <redacted>`,
  `groupAllowFrom`. Owner privileged commands:
  `commands.ownerAllowFrom: ["telegram:<redacted>"]`.
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
  (`--channel telegram --account main --to <redacted> --announce
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
