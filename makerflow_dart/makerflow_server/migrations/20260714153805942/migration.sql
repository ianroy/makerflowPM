BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "project" ADD COLUMN "version" bigint NOT NULL DEFAULT 1;

--
-- MIGRATION VERSION FOR makerflow
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('makerflow', '20260714153805942', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260714153805942', "timestamp" = now();

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
