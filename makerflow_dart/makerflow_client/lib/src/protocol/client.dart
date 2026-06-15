/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:makerflow_client/src/protocol/item_comment.dart' as _i3;
import 'package:makerflow_client/src/protocol/change_event.dart' as _i4;
import 'package:makerflow_client/src/protocol/consumable.dart' as _i5;
import 'package:makerflow_client/src/protocol/equipment_asset.dart' as _i6;
import 'package:makerflow_client/src/protocol/enums/equipment_status.dart'
    as _i7;
import 'package:makerflow_client/src/protocol/intake_request.dart' as _i8;
import 'package:makerflow_client/src/protocol/project.dart' as _i9;
import 'package:makerflow_client/src/protocol/meeting_agenda.dart' as _i10;
import 'package:makerflow_client/src/protocol/meeting_item.dart' as _i11;
import 'package:makerflow_client/src/protocol/task.dart' as _i12;
import 'package:makerflow_client/src/protocol/onboarding_template.dart' as _i13;
import 'package:makerflow_client/src/protocol/onboarding_assignment.dart'
    as _i14;
import 'package:makerflow_client/src/protocol/enums/onboarding_state.dart'
    as _i15;
import 'package:makerflow_client/src/protocol/organization.dart' as _i16;
import 'package:makerflow_client/src/protocol/membership.dart' as _i17;
import 'package:makerflow_client/src/protocol/enums/membership_role.dart'
    as _i18;
import 'package:makerflow_client/src/protocol/partnership.dart' as _i19;
import 'package:makerflow_client/src/protocol/enums/partnership_stage.dart'
    as _i20;
import 'package:makerflow_client/src/protocol/task_delta_page.dart' as _i21;
import 'package:makerflow_client/src/protocol/enums/task_status.dart' as _i22;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i23;
import 'protocol.dart' as _i24;

