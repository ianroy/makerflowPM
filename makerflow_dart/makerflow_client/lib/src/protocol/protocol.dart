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
import 'attachment.dart' as _i2;
import 'audit_log.dart' as _i3;
import 'calendar_event.dart' as _i4;
import 'calendar_sync_link.dart' as _i5;
import 'calendar_sync_setting.dart' as _i6;
import 'change_event.dart' as _i7;
import 'consumable.dart' as _i8;
import 'custom_view.dart' as _i9;
import 'device_token.dart' as _i10;
import 'email_message.dart' as _i11;
import 'enums/attachment_kind.dart' as _i12;
import 'enums/consumable_status.dart' as _i13;
import 'enums/equipment_status.dart' as _i14;
import 'enums/intake_stage.dart' as _i15;
import 'enums/lane.dart' as _i16;
import 'enums/membership_role.dart' as _i17;
import 'enums/onboarding_state.dart' as _i18;
import 'enums/partnership_stage.dart' as _i19;
import 'enums/project_status.dart' as _i20;
import 'enums/task_priority.dart' as _i21;
import 'enums/task_status.dart' as _i22;
import 'equipment_asset.dart' as _i23;
import 'field_config.dart' as _i24;
import 'insight_snapshot.dart' as _i25;
import 'intake_request.dart' as _i26;
import 'item_comment.dart' as _i27;
import 'item_watcher.dart' as _i28;
import 'meeting_agenda.dart' as _i29;
import 'meeting_item.dart' as _i30;
import 'meeting_item_note.dart' as _i31;
import 'meeting_note_source.dart' as _i32;
import 'membership.dart' as _i33;
import 'onboarding_assignment.dart' as _i34;
import 'onboarding_template.dart' as _i35;
import 'organization.dart' as _i36;
import 'partnership.dart' as _i37;
import 'password_reset.dart' as _i38;
import 'project.dart' as _i39;
import 'report_template.dart' as _i40;
import 'role_nav_preference.dart' as _i41;
import 'space.dart' as _i42;
import 'sync_cursor.dart' as _i43;
import 'task.dart' as _i44;
import 'task_delta_page.dart' as _i45;
import 'team.dart' as _i46;
import 'team_member.dart' as _i47;
import 'user_preference.dart' as _i48;
import 'user_profile.dart' as _i49;
import 'package:makerflow_client/src/protocol/item_comment.dart' as _i50;
import 'package:makerflow_client/src/protocol/consumable.dart' as _i51;
import 'package:makerflow_client/src/protocol/equipment_asset.dart' as _i52;
import 'package:makerflow_client/src/protocol/intake_request.dart' as _i53;
import 'package:makerflow_client/src/protocol/meeting_agenda.dart' as _i54;
import 'package:makerflow_client/src/protocol/meeting_item.dart' as _i55;
import 'package:makerflow_client/src/protocol/onboarding_template.dart' as _i56;
import 'package:makerflow_client/src/protocol/organization.dart' as _i57;
import 'package:makerflow_client/src/protocol/membership.dart' as _i58;
import 'package:makerflow_client/src/protocol/partnership.dart' as _i59;
import 'package:makerflow_client/src/protocol/project.dart' as _i60;
import 'package:makerflow_client/src/protocol/task.dart' as _i61;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i62;
export 'attachment.dart';
export 'audit_log.dart';
export 'calendar_event.dart';
export 'calendar_sync_link.dart';
export 'calendar_sync_setting.dart';
export 'change_event.dart';
export 'consumable.dart';
export 'custom_view.dart';
export 'device_token.dart';
export 'email_message.dart';
export 'enums/attachment_kind.dart';
export 'enums/consumable_status.dart';
export 'enums/equipment_status.dart';
export 'enums/intake_stage.dart';
export 'enums/lane.dart';
export 'enums/membership_role.dart';
export 'enums/onboarding_state.dart';
export 'enums/partnership_stage.dart';
export 'enums/project_status.dart';
export 'enums/task_priority.dart';
export 'enums/task_status.dart';
export 'equipment_asset.dart';
export 'field_config.dart';
export 'insight_snapshot.dart';
export 'intake_request.dart';
export 'item_comment.dart';
export 'item_watcher.dart';
export 'meeting_agenda.dart';
export 'meeting_item.dart';
export 'meeting_item_note.dart';
export 'meeting_note_source.dart';
export 'membership.dart';
export 'onboarding_assignment.dart';
export 'onboarding_template.dart';
export 'organization.dart';
export 'partnership.dart';
export 'password_reset.dart';
export 'project.dart';
export 'report_template.dart';
export 'role_nav_preference.dart';
export 'space.dart';
export 'sync_cursor.dart';
export 'task.dart';
export 'task_delta_page.dart';
export 'team.dart';
export 'team_member.dart';
export 'user_preference.dart';
export 'user_profile.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Attachment) {
      return _i2.Attachment.fromJson(data) as T;
    }
    if (t == _i3.AuditLog) {
      return _i3.AuditLog.fromJson(data) as T;
    }
    if (t == _i4.CalendarEvent) {
      return _i4.CalendarEvent.fromJson(data) as T;
    }
    if (t == _i5.CalendarSyncLink) {
      return _i5.CalendarSyncLink.fromJson(data) as T;
    }
    if (t == _i6.CalendarSyncSetting) {
      return _i6.CalendarSyncSetting.fromJson(data) as T;
    }
    if (t == _i7.ChangeEvent) {
      return _i7.ChangeEvent.fromJson(data) as T;
    }
    if (t == _i8.Consumable) {
      return _i8.Consumable.fromJson(data) as T;
    }
    if (t == _i9.CustomView) {
      return _i9.CustomView.fromJson(data) as T;
    }
    if (t == _i10.DeviceToken) {
      return _i10.DeviceToken.fromJson(data) as T;
    }
    if (t == _i11.EmailMessage) {
      return _i11.EmailMessage.fromJson(data) as T;
    }
    if (t == _i12.AttachmentKind) {
      return _i12.AttachmentKind.fromJson(data) as T;
    }
    if (t == _i13.ConsumableStatus) {
      return _i13.ConsumableStatus.fromJson(data) as T;
    }
    if (t == _i14.EquipmentStatus) {
      return _i14.EquipmentStatus.fromJson(data) as T;
    }
    if (t == _i15.IntakeStage) {
      return _i15.IntakeStage.fromJson(data) as T;
    }
    if (t == _i16.Lane) {
      return _i16.Lane.fromJson(data) as T;
    }
    if (t == _i17.MembershipRole) {
      return _i17.MembershipRole.fromJson(data) as T;
    }
    if (t == _i18.OnboardingState) {
      return _i18.OnboardingState.fromJson(data) as T;
    }
    if (t == _i19.PartnershipStage) {
      return _i19.PartnershipStage.fromJson(data) as T;
    }
    if (t == _i20.ProjectStatus) {
      return _i20.ProjectStatus.fromJson(data) as T;
    }
    if (t == _i21.TaskPriority) {
      return _i21.TaskPriority.fromJson(data) as T;
    }
    if (t == _i22.TaskStatus) {
      return _i22.TaskStatus.fromJson(data) as T;
    }
    if (t == _i23.EquipmentAsset) {
      return _i23.EquipmentAsset.fromJson(data) as T;
    }
    if (t == _i24.FieldConfig) {
      return _i24.FieldConfig.fromJson(data) as T;
    }
    if (t == _i25.InsightSnapshot) {
      return _i25.InsightSnapshot.fromJson(data) as T;
    }
    if (t == _i26.IntakeRequest) {
      return _i26.IntakeRequest.fromJson(data) as T;
    }
    if (t == _i27.ItemComment) {
      return _i27.ItemComment.fromJson(data) as T;
    }
    if (t == _i28.ItemWatcher) {
      return _i28.ItemWatcher.fromJson(data) as T;
    }
    if (t == _i29.MeetingAgenda) {
      return _i29.MeetingAgenda.fromJson(data) as T;
    }
    if (t == _i30.MeetingItem) {
      return _i30.MeetingItem.fromJson(data) as T;
    }
    if (t == _i31.MeetingItemNote) {
      return _i31.MeetingItemNote.fromJson(data) as T;
    }
    if (t == _i32.MeetingNoteSource) {
      return _i32.MeetingNoteSource.fromJson(data) as T;
    }
    if (t == _i33.Membership) {
      return _i33.Membership.fromJson(data) as T;
    }
    if (t == _i34.OnboardingAssignment) {
      return _i34.OnboardingAssignment.fromJson(data) as T;
    }
    if (t == _i35.OnboardingTemplate) {
      return _i35.OnboardingTemplate.fromJson(data) as T;
    }
    if (t == _i36.Organization) {
      return _i36.Organization.fromJson(data) as T;
    }
    if (t == _i37.Partnership) {
      return _i37.Partnership.fromJson(data) as T;
    }
    if (t == _i38.PasswordReset) {
      return _i38.PasswordReset.fromJson(data) as T;
    }
    if (t == _i39.Project) {
      return _i39.Project.fromJson(data) as T;
    }
    if (t == _i40.ReportTemplate) {
      return _i40.ReportTemplate.fromJson(data) as T;
    }
    if (t == _i41.RoleNavPreference) {
      return _i41.RoleNavPreference.fromJson(data) as T;
    }
    if (t == _i42.Space) {
      return _i42.Space.fromJson(data) as T;
    }
    if (t == _i43.SyncCursor) {
      return _i43.SyncCursor.fromJson(data) as T;
    }
    if (t == _i44.Task) {
      return _i44.Task.fromJson(data) as T;
    }
    if (t == _i45.TaskDeltaPage) {
      return _i45.TaskDeltaPage.fromJson(data) as T;
    }
    if (t == _i46.Team) {
      return _i46.Team.fromJson(data) as T;
    }
    if (t == _i47.TeamMember) {
      return _i47.TeamMember.fromJson(data) as T;
    }
    if (t == _i48.UserPreference) {
      return _i48.UserPreference.fromJson(data) as T;
    }
    if (t == _i49.UserProfile) {
      return _i49.UserProfile.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Attachment?>()) {
      return (data != null ? _i2.Attachment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AuditLog?>()) {
      return (data != null ? _i3.AuditLog.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.CalendarEvent?>()) {
      return (data != null ? _i4.CalendarEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.CalendarSyncLink?>()) {
      return (data != null ? _i5.CalendarSyncLink.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.CalendarSyncSetting?>()) {
      return (data != null ? _i6.CalendarSyncSetting.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.ChangeEvent?>()) {
      return (data != null ? _i7.ChangeEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Consumable?>()) {
      return (data != null ? _i8.Consumable.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.CustomView?>()) {
      return (data != null ? _i9.CustomView.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.DeviceToken?>()) {
      return (data != null ? _i10.DeviceToken.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.EmailMessage?>()) {
      return (data != null ? _i11.EmailMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.AttachmentKind?>()) {
      return (data != null ? _i12.AttachmentKind.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.ConsumableStatus?>()) {
      return (data != null ? _i13.ConsumableStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.EquipmentStatus?>()) {
      return (data != null ? _i14.EquipmentStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.IntakeStage?>()) {
      return (data != null ? _i15.IntakeStage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.Lane?>()) {
      return (data != null ? _i16.Lane.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.MembershipRole?>()) {
      return (data != null ? _i17.MembershipRole.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.OnboardingState?>()) {
      return (data != null ? _i18.OnboardingState.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.PartnershipStage?>()) {
      return (data != null ? _i19.PartnershipStage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i20.ProjectStatus?>()) {
      return (data != null ? _i20.ProjectStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i21.TaskPriority?>()) {
      return (data != null ? _i21.TaskPriority.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i22.TaskStatus?>()) {
      return (data != null ? _i22.TaskStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i23.EquipmentAsset?>()) {
      return (data != null ? _i23.EquipmentAsset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i24.FieldConfig?>()) {
      return (data != null ? _i24.FieldConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i25.InsightSnapshot?>()) {
      return (data != null ? _i25.InsightSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i26.IntakeRequest?>()) {
      return (data != null ? _i26.IntakeRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i27.ItemComment?>()) {
      return (data != null ? _i27.ItemComment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i28.ItemWatcher?>()) {
      return (data != null ? _i28.ItemWatcher.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.MeetingAgenda?>()) {
      return (data != null ? _i29.MeetingAgenda.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.MeetingItem?>()) {
      return (data != null ? _i30.MeetingItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.MeetingItemNote?>()) {
      return (data != null ? _i31.MeetingItemNote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.MeetingNoteSource?>()) {
      return (data != null ? _i32.MeetingNoteSource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.Membership?>()) {
      return (data != null ? _i33.Membership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.OnboardingAssignment?>()) {
      return (data != null ? _i34.OnboardingAssignment.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i35.OnboardingTemplate?>()) {
      return (data != null ? _i35.OnboardingTemplate.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i36.Organization?>()) {
      return (data != null ? _i36.Organization.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.Partnership?>()) {
      return (data != null ? _i37.Partnership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.PasswordReset?>()) {
      return (data != null ? _i38.PasswordReset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i39.Project?>()) {
      return (data != null ? _i39.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i40.ReportTemplate?>()) {
      return (data != null ? _i40.ReportTemplate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.RoleNavPreference?>()) {
      return (data != null ? _i41.RoleNavPreference.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.Space?>()) {
      return (data != null ? _i42.Space.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.SyncCursor?>()) {
      return (data != null ? _i43.SyncCursor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.Task?>()) {
      return (data != null ? _i44.Task.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.TaskDeltaPage?>()) {
      return (data != null ? _i45.TaskDeltaPage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.Team?>()) {
      return (data != null ? _i46.Team.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.TeamMember?>()) {
      return (data != null ? _i47.TeamMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.UserPreference?>()) {
      return (data != null ? _i48.UserPreference.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.UserProfile?>()) {
      return (data != null ? _i49.UserProfile.fromJson(data) : null) as T;
    }
    if (t == List<_i44.Task>) {
      return (data as List).map((e) => deserialize<_i44.Task>(e)).toList() as T;
    }
    if (t == List<_i50.ItemComment>) {
      return (data as List)
              .map((e) => deserialize<_i50.ItemComment>(e))
              .toList()
          as T;
    }
    if (t == List<_i51.Consumable>) {
      return (data as List).map((e) => deserialize<_i51.Consumable>(e)).toList()
          as T;
    }
    if (t == List<_i52.EquipmentAsset>) {
      return (data as List)
              .map((e) => deserialize<_i52.EquipmentAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i53.IntakeRequest>) {
      return (data as List)
              .map((e) => deserialize<_i53.IntakeRequest>(e))
              .toList()
          as T;
    }
    if (t == List<_i54.MeetingAgenda>) {
      return (data as List)
              .map((e) => deserialize<_i54.MeetingAgenda>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.MeetingItem>) {
      return (data as List)
              .map((e) => deserialize<_i55.MeetingItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i56.OnboardingTemplate>) {
      return (data as List)
              .map((e) => deserialize<_i56.OnboardingTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_i57.Organization>) {
      return (data as List)
              .map((e) => deserialize<_i57.Organization>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.Membership>) {
      return (data as List).map((e) => deserialize<_i58.Membership>(e)).toList()
          as T;
    }
    if (t == List<_i59.Partnership>) {
      return (data as List)
              .map((e) => deserialize<_i59.Partnership>(e))
              .toList()
          as T;
    }
    if (t == List<_i60.Project>) {
      return (data as List).map((e) => deserialize<_i60.Project>(e)).toList()
          as T;
    }
    if (t == List<_i61.Task>) {
      return (data as List).map((e) => deserialize<_i61.Task>(e)).toList() as T;
    }
    try {
      return _i62.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.Attachment => 'Attachment',
      _i3.AuditLog => 'AuditLog',
      _i4.CalendarEvent => 'CalendarEvent',
      _i5.CalendarSyncLink => 'CalendarSyncLink',
      _i6.CalendarSyncSetting => 'CalendarSyncSetting',
      _i7.ChangeEvent => 'ChangeEvent',
      _i8.Consumable => 'Consumable',
      _i9.CustomView => 'CustomView',
      _i10.DeviceToken => 'DeviceToken',
      _i11.EmailMessage => 'EmailMessage',
      _i12.AttachmentKind => 'AttachmentKind',
      _i13.ConsumableStatus => 'ConsumableStatus',
      _i14.EquipmentStatus => 'EquipmentStatus',
      _i15.IntakeStage => 'IntakeStage',
      _i16.Lane => 'Lane',
      _i17.MembershipRole => 'MembershipRole',
      _i18.OnboardingState => 'OnboardingState',
      _i19.PartnershipStage => 'PartnershipStage',
      _i20.ProjectStatus => 'ProjectStatus',
      _i21.TaskPriority => 'TaskPriority',
      _i22.TaskStatus => 'TaskStatus',
      _i23.EquipmentAsset => 'EquipmentAsset',
      _i24.FieldConfig => 'FieldConfig',
      _i25.InsightSnapshot => 'InsightSnapshot',
      _i26.IntakeRequest => 'IntakeRequest',
      _i27.ItemComment => 'ItemComment',
      _i28.ItemWatcher => 'ItemWatcher',
      _i29.MeetingAgenda => 'MeetingAgenda',
      _i30.MeetingItem => 'MeetingItem',
      _i31.MeetingItemNote => 'MeetingItemNote',
      _i32.MeetingNoteSource => 'MeetingNoteSource',
      _i33.Membership => 'Membership',
      _i34.OnboardingAssignment => 'OnboardingAssignment',
      _i35.OnboardingTemplate => 'OnboardingTemplate',
      _i36.Organization => 'Organization',
      _i37.Partnership => 'Partnership',
      _i38.PasswordReset => 'PasswordReset',
      _i39.Project => 'Project',
      _i40.ReportTemplate => 'ReportTemplate',
      _i41.RoleNavPreference => 'RoleNavPreference',
      _i42.Space => 'Space',
      _i43.SyncCursor => 'SyncCursor',
      _i44.Task => 'Task',
      _i45.TaskDeltaPage => 'TaskDeltaPage',
      _i46.Team => 'Team',
      _i47.TeamMember => 'TeamMember',
      _i48.UserPreference => 'UserPreference',
      _i49.UserProfile => 'UserProfile',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('makerflow.', '');
    }

    switch (data) {
      case _i2.Attachment():
        return 'Attachment';
      case _i3.AuditLog():
        return 'AuditLog';
      case _i4.CalendarEvent():
        return 'CalendarEvent';
      case _i5.CalendarSyncLink():
        return 'CalendarSyncLink';
      case _i6.CalendarSyncSetting():
        return 'CalendarSyncSetting';
      case _i7.ChangeEvent():
        return 'ChangeEvent';
      case _i8.Consumable():
        return 'Consumable';
      case _i9.CustomView():
        return 'CustomView';
      case _i10.DeviceToken():
        return 'DeviceToken';
      case _i11.EmailMessage():
        return 'EmailMessage';
      case _i12.AttachmentKind():
        return 'AttachmentKind';
      case _i13.ConsumableStatus():
        return 'ConsumableStatus';
      case _i14.EquipmentStatus():
        return 'EquipmentStatus';
      case _i15.IntakeStage():
        return 'IntakeStage';
      case _i16.Lane():
        return 'Lane';
      case _i17.MembershipRole():
        return 'MembershipRole';
      case _i18.OnboardingState():
        return 'OnboardingState';
      case _i19.PartnershipStage():
        return 'PartnershipStage';
      case _i20.ProjectStatus():
        return 'ProjectStatus';
      case _i21.TaskPriority():
        return 'TaskPriority';
      case _i22.TaskStatus():
        return 'TaskStatus';
      case _i23.EquipmentAsset():
        return 'EquipmentAsset';
      case _i24.FieldConfig():
        return 'FieldConfig';
      case _i25.InsightSnapshot():
        return 'InsightSnapshot';
      case _i26.IntakeRequest():
        return 'IntakeRequest';
      case _i27.ItemComment():
        return 'ItemComment';
      case _i28.ItemWatcher():
        return 'ItemWatcher';
      case _i29.MeetingAgenda():
        return 'MeetingAgenda';
      case _i30.MeetingItem():
        return 'MeetingItem';
      case _i31.MeetingItemNote():
        return 'MeetingItemNote';
      case _i32.MeetingNoteSource():
        return 'MeetingNoteSource';
      case _i33.Membership():
        return 'Membership';
      case _i34.OnboardingAssignment():
        return 'OnboardingAssignment';
      case _i35.OnboardingTemplate():
        return 'OnboardingTemplate';
      case _i36.Organization():
        return 'Organization';
      case _i37.Partnership():
        return 'Partnership';
      case _i38.PasswordReset():
        return 'PasswordReset';
      case _i39.Project():
        return 'Project';
      case _i40.ReportTemplate():
        return 'ReportTemplate';
      case _i41.RoleNavPreference():
        return 'RoleNavPreference';
      case _i42.Space():
        return 'Space';
      case _i43.SyncCursor():
        return 'SyncCursor';
      case _i44.Task():
        return 'Task';
      case _i45.TaskDeltaPage():
        return 'TaskDeltaPage';
      case _i46.Team():
        return 'Team';
      case _i47.TeamMember():
        return 'TeamMember';
      case _i48.UserPreference():
        return 'UserPreference';
      case _i49.UserProfile():
        return 'UserProfile';
    }
    className = _i62.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Attachment') {
      return deserialize<_i2.Attachment>(data['data']);
    }
    if (dataClassName == 'AuditLog') {
      return deserialize<_i3.AuditLog>(data['data']);
    }
    if (dataClassName == 'CalendarEvent') {
      return deserialize<_i4.CalendarEvent>(data['data']);
    }
    if (dataClassName == 'CalendarSyncLink') {
      return deserialize<_i5.CalendarSyncLink>(data['data']);
    }
    if (dataClassName == 'CalendarSyncSetting') {
      return deserialize<_i6.CalendarSyncSetting>(data['data']);
    }
    if (dataClassName == 'ChangeEvent') {
      return deserialize<_i7.ChangeEvent>(data['data']);
    }
    if (dataClassName == 'Consumable') {
      return deserialize<_i8.Consumable>(data['data']);
    }
    if (dataClassName == 'CustomView') {
      return deserialize<_i9.CustomView>(data['data']);
    }
    if (dataClassName == 'DeviceToken') {
      return deserialize<_i10.DeviceToken>(data['data']);
    }
    if (dataClassName == 'EmailMessage') {
      return deserialize<_i11.EmailMessage>(data['data']);
    }
    if (dataClassName == 'AttachmentKind') {
      return deserialize<_i12.AttachmentKind>(data['data']);
    }
    if (dataClassName == 'ConsumableStatus') {
      return deserialize<_i13.ConsumableStatus>(data['data']);
    }
    if (dataClassName == 'EquipmentStatus') {
      return deserialize<_i14.EquipmentStatus>(data['data']);
    }
    if (dataClassName == 'IntakeStage') {
      return deserialize<_i15.IntakeStage>(data['data']);
    }
    if (dataClassName == 'Lane') {
      return deserialize<_i16.Lane>(data['data']);
    }
    if (dataClassName == 'MembershipRole') {
      return deserialize<_i17.MembershipRole>(data['data']);
    }
    if (dataClassName == 'OnboardingState') {
      return deserialize<_i18.OnboardingState>(data['data']);
    }
    if (dataClassName == 'PartnershipStage') {
      return deserialize<_i19.PartnershipStage>(data['data']);
    }
    if (dataClassName == 'ProjectStatus') {
      return deserialize<_i20.ProjectStatus>(data['data']);
    }
    if (dataClassName == 'TaskPriority') {
      return deserialize<_i21.TaskPriority>(data['data']);
    }
    if (dataClassName == 'TaskStatus') {
      return deserialize<_i22.TaskStatus>(data['data']);
    }
    if (dataClassName == 'EquipmentAsset') {
      return deserialize<_i23.EquipmentAsset>(data['data']);
    }
    if (dataClassName == 'FieldConfig') {
      return deserialize<_i24.FieldConfig>(data['data']);
    }
    if (dataClassName == 'InsightSnapshot') {
      return deserialize<_i25.InsightSnapshot>(data['data']);
    }
    if (dataClassName == 'IntakeRequest') {
      return deserialize<_i26.IntakeRequest>(data['data']);
    }
    if (dataClassName == 'ItemComment') {
      return deserialize<_i27.ItemComment>(data['data']);
    }
    if (dataClassName == 'ItemWatcher') {
      return deserialize<_i28.ItemWatcher>(data['data']);
    }
    if (dataClassName == 'MeetingAgenda') {
      return deserialize<_i29.MeetingAgenda>(data['data']);
    }
    if (dataClassName == 'MeetingItem') {
      return deserialize<_i30.MeetingItem>(data['data']);
    }
    if (dataClassName == 'MeetingItemNote') {
      return deserialize<_i31.MeetingItemNote>(data['data']);
    }
    if (dataClassName == 'MeetingNoteSource') {
      return deserialize<_i32.MeetingNoteSource>(data['data']);
    }
    if (dataClassName == 'Membership') {
      return deserialize<_i33.Membership>(data['data']);
    }
    if (dataClassName == 'OnboardingAssignment') {
      return deserialize<_i34.OnboardingAssignment>(data['data']);
    }
    if (dataClassName == 'OnboardingTemplate') {
      return deserialize<_i35.OnboardingTemplate>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_i36.Organization>(data['data']);
    }
    if (dataClassName == 'Partnership') {
      return deserialize<_i37.Partnership>(data['data']);
    }
    if (dataClassName == 'PasswordReset') {
      return deserialize<_i38.PasswordReset>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i39.Project>(data['data']);
    }
    if (dataClassName == 'ReportTemplate') {
      return deserialize<_i40.ReportTemplate>(data['data']);
    }
    if (dataClassName == 'RoleNavPreference') {
      return deserialize<_i41.RoleNavPreference>(data['data']);
    }
    if (dataClassName == 'Space') {
      return deserialize<_i42.Space>(data['data']);
    }
    if (dataClassName == 'SyncCursor') {
      return deserialize<_i43.SyncCursor>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i44.Task>(data['data']);
    }
    if (dataClassName == 'TaskDeltaPage') {
      return deserialize<_i45.TaskDeltaPage>(data['data']);
    }
    if (dataClassName == 'Team') {
      return deserialize<_i46.Team>(data['data']);
    }
    if (dataClassName == 'TeamMember') {
      return deserialize<_i47.TeamMember>(data['data']);
    }
    if (dataClassName == 'UserPreference') {
      return deserialize<_i48.UserPreference>(data['data']);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_i49.UserProfile>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i62.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i62.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
