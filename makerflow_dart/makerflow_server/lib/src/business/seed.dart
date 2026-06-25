import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_server/serverpod_auth_server.dart' as auth;

import '../generated/protocol.dart';

/// Demo/first-run seed (fl-0-seed-data) — the Dart analog of the legacy
/// `scripts/load_sample_data.py`. Idempotent: a no-op if the default org
/// already exists. Run on-demand in dev via `dart run bin/seed.dart` and in a
/// deployed container via `server --mode production --seed` (both go through
/// `runSeed` in `../../server.dart`). Never auto-run on boot — the serve path
/// does not touch it.
class Seed {
  static const orgSlug = 'default';
  static const adminEmail = 'admin@makerflow.local';
  static const adminPassword = 'ChangeMeMeow!2026'; // rotate immediately

  static Future<void> run(Session session) async {
    final existing = await Organization.db.findFirstRow(
      session,
      where: (o) => o.slug.equals(orgSlug),
    );
    if (existing != null) {
      session.log('seed: "$orgSlug" already exists — skipping', level: LogLevel.info);
      return;
    }

    final now = DateTime.now().toUtc();

    final org = await Organization.db.insertRow(
      session,
      Organization(name: 'Default Workspace', slug: orgSlug, createdAt: now, updatedAt: now),
    );

    // Owner account via serverpod_auth (email/password) + superuser scope.
    final owner = await auth.Emails.createUser(
      session, 'MakerFlow Admin', adminEmail, adminPassword);
    if (owner?.id != null) {
      await auth.Users.updateUserScopes(session, owner!.id!, {const Scope('superuser')});
      await Membership.db.insertRow(
        session,
        Membership(
          organizationId: org.id!,
          userInfoId: owner.id!,
          role: MembershipRole.owner,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await UserProfile.db.insertRow(
        session,
        UserProfile(
          userInfoId: owner.id!,
          displayName: 'MakerFlow Admin',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    final project = await Project.db.insertRow(
      session,
      Project(
        organizationId: org.id!,
        name: 'Fall capstone cohort',
        lane: 'build',
        status: 'active',
        priority: TaskPriority.high,
        createdAt: now,
        updatedAt: now,
        createdByUserInfoId: owner?.id,
      ),
    );

    final tasks = <Task>[
      _task(org.id!, project.id, 'Laser cutter monthly PM', TaskStatus.todo, TaskPriority.high, now),
      _task(org.id!, null, 'Restock 3mm plywood', TaskStatus.backlog, TaskPriority.medium, now),
      _task(org.id!, project.id, 'Onboard fall student cohort', TaskStatus.inProgress, TaskPriority.high, now),
      _task(org.id!, null, 'Fix dust collector sensor', TaskStatus.blocked, TaskPriority.urgent, now),
      _task(org.id!, project.id, 'Publish Q3 usage report', TaskStatus.inReview, TaskPriority.low, now),
      _task(org.id!, null, 'Archive completed capstones', TaskStatus.done, TaskPriority.low, now),
    ];
    for (final t in tasks) {
      await Task.db.insertRow(session, t);
    }

    // A couple of equipment + consumable rows for the inventory screens.
    await EquipmentAsset.db.insertRow(session, EquipmentAsset(
      organizationId: org.id!, name: 'Glowforge laser', status: EquipmentStatus.operational,
      certificationRequired: true, version: 1, createdAt: now, updatedAt: now));
    await Consumable.db.insertRow(session, Consumable(
      organizationId: org.id!, name: '3mm plywood', unit: 'sheets', quantityOnHand: 4, reorderPoint: 10,
      status: ConsumableStatus.reorder, version: 1, createdAt: now, updatedAt: now));

    session.log(
      'seed: org=${org.id} owner=${owner?.id} project=${project.id} tasks=${tasks.length}',
      level: LogLevel.info,
    );
  }

  static Task _task(int orgId, int? projectId, String title, TaskStatus status,
          TaskPriority priority, DateTime now) =>
      Task(
        organizationId: orgId,
        projectId: projectId,
        title: title,
        status: status,
        priority: priority,
        sortOrder: 0,
        version: 1,
        createdAt: now,
        updatedAt: now,
      );
}
