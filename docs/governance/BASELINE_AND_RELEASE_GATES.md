# LMS baseline, release gates and first implementation slices

Snapshot review: 2026-11-04, GitHub `main` commit `52e014494c40f7bed4b21968c3e88364d1cc6b45`. Findings from the connected GitHub repository; deployed database/auth behavior has **not** been independently tested with account credentials.

## Assigned review sequence
1. **Claude baseline checker (read-only):** independently assess Codex-built current `main`, live-test limitations, and governance PR #4. Document PASS / FAIL / UNVERIFIED and specific acceptance tests.
2. **Founder decision:** prioritize repairs and accept/reject the governance framework; keep PR #4 draft until approved.
3. **Claude Maker (separate implementation session):** work on issue #5 and scoped engineering changes in a new draft PR.
4. **Independent checker of new Claude work:** another unaffiliated reviewer/session, preferably with human account-level review. Do not reuse the same Maker session for signoff or presume that approval by the PR author's GitHub identity is valid.
5. **Human release sign-off:** after verified tests, legal/policy approval, content versioning, and deployment evidence.

The original Codex builder is not assigned as the initial independent checker.

## Confirmed baseline
- Public repo: `deepmindSam/store-lms`; GitHub Pages deployment run `41724038307` reports `success` with the above commit.
- PR #2 (private lessons) is merged. PR #1 (launch security) is closed without a direct merge. Judge the *effective HEAD*, not PR labels.
- Private lesson migration: `supabase/private_lessons.sql` stores Markdown in `lesson_content` with `is_published`, and RLS. Code loads private Markdown and runs DOMPurify.
- `supabase/schema.sql` contains security-definer `grade_quiz`, separate read-only questions view, progress/attempt tables and basic admin/learner RLS.
- `package.json` has build/dev/preview only: **no automated test command**. The sole current GitHub workflow builds and deploys on `main`; PR test workflow absent.
- `supabase/seed_courses.sql` remains a **retail staff draft**, inappropriate for Agile Minds video-validation release.
- The admin dashboard aggregates completion/attempts/time; it does not show approval evidence, due dates, practical credentials, effective content versions, or calibration QA.
- Public quiz answers previously committed to Git history are compromised and must be replaced privately.
- Repository rulesets API returned an empty array; branch-protection API returned 403, so actual branch protection is **UNVERIFIED**. GitHub code review approvals cannot be assumed enforced.
- An authorized Notion training page has been named by the founder, but the connector previously returned page not found; content-source access and authority must be verified independently.

## Immediate high-risk gaps to resolve
1. No distinct content maker/checker/publisher authorization or immutable approval record.
2. No version-bound lesson, assessment, attempt, or completion data. Updating current content can make historical passes misleading.
3. `grade_quiz` must be tested for restrictions on draft/unpublished, unassigned, retired, wrong-scope, stale-version, and no-content modules. The current function does not itself check `lesson_content.is_published`.
4. No practical video competency or separate production authorization; quiz completion is not equivalently competent.
5. No real end-to-end admin / operator / supervisor acceptance evidence. Do not ask for credentials in logs or public GitHub issues.
6. No automated PR checks or test suite; deployment build alone is insufficient.
7. Need safe, independently reviewed source for each policy and question. Draft/confidential manual and assessment footage must not enter Git.

## Recommended delivery order
**Slice 0 — Evidence and foundations.** Read current source and commit, map all permissions, stage controlled test accounts, establish PR CI and negative security tests, verify live-vs-repo schema when authorized. Produce an R0 report. No rollout.

**Slice 1 — Content governance.** Add distinct role permissions, immutable revisions, review records, actor separation, publication audit events, and safe migrations. Demonstrate maker cannot self-check and cannot self-publish; protect private content.

**Slice 2 — Operator learning journeys.** Replace retail-facing terminology; design assigned, scoped curricula; due dates; failure/remediation; resume; dashboard; accessibility and realistic onboarding. Import only approved lessons from the private Notion source.

