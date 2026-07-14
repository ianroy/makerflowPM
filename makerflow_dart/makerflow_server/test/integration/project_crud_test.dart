@Timeout(Duration(minutes: 4))
library;

import 'package:test/test.dart';
import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/endpoints/project_endpoint.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Project CRUD contract (M1.4): the same security + concurrency guarantees the
/// task suite proves, applied to ProjectEndpoint.update/softDelete. Harness
/// style matches role_matrix_test.dart: endpoint classes called directly with a
/// built, authenticated Session.
void main() {
  final projects = ProjectEndpoint();

  withServerpod('Project CRUD contract', (sessionBuilder, endpoints) {
    final now = DateTime.now().toUtc();

    Future<int> seedOrgWithMember(int userInfoId, MembershipRole role,
        {String slug = 'acme'}) async {
      final session = sessionBuilder.build();
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

    Project draft(int orgId, {String name = 'Fall capstone'}) => Project(
          organizationId: orgId,
          name: name,
          status: 'planned',
          lane: 'discovery',
          priority: TaskPriority.medium,
          version: 1,
          createdAt: now,
          updatedAt: now,
        );

    test('staff CAN create; update applies + bumps version', () async {
      final orgId = await seedOrgWithMember(700, MembershipRole.staff);
      final p1 = await projects.create(sessionFor(700), draft(orgId));
      expect(p1.id, isNotNull);

      final p2 = await projects.update(
          sessionFor(700), p1.copyWith(name: 'Fall capstone v2', status: 'active'));
      expect(p2.version, p1.version + 1);
      expect(p2.name, 'Fall capstone v2');
      expect(p2.status, 'active');
    });

    test('stale-version update is rejected (optimistic concurrency)', () async {
      final orgId = await seedOrgWithMember(710, MembershipRole.staff);
      final p1 = await projects.create(sessionFor(710), draft(orgId));
      await projects.update(sessionFor(710), p1.copyWith(name: 'rev2'));
      await expectLater(
        projects.update(sessionFor(710), p1.copyWith(name: 'stale')),
        throwsA(isA<MakerflowConflictException>()),
      );
    });

    test('viewer CANNOT create (Forbidden)', () async {
      final orgId = await seedOrgWithMember(720, MembershipRole.viewer);
      await expectLater(
        projects.create(sessionFor(720), draft(orgId)),
        throwsA(isA<MakerflowForbiddenException>()),
      );
    });

    test('softDelete archives: gone from list; mutating it throws NotFound',
        () async {
      final orgId = await seedOrgWithMember(730, MembershipRole.staff);
      final keep = await projects.create(sessionFor(730), draft(orgId, name: 'keep'));
      final gone = await projects.create(sessionFor(730), draft(orgId, name: 'gone'));

      await projects.softDelete(sessionFor(730), gone.id!);

      final visible = await projects.list(sessionFor(730), orgId);
      expect(visible.map((p) => p.id), [keep.id]);

      await expectLater(
        projects.update(sessionFor(730), gone.copyWith(name: 'zombie')),
        throwsA(isA<MakerflowNotFoundException>()),
      );
    });

    test('update cannot reassign tenancy (org preserved)', () async {
      final orgA = await seedOrgWithMember(740, MembershipRole.staff, slug: 'org-a');
      final orgB = await Organization.db.insertRow(sessionBuilder.build(),
          Organization(name: 'B', slug: 'org-b', createdAt: now, updatedAt: now));
      final p = await projects.create(sessionFor(740), draft(orgA));

      final saved = await projects.update(
          sessionFor(740), p.copyWith(organizationId: orgB.id!, name: 'moved?'));
      expect(saved.organizationId, orgA); // server pins tenancy to the existing row
    });
  });
}
