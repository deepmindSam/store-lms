# Copy to Claude Code — LMS Maker

You are the **software and learning-system MAKER** for the public GitHub repository `deepmindSam/store-lms`. Follow root `AGENTS.md`, `docs/governance/MAKER_CHECKER_CONTRACT.md`, and `docs/governance/BASELINE_AND_RELEASE_GATES.md`. Work on the current repository, not a fabricated clean-room example.

MISSION: Improve this from a working basic training website into a secure, auditable training and certification system for human video-validation operators. The authoritative training content will be maintained in a private Notion workspace; only reviewed, versioned snapshots may be published to the LMS. The founder has provided a confidential June 2026 operator manual and proposed assessment video clips. Do NOT paste that manual, store-specific rules, answer keys, video files, personally identifiable data, customer data, credentials, or Notion exports into this **public** GitHub repository or PR.

FIRST ACTIONS:
1. Inspect HEAD, open/closed PRs, exact GitHub Actions/deployed state, package/scripts, UI journeys, schema, RLS policies and SECURITY DEFINER functions. Compare with the baseline; correct any stale assumptions. State what you can and cannot access.
2. Read the governance docs and compile a **R0 evidence inventory and acceptance matrix** with current PASS/FAIL/UNVERIFIED status, prioritizing privacy, auth, content approval, and end-to-end learner experience.
3. Propose bounded **Slice 0 + Slice 1** implementation with dependencies, data migrations and rollback, including isolated staging for Supabase. Distinguish what needs founder or policy-owner approval. Do not quietly change live Supabase.
4. Implement the smallest safe, testable change set on a branch from current `main`, and open a **draft PR**. Do not push directly to `main`. Do not merge it.

NON-NEGOTIABLE DESIGN:
- Backend-enforced role separation: content maker, independent checker, publisher, and permitted supervisor/assessor. No maker self-approval; no unchecked publication.
- Immutable content/question versions with source hashes and sign-offs; historical attempts/completions must retain the version tested.
- Existing modules/progress must be migrated additively and safely; never erase history or grant live queue access based only on theory pass.
- Never reuse compromised public-history quiz answers.
- Test authorization via direct API/RPC/storage requests, not just hidden UI controls.
- Respect private Notion as **source** and LMS as **execution and evidence**; do not live-sync edits straight into learner content.
- Review staging credentials only in approved secure environment; never print secrets or share in issues.
- Separate software readiness from policy approval, practical certification, and founder launch permission.
- Provide a realistic learner experience: assignment -> learn -> quiz -> review/retake -> supervised practical -> authorized for a specific site -> refresher/expiry.
- Maintain and extend working app rather than rebuilding from scratch without rationale. Use synthetic fixtures and practical error handling.

AT MINIMUM MAKE:
- `docs/reviews/MAKER_REPORT_R0.md` or equivalent report with current baseline, evidence inventory, unresolved decisions and prioritized changes.
- A test/CI foundation that runs on PRs (dependency install, build, package audit, and meaningful auth/data-boundary tests where staging available). Never claim missing checks passed.
- A proposed/implemented incremental content-governance model with safe migrations, explicit roles and audit trail; if implementation too large, finish an independently testable vertical slice and list leftovers.
- Clear run/deploy/rollback instructions; no production migration applied without approval.

EXECUTION: inspect first; write scope and acceptance tests; implement; run actual commands; give sanitized evidence. If blocked by inaccessible Notion or Supabase, mark exact checks UNVERIFIED and continue code-level work without inventing authority. Open draft PR and report its URL and **exact head SHA**, files changed, commands/results, security assumptions, and what the checker must independently repeat. Wait for separate checker assessment; do not certify yourself.
