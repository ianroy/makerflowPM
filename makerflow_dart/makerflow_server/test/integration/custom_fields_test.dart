@Timeout(Duration(minutes: 4))
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/endpoints/task_endpoint.dart';
import 'package:makerflow_server/src/endpoints/field_config_endpoint.dart';

import 'test_tools/serverpod_test_tools.dart';

/// fl-8-custom-fields contract (D6): task values live in `customFieldsJson`,
/// validated against the org's FieldConfig definitions on every write; a
/// definition type change warns first, then coerces on confirm.
void main() {
  final tasks = TaskEndpoint();
  final fields = FieldConfigEndpoint();

  withServerpod('Custom field values (D6)', (sessionBuilder, endpoints) {
    final now = DateTime.now().toUtc();

    Future<int> seedOrgWithMember(int userInfoId, MembershipRole role,
        {String slug = 'cf-org'}) async {
      final session = sessionBuilder.build();
      var org = await Organization.db
          .findFirstRow(session, where: (o) => o.slug.equals(slug));
      org ??= await Organization.db.insertRow(
          session,
          Organization(
              name: 'CF Org', slug: slug, createdAt: now, updatedAt: now));
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

    FieldConfig draftField(int orgId, String key, String fieldType,
            {String? optionsJson}) =>
        FieldConfig(
          organizationId: orgId,
          entityType: 'task',
          key: key,
          label: key,
          fieldType: fieldType,
          optionsJson: optionsJson,
          required: false,
          sortOrder: 0,
          createdAt: now,
          updatedAt: now,
        );

    Task draftTask(int orgId, {String? customFieldsJson}) => Task(
          organizationId: orgId,
          title: 'cf task',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          sortOrder: 0,
          customFieldsJson: customFieldsJson,
          version: 1,
          createdAt: now,
          updatedAt: now,
        );

    test('values round-trip through create/update and validate by type',
        () async {
      final orgId = await seedOrgWithMember(920, MembershipRole.workspaceAdmin);
      final admin = sessionFor(920);
      await fields.save(admin, draftField(orgId, 'weight_kg', 'number'));
      await fields.save(
          admin,
          draftField(orgId, 'material', 'label',
              optionsJson:
                  '[{"value":"Wood","color":"#7F5347"},{"value":"Metal","color":"#9AADBD"}]'));

      final created = await tasks.create(
        admin,
        draftTask(orgId,
            customFieldsJson: jsonEncode({'weight_kg': 3.5, 'material': 'Wood'})),
      );
      final bag = jsonDecode(created.customFieldsJson!) as Map<String, dynamic>;
      expect(bag['weight_kg'], 3.5);
      expect(bag['material'], 'Wood');

      final updated = await tasks.update(
        admin,
        created.copyWith(
            customFieldsJson:
                jsonEncode({'weight_kg': 4, 'material': 'Metal'})),
      );
      final bag2 = jsonDecode(updated.customFieldsJson!) as Map<String, dynamic>;
      expect(bag2['weight_kg'], 4);
      expect(bag2['material'], 'Metal');
    });

    test('writes reject wrong types, unknown keys, and off-list options',
        () async {
      final orgId = await seedOrgWithMember(921, MembershipRole.workspaceAdmin,
          slug: 'cf-org-2');
      final admin = sessionFor(921);
      await fields.save(admin, draftField(orgId, 'weight_kg', 'number'));
      await fields.save(admin,
          draftField(orgId, 'finish', 'select', optionsJson: '["Matte","Gloss"]'));
      await fields.save(admin,
          draftField(orgId, 'tags', 'multiSelect', optionsJson: '["cnc","laser"]'));

      // Wrong type: string into a number field.
      await expectLater(
        tasks.create(admin,
            draftTask(orgId, customFieldsJson: jsonEncode({'weight_kg': 'heavy'}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // Unknown key: no definition.
      await expectLater(
        tasks.create(admin,
            draftTask(orgId, customFieldsJson: jsonEncode({'mystery': 1}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // Select value outside the defined options.
      await expectLater(
        tasks.create(admin,
            draftTask(orgId, customFieldsJson: jsonEncode({'finish': 'Chrome'}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // multiSelect must be a subset of the options.
      await expectLater(
        tasks.create(
            admin,
            draftTask(orgId,
                customFieldsJson: jsonEncode({'tags': ['cnc', 'welding']}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // Malformed JSON is rejected outright.
      await expectLater(
        tasks.create(admin, draftTask(orgId, customFieldsJson: 'not json')),
        throwsA(isA<MakerflowConflictException>()),
      );
      // Null value clears; valid values pass.
      final ok = await tasks.create(
          admin,
          draftTask(orgId,
              customFieldsJson: jsonEncode(
                  {'weight_kg': null, 'finish': 'Matte', 'tags': ['cnc']})));
      expect(ok.id, isNotNull);
    });

    test('UPDATE rejects invalid values too (the primary production write path)',
        () async {
      final orgId = await seedOrgWithMember(924, MembershipRole.workspaceAdmin,
          slug: 'cf-org-5');
      final admin = sessionFor(924);
      await fields.save(admin, draftField(orgId, 'weight_kg', 'number'));
      final task = await tasks.create(admin,
          draftTask(orgId, customFieldsJson: jsonEncode({'weight_kg': 3.5})));

      // Changed-to-invalid value → typed Conflict (carried values are exempt,
      // changed values are not).
      await expectLater(
        tasks.update(admin,
            task.copyWith(customFieldsJson: jsonEncode({'weight_kg': 'heavy'}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // New unknown key via update → typed Conflict.
      await expectLater(
        tasks.update(
            admin,
            task.copyWith(
                customFieldsJson:
                    jsonEncode({'weight_kg': 3.5, 'mystery': 1}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // Non-finite numbers are rejected (they would crash jsonEncode later).
      await expectLater(
        tasks.update(admin,
            task.copyWith(customFieldsJson: '{"weight_kg": 1e999}')),
        throwsA(isA<MakerflowConflictException>()),
      );
    });

    test('the stored doc is sanitized: nulls removed, canonical re-encode',
        () async {
      final orgId = await seedOrgWithMember(925, MembershipRole.workspaceAdmin,
          slug: 'cf-org-6');
      final admin = sessionFor(925);
      await fields.save(admin, draftField(orgId, 'weight_kg', 'number'));

      // Duplicate keys in raw JSON: last one wins and ONLY the parsed map is
      // stored (no raw-bytes smuggling); explicit nulls are removed entirely.
      final created = await tasks.create(
          admin,
          draftTask(orgId,
              customFieldsJson:
                  '{"weight_kg": 1, "weight_kg": 2.5, "weight_kg": null}'));
      expect(created.customFieldsJson, '{}'); // last duplicate = null = cleared

      final withValue = await tasks.update(admin,
          created.copyWith(customFieldsJson: jsonEncode({'weight_kg': 2.5})));
      expect(withValue.customFieldsJson, '{"weight_kg":2.5}'); // canonical
    });

    test('deleting a definition never bricks tasks: carried orphans survive '
        'unrelated edits, and null clears them', () async {
      final orgId = await seedOrgWithMember(926, MembershipRole.workspaceAdmin,
          slug: 'cf-org-7');
      final admin = sessionFor(926);
      final weight =
          await fields.save(admin, draftField(orgId, 'weight_kg', 'number'));
      final task = await tasks.create(admin,
          draftTask(orgId, customFieldsJson: jsonEncode({'weight_kg': 3.5})));

      await fields.delete(admin, weight.id!); // definition gone, value orphaned

      // An unrelated edit carries the orphaned value through unchanged.
      final retitled = await tasks.update(
          admin, task.copyWith(title: 'renamed after field delete'));
      expect(jsonDecode(retitled.customFieldsJson!), {'weight_kg': 3.5});

      // Writing a NEW value to the dead key is still rejected...
      await expectLater(
        tasks.update(admin,
            retitled.copyWith(customFieldsJson: jsonEncode({'weight_kg': 9}))),
        throwsA(isA<MakerflowConflictException>()),
      );
      // ...but clearing it (null) is always allowed.
      final cleared = await tasks.update(admin,
          retitled.copyWith(customFieldsJson: jsonEncode({'weight_kg': null})));
      expect(cleared.customFieldsJson, '{}');
    });

    test('type change warns first, then coerces on confirm (Airtable pattern)',
        () async {
      final orgId = await seedOrgWithMember(922, MembershipRole.workspaceAdmin,
          slug: 'cf-org-3');
      final admin = sessionFor(922);
      final weight =
          await fields.save(admin, draftField(orgId, 'weight_kg', 'number'));
      final task = await tasks.create(admin,
          draftTask(orgId, customFieldsJson: jsonEncode({'weight_kg': 3.5})));

      // First attempt: warn (typed conflict naming the affected count).
      await expectLater(
        fields.save(admin, weight.copyWith(fieldType: 'text')),
        throwsA(isA<MakerflowConflictException>().having(
            (e) => e.message, 'message', contains('affects 1 existing value'))),
      );
      // The definition must NOT have changed (warn-before-write).
      final still = await fields.list(sessionFor(922), orgId);
      expect(still.single.fieldType, 'number');

      // Confirmed: coerce number -> text.
      final changed = await fields
          .save(admin, weight.copyWith(fieldType: 'text'), coerceValues: true);
      expect(changed.fieldType, 'text');
      final after = (await tasks.list(sessionFor(922), orgId))
          .firstWhere((t) => t.id == task.id);
      final bag = jsonDecode(after.customFieldsJson!) as Map<String, dynamic>;
      expect(bag['weight_kg'], '3.5'); // string now
      expect(after.version, greaterThan(task.version)); // reconcile bump
    });

    test('unconvertible values are cleared on confirmed type change', () async {
      final orgId = await seedOrgWithMember(923, MembershipRole.workspaceAdmin,
          slug: 'cf-org-4');
      final admin = sessionFor(923);
      final notes =
          await fields.save(admin, draftField(orgId, 'notes', 'text'));
      final task = await tasks.create(admin,
          draftTask(orgId, customFieldsJson: jsonEncode({'notes': 'not a number'})));

      final changed = await fields
          .save(admin, notes.copyWith(fieldType: 'number'), coerceValues: true);
      expect(changed.fieldType, 'number');
      final after = (await tasks.list(sessionFor(923), orgId))
          .firstWhere((t) => t.id == task.id);
      final bag = jsonDecode(after.customFieldsJson!) as Map<String, dynamic>;
      expect(bag.containsKey('notes'), isFalse); // cleared, not corrupted
    });
  });
}
