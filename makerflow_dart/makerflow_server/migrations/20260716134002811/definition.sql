BEGIN;

--
-- Class Attachment as table attachment
--
CREATE TABLE "attachment" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "entityType" text NOT NULL,
    "entityId" bigint NOT NULL,
    "kind" text NOT NULL DEFAULT 'other'::text,
    "filename" text NOT NULL,
    "contentType" text NOT NULL,
    "bytes" bigint NOT NULL,
    "storageKey" text NOT NULL,
    "altText" text,
    "createdAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "attachment_entity_idx" ON "attachment" USING btree ("organizationId", "entityType", "entityId");

--
-- Class AuditLog as table audit_log
--
CREATE TABLE "audit_log" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "actorUserInfoId" bigint,
    "entityType" text NOT NULL,
    "entityId" bigint,
    "action" text NOT NULL,
    "payloadHash" text,
    "summary" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "audit_org_idx" ON "audit_log" USING btree ("organizationId");
CREATE INDEX "audit_entity_idx" ON "audit_log" USING btree ("organizationId", "entityType", "entityId");

--
-- Class CalendarEvent as table calendar_event
--
CREATE TABLE "calendar_event" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "title" text NOT NULL,
    "startAt" timestamp without time zone NOT NULL,
    "endAt" timestamp without time zone,
    "source" text NOT NULL DEFAULT 'manual'::text,
    "externalId" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "calendar_event_org_idx" ON "calendar_event" USING btree ("organizationId");
CREATE INDEX "calendar_event_external_idx" ON "calendar_event" USING btree ("organizationId", "externalId");

--
-- Class CalendarSyncLink as table calendar_sync_link
--
CREATE TABLE "calendar_sync_link" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "taskId" bigint NOT NULL,
    "externalEventId" text NOT NULL,
    "lastPushedAt" timestamp without time zone,
    "lastPulledAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "calendar_sync_link_task_idx" ON "calendar_sync_link" USING btree ("organizationId", "taskId");
CREATE INDEX "calendar_sync_link_external_idx" ON "calendar_sync_link" USING btree ("organizationId", "externalEventId");

--
-- Class CalendarSyncSetting as table calendar_sync_setting
--
CREATE TABLE "calendar_sync_setting" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "userInfoId" bigint NOT NULL,
    "calendarId" text NOT NULL DEFAULT 'primary'::text,
    "refreshTokenEnc" text,
    "enabled" boolean NOT NULL DEFAULT false,
    "lastSyncedAt" timestamp without time zone,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "calendar_sync_setting_unique_idx" ON "calendar_sync_setting" USING btree ("organizationId", "userInfoId");

--
-- Class Consumable as table consumable
--
CREATE TABLE "consumable" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "unit" text,
    "quantityOnHand" double precision NOT NULL DEFAULT 0,
    "reorderPoint" double precision NOT NULL DEFAULT 0,
    "status" text NOT NULL DEFAULT 'inStock'::text,
    "spaceId" bigint,
    "category" text,
    "clientUuid" text,
    "version" bigint NOT NULL DEFAULT 1,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "consumable_org_idx" ON "consumable" USING btree ("organizationId");
CREATE INDEX "consumable_status_idx" ON "consumable" USING btree ("organizationId", "status");

--
-- Class CustomView as table custom_view
--
CREATE TABLE "custom_view" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "ownerUserInfoId" bigint NOT NULL,
    "name" text NOT NULL,
    "entityType" text NOT NULL,
    "viewType" text NOT NULL DEFAULT 'table'::text,
    "filtersJson" text NOT NULL,
    "columnsJson" text NOT NULL,
    "isShared" boolean NOT NULL DEFAULT false,
    "version" bigint NOT NULL DEFAULT 1,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "custom_view_org_idx" ON "custom_view" USING btree ("organizationId");
CREATE INDEX "custom_view_owner_idx" ON "custom_view" USING btree ("organizationId", "ownerUserInfoId");

--
-- Class DeviceToken as table device_token
--
CREATE TABLE "device_token" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "token" text NOT NULL,
    "platform" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "lastSeenAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "device_token_unique_idx" ON "device_token" USING btree ("token");
CREATE INDEX "device_token_user_idx" ON "device_token" USING btree ("userInfoId");