/// Comments + watchers on any entity, plus a streaming activity feed that
/// replaces the legacy poll/refresh helper. Comments are announced to watchers
/// via the realtime channel (Appendix C); the client surfaces them in a live
/// region (WCAG 4.1.3).
/// {@category Endpoint}
class EndpointCollab extends _i1.EndpointRef {
  EndpointCollab(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'collab';

  _i2.Future<List<_i3.ItemComment>> comments(
    int organizationId,
    String entityType,
    int entityId,
  ) => caller.callServerEndpoint<List<_i3.ItemComment>>(
    'collab',
    'comments',
    {
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
    },
  );

  /// Add a comment (student+ may comment). Publishes an activity event.
  _i2.Future<_i3.ItemComment> addComment(_i3.ItemComment draft) =>
      caller.callServerEndpoint<_i3.ItemComment>(
        'collab',
        'addComment',
        {'draft': draft},
      );

  /// Follow/unfollow an entity (drives push fan-out, fl-5-push).
  _i2.Future<void> watch(
    int organizationId,
    String entityType,
    int entityId,
    bool watching,
  ) => caller.callServerEndpoint<void>(
    'collab',
    'watch',
    {
      'organizationId': organizationId,
      'entityType': entityType,
      'entityId': entityId,
      'watching': watching,
    },
  );

  /// Streaming activity feed for the active org. Each event is a compact
  /// change notice the client applies to local state.
  _i2.Stream<_i4.ChangeEvent> activityStream(int organizationId) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i4.ChangeEvent>,
        _i4.ChangeEvent
      >(
        'collab',
        'activityStream',
        {'organizationId': organizationId},
        {},
      );
}

/// Consumables — stock + reorder tracking. Reorder status is derived on save so
/// the UI can show a non-color cue (WCAG 1.4.1).
/// {@category Endpoint}
class EndpointConsumable extends _i1.EndpointRef {
  EndpointConsumable(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'consumable';

  _i2.Future<List<_i5.Consumable>> list(int organizationId) =>
      caller.callServerEndpoint<List<_i5.Consumable>>(
        'consumable',
        'list',
        {'organizationId': organizationId},
      );

  _i2.Future<_i5.Consumable> save(_i5.Consumable draft) =>
      caller.callServerEndpoint<_i5.Consumable>(
        'consumable',
        'save',
        {'draft': draft},
      );

  _i2.Future<void> softDelete(int id) => caller.callServerEndpoint<void>(
    'consumable',
    'softDelete',
    {'id': id},
  );
}

/// Equipment assets — maintenance + certification tracking. Same security
/// contract as TaskEndpoint (requireRole → org-scope → audit → soft-delete).
/// {@category Endpoint}
class EndpointEquipment extends _i1.EndpointRef {
  EndpointEquipment(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'equipment';

  _i2.Future<List<_i6.EquipmentAsset>> list(
    int organizationId, {
    _i7.EquipmentStatus? status,
  }) => caller.callServerEndpoint<List<_i6.EquipmentAsset>>(
    'equipment',
    'list',
    {
      'organizationId': organizationId,
      'status': status,
    },
  );

  _i2.Future<_i6.EquipmentAsset> save(_i6.EquipmentAsset draft) =>
      caller.callServerEndpoint<_i6.EquipmentAsset>(
        'equipment',
        'save',
        {'draft': draft},
      );

  _i2.Future<void> softDelete(int id) => caller.callServerEndpoint<void>(
    'equipment',
    'softDelete',
    {'id': id},
  );
}

/// Readiness probe with a DB round-trip (legacy /readyz). The cheap liveness
/// probe (/healthz) is wired as a web route in server.dart.
/// {@category Endpoint}
class EndpointHealth extends _i1.EndpointRef {
  EndpointHealth(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'health';

  _i2.Future<bool> ready() => caller.callServerEndpoint<bool>(
    'health',
    'ready',
    {},
  );
}

/// Scored intake queue. Feature-flagged at the app layer (matches the legacy
/// FEATURE_INTAKE_ENABLED). Items can convert into a project.
/// {@category Endpoint}
class EndpointIntake extends _i1.EndpointRef {
  EndpointIntake(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'intake';

  _i2.Future<List<_i8.IntakeRequest>> list(int organizationId) =>
      caller.callServerEndpoint<List<_i8.IntakeRequest>>(
        'intake',
        'list',
        {'organizationId': organizationId},
      );

  _i2.Future<_i8.IntakeRequest> save(_i8.IntakeRequest draft) =>
      caller.callServerEndpoint<_i8.IntakeRequest>(
        'intake',
        'save',
        {'draft': draft},
      );

  _i2.Future<_i9.Project> convertToProject(
    int organizationId,
    int requestId,
  ) => caller.callServerEndpoint<_i9.Project>(
    'intake',
    'convertToProject',
    {
      'organizationId': organizationId,
      'requestId': requestId,
    },
  );
}

/// Meetings & agendas. Items can be **converted** into a task or project — the
/// meeting → execution bridge. Replaces /agenda* and /api/agenda*.
/// {@category Endpoint}
class EndpointMeeting extends _i1.EndpointRef {
  EndpointMeeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'meeting';

  _i2.Future<List<_i10.MeetingAgenda>> agendas(int organizationId) =>
      caller.callServerEndpoint<List<_i10.MeetingAgenda>>(
        'meeting',
        'agendas',
        {'organizationId': organizationId},
      );

  _i2.Future<List<_i11.MeetingItem>> items(
    int organizationId,
    int agendaId,
  ) => caller.callServerEndpoint<List<_i11.MeetingItem>>(
    'meeting',
    'items',
    {
      'organizationId': organizationId,
      'agendaId': agendaId,
    },
  );

  _i2.Future<_i10.MeetingAgenda> saveAgenda(_i10.MeetingAgenda draft) =>
      caller.callServerEndpoint<_i10.MeetingAgenda>(
        'meeting',
        'saveAgenda',
        {'draft': draft},
      );

  _i2.Future<_i11.MeetingItem> saveItem(_i11.MeetingItem draft) =>
      caller.callServerEndpoint<_i11.MeetingItem>(
        'meeting',
        'saveItem',
        {'draft': draft},
      );

