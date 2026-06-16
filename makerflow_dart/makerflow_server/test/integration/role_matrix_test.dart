@Timeout(Duration(minutes: 4))
library;

import 'package:test/test.dart';
import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/endpoints/task_endpoint.dart';
import 'package:makerflow_server/src/endpoints/org_endpoint.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Live RBAC + tenancy integration tests — the Dart port of the Python
/// `scripts/comprehensive_feature_security_test.py`, run against the test DB
/// with rollback-per-test. Asserts the contract in docs/SECURITY.md.
///
/// We use `withServerpod` for the DB + rollback + session harness, but call the
/// endpoint classes directly (Serverpod 3.4's test-tools generator only wraps
/// streaming endpoints here, so `endpoints.task` etc. aren't generated).
void main() {
  final tasks = TaskEndpoint();
  final orgs = OrgEndpoint();

  withServerpod('Role matrix + tenancy', (sessionBuilder, endpoints) {
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

    // A built Session authenticated as [userInfoId] (override bypasses the auth
    // handler; userIdentifier maps to AuthIdentity.requireUserInfoId).
    sessionFor(int userInfoId) => sessionBuilder
        .copyWith(
          authentication:
              AuthenticationOverride.authenticationInfo('$userInfoId', {}),
        )
        .build();

    Task draftTask(int orgId) => Task(
          organizationId: orgId,
          title: 'PM the laser',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          sortOrder: 0,
          version: 1,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );

    test('staff CAN create a task', () async {
      final orgId = await seedOrgWithMember(100, MembershipRole.staff);
      final task = await tasks.create(sessionFor(100), draftTask(orgId));
      expect(task.id, isNotNull);
      expect(task.title, 'PM the laser');
    });

    test('viewer CANNOT create a task (Forbidden)', () async {
      final orgId = await seedOrgWithMember(200, MembershipRole.viewer);
      await expectLater(
        tasks.create(sessionFor(200), draftTask(orgId)),
        throwsA(isA<MakerflowForbiddenException>()),
      );
    });

    test('unauthenticated CANNOT list tasks (Auth required)', () async {
      final orgId = await seedOrgWithMember(300, MembershipRole.staff);
      await expectLater(
        tasks.list(sessionBuilder.build(), orgId), // no auth override
        throwsA(isA<MakerflowAuthException>()),
      );
    });

    test('cross-org write is rejected (no membership in target org)', () async {
      await seedOrgWithMember(400, MembershipRole.staff, slug: 'a');
      final now = DateTime.now().toUtc();
      final orgB = await Organization.db.insertRow(sessionBuilder.build(),
          Organization(name: 'B', slug: 'b', createdAt: now, updatedAt: now));
      await expectLater(
        tasks.create(sessionFor(400), draftTask(orgB.id!)),
        throwsA(isA<MakerflowForbiddenException>()),
      );
    });

    test('workspaceAdmin CANNOT grant the owner role', () async {
      final orgId = await seedOrgWithMember(500, MembershipRole.workspaceAdmin);
      await expectLater(
        orgs.setRole(sessionFor(500), orgId, 999, MembershipRole.owner),
        throwsA(isA<MakerflowForbiddenException>()),
      );
    });

    test('manager CAN create + list tasks', () async {
      final orgId = await seedOrgWithMember(600, MembershipRole.manager);
      await tasks.create(sessionFor(600), draftTask(orgId));
      final list = await tasks.list(sessionFor(600), orgId);
      expect(list, isNotEmpty);
    });
  });
}