--
-- Class EmailMessage as table email_message
--
CREATE TABLE "email_message" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint,
    "toAddress" text NOT NULL,
    "subject" text NOT NULL,
    "status" text NOT NULL DEFAULT 'queued'::text,
    "error" text,
    "sentAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "email_message_org_idx" ON "email_message" USING btree ("organizationId");

--
-- Class EquipmentAsset as table equipment_asset
--
CREATE TABLE "equipment_asset" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "assetTag" text,
    "status" text NOT NULL DEFAULT 'operational'::text,
    "spaceId" bigint,
    "certificationRequired" boolean NOT NULL DEFAULT false,
    "lastMaintenanceAt" timestamp without time zone,
    "nextMaintenanceAt" timestamp without time zone,
    "notes" text,
    "clientUuid" text,
    "version" bigint NOT NULL DEFAULT 1,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "equipment_asset_org_idx" ON "equipment_asset" USING btree ("organizationId");
CREATE INDEX "equipment_asset_status_idx" ON "equipment_asset" USING btree ("organizationId", "status");

--
-- Class FieldConfig as table field_config
--
CREATE TABLE "field_config" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "entityType" text NOT NULL,
    "key" text NOT NULL,
    "label" text NOT NULL,
    "fieldType" text NOT NULL,
    "optionsJson" text,
    "required" boolean NOT NULL DEFAULT false,
    "sortOrder" double precision NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "field_config_unique_idx" ON "field_config" USING btree ("organizationId", "entityType", "key");

--
-- Class InsightSnapshot as table insight_snapshot
--
CREATE TABLE "insight_snapshot" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "metricKey" text NOT NULL,
    "value" double precision NOT NULL,
    "capturedAt" timestamp without time zone NOT NULL,
    "dimensionsJson" text
);

-- Indexes
CREATE INDEX "insight_snapshot_org_idx" ON "insight_snapshot" USING btree ("organizationId", "metricKey", "capturedAt");

--
-- Class IntakeRequest as table intake_request
--
CREATE TABLE "intake_request" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "title" text NOT NULL,
    "description" text,
    "stage" text NOT NULL DEFAULT 'submitted'::text,
    "score" double precision,
    "requesterName" text,
    "requesterEmail" text,
    "convertedProjectId" bigint,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "intake_request_org_idx" ON "intake_request" USING btree ("organizationId");
CREATE INDEX "intake_request_stage_idx" ON "intake_request" USING btree ("organizationId", "stage");

--
-- Class ItemComment as table item_comment
--
CREATE TABLE "item_comment" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "entityType" text NOT NULL,
    "entityId" bigint NOT NULL,
    "parentCommentId" bigint,
    "body" text NOT NULL,
    "clientUuid" text,
    "version" bigint NOT NULL DEFAULT 1,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "item_comment_org_idx" ON "item_comment" USING btree ("organizationId");
CREATE INDEX "item_comment_entity_idx" ON "item_comment" USING btree ("organizationId", "entityType", "entityId");

--
-- Class ItemWatcher as table item_watcher
--
CREATE TABLE "item_watcher" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "entityType" text NOT NULL,
    "entityId" bigint NOT NULL,
    "userInfoId" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "item_watcher_unique_idx" ON "item_watcher" USING btree ("organizationId", "entityType", "entityId", "userInfoId");
CREATE INDEX "item_watcher_entity_idx" ON "item_watcher" USING btree ("organizationId", "entityType", "entityId");

--
-- Class MeetingAgenda as table meeting_agenda
--
CREATE TABLE "meeting_agenda" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "title" text NOT NULL,
    "meetingAt" timestamp without time zone,
    "status" text NOT NULL DEFAULT 'draft'::text,
    "ownerUserInfoId" bigint,
    "teamId" bigint,
    "spaceId" bigint,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "meeting_agenda_org_idx" ON "meeting_agenda" USING btree ("organizationId");

--
-- Class MeetingItem as table meeting_item
--
CREATE TABLE "meeting_item" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "agendaId" bigint NOT NULL,
    "parentItemId" bigint,
    "title" text NOT NULL,
    "notes" text,
    "status" text NOT NULL DEFAULT 'open'::text,
    "linkedTaskId" bigint,
    "linkedProjectId" bigint,
    "sortOrder" double precision NOT NULL DEFAULT 0,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "meeting_item_agenda_idx" ON "meeting_item" USING btree ("organizationId", "agendaId");

--
-- Class MeetingItemNote as table meeting_item_note
--
CREATE TABLE "meeting_item_note" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "itemId" bigint NOT NULL,
    "body" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "meeting_item_note_item_idx" ON "meeting_item_note" USING btree ("organizationId", "itemId");