  /// Convert a meeting item into a Task (the execution bridge). Links the new
  /// task back onto the item so the agenda shows what it became.
  _i2.Future<_i12.Task> convertItemToTask(
    int organizationId,
    int itemId,
  ) => caller.callServerEndpoint<_i12.Task>(
    'meeting',
    'convertItemToTask',
    {
      'organizationId': organizationId,
      'itemId': itemId,
    },
  );
}

/// Onboarding templates → assignments. Templates are manager-managed; an
/// assignee (student+) can advance their own assignment's state.
/// {@category Endpoint}
class EndpointOnboarding extends _i1.EndpointRef {
  EndpointOnboarding(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'onboarding';

  _i2.Future<List<_i13.OnboardingTemplate>> templates(int organizationId) =>
      caller.callServerEndpoint<List<_i13.OnboardingTemplate>>(
        'onboarding',
        'templates',
        {'organizationId': organizationId},
      );

  _i2.Future<_i13.OnboardingTemplate> saveTemplate(
    _i13.OnboardingTemplate draft,
  ) => caller.callServerEndpoint<_i13.OnboardingTemplate>(
    'onboarding',
    'saveTemplate',
    {'draft': draft},
  );

  _i2.Future<_i14.OnboardingAssignment> assign(
    int organizationId,
    int templateId,
    int assigneeUserInfoId,
    DateTime? dueAt,
  ) => caller.callServerEndpoint<_i14.OnboardingAssignment>(
    'onboarding',
    'assign',
    {
      'organizationId': organizationId,
      'templateId': templateId,
      'assigneeUserInfoId': assigneeUserInfoId,
      'dueAt': dueAt,
    },
  );

  /// Advance state. The assignee may update their own; managers may update any.
  _i2.Future<_i14.OnboardingAssignment> setState(
    int assignmentId,
    _i15.OnboardingState state,
    String? progressJson,
  ) => caller.callServerEndpoint<_i14.OnboardingAssignment>(
    'onboarding',
    'setState',
    {
      'assignmentId': assignmentId,
      'state': state,
      'progressJson': progressJson,
    },
  );
}

/// Organizations + memberships. Replaces the legacy org switch (`?org=`) and
/// `/admin/users*` routes. Enforces the workspace_admin/owner boundary from
/// docs/SECURITY.md: workspace admins manage their own org but cannot grant or
/// modify `owner` unless they are owner/superuser.
/// {@category Endpoint}
class EndpointOrg extends _i1.EndpointRef {
  EndpointOrg(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'org';

  /// Organizations the caller belongs to (for the org switcher).
  _i2.Future<List<_i16.Organization>> listMine() =>
      caller.callServerEndpoint<List<_i16.Organization>>(
        'org',
        'listMine',
        {},
      );

  /// Members of an org (manager+).
  _i2.Future<List<_i17.Membership>> members(int organizationId) =>
      caller.callServerEndpoint<List<_i17.Membership>>(
        'org',
        'members',
        {'organizationId': organizationId},
      );

  /// Add or update a member's role (workspace_admin+). Cannot set/modify `owner`
  /// unless the caller is owner or superuser.
  _i2.Future<_i17.Membership> setRole(
    int organizationId,
    int targetUserInfoId,
    _i18.MembershipRole role,
  ) => caller.callServerEndpoint<_i17.Membership>(
    'org',
    'setRole',
    {
      'organizationId': organizationId,
      'targetUserInfoId': targetUserInfoId,
      'role': role,
    },
  );

  /// Remove a member (workspace_admin+; owners protected as above).
  _i2.Future<void> removeMember(
    int organizationId,
    int targetUserInfoId,
  ) => caller.callServerEndpoint<void>(
    'org',
    'removeMember',
    {
      'organizationId': organizationId,
      'targetUserInfoId': targetUserInfoId,
    },
  );
}

/// Partnerships pipeline. Manager+ to mutate (it's a relationship/governance
/// surface), viewer+ to read.
/// {@category Endpoint}
class EndpointPartnership extends _i1.EndpointRef {
  EndpointPartnership(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'partnership';

  _i2.Future<List<_i19.Partnership>> list(
    int organizationId, {
    _i20.PartnershipStage? stage,
  }) => caller.callServerEndpoint<List<_i19.Partnership>>(
    'partnership',
    'list',
    {
      'organizationId': organizationId,
      'stage': stage,
    },
  );

  _i2.Future<_i19.Partnership> save(_i19.Partnership draft) =>
      caller.callServerEndpoint<_i19.Partnership>(
        'partnership',
        'save',
        {'draft': draft},
      );

  _i2.Future<void> softDelete(int id) => caller.callServerEndpoint<void>(
    'partnership',
    'softDelete',
    {'id': id},
  );
}

/// Project CRUD. Same security contract as [TaskEndpoint].
/// Replaces the legacy /projects, /projects/new, /projects/update routes.
/// {@category Endpoint}
class EndpointProject extends _i1.EndpointRef {
  EndpointProject(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'project';

  _i2.Future<List<_i9.Project>> list(int organizationId) =>
      caller.callServerEndpoint<List<_i9.Project>>(
        'project',
        'list',
        {'organizationId': organizationId},
      );

  _i2.Future<_i9.Project> create(_i9.Project draft) =>
      caller.callServerEndpoint<_i9.Project>(
        'project',
        'create',
        {'draft': draft},
      );
}

/// The realtime rail (fl-1-realtime-infra). A single streaming endpoint that
/// authenticates, authorizes the org, and yields the org's change stream.
/// Both the activity feed and offline sync consume this.
/// {@category Endpoint}
class EndpointRealtime extends _i1.EndpointRef {
  EndpointRealtime(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'realtime';

  _i2.Stream<_i4.ChangeEvent> subscribe(int organizationId) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i4.ChangeEvent>,
        _i4.ChangeEvent
      >(
        'realtime',
        'subscribe',
        {'organizationId': organizationId},
        {},
      );
}

/// Offline sync (fl-5-offline-sync, Appendix C). The client PULLS deltas since
/// its [SyncCursor] and PUSHES queued mutations keyed by clientUuid. This
/// endpoint sketches the pull side for `task` (the first offline entity); push
/// + multi-entity + conflict resolution land in fl-5.
/// {@category Endpoint}
class EndpointSync extends _i1.EndpointRef {
  EndpointSync(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sync';

  /// Tasks changed since the device's cursor, ordered by (updatedAt, id).
  /// Includes soft-deleted rows as tombstones so the client can remove them.
  _i2.Future<_i21.TaskDeltaPage> pullTasks(
    int organizationId,
    String? cursor, {
    int? limit,
  }) => caller.callServerEndpoint<_i21.TaskDeltaPage>(
    'sync',
    'pullTasks',
    {
      'organizationId': organizationId,
      'cursor': cursor,
      'limit': limit,
    },
  );

  /// Persist/advance this device's cursor after applying a page.
  _i2.Future<void> ackCursor(
    int organizationId,
    String deviceId,
    String cursor,
  ) => caller.callServerEndpoint<void>(
    'sync',
    'ackCursor',
    {
      'organizationId': organizationId,
      'deviceId': deviceId,
      'cursor': cursor,
    },
  );
}

/// Task CRUD + kanban move. Every method enforces the security contract:
/// authenticate → requireRole → org-scope every query → audit mutations →
/// soft-delete (never hard-delete here).
///
/// Replaces the legacy /tasks, /tasks/new, /tasks/update, /api/tasks* routes.
/// {@category Endpoint}
class EndpointTask extends _i1.EndpointRef {
  EndpointTask(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'task';

  /// List non-deleted tasks for an org, optionally filtered by project/status.
  _i2.Future<List<_i12.Task>> list(
    int organizationId, {
    int? projectId,
    _i22.TaskStatus? status,
  }) => caller.callServerEndpoint<List<_i12.Task>>(
    'task',
    'list',
    {
      'organizationId': organizationId,
      'projectId': projectId,
      'status': status,
    },
  );

  /// Create a task. Requires `staff`+ (students create only via their own
  /// scoped flow — modeled in fl-1; viewer/student blocked here).
  _i2.Future<_i12.Task> create(_i12.Task draft) =>
      caller.callServerEndpoint<_i12.Task>(
        'task',
        'create',
        {'draft': draft},
      );

  /// Update a task. Optimistic-concurrency aware via [Task.version]:
  /// throws if the client's base version is stale (offline reconcile, R5).
  _i2.Future<_i12.Task> update(_i12.Task incoming) =>
      caller.callServerEndpoint<_i12.Task>(
        'task',
        'update',
        {'incoming': incoming},
      );

  /// Kanban move: change status and reorder. Used by both drag-and-drop and
  /// the keyboard move pattern (fl-1-projects-tasks, WCAG 2.1.1 / 2.5.1).
  _i2.Future<_i12.Task> move(
    int taskId,
    _i22.TaskStatus toStatus,
    double toSortOrder,
  ) => caller.callServerEndpoint<_i12.Task>(
    'task',
    'move',
    {
      'taskId': taskId,
      'toStatus': toStatus,
      'toSortOrder': toSortOrder,
    },
  );

  /// Soft-delete (goes to the trash queue; never a hard delete here).
  _i2.Future<void> softDelete(int taskId) => caller.callServerEndpoint<void>(
    'task',
    'softDelete',
    {'taskId': taskId},
  );
}

/// The deleted queue (/deleted): list soft-deleted rows, restore, or
/// permanently purge. Restore is staff+; purge is workspace_admin+ (matches
/// docs/SECURITY.md). v1 covers tasks + projects; extend per entity.
/// {@category Endpoint}
class EndpointTrash extends _i1.EndpointRef {
  EndpointTrash(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'trash';

  _i2.Future<List<_i12.Task>> deletedTasks(int organizationId) =>
      caller.callServerEndpoint<List<_i12.Task>>(
        'trash',
        'deletedTasks',
        {'organizationId': organizationId},
      );

  _i2.Future<_i12.Task> restoreTask(int id) =>
      caller.callServerEndpoint<_i12.Task>(
        'trash',
        'restoreTask',
        {'id': id},
      );

  /// Permanent purge (workspace_admin+). Irreversible; audited (and the audit
  /// row itself is never purged).
  _i2.Future<void> purgeTask(int id) => caller.callServerEndpoint<void>(
    'trash',
    'purgeTask',
    {'id': id},
  );
}

class Modules {
  Modules(Client client) {
    auth = _i23.Caller(client);
  }

