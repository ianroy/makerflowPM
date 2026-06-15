@Timeout(Duration(minutes: 2))
import 'package:serverpod_test/serverpod_test.dart';
import 'package:test/test.dart';

import 'package:makerflow_server/src/generated/protocol.dart';
import 'package:makerflow_server/src/generated/test/serverpod_test_tools.dart';

/// Role-matrix regression gate — the Dart port of the Python
/// `scripts/comprehensive_feature_security_test.py`. For each (role × action)
/// it asserts allow/deny per docs/SECURITY.md. This is the security gate the
/// CI must keep green (Appendix F / fl-1-testing-harness).
///
/// Run after `serverpod generate` (which produces serverpod_test_tools.dart):
///   dart test test/role_matrix_test.dart
///
/// NOTE: this is a scaffold expressing the intended assertions. Fill the
/// fixture helpers (`_seedUserWithRole`, sign-in) once serverpod_auth test
/// helpers are wired in fl-0-auth-rbac-tenancy.
void main() {
  withServerpod('Role matrix', (sessionBuilder, endpoints) {
    // Expected: can this role create a task?
    const canCreateTask = {
      MembershipRole.viewer: false,
      MembershipRole.student: false, // students create via their own scoped flow
      MembershipRole.staff: true,
      MembershipRole.manager: true,
      MembershipRole.workspaceAdmin: true,
      MembershipRole.owner: true,
    };

    for (final entry in canCreateTask.entries) {
      test('${entry.key.name} create task → ${entry.value ? "allow" : "deny"}',
          () async {
        // final session = await _seedUserWithRole(sessionBuilder, entry.key);
        // final call = endpoints.task.create(session, _draftTask());
        // if (entry.value) {
        //   expect(await call, isA<Task>());
        // } else {
        //   await expectLater(call, throwsA(isA<MakerflowForbiddenException>()));
        // }
        markTestSkipped('Wire serverpod_auth test fixtures (fl-0-auth-rbac-tenancy).');
      });
    }

    test('cross-org read is rejected', () async {
      // A staff member of org A cannot list tasks of org B.
      markTestSkipped('Wire fixtures; assert tenancy isolation throws Forbidden.');
    });

    test('workspace_admin cannot grant owner', () async {
      markTestSkipped('Assert OrgEndpoint.setRole(owner) throws for non-owner.');
    });
  });
}