--
-- Class MeetingNoteSource as table meeting_note_source
--
CREATE TABLE "meeting_note_source" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "agendaId" bigint,
    "calendarEventId" bigint,
    "sourceKind" text NOT NULL,
    "rawJson" text,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "meeting_note_source_org_idx" ON "meeting_note_source" USING btree ("organizationId");

--
-- Class Membership as table membership
--
CREATE TABLE "membership" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "userInfoId" bigint NOT NULL,
    "role" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "membership_unique_idx" ON "membership" USING btree ("organizationId", "userInfoId");
CREATE INDEX "membership_user_idx" ON "membership" USING btree ("userInfoId");

--
-- Class OnboardingAssignment as table onboarding_assignment
--
CREATE TABLE "onboarding_assignment" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "templateId" bigint NOT NULL,
    "assigneeUserInfoId" bigint NOT NULL,
    "state" text NOT NULL DEFAULT 'notStarted'::text,
    "progressJson" text,
    "dueAt" timestamp without time zone,
    "completedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "onboarding_assignment_org_idx" ON "onboarding_assignment" USING btree ("organizationId");
CREATE INDEX "onboarding_assignment_assignee_idx" ON "onboarding_assignment" USING btree ("organizationId", "assigneeUserInfoId");

--
-- Class OnboardingTemplate as table onboarding_template
--
CREATE TABLE "onboarding_template" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "forRole" text,
    "itemsJson" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "onboarding_template_org_idx" ON "onboarding_template" USING btree ("organizationId");

--
-- Class Organization as table organization
--
CREATE TABLE "organization" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "slug" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "organization_slug_idx" ON "organization" USING btree ("slug");

--
-- Class Partnership as table partnership
--
CREATE TABLE "partnership" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "stage" text NOT NULL DEFAULT 'prospect'::text,
    "contactName" text,
    "contactEmail" text,
    "health" text,
    "nextFollowUpAt" timestamp without time zone,
    "notes" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "partnership_org_idx" ON "partnership" USING btree ("organizationId");
CREATE INDEX "partnership_stage_idx" ON "partnership" USING btree ("organizationId", "stage");

--
-- Class PasswordReset as table password_reset
--
CREATE TABLE "password_reset" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "token" text NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL,
    "usedAt" timestamp without time zone,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "password_reset_token_idx" ON "password_reset" USING btree ("token");

--
-- Class Project as table project
--
CREATE TABLE "project" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "lane" text,
    "status" text NOT NULL,
    "priority" text NOT NULL,
    "ownerUserInfoId" bigint,
    "teamId" bigint,
    "spaceId" bigint,
    "version" bigint NOT NULL DEFAULT 1,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "project_org_idx" ON "project" USING btree ("organizationId");
CREATE INDEX "project_org_status_idx" ON "project" USING btree ("organizationId", "status");

--
-- Class ReportTemplate as table report_template
--
CREATE TABLE "report_template" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "configJson" text NOT NULL,
    "visibility" text NOT NULL DEFAULT 'org'::text,
    "ownerUserInfoId" bigint,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "report_template_org_idx" ON "report_template" USING btree ("organizationId");

--
-- Class RoleNavPreference as table role_nav_preference
--
CREATE TABLE "role_nav_preference" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "role" text NOT NULL,
    "navJson" text NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "role_nav_preference_unique_idx" ON "role_nav_preference" USING btree ("organizationId", "role");

--
-- Class Space as table space
--
CREATE TABLE "space" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "space_org_idx" ON "space" USING btree ("organizationId");

--
-- Class SyncCursor as table sync_cursor
--
CREATE TABLE "sync_cursor" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "userInfoId" bigint NOT NULL,
    "deviceId" text NOT NULL,
    "lastUpdatedAt" timestamp without time zone NOT NULL,
    "lastId" bigint NOT NULL DEFAULT 0,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "sync_cursor_unique_idx" ON "sync_cursor" USING btree ("organizationId", "userInfoId", "deviceId");

