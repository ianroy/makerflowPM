@Timeout(Duration(minutes: 4))
library;

import 'package:test/test.dart';
import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/endpoints/view_endpoint.dart';
import 'package:makerflow_server/src/endpoints/field_config_endpoint.dart';
import 'package:makerflow_server/src/endpoints/preference_endpoint.dart';

import 'test_tools/serverpod_test_tools.dart';

/// fl-8-view-field-endpoints contract: saved views (ownership + sharing +
/// version), field definitions (admin gate + uniqueness + type validation),
/// and self-service preferences (userInfoId pinning).
void main() {
  final views = ViewEndpoint();
  final fields = FieldConfigEndpoint();
  final prefs = PreferenceEndpoint();

  withServerpod('Customization endpoints', (sessionBuilder, endpoints) {
    final now = DateTime.now().toUtc();

    Future<int> seedOrgWithMember(int userInfoId, MembershipRole role,
        {String slug = 'acme'}) async {
      final session = sessionBuilder.build();
      var org = await Organization.db
          .findFirstRow(session, where: (o) => o.slug.equals(slug));
      org ??= await Organization.db.insertRow(session,
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

    CustomView draftView(int orgId,
            {String name = 'My table',
            bool shared = false,
            String viewType = 'table'}) =>
        CustomView(
          organizationId: orgId,
          ownerUserInfoId: 0, // server pins the real owner
          name: name,
          entityType: 'task',
          viewType: viewType,
          filtersJson: '{}',
          columnsJson: '[]',
          isShared: shared,
          version: 1,
          createdAt: now,
          updatedAt: now,
        );

    test('views: owner sees own; shared views visible to others; private not',
        () async {
      final orgId = await seedOrgWithMember(900, MembershipRole.staff);
      await seedOrgWithMember(901, MembershipRole.viewer);

      await views.save(sessionFor(900), draftView(orgId, name: 'private'));
      await views.save(
          sessionFor(900),
          draftView(orgId, name: 'team view', shared: true, viewType: 'kanban'));

      final mine = await views.list(sessionFor(900), orgId);
      expect(mine.map((v) => v.name).toSet(), {'private', 'team view'});
      // fl-8-saved-views: the view TYPE round-trips.
      expect(mine.firstWhere((v) => v.name == 'team view').viewType, 'kanban');
      expect(mine.firstWhere((v) => v.name == 'private').viewType, 'table');

      final theirs = await views.list(sessionFor(901), orgId);
      expect(theirs.map((v) => v.name), ['team view']); // shared only
    });

    test('views: non-owner member cannot edit; admin can; version conflicts',
        () async {
      final orgId = await seedOrgWithMember(910, MembershipRole.staff);
      await seedOrgWithMember(911, MembershipRole.staff);
      await seedOrgWithMember(912, MembershipRole.workspaceAdmin);

      final v = await views.save(
          sessionFor(910), draftView(orgId, name: 'v1', shared: true));

      await expectLater(
        views.save(sessionFor(911), v.copyWith(name: 'stolen')),
        throwsA(isA<MakerflowForbiddenException>()),
      );

      final adminEdit =
          await views.save(sessionFor(912), v.copyWith(name: 'renamed'));
      expect(adminEdit.version, v.version + 1);

      await expectLater(
        views.save(sessionFor(910), v.copyWith(name: 'stale')), // old version
        throwsA(isA<MakerflowConflictException>()),
      );
    });

    test('views: soft-delete hides from list', () async {
      final orgId = await seedOrgWithMember(920, MembershipRole.staff);
      final v = await views.save(sessionFor(920), draftView(orgId, name: 'gone'));
      await views.softDelete(sessionFor(920), v.id!);
      final after = await views.list(sessionFor(920), orgId);
      expect(after.where((x) => x.id == v.id), isEmpty);
    });

    test('fields: staff cannot define; admin can; duplicate key + bad type conflict',
        () async {
      final orgId = await seedOrgWithMember(930, MembershipRole.staff);
      await seedOrgWithMember(931, MembershipRole.workspaceAdmin);

      FieldConfig draft(String key, {String type = 'number'}) => FieldConfig(
            organizationId: orgId,
            entityType: 'task',
            key: key,
            label: key,
            fieldType: type,
            required: false,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          );

      await expectLater(fields.save(sessionFor(930), draft('cost')),
          throwsA(isA<MakerflowForbiddenException>()));

      final created = await fields.save(sessionFor(931), draft('cost'));
      expect(created.id, isNotNull);

      await expectLater(fields.save(sessionFor(931), draft('cost')),
          throwsA(isA<MakerflowConflictException>())); // duplicate key
      await expectLater(
          fields.save(sessionFor(931), draft('weird', type: 'hologram')),
          throwsA(isA<MakerflowConflictException>())); // invalid type

      final listed = await fields.list(sessionFor(930), orgId, entityType: 'task');
      expect(listed.map((f) => f.key), ['cost']); // members can read

      await fields.delete(sessionFor(931), created.id!);
      expect(await fields.list(sessionFor(931), orgId), isEmpty);
    });

    test('preferences: defaults on first read; upsert; userInfoId pinned',
        () async {
      await seedOrgWithMember(940, MembershipRole.viewer);
      final first = await prefs.getMine(sessionFor(940));
      expect(first.theme, 'light');

      final saved = await prefs.saveMine(
          sessionFor(940),
          first.copyWith(
              theme: 'dark', uiJson: '{"sidebarCollapsed":true}',
              userInfoId: 999999)); // spoof attempt — must be pinned back
      expect(saved.userInfoId, 940);
      expect(saved.theme, 'dark');

      final reread = await prefs.getMine(sessionFor(940));
      expect(reread.uiJson, '{"sidebarCollapsed":true}');

      // Another user gets their own defaults, not 940's row.
      await seedOrgWithMember(941, MembershipRole.viewer);
      final other = await prefs.getMine(sessionFor(941));
      expect(other.theme, 'light');
    });
  });
}
