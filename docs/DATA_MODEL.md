# Data Model Overview

Core multi-tenant entities:

- `organizations`: department workspaces.
- `users`: platform accounts.
- `memberships`: user role per organization.
- `sessions`: secure server-side login sessions.

Membership roles (least to most privileged):

- `viewer`
- `student`
- `staff`
- `manager`
- `workspace_admin` (workspace account admin)
- `owner` (workspace provisioning + owner-level governance)

Project management:

- `projects`: portfolio units under lanes.
- `tasks`: staff/student execution items.
- `custom_views`: saved and shared filters/columns.
- `field_configs`: customizable field definitions.
- `item_comments`: threaded comments for project/task collaboration.

Operations and meetings:

- `meeting_agendas` / `meeting_items`: tactical meeting structure.
- `intake_requests`: scored intake queue.
- `equipment_assets`: maintenance and certification tracking.
- `consumables`: per-space stock and reorder tracking.
- `partnerships`: external/internal relationship pipeline.

People enablement:

- `onboarding_templates`: role-based onboarding checklists.
- `onboarding_assignments`: assigned onboarding tasks.
- `user_preferences`: UI/workflow settings.
- `role_nav_preferences`: role-level sidebar defaults.

Analytics and governance:

- `calendar_events`: imported schedule records for trend analysis.
- `calendar_sync_settings`: per-user Google Calendar sync config.
- `calendar_sync_links`: mapping between MakerFlow tasks and Google events.
- `insight_snapshots`: seeded baseline metrics from reports.
- `audit_log`: action trace for accountability and security.

Deletion model:

- Core operational entities (`projects`, `tasks`, `intake_requests`, `equipment_assets`, `consumables`, `partnerships`) are soft-deleted first.
- Soft-delete fields:
  - `deleted_at`
  - `deleted_by_user_id`
- Permanent purge happens from the deleted queue or admin cleanup workflows.