--
-- Class Task as table task
--
CREATE TABLE "task" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "projectId" bigint,
    "title" text NOT NULL,
    "description" text,
    "status" text NOT NULL,
    "priority" text NOT NULL,
    "assigneeUserInfoId" bigint,
    "reporterUserInfoId" bigint,
    "energy" text,
    "estimateHours" double precision,
    "dueAt" timestamp without time zone,
    "spaceId" bigint,
    "teamId" bigint,
    "sortOrder" double precision NOT NULL DEFAULT 0,
    "customFieldsJson" text,
    "version" bigint NOT NULL DEFAULT 1,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "createdByUserInfoId" bigint,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "task_org_idx" ON "task" USING btree ("organizationId");
CREATE INDEX "task_org_status_idx" ON "task" USING btree ("organizationId", "status");
CREATE INDEX "task_org_assignee_idx" ON "task" USING btree ("organizationId", "assigneeUserInfoId");

--
-- Class Team as table team
--
CREATE TABLE "team" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL,
    "deletedAt" timestamp without time zone,
    "deletedByUserInfoId" bigint
);

-- Indexes
CREATE INDEX "team_org_idx" ON "team" USING btree ("organizationId");

--
-- Class TeamMember as table team_member
--
CREATE TABLE "team_member" (
    "id" bigserial PRIMARY KEY,
    "organizationId" bigint NOT NULL,
    "teamId" bigint NOT NULL,
    "userInfoId" bigint NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "team_member_unique_idx" ON "team_member" USING btree ("teamId", "userInfoId");
CREATE INDEX "team_member_org_idx" ON "team_member" USING btree ("organizationId");

--
-- Class UserPreference as table user_preference
--
CREATE TABLE "user_preference" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "theme" text NOT NULL DEFAULT 'dark'::text,
    "locale" text NOT NULL DEFAULT 'en'::text,
    "timezone" text,
    "notificationsJson" text,
    "sessionTimeoutSeconds" bigint,
    "uiJson" text,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_preference_unique_idx" ON "user_preference" USING btree ("userInfoId");

--
-- Class UserProfile as table user_profile
--
CREATE TABLE "user_profile" (
    "id" bigserial PRIMARY KEY,
    "userInfoId" bigint NOT NULL,
    "displayName" text,
    "title" text,
    "avatarAttachmentId" bigint,
    "isActive" boolean NOT NULL DEFAULT true,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_profile_unique_idx" ON "user_profile" USING btree ("userInfoId");

--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "addedTime" timestamp without time zone NOT NULL,
    "expiration" timestamp without time zone,
    "byteData" bytea NOT NULL,
    "verified" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" USING btree ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" USING btree ("expiration");

--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" bigserial PRIMARY KEY,
    "storageId" text NOT NULL,
    "path" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL,
    "authKey" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" USING btree ("storageId", "path");

--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "serializedObject" text,
    "serverId" text NOT NULL,
    "identifier" text
);

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" USING btree ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" USING btree ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" USING btree ("identifier");

--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "active" bigint NOT NULL,
    "closing" bigint NOT NULL,
    "idle" bigint NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" USING btree ("timestamp", "serverId", "granularity");

--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "serverId" text NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    "isHealthy" boolean NOT NULL,
    "value" double precision NOT NULL,
    "granularity" bigint NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" USING btree ("timestamp", "serverId", "name", "granularity");

--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "reference" text,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "logLevel" bigint NOT NULL,
    "message" text NOT NULL,
    "error" text,
    "stackTrace" text,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" USING btree ("sessionLogId");

--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" bigserial PRIMARY KEY,
    "sessionLogId" bigint NOT NULL,
    "serverId" text NOT NULL,
    "messageId" bigint NOT NULL,
    "endpoint" text NOT NULL,
    "messageName" text NOT NULL,
    "duration" double precision NOT NULL,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" bigserial PRIMARY KEY,
    "endpoint" text NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" USING btree ("endpoint", "method");

--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" bigserial PRIMARY KEY,
    "module" text NOT NULL,
    "version" text NOT NULL,
    "timestamp" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" USING btree ("module");

--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "sessionLogId" bigint NOT NULL,
    "messageId" bigint,
    "query" text NOT NULL,
    "duration" double precision NOT NULL,
    "numRows" bigint,
    "error" text,
    "stackTrace" text,
    "slow" boolean NOT NULL,
    "order" bigint NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" USING btree ("sessionLogId");

--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" bigserial PRIMARY KEY,
    "number" bigint NOT NULL
);

--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" bigserial PRIMARY KEY,
    "logSettings" json NOT NULL,
    "logSettingsOverrides" json NOT NULL,
    "logServiceCalls" boolean NOT NULL,
    "logMalformedCalls" boolean NOT NULL
);

