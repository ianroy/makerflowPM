BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "custom_view" ADD COLUMN "viewType" text NOT NULL DEFAULT 'table'::text;

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
