# Decision Log

This file records high-impact architectural and product decisions with rationale.

## 2026-02-16: Keep stdlib-first Python backend + SQLite

- Decision: Continue with a lightweight WSGI + SQLite architecture.
- Why:
  - Lowest deploy complexity for university/department IT constraints.
  - Works on low-cost hosts with minimal ops overhead.
  - Easy local development and troubleshooting.
- Tradeoff:
  - Large single-file backend requires stronger documentation discipline.
  - High-concurrency deployments will need a future PostgreSQL path.

## 2026-02-16: Server-rendered HTML with progressive JS enhancements

- Decision: Keep server-rendered pages as canonical UI output.
- Why:
  - Better resilience if JS fails.
  - Predictable first render and simpler accessibility baseline.
  - Easier incremental feature rollout without SPA rewrite.
- Tradeoff:
  - Some UI interactions require careful bridge code between HTML and JS.

## 2026-02-16: Role split between `workspace_admin` and `owner`

- Decision: Introduce dedicated `workspace_admin` role and retain `owner` for higher governance.
- Why:
  - Matches operational reality: workspace admins manage one department.
  - Keeps top-level provisioning permissions constrained to owner/superuser.
  - Reduces accidental privilege escalation across workspaces.
- Tradeoff:
  - Additional role increases permission matrix complexity.

## 2026-02-16: Non-superuser admin accounts constrained to one workspace

- Decision: Enforce one-workspace admin control for non-superusers.
- Why:
  - Clear accountability per department.
  - Reduced blast radius if an admin account is compromised.
  - Simpler governance model for multi-department deployments.
- Tradeoff:
  - Staff serving many departments may need separate non-admin memberships or superuser oversight.

## 2026-02-16: CSV import/export as first-class portability contract

- Decision: Keep CSV export/import pathways for core entities.
- Why:
  - Supports institutional portability and vendor exit requirements.
  - Eases integrations with spreadsheet-heavy operational workflows.
- Tradeoff:
  - CSV schema needs backward-compatible maintenance as features evolve.

## 2026-02-16: Harden admin and mutation routes with explicit authorization boundaries

- Decision: Enforce stricter role gates and target-account protections for admin operations and high-impact write routes.
- Why:
  - Prevent workspace admins from managing owner/superuser accounts.
  - Reduce accidental or malicious cross-role privilege escalation.
  - Keep read-heavy roles from mutating operational data unexpectedly.
- Tradeoff:
  - Fewer users can access import/export and certain mutation paths by default.
  - Administrators may need role adjustments to complete migration/data tasks.

## 2026-02-16: Add comprehensive in-process feature/security simulation suite

- Decision: Add `scripts/comprehensive_feature_security_test.py` as a release gate.
- Why:
  - Validates interfaces and permissions under realistic multi-user collaboration.
  - Catches regressions in authz, CSRF behavior, and route wiring.
  - Provides a repeatable report artifact for QA and maintenance.
- Tradeoff:
  - Longer runtime than smoke/usability/a11y checks.