--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" bigserial PRIMARY KEY,
    "serverId" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "module" text,
    "endpoint" text,
    "method" text,
    "duration" double precision,
    "numQueries" bigint,
    "slow" boolean,
    "error" text,
    "stackTrace" text,
    "authenticatedUserId" bigint,
    "userId" text,
    "isOpen" boolean,
    "touched" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" USING btree ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" USING btree ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" USING btree ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" USING btree ("isOpen");

--
-- Class AuthKey as table serverpod_auth_key
--
CREATE TABLE "serverpod_auth_key" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "hash" text NOT NULL,
    "scopeNames" json NOT NULL,
    "method" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_auth_key_userId_idx" ON "serverpod_auth_key" USING btree ("userId");

--
-- Class EmailAuth as table serverpod_email_auth
--
CREATE TABLE "serverpod_email_auth" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "email" text NOT NULL,
    "hash" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_auth_email" ON "serverpod_email_auth" USING btree ("email");

--
-- Class EmailCreateAccountRequest as table serverpod_email_create_request
--
CREATE TABLE "serverpod_email_create_request" (
    "id" bigserial PRIMARY KEY,
    "userName" text NOT NULL,
    "email" text NOT NULL,
    "hash" text NOT NULL,
    "verificationCode" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_auth_create_account_request_idx" ON "serverpod_email_create_request" USING btree ("email");

--
-- Class EmailFailedSignIn as table serverpod_email_failed_sign_in
--
CREATE TABLE "serverpod_email_failed_sign_in" (
    "id" bigserial PRIMARY KEY,
    "email" text NOT NULL,
    "time" timestamp without time zone NOT NULL,
    "ipAddress" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_email_failed_sign_in_email_idx" ON "serverpod_email_failed_sign_in" USING btree ("email");
CREATE INDEX "serverpod_email_failed_sign_in_time_idx" ON "serverpod_email_failed_sign_in" USING btree ("time");

--
-- Class EmailReset as table serverpod_email_reset
--
CREATE TABLE "serverpod_email_reset" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "verificationCode" text NOT NULL,
    "expiration" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_email_reset_verification_idx" ON "serverpod_email_reset" USING btree ("verificationCode");

--
-- Class GoogleRefreshToken as table serverpod_google_refresh_token
--
CREATE TABLE "serverpod_google_refresh_token" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "refreshToken" text NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_google_refresh_token_userId_idx" ON "serverpod_google_refresh_token" USING btree ("userId");

--
-- Class UserImage as table serverpod_user_image
--
CREATE TABLE "serverpod_user_image" (
    "id" bigserial PRIMARY KEY,
    "userId" bigint NOT NULL,
    "version" bigint NOT NULL,
    "url" text NOT NULL
);

-- Indexes
CREATE INDEX "serverpod_user_image_user_id" ON "serverpod_user_image" USING btree ("userId", "version");

--
-- Class UserInfo as table serverpod_user_info
--
CREATE TABLE "serverpod_user_info" (
    "id" bigserial PRIMARY KEY,
    "userIdentifier" text NOT NULL,
    "userName" text,
    "fullName" text,
    "email" text,
    "created" timestamp without time zone NOT NULL,
    "imageUrl" text,
    "scopeNames" json NOT NULL,
    "blocked" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "serverpod_user_info_user_identifier" ON "serverpod_user_info" USING btree ("userIdentifier");
CREATE INDEX "serverpod_user_info_email" ON "serverpod_user_info" USING btree ("email");

--
-- Foreign relations for "attachment" table
--
ALTER TABLE ONLY "attachment"
    ADD CONSTRAINT "attachment_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "calendar_event" table
--
ALTER TABLE ONLY "calendar_event"
    ADD CONSTRAINT "calendar_event_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "calendar_sync_link" table
--
ALTER TABLE ONLY "calendar_sync_link"
    ADD CONSTRAINT "calendar_sync_link_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "calendar_sync_link"
    ADD CONSTRAINT "calendar_sync_link_fk_1"
    FOREIGN KEY("taskId")
    REFERENCES "task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "calendar_sync_setting" table
--
ALTER TABLE ONLY "calendar_sync_setting"
    ADD CONSTRAINT "calendar_sync_setting_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "consumable" table
--
ALTER TABLE ONLY "consumable"
    ADD CONSTRAINT "consumable_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "custom_view" table
--
ALTER TABLE ONLY "custom_view"
    ADD CONSTRAINT "custom_view_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "equipment_asset" table
--
ALTER TABLE ONLY "equipment_asset"
    ADD CONSTRAINT "equipment_asset_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "field_config" table
--
ALTER TABLE ONLY "field_config"
    ADD CONSTRAINT "field_config_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "insight_snapshot" table
--
ALTER TABLE ONLY "insight_snapshot"
    ADD CONSTRAINT "insight_snapshot_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "intake_request" table
--
ALTER TABLE ONLY "intake_request"
    ADD CONSTRAINT "intake_request_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "item_comment" table
--
ALTER TABLE ONLY "item_comment"
    ADD CONSTRAINT "item_comment_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "item_watcher" table
--
ALTER TABLE ONLY "item_watcher"
    ADD CONSTRAINT "item_watcher_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "meeting_agenda" table
--
ALTER TABLE ONLY "meeting_agenda"
    ADD CONSTRAINT "meeting_agenda_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "meeting_item" table
--
ALTER TABLE ONLY "meeting_item"
    ADD CONSTRAINT "meeting_item_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "meeting_item"
    ADD CONSTRAINT "meeting_item_fk_1"
    FOREIGN KEY("agendaId")
    REFERENCES "meeting_agenda"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "meeting_item_note" table
--
ALTER TABLE ONLY "meeting_item_note"
    ADD CONSTRAINT "meeting_item_note_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "meeting_item_note"
    ADD CONSTRAINT "meeting_item_note_fk_1"
    FOREIGN KEY("itemId")
    REFERENCES "meeting_item"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "meeting_note_source" table
--
ALTER TABLE ONLY "meeting_note_source"
    ADD CONSTRAINT "meeting_note_source_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "membership" table
--
ALTER TABLE ONLY "membership"
    ADD CONSTRAINT "membership_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "onboarding_assignment" table
--
ALTER TABLE ONLY "onboarding_assignment"
    ADD CONSTRAINT "onboarding_assignment_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "onboarding_assignment"
    ADD CONSTRAINT "onboarding_assignment_fk_1"
    FOREIGN KEY("templateId")
    REFERENCES "onboarding_template"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "onboarding_template" table
--
ALTER TABLE ONLY "onboarding_template"
    ADD CONSTRAINT "onboarding_template_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "partnership" table
--
ALTER TABLE ONLY "partnership"
    ADD CONSTRAINT "partnership_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "project" table
--
ALTER TABLE ONLY "project"
    ADD CONSTRAINT "project_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "report_template" table
--
ALTER TABLE ONLY "report_template"
    ADD CONSTRAINT "report_template_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "role_nav_preference" table
--
ALTER TABLE ONLY "role_nav_preference"
    ADD CONSTRAINT "role_nav_preference_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "space" table
--
ALTER TABLE ONLY "space"
    ADD CONSTRAINT "space_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "sync_cursor" table
--
ALTER TABLE ONLY "sync_cursor"
    ADD CONSTRAINT "sync_cursor_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "task" table
--
ALTER TABLE ONLY "task"
    ADD CONSTRAINT "task_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "task"
    ADD CONSTRAINT "task_fk_1"
    FOREIGN KEY("projectId")
    REFERENCES "project"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "team" table
--
ALTER TABLE ONLY "team"
    ADD CONSTRAINT "team_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "team_member" table
--
ALTER TABLE ONLY "team_member"
    ADD CONSTRAINT "team_member_fk_0"
    FOREIGN KEY("organizationId")
    REFERENCES "organization"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "team_member"
    ADD CONSTRAINT "team_member_fk_1"
    FOREIGN KEY("teamId")
    REFERENCES "team"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_log" table
--
ALTER TABLE ONLY "serverpod_log"
    ADD CONSTRAINT "serverpod_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_message_log" table
--
ALTER TABLE ONLY "serverpod_message_log"
    ADD CONSTRAINT "serverpod_message_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;

--
-- Foreign relations for "serverpod_query_log" table
--
ALTER TABLE ONLY "serverpod_query_log"
    ADD CONSTRAINT "serverpod_query_log_fk_0"
    FOREIGN KEY("sessionLogId")
    REFERENCES "serverpod_session_log"("id")
    ON DELETE CASCADE
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR makerflow
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('makerflow', '20260716134002811', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260716134002811', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth', '20260129181059877', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181059877', "timestamp" = now();


COMMIT;