  late final _i23.Caller auth;
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i24.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    collab = EndpointCollab(this);
    consumable = EndpointConsumable(this);
    equipment = EndpointEquipment(this);
    health = EndpointHealth(this);
    intake = EndpointIntake(this);
    meeting = EndpointMeeting(this);
    onboarding = EndpointOnboarding(this);
    org = EndpointOrg(this);
    partnership = EndpointPartnership(this);
    project = EndpointProject(this);
    realtime = EndpointRealtime(this);
    sync = EndpointSync(this);
    task = EndpointTask(this);
    trash = EndpointTrash(this);
    modules = Modules(this);
  }

  late final EndpointCollab collab;

  late final EndpointConsumable consumable;

  late final EndpointEquipment equipment;

  late final EndpointHealth health;

  late final EndpointIntake intake;

  late final EndpointMeeting meeting;

  late final EndpointOnboarding onboarding;

  late final EndpointOrg org;

  late final EndpointPartnership partnership;

  late final EndpointProject project;

  late final EndpointRealtime realtime;

  late final EndpointSync sync;

  late final EndpointTask task;

  late final EndpointTrash trash;

  late final Modules modules;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'collab': collab,
    'consumable': consumable,
    'equipment': equipment,
    'health': health,
    'intake': intake,
    'meeting': meeting,
    'onboarding': onboarding,
    'org': org,
    'partnership': partnership,
    'project': project,
    'realtime': realtime,
    'sync': sync,
    'task': task,
    'trash': trash,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {
    'auth': modules.auth,
  };
}
