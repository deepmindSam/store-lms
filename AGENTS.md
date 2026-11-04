# Agile Minds LMS — Agent operating instructions

This public repository contains the LMS application code, not confidential training content. Read this file before editing. The operating contract is in `docs/governance/MAKER_CHECKER_CONTRACT.md`; the audit baseline and release gates are in `docs/governance/BASELINE_AND_RELEASE_GATES.md`. Agent handoff prompts are in `docs/agents/`.

## Mission
Build an auditable LMS for human video-validation operators, their reviewers, and managers. Success is demonstrated operator competence, not just page completion. The product should support private training content, learning progress, knowledge checks, practical certification, customer/site-specific authority, updates, recertification, and QA feedback over time.

## Source hierarchy
1. Approved, versioned operational policies and SOPs in the authorised private Notion training workspace; do not assume a referenced page is accessible without checking.
2. Founder-supplied operator training manual (June 2026, confidential), **draft pending policy-owner review**. Do not copy it into this public repo.
3. Explicitly approved product decisions and acceptance criteria.
4. Existing implementation (descriptive of what exists, not policy authority).

Never invent customer-specific validation criteria, video labels, employment rules, disciplinary procedures, pass marks, legal conclusions, or evidence of operational permission. Escalate conflicting sources to the founder and designated policy owner.

## Public-repository confidentiality
Never commit, quote, or paste in GitHub issues/PRs/logs: real client/store rules, training footage, employee names or results, personal data, quiz answer keys, credentials, signed URLs, Notion exports containing protected policies, or live Supabase dumps. Use synthetic non-identifying fixtures only. Legacy question answers exist in Git history: they are compromised and must not be reused.

GitHub Pages may serve public code; private policy and assessment media must be retrieved through server-enforced authentication/authorization. Visual hiding is not security.

## Maker and checker
- **Maker (Claude Code preferred):** designs and implements on a separate feature branch; provides tests, migration/rollback plans, evidence, and a draft pull request.
- **Checker (independent Codex session preferred):** did not author the change; independently inspects the exact PR commit, tests negative cases, reads source authorities available to it, and publishes PASS / FAIL / UNVERIFIED findings. Checker does not edit the maker branch or close its own findings.
- **Policy approver / publisher (authorized human):** approves content accuracy, authorization decisions, live Supabase migration, and production release. Agent PASS never substitutes for human sign-off.

Never merge or deploy just because build succeeds. Do not alter live authentication, production records, database schemas, published lessons, or access grants without authorized approval and a rollback plan. Preserve existing learner history.

## Engineering workflow
1. Inspect current `main`, open PRs, deploy status, schema, and data flows. Historical handoffs are unverified until reconciled with HEAD.
2. Write an acceptance matrix, risks, scope, and tests before coding.
3. Branch from current `main`; commit one bounded change set; open a **draft** PR.
4. Maker runs the existing build, audit, and any new tests. Do not invent unrun output. Do not use real data in tests.
5. Independent checker repeats evidence and adversarial tests. Each finding has ID, severity, exact file/line or query, reproduction, expected/actual, and proposed remediation.
6. Maker fixes, checker rechecks the *new* SHA. A stale PASS is invalid if reviewed code changes.
7. Human authorizes the deployment and separately publishes approved content. Record the exact published code and content versions.

## Core product rules
- The current retail seed curriculum is **not** approved for video operators.
- Learning time is a coaching signal, not proof of attention or competence.
- Knowledge pass, supervised practical pass, and customer/site-specific production authorization are distinct states.
- A policy/quiz update must preserve historic attempt facts and show which version was assessed; substantive changes can require recertification.
- Learner permissions and approval gates must be enforced by the database/API, not only buttons or JavaScript.
- Distinct maker, checker, and publisher actors must be enforced server-side; no self-approval.
- All unsupported live/staging checks are marked **UNVERIFIED**, not PASS.

Start with `docs/agents/CLAUDE_MAKER_PROMPT.md` or `docs/agents/CODEX_CHECKER_PROMPT.md` as appropriate.
