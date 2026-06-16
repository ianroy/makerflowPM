@Timeout(Duration(minutes: 4))
library;

import 'package:test/test.dart';
import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/endpoints/task_endpoint.dart';
import 'package:makerflow_server/src/endpoints/trash_endpoint.dart';

import 'test_tools/serverpod_test_tools.dart';

/// The non-RBAC half of the security contract from docs/SECURITY.md, proven live
/// against the test DB (rollback-per-test): the audit trail, soft-delete +
/// trash/restore, optimistic-concurrency conflicts, and tenant-scoped reads.
/// Companion to role_matrix_test.dart. Same harness style: call endpoint
/// classes directly with a built, authenticated Session.
void main() {
  final tasks = TaskEndpoint();
  final trash = TrashEndpoint();

  withServerpod('Security contract — audit / soft-delete / concurrency / tenancy',
      (sessionBuilder, endpoints) {
    Future<int> seedOrgWithMember(int userInfoId, MembershipRole role,
        {String slug = 'acme'}) async {
      final session = sessionBuilder.build();
      final now = DateTime.now().toUtc();
      final org = await Organization.db.insertRow(session,
          Organization(name: 'Acme', slug: slug, createdAt: now, updatedAt: now));
      await Membership.db.insertRow(
        session,
        Membership(
            organizationId: org.id!,
            userInfoId: userInfoId,
            role: role,
            createdAt: now,
            updatedAt: now),
      );
      return org.id!;
    }

    sessionFor(int userInfoId) => sessionBuilder
        .copyWith(
          authentication:
              AuthenticationOverride.authenticationInfo('$userInfoId', {}),
        )
        .build();

    Task draftTask(int orgId, {String title = 'PM the laser'}) => Task(
          organizationId: orgId,
          title: title,
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          sortOrder: 0,
          version: 1,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );

    test('every create writes an org-scoped audit row', () async {
      final orgId = await seedOrgWithMember(100, MembershipRole.staff);
      final task = await tasks.create(sessionFor(100), draftTask(orgId));

      final audits = await AuditLog.db.find(
        sessionBuilder.build(),
        where: (a) =>
            a.organizationId.equals(orgId) & a.entityType.equals('task'),
      );
      expect(audits, hasLength(1));
      expect(audits.first.action, 'create');
      expect(audits.first.actorUserInfoId, 100);
      expect(audits.first.entityId, task.id);
      expect(audits.first.payloadHash, isNotNull); // create hashes its payload
    });

    test('soft-delete hides from list but is restorable via trash', () async {
      final orgId = await seedOrgWithMember(110, MembershipRole.staff);
      final keep = await tasks.create(sessionFor(110), draftTask(orgId, title: 'keep'));
      final gone = await tasks.create(sessionFor(110), draftTask(orgId, title: 'gone'));

      await tasks.softDelete(sessionFor(110), gone.id!);

      // Default reads exclude soft-deleted rows.
      final visible = await tasks.list(sessionFor(110), orgId);
      expect(visible.map((t) => t.id), [keep.id]);

      // ...but the row survives and shows up in the trash queue.
      final deleted = await trash.deletedTasks(sessionFor(110), orgId);
      expect(deleted.map((t) => t.id), [gone.id]);

      // Restore brings it back into the live list.
      await trash.restoreTask(sessionFor(110), gone.id!);
      final afterRestore = await tasks.list(sessionFor(110), orgId);
      expect(afterRestore.map((t) => t.id).toSet(), {keep.id, gone.id});
    });

    test('stale-version update is rejected (optimistic concurrency)', () async {
      final orgId = await seedOrgWithMember(120, MembershipRole.staff);
      final v1 = await tasks.create(sessionFor(120), draftTask(orgId));

      // First update off v1 succeeds and bumps the version.
      final v2 = await tasks.update(sessionFor(120), v1.copyWith(title: 'rev2'));
      expect(v2.version, v1.version + 1);

      // Replaying the now-stale v1 conflicts.
      await expectLater(
        tasks.update(sessionFor(120), v1.copyWith(title: 'stale')),
        throwsA(isA<MakerflowConflictException>()),
      );
    });

    test('reads are tenant-scoped: a member sees only their org', () async {
      final orgA = await seedOrgWithMember(130, MembershipRole.staff, slug: 'org-a');
      final orgB = await seedOrgWithMember(140, MembershipRole.staff, slug: 'org-b');
      await tasks.create(sessionFor(130), draftTask(orgA));
      await tasks.create(sessionFor(130), draftTask(orgA));
      await tasks.create(sessionFor(140), draftTask(orgB));

      final aList = await tasks.list(sessionFor(130), orgA);
      final bList = await tasks.list(sessionFor(140), orgB);
      expect(aList, hasLength(2));
      expect(bList, hasLength(1));
      expect(aList.every((t) => t.organizationId == orgA), isTrue);
    });

    test('mutating a soft-deleted task throws NotFound', () async {
      final orgId = await seedOrgWithMember(150, MembershipRole.staff);
      final task = await tasks.create(sessionFor(150), draftTask(orgId));
      await tasks.softDelete(sessionFor(150), task.id!);
      await expectLater(
        tasks.move(sessionFor(150), task.id!, TaskStatus.inProgress, 1.0),
        throwsA(isA<MakerflowNotFoundException>()),
      );
    });
  });
}