**Slice 3 — Competency.** Private video/simulated practical tests using authorized, reviewed ground truth; assessor review; calibration; training vs supervised practice vs production authorization; record expiry and re-certification.

**Slice 4 — Operational effectiveness.** QA feedback tied to coaching, error taxonomy, false-positive/negative analysis where ground truth exists, training compliance reporting, manager views, escalation and absence/shift understanding. Never manufacture metrics or grant OPDB access merely by UI badge.

Keep slices bounded. Maker may propose scope changes, but checker must review each merged code/content change at its exact SHA.

## Independent acceptance matrix
The checker should write a row for each test with requirement ID, role, setup, expected result, actual evidence, result (PASS / FAIL / UNVERIFIED) and defect link. Run with **synthetic** accounts/content and an isolated staging environment.

| ID | Must demonstrate |
| --- | --- |
| SEC-01 | Anonymous cannot read lesson, quiz, progress, employee or media data; public app files contain no confidential text |
| SEC-02 | Learner cannot read another learner's profile, attempts, or progress |
| SEC-03 | Learner cannot change own role, store/site assignment or privileges |
| SEC-04 | Learner cannot insert/update a forged completion or quiz result through API/RPC |
| SEC-05 | Questions API/bundle does not expose correct answers |
| SEC-06 | Learner cannot grade unpublished, retired, unassigned, wrong-scope or stale assessments |
| SEC-07 | Learner cannot bypass prerequisites by direct URL or RPC |
| SEC-08 | Auth/session expiry, logout, disabled account and password reset tested |
| SEC-09 | Maker cannot approve own content; checker cannot edit approved version undetected |
| SEC-10 | Publisher cannot publish without approval of exact revision/hash; unauthorized roles denied |
| SEC-11 | Sensitive transitions are audited and cannot be silently rewritten |
| SEC-12 | Signed/private media access denies unassigned and anonymous users; links expire |
| GOV-01 | Policy source, owner, revision, maker, checker, approver, audience and effective dates present |
| GOV-02 | Revision changes invalidate prior approval; old learner attempt evidence remains |
| GOV-03 | New policy can require recertification without erasing earlier passes |
| LRN-01 | New learner can sign in, see only assigned and published required modules |
| LRN-02 | Progress resumes; duplicate tabs/retries do not fabricate duration/completion |
| LRN-03 | Quiz score/pass persist correctly; fail, retry and coaching work |
| LRN-04 | Real user can finish lesson and return to dashboard on deployed Pages base path |
| PRA-01 | Theory pass alone does not mark practical pass or production authorization |
| PRA-02 | Assessor result records case-set version, evidence, identity and remediation |
| OPS-01 | Supervisor sees appropriate team scope, due/overdue/current state and escalation needs |
| OPS-02 | A changed site rule applies only to intended staff and triggers appropriate updates |
| UX-01 | Mobile/desktop, keyboard navigation, understandable errors, privacy-safe support work |
| DEP-01 | PR checks pass, reviewed SHA is deployed, rollback procedure tested or documented |
| DEP-02 | Live schema, grants and RLS match reviewed migrations, with explicit evidence |
| CONT-01 | Real lesson claims and quiz keys match approved policy; no exposed client footage |

Critical SEC/GOV failures, missing production verification, or absence of independent policy approval block staff rollout. A generic smoke test is not sufficient.

## Report format and decision rule
A checker report must include: exact commit SHA, environment, approach, evidence commands/screenshots (sanitized), all matrix results, defects ranked P0–P3, reproducible steps, unverified items, and separate verdicts for **source code**, **deployed/authenticated system**, **content/policy fidelity**, **employee journey**, and **founder acceptance**.

**PASS:** full required evidence, no critical/high unresolved issues.
**FAIL:** reproducible critical/high issue or required gate violated.
**UNVERIFIED:** missing live access, policy source, test data, or operational evidence. Not interchangeable with PASS.

Founder decides rollout only after independent review and human policy approval.
