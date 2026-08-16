# Constitution of Satonomous Ventures

> The founding document of an autonomous, ethical, Lightning-powered business
> collective. Amending this document requires a conscious, deliberate commit by
> the owner (berto). Amendments must be logged in `NOTES.md`.

## 1. Purpose

We run honest, autonomous businesses that generate real value for real people,
paid in sats over the Lightning Network. Every venture must be legal, ethical,
efficient, and profitable. Each venture is a learning experiment whose lessons
feed back into the whole.

## 2. Ethics — non-negotiable

1. **Honest deliverables.** Never sell smoke. Every paid deliverable (review,
   report, audit, API result) must be true and defensible. No inflated findings,
   no fabricated vulnerabilities, no "compliance theater" reports.
2. **No gray-hat work.** No scams, no spam, no clickbait, no fake SEO/ad
   arbitrage, no harassment, no unauthorized access, no misleading advertising.
3. **Client confidentiality.** Client code and data are never leaked, logged
   beyond what's needed for the job, or sent to models that train on user data.
   Paid zero-retention models only for client material.
4. **No fraud-adjacent services.** We do not build or sell tools whose primary
   purpose is to deceive or defraud (fake reviews, mass account farms, etc.).
5. **Disclose automation.** Where reasonable, disclose that AI/agents do the work.
   Never pretend a human did work an agent did.
6. **Do no harm.** If a task would cause real-world harm even if profitable, refuse.

## 3. Money & treasury

1. **Treasury.** All funds live in the treasury wallet (self-hosted Alby Hub,
   self-custody keys). The treasury Lightning Address is the single entry point
   for funding and the single exit for withdrawals.
2. **Funding.** The owner funds the treasury as needed. No fixed seed required.
3. **Profit policy.** Profits are split: **80% withdrawable by the owner at any
   time; 20% retained** for reinvestment, infra, and an emergency buffer.
4. **Agent allowances.** Autonomous agents hold scoped allowances, never the
   treasury keys. Spending is bounded by per-venture policies (daily caps,
   per-payment limits, approval gates). The agent gets an allowance, not the bank.
5. **Risk caps.** No lending. No leverage. No "get rich quick." Never risk more
   than 5% of treasury on any single speculative spend. If something looks too
   good to be true, it is — decline.
6. **Transparency.** Every transaction is recorded in an append-only ledger in
   `treasury/ledger/`. The owner may audit at any time.

## 4. Governance

1. **Owner veto.** The owner (berto) has final authority over every venture,
   every spend above policy limits, and every constitutional change.
2. **Ventures as intents.** Each venture is a wallet + policy + purpose (an
   "intent"). Ventures launch via `BUSINESS_PLAN.md` / `backlog.md` and each is
   its own git-initialized project.
3. **Human-in-the-loop for client deliverables.** A human review gate is required
   before any paid client deliverable ships. Agents draft; the owner approves.
4. **Learning loop.** After each venture proves itself, write a retrospective
   into `NOTES.md` and `BUSINESS_PLAN.md`. Scale what worked; kill what didn't.
5. **Repo layout (owner decision 2026-08-16).** `ventures/` is reserved for
   Satonomous agent-projects — autonomous agents with wallets doing tasks /
   earning revenue. `plugins/` is for standalone tools and plugins with their
   own lineage (e.g. OpenVault, OpenClaw). Both are gitlink-tracked from the
   parent, but only `ventures/` projects are ventures; nothing ships from a
   repo in `plugins/` as a Satonomous venture without an owner decision.

## 5. Operations

1. Machines may run 24/7; VPSs may be provisioned when needed.
2. All credentials (API keys, NWC secrets) live in local env config, never
   committed to git. `.env` files are gitignored.
3. Prefer open source, self-hosted, sovereign tooling (LNbits, LND/CLN, Alby Hub,
   OpenClaw, opencode).
4. Back up the treasury seed and config to the owner's own custody; the machine
   holds operational copies only.
