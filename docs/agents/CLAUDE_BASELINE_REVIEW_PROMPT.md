# Copy to Claude — Independent baseline review of Codex-built LMS

**ROLE: CHECKER, NOT MAKER.** You did not create the initial LMS. The founder confirms Codex created it. Your job is to independently review the **Codex-authored baseline** in `deepmindSam/store-lms` and the proposed governance draft PR #4, without making changes. You are not approving future code that you yourself will write in a later Maker session.

## Start here
- Repo: https://github.com/deepmindSam/store-lms
- Current deployed site: https://deepmindsam.github.io/store-lms/
- Deployment evidence: https://github.com/deepmindSam/store-lms/actions/runs/41724038307
- Proposed governance: https://github.com/deepmindSam/store-lms/pull/4
- Standing docs on PR #4 branch: `AGENTS.md`, `docs/governance/MAKER_CHECKER_CONTRACT.md`, `docs/governance/BASELINE_AND_RELEASE_GATES.md`.
- Existing foundation issue: https://github.com/deepmindSam/store-lms/issues/5

## Independent checker mandate
1. Pin the exact current `main` SHA and the precise governance PR head SHA. Inspect the actual code, dependency tree, migrations, role permissions, GitHub Actions deployment, status of past PRs, and learner/admin journeys. Do not assume historical claims are current.
2. Independently verify what is demonstrably working, flawed, inaccessible or unsafe. Check GitHub Pages for exposed public content, public JS secrets, wrong base-path URLs and form errors. Distinguish publicly observable UI checks from authenticated/live Supabase checks.
3. Build a full requirements/acceptance matrix with PASS / FAIL / UNVERIFIED for anonymous, learner, administrator, content maker, independent content checker, publisher, supervisor and practical assessor flows. Roles not implemented yet are design gaps, not passed tests.
4. Threat model direct API/RPC/storage bypass: exposed quiz answers (including compromised public history), forged completion, privilege escalation, read of others' progress, unpublished lesson/quiz grading, unassigned/wrong-site/retired/revised content, unauthorized publication, lack of revision hashes, approval self-signoff, and media leakage. Where authorized, test with synthetic isolated staging accounts and a staging database only. No probing production with real employee accounts/data without explicit founder authorization.
5. Assess the confidential source hierarchy, private Notion publishing design, policy fidelity review requirements, operator theory/practical qualification separation, production authorization boundary, and audit history preservation. No unauthorized training content imports and no real footage or question answers in public PR text.
6. Check whether the current reviewer policies are enforceable by GitHub branch rules or if they only exist in prose. The existing rulesets endpoint was empty and branch-protection inspection was denied; mark enforcement UNVERIFIED until established.
7. Review draft governance PR #4 itself. Challenge role assignment, realistic workload, stage order, source integrity, missing tests, data retention and rollback. Suggest corrections rather than editing.
8. Re-run any commands/tests you can actually execute; report exact commands and outputs. Identify no-test areas explicitly. A successful build is not a security, content or operator-journey PASS.
9. Do not modify code, migration, PR, Supabase, Notion, or production data. Do not merge PR #4. Do not produce policy approvals or publish lessons.

## Expected review deliverable
Create your independent report as **local/uncommitted Markdown** or a sanitized comment on PR #4 where allowed (do not commit into the branch under review). Recommended filename:
`CLAUDE_BASELINE_CHECK_R1.md`.

Include:
- Provenance: initial implementation attributed to Codex by founder; current checker is Claude.
- Exact main SHA and governance PR SHA, environment and scope.
- Summary of claims checked and evidence links.
- Full requirement matrix with pass/fail/unverified, setup/expected/actual, and reproducible steps.
- Severity-ranked P0-P3 defects and whether they block learner launch.
- Separate verdicts for (a) governance PR documentation, (b) current code/security, (c) live authentication/Supabase, (d) policy/content correctness, (e) employee journey and practical certification, (f) overall rollout.
- Prioritized repair assignments for a **future, separate Claude Maker session**.
- Explicit declaration that this review **does not cover future Claude-authored changes**.

## Independence for subsequent work
After this report, the founder may assign a **new Claude Code session as Maker** to fix/build the LMS. That Maker must open a separate PR. That new PR requires a reviewer who did **not** author or edit those changes: an independent human or a separately instructed, clean Claude reviewer session, with a distinct GitHub approver if formal independent approval is needed. Do not reuse the Maker session to review its own code. Codex is **not** the designated baseline checker.

**Stop after reporting. Do not implement the repairs in this checker session.**
