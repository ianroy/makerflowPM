import 'package:test/test.dart';
import 'package:makerflow_server/src/business/rbac.dart';
import 'package:makerflow_server/src/generated/protocol.dart';

// Pure unit test of the role ladder — no DB required.
// Run after `serverpod generate` (which produces MembershipRole): `dart test`.
void main() {
  group('RbacGuard role ranking', () {
    test('ladder is ordered least -> most privileged', () {
      expect(RbacGuard.rank(MembershipRole.viewer), 0);
      expect(RbacGuard.rank(MembershipRole.owner),
          MembershipRole.values.length - 1);
    });

    test('atLeast respects the ladder', () {
      expect(
          RbacGuard.atLeast(MembershipRole.manager, MembershipRole.staff), true);
      expect(
          RbacGuard.atLeast(MembershipRole.student, MembershipRole.staff), false);
      expect(RbacGuard.atLeast(MembershipRole.owner, MembershipRole.owner), true);
    });
  });
}
