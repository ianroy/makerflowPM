@Timeout(Duration(minutes: 4))
library;

import 'package:test/test.dart';
import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/endpoints/project_endpoint.dart';
import 'package:makerflow_server/src/endpoints/equipment_endpoint.dart';
import 'package:makerflow_server/src/endpoints/consumable_endpoint.dart';
import 'package:makerflow_server/src/endpoints/meeting_endpoint.dart';
import 'package:makerflow_server/src/endpoints/org_endpoint.dart';

import 'test_tools/serverpod_test_tools.dart';

/// Live read-path coverage for the feature endpoints the Flutter app's
/// Serverpod*Repository impls call (project/equipment/consumable/meeting/org).
/// The client mappers are type-checked by `flutter analyze`; this proves the
/// server side returns org-scoped rows through the RBAC gate. Same harness
/// style: endpoint classes called with a built, authenticated Session.
void main() {
  final projects = ProjectEndpoint();
  final equipment = EquipmentEndpoint();
  final consumables = ConsumableEndpoint();
  final meetings = MeetingEndpoint();
  final orgs = OrgEndpoint();

  withServerpod('Feature read paths (repository-backed endpoints)',
      (sessionBuilder, endpoints) {
    final now = DateTime.now().toUtc();

    Future<int> seedOrgWithMember(int userInfoId,
        {String slug = 'acme', MembershipRole role = MembershipRole.staff}) async {
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

    test('org.listMine returns only orgs the caller belongs to', () async {
      final orgId = await seedOrgWithMember(100, slug: 'mine');
      // A second org the caller is NOT a member of.
      await Organization.db.insertRow(sessionBuilder.build(),
          Organization(name: 'Other', slug: 'other', createdAt: now, updatedAt: now));

      final mine = await orgs.listMine(sessionFor(100));
      expect(mine.map((o) => o.id), [orgId]);
    });

    test('project.list returns org-scoped projects', () async {
      final orgId = await seedOrgWithMember(110);
      await Project.db.insertRow(
        sessionBuilder.build(),
        Project(
            organizationId: orgId,
            name: 'Capstone',
            status: 'active',
            lane: 'build',
            priority: TaskPriority.high,
            createdAt: now,
            updatedAt: now),
      );
      final list = await projects.list(sessionFor(110), orgId);
      expect(list, hasLength(1));
      expect(list.single.name, 'Capstone');
      expect(list.single.lane, 'build');
    });

    test('equipment.list returns org-scoped assets', () async {
      final orgId = await seedOrgWithMember(120);
      await EquipmentAsset.db.insertRow(
        sessionBuilder.build(),
        EquipmentAsset(
            organizationId: orgId,
            name: 'Glowforge',
            status: EquipmentStatus.operational,
            certificationRequired: false,
            version: 1,
            createdAt: now,
            updatedAt: now),
      );
      final list = await equipment.list(sessionFor(120), orgId);
      expect(list, hasLength(1));
      expect(list.single.name, 'Glowforge');
      expect(list.single.status, EquipmentStatus.operational);
    });

    test('consumable.list returns org-scoped stock', () async {
      final orgId = await seedOrgWithMember(130);
      await Consumable.db.insertRow(
        sessionBuilder.build(),
        Consumable(
            organizationId: orgId,
            name: '3mm plywood',
            unit: 'sheets',
            quantityOnHand: 4,
            reorderPoint: 10,
            status: ConsumableStatus.reorder,
            version: 1,
            createdAt: now,
            updatedAt: now),
      );
      final list = await consumables.list(sessionFor(130), orgId);
      expect(list, hasLength(1));
      expect(list.single.name, '3mm plywood');
      expect(list.single.quantityOnHand, 4);
    });

    test('meeting.agendas returns org-scoped agendas', () async {
      final orgId = await seedOrgWithMember(140);
      await MeetingAgenda.db.insertRow(
        sessionBuilder.build(),
        MeetingAgenda(
            organizationId: orgId,
            title: 'Weekly staff sync',
            status: 'active',
            createdAt: now,
            updatedAt: now),
      );
      final list = await meetings.agendas(sessionFor(140), orgId);
      expect(list, hasLength(1));
      expect(list.single.title, 'Weekly staff sync');
    });

    test('feature reads require viewer+ (unauthenticated rejected)', () async {
      final orgId = await seedOrgWithMember(150);
      await expectLater(
        projects.list(sessionBuilder.build(), orgId), // no auth override
        throwsA(isA<MakerflowAuthException>()),
      );
    });
  });
}
