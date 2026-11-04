# Agile Minds LMS — Maker–Checker & Publication Contract

Status: proposed governance design for independent review. No authorization to publish company policies or change production data is implied.

## Why this exists
The present code offers authentication, a private `lesson_content` table, server-side quiz grading, and learner progress. A one-bit `is_published` flag is **not** a maker/checker workflow. The goal is to prevent unchecked content and unverified functionality from becoming operationally authoritative.

## Provenance and assignment of agents
- **Original application:** built initially by Codex, per founder handover. Codex must not independently certify its own baseline.
- **Initial independent baseline checker:** Claude in a review-only session, including independent review of this governance draft PR.
- **Subsequent implementation maker:** Claude Code, in a separate implementation session after review and founder prioritization.
- **Subsequent checker of Claude implementation:** a person or separate, clean-context reviewer session with no authorship or implementation involvement in the reviewed change. Another Claude session may supply independent technical challenge, but do not misrepresent same-account GitHub approval as independent actor enforcement; a human reviewer should approve protected merges.
- **Founder:** final policy and release authority. No automatic approval or role switch based on brand or tool.

Review independence is determined for each **specific change**. A session that authored a commit cannot independently check that same commit. For a reviewer who later becomes Maker, any new Maker commits need an unrelated reviewer; the earlier baseline review does not cover the new work.

## Actor boundaries

| Actor | May do | Must not do |
| --- | --- | --- |
| Learner | Read assigned, approved lessons; attempt approved assessments; view own records | Create passes, read other learners, see secret answers, bypass assignment |
| Content maker | Draft lesson/assessment revisions from approved sources | Approve or publish own revisions |
| Independent content checker | Verify source fidelity, answers, scenarios, scope, pass marks, readability and applicability | Edit then approve their own revision, bypass policy owner |
| Policy owner / authorized publisher | Approve policy authority and publish after independent check | Treat unpublished or disputed draft as live policy |
| Supervisor / practical assessor | Evaluate labelled practical exercises and document evidence | Self-certify or change historical evidence silently |
| System administrator | Configure users, scopes, role assignment, incidents, backups | Override approval trails without an auditable break-glass procedure |
| Software maker | Code, document, add tests and migrations in a PR | Merge, change production data, or attest to own independence |
| Independent software checker | Inspect code/security/journeys and issue documented verdict | Repair the same change and still represent its review as independent |
| Founder / release authority | Resolve conflicts and authorize production rollout | Rely on a green build alone for competency or compliance claims |

A single human can hold more than one job title, but the application must prevent the **same actor** making and checking the same content revision, and forbid same-actor approval and publication when separation is required by the approved policy.

## Content source and revision lifecycle
**Notion** is the authoring/source-of-truth workspace for manuals and SOPs, subject to access and document owner verification. The LMS consumes only **approved versioned snapshots** after explicit review. Do not auto-publish when a Notion page changes.

Proposed states:
`draft -> submitted_for_review -> changes_requested | approved -> published -> superseded -> archived`

Store immutable revision metadata: module ID; revision ID; private source reference; source revision or snapshot checksum; content hash; policy owner; scope (role/client/site, where authorized); effective date; assessment version; proposed threshold; maker ID/time; checker ID/time; approval decision/reason/time; publisher ID/time; published/retired timestamps. Keep content and answer keys private; record only hashes/metadata in public software change logs.

Rules to implement in backend transaction/RLS/RPC:
1. Changes to approved content create a **new revision**, never overwrite the evidence of past assessment.
2. A reviewer cannot approve a revision they created or materially edited. Approval is invalidated when the content or questions change.
3. Publisher cannot publish without a valid independent approval of that exact immutable hash, policy-owner approval, and explicit audience/scope.
4. Learners see only revisions that are published, current for their assignment, and authorized for their scope.
5. No old generic leaked quiz answers are reused. Correct answers never appear in public client files.
6. Attempts, completions, and certifications reference the **exact content and assessment versions**; history survives revision and retirement.
7. Critical changes can trigger a re-assessment campaign without silently deleting historical passes.
8. All sensitive transitions append to an audit log (actor, action, before/after IDs or hashes, time, reason); corrections append new evidence.
9. Draft previews and QA media are restricted. Removing public URLs is necessary but insufficient: direct API calls and storage policies must also deny unauthorized access.
10. Store/site applicability is an explicit assignment, not a user-controlled slug, path, or query parameter.

### Avoid a fragile migration
Current `lesson_content` has one row per module and `is_published`; current `progress` and `quiz_attempts` are not version-bound. Maker must first propose additive migration and backfill strategy. Checker must verify historic data retention, duplicate-request/idempotency handling, and safe rollback. Do not run destructive SQL on live Supabase.

## Learning and certification
Separate evidence states:
- Assigned / not started / in progress (browser time is advisory)
- Knowledge quiz attempted / knowledge passed (threshold tied to approved version)
- Practical assessment pending / passed / failed / supervised remediation
- Customer/site-specific **authorized for production** (requires independent practical check and appropriate approval)
- Expired / revoked / recertification required

Passing theory never automatically grants live OPDB/customer-system access. Record a deliberate authorization decision and enforce it in whichever system controls access; the LMS badge alone is not access control. Practical cases must have approved ground truth, independent reviewer agreement for ambiguous cases, consent/use rights, and secure delivery. No production/customer videos in this public repository.

## Product baseline and source conflicts
The founder-supplied June 2026 manual includes a theory threshold, practical accuracy requirement, ongoing QA standard, and operational conduct requirements. These are **source text pending verification**, not a license to change employment terms or publish policy. Check employment, leave, discipline, data protection and customer-specific rules with responsible human owners before release. Where a proposed engineering threshold conflicts with the manual, use the approved source or flag unresolved, rather than silently substituting a value.

## Release record template
- Change ID / PR / exact head SHA:
- Policy source and owner / source revision:
- Modules / audience / customer/site scope:
- Maker identity:
- Independent checker identity and verdict:
- Human policy approval reference:
- Tests run (command, environment, output/evidence):
- Live Supabase grant/RLS/function verification:
- Data migration preview and rollback:
- Security/privacy issues (including unresolved):
- Published code SHA / content revision / assessment revision:
- Founder approval and timestamp:
- Post-release smoke test / reversal trigger:

No verified approval record = no publication. No release approval = no merge/deploy.
