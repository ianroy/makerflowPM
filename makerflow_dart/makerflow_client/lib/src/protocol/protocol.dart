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
import 'exceptions/makerflow_auth_exception.dart' as _i24;
import 'exceptions/makerflow_conflict_exception.dart' as _i25;
import 'exceptions/makerflow_forbidden_exception.dart' as _i26;
import 'exceptions/makerflow_not_found_exception.dart' as _i27;
import 'field_config.dart' as _i28;
import 'insight_snapshot.dart' as _i29;
import 'intake_request.dart' as _i30;
import 'item_comment.dart' as _i31;
import 'item_watcher.dart' as _i32;
import 'meeting_agenda.dart' as _i33;
import 'meeting_item.dart' as _i34;
import 'meeting_item_note.dart' as _i35;
import 'meeting_note_source.dart' as _i36;
import 'membership.dart' as _i37;
import 'onboarding_assignment.dart' as _i38;
import 'onboarding_template.dart' as _i39;
import 'organization.dart' as _i40;
import 'partnership.dart' as _i41;
import 'password_reset.dart' as _i42;
import 'project.dart' as _i43;
import 'report_template.dart' as _i44;
import 'role_nav_preference.dart' as _i45;
import 'space.dart' as _i46;
import 'sync_cursor.dart' as _i47;
import 'task.dart' as _i48;
import 'task_delta_page.dart' as _i49;
import 'team.dart' as _i50;
import 'team_member.dart' as _i51;
import 'user_preference.dart' as _i52;
import 'user_profile.dart' as _i53;
import 'package:makerflow_client/src/protocol/item_comment.dart' as _i54;
import 'package:makerflow_client/src/protocol/consumable.dart' as _i55;
import 'package:makerflow_client/src/protocol/equipment_asset.dart' as _i56;
import 'package:makerflow_client/src/protocol/field_config.dart' as _i57;
import 'package:makerflow_client/src/protocol/intake_request.dart' as _i58;
import 'package:makerflow_client/src/protocol/meeting_agenda.dart' as _i59;
import 'package:makerflow_client/src/protocol/meeting_item.dart' as _i60;
import 'package:makerflow_client/src/protocol/onboarding_template.dart' as _i61;
import 'package:makerflow_client/src/protocol/organization.dart' as _i62;
import 'package:makerflow_client/src/protocol/membership.dart' as _i63;
import 'package:makerflow_client/src/protocol/partnership.dart' as _i64;
import 'package:makerflow_client/src/protocol/project.dart' as _i65;
import 'package:makerflow_client/src/protocol/task.dart' as _i66;
import 'package:makerflow_client/src/protocol/custom_view.dart' as _i67;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i68;
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
export 'exceptions/makerflow_auth_exception.dart';
export 'exceptions/makerflow_conflict_exception.dart';
export 'exceptions/makerflow_forbidden_exception.dart';
export 'exceptions/makerflow_not_found_exception.dart';
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
    if (t == _i24.MakerflowAuthException) {
      return _i24.MakerflowAuthException.fromJson(data) as T;
    }
    if (t == _i25.MakerflowConflictException) {
      return _i25.MakerflowConflictException.fromJson(data) as T;
    }
    if (t == _i26.MakerflowForbiddenException) {
      return _i26.MakerflowForbiddenException.fromJson(data) as T;
    }
    if (t == _i27.MakerflowNotFoundException) {
      return _i27.MakerflowNotFoundException.fromJson(data) as T;
    }
    if (t == _i28.FieldConfig) {
      return _i28.FieldConfig.fromJson(data) as T;
    }
    if (t == _i29.InsightSnapshot) {
      return _i29.InsightSnapshot.fromJson(data) as T;
    }
    if (t == _i30.IntakeRequest) {
      return _i30.IntakeRequest.fromJson(data) as T;
    }
    if (t == _i31.ItemComment) {
      return _i31.ItemComment.fromJson(data) as T;
    }
    if (t == _i32.ItemWatcher) {
      return _i32.ItemWatcher.fromJson(data) as T;
    }
    if (t == _i33.MeetingAgenda) {
      return _i33.MeetingAgenda.fromJson(data) as T;
    }
    if (t == _i34.MeetingItem) {
      return _i34.MeetingItem.fromJson(data) as T;
    }
    if (t == _i35.MeetingItemNote) {
      return _i35.MeetingItemNote.fromJson(data) as T;
    }
    if (t == _i36.MeetingNoteSource) {
      return _i36.MeetingNoteSource.fromJson(data) as T;
    }
    if (t == _i37.Membership) {
      return _i37.Membership.fromJson(data) as T;
    }
    if (t == _i38.OnboardingAssignment) {
      return _i38.OnboardingAssignment.fromJson(data) as T;
    }
    if (t == _i39.OnboardingTemplate) {
      return _i39.OnboardingTemplate.fromJson(data) as T;
    }
    if (t == _i40.Organization) {
      return _i40.Organization.fromJson(data) as T;
    }
    if (t == _i41.Partnership) {
      return _i41.Partnership.fromJson(data) as T;
    }
    if (t == _i42.PasswordReset) {
      return _i42.PasswordReset.fromJson(data) as T;
    }
    if (t == _i43.Project) {
      return _i43.Project.fromJson(data) as T;
    }
    if (t == _i44.ReportTemplate) {
      return _i44.ReportTemplate.fromJson(data) as T;
    }
    if (t == _i45.RoleNavPreference) {
      return _i45.RoleNavPreference.fromJson(data) as T;
    }
    if (t == _i46.Space) {
      return _i46.Space.fromJson(data) as T;
    }
    if (t == _i47.SyncCursor) {
      return _i47.SyncCursor.fromJson(data) as T;
    }
    if (t == _i48.Task) {
      return _i48.Task.fromJson(data) as T;
    }
    if (t == _i49.TaskDeltaPage) {
      return _i49.TaskDeltaPage.fromJson(data) as T;
    }
    if (t == _i50.Team) {
      return _i50.Team.fromJson(data) as T;
    }
    if (t == _i51.TeamMember) {
      return _i51.TeamMember.fromJson(data) as T;
    }
    if (t == _i52.UserPreference) {
      return _i52.UserPreference.fromJson(data) as T;
    }
    if (t == _i53.UserProfile) {
      return _i53.UserProfile.fromJson(data) as T;
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
    if (t == _i1.getType<_i24.MakerflowAuthException?>()) {
      return (data != null ? _i24.MakerflowAuthException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i25.MakerflowConflictException?>()) {
      return (data != null
              ? _i25.MakerflowConflictException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i26.MakerflowForbiddenException?>()) {
      return (data != null
              ? _i26.MakerflowForbiddenException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i27.MakerflowNotFoundException?>()) {
      return (data != null
              ? _i27.MakerflowNotFoundException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i28.FieldConfig?>()) {
      return (data != null ? _i28.FieldConfig.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i29.InsightSnapshot?>()) {
      return (data != null ? _i29.InsightSnapshot.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i30.IntakeRequest?>()) {
      return (data != null ? _i30.IntakeRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i31.ItemComment?>()) {
      return (data != null ? _i31.ItemComment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i32.ItemWatcher?>()) {
      return (data != null ? _i32.ItemWatcher.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i33.MeetingAgenda?>()) {
      return (data != null ? _i33.MeetingAgenda.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i34.MeetingItem?>()) {
      return (data != null ? _i34.MeetingItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i35.MeetingItemNote?>()) {
      return (data != null ? _i35.MeetingItemNote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i36.MeetingNoteSource?>()) {
      return (data != null ? _i36.MeetingNoteSource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i37.Membership?>()) {
      return (data != null ? _i37.Membership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i38.OnboardingAssignment?>()) {
      return (data != null ? _i38.OnboardingAssignment.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i39.OnboardingTemplate?>()) {
      return (data != null ? _i39.OnboardingTemplate.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i40.Organization?>()) {
      return (data != null ? _i40.Organization.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i41.Partnership?>()) {
      return (data != null ? _i41.Partnership.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i42.PasswordReset?>()) {
      return (data != null ? _i42.PasswordReset.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i43.Project?>()) {
      return (data != null ? _i43.Project.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i44.ReportTemplate?>()) {
      return (data != null ? _i44.ReportTemplate.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i45.RoleNavPreference?>()) {
      return (data != null ? _i45.RoleNavPreference.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i46.Space?>()) {
      return (data != null ? _i46.Space.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i47.SyncCursor?>()) {
      return (data != null ? _i47.SyncCursor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i48.Task?>()) {
      return (data != null ? _i48.Task.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i49.TaskDeltaPage?>()) {
      return (data != null ? _i49.TaskDeltaPage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i50.Team?>()) {
      return (data != null ? _i50.Team.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i51.TeamMember?>()) {
      return (data != null ? _i51.TeamMember.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i52.UserPreference?>()) {
      return (data != null ? _i52.UserPreference.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i53.UserProfile?>()) {
      return (data != null ? _i53.UserProfile.fromJson(data) : null) as T;
    }
    if (t == List<_i48.Task>) {
      return (data as List).map((e) => deserialize<_i48.Task>(e)).toList() as T;
    }
    if (t == List<_i54.ItemComment>) {
      return (data as List)
              .map((e) => deserialize<_i54.ItemComment>(e))
              .toList()
          as T;
    }
    if (t == List<_i55.Consumable>) {
      return (data as List).map((e) => deserialize<_i55.Consumable>(e)).toList()
          as T;
    }
    if (t == List<_i56.EquipmentAsset>) {
      return (data as List)
              .map((e) => deserialize<_i56.EquipmentAsset>(e))
              .toList()
          as T;
    }
    if (t == List<_i57.FieldConfig>) {
      return (data as List)
              .map((e) => deserialize<_i57.FieldConfig>(e))
              .toList()
          as T;
    }
    if (t == List<_i58.IntakeRequest>) {
      return (data as List)
              .map((e) => deserialize<_i58.IntakeRequest>(e))
              .toList()
          as T;
    }
    if (t == List<_i59.MeetingAgenda>) {
      return (data as List)
              .map((e) => deserialize<_i59.MeetingAgenda>(e))
              .toList()
          as T;
    }
    if (t == List<_i60.MeetingItem>) {
      return (data as List)
              .map((e) => deserialize<_i60.MeetingItem>(e))
              .toList()
          as T;
    }
    if (t == List<_i61.OnboardingTemplate>) {
      return (data as List)
              .map((e) => deserialize<_i61.OnboardingTemplate>(e))
              .toList()
          as T;
    }
    if (t == List<_i62.Organization>) {
      return (data as List)
              .map((e) => deserialize<_i62.Organization>(e))
              .toList()
          as T;
    }
    if (t == List<_i63.Membership>) {
      return (data as List).map((e) => deserialize<_i63.Membership>(e)).toList()
          as T;
    }
    if (t == List<_i64.Partnership>) {
      return (data as List)
              .map((e) => deserialize<_i64.Partnership>(e))
              .toList()
          as T;
    }
    if (t == List<_i65.Project>) {
      return (data as List).map((e) => deserialize<_i65.Project>(e)).toList()
          as T;
    }
    if (t == List<_i66.Task>) {
      return (data as List).map((e) => deserialize<_i66.Task>(e)).toList() as T;
    }
    if (t == List<_i67.CustomView>) {
      return (data as List).map((e) => deserialize<_i67.CustomView>(e)).toList()
          as T;
    }
    try {
      return _i68.Protocol().deserialize<T>(data, t);
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
      _i24.MakerflowAuthException => 'MakerflowAuthException',
      _i25.MakerflowConflictException => 'MakerflowConflictException',
      _i26.MakerflowForbiddenException => 'MakerflowForbiddenException',
      _i27.MakerflowNotFoundException => 'MakerflowNotFoundException',
      _i28.FieldConfig => 'FieldConfig',
      _i29.InsightSnapshot => 'InsightSnapshot',
      _i30.IntakeRequest => 'IntakeRequest',
      _i31.ItemComment => 'ItemComment',
      _i32.ItemWatcher => 'ItemWatcher',
      _i33.MeetingAgenda => 'MeetingAgenda',
      _i34.MeetingItem => 'MeetingItem',
      _i35.MeetingItemNote => 'MeetingItemNote',
      _i36.MeetingNoteSource => 'MeetingNoteSource',
      _i37.Membership => 'Membership',
      _i38.OnboardingAssignment => 'OnboardingAssignment',
      _i39.OnboardingTemplate => 'OnboardingTemplate',
      _i40.Organization => 'Organization',
      _i41.Partnership => 'Partnership',
      _i42.PasswordReset => 'PasswordReset',
      _i43.Project => 'Project',
      _i44.ReportTemplate => 'ReportTemplate',
      _i45.RoleNavPreference => 'RoleNavPreference',
      _i46.Space => 'Space',
      _i47.SyncCursor => 'SyncCursor',
      _i48.Task => 'Task',
      _i49.TaskDeltaPage => 'TaskDeltaPage',
      _i50.Team => 'Team',
      _i51.TeamMember => 'TeamMember',
      _i52.UserPreference => 'UserPreference',
      _i53.UserProfile => 'UserProfile',
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
      case _i24.MakerflowAuthException():
        return 'MakerflowAuthException';
      case _i25.MakerflowConflictException():
        return 'MakerflowConflictException';
      case _i26.MakerflowForbiddenException():
        return 'MakerflowForbiddenException';
      case _i27.MakerflowNotFoundException():
        return 'MakerflowNotFoundException';
      case _i28.FieldConfig():
        return 'FieldConfig';
      case _i29.InsightSnapshot():
        return 'InsightSnapshot';
      case _i30.IntakeRequest():
        return 'IntakeRequest';
      case _i31.ItemComment():
        return 'ItemComment';
      case _i32.ItemWatcher():
        return 'ItemWatcher';
      case _i33.MeetingAgenda():
        return 'MeetingAgenda';
      case _i34.MeetingItem():
        return 'MeetingItem';
      case _i35.MeetingItemNote():
        return 'MeetingItemNote';
      case _i36.MeetingNoteSource():
        return 'MeetingNoteSource';
      case _i37.Membership():
        return 'Membership';
      case _i38.OnboardingAssignment():
        return 'OnboardingAssignment';
      case _i39.OnboardingTemplate():
        return 'OnboardingTemplate';
      case _i40.Organization():
        return 'Organization';
      case _i41.Partnership():
        return 'Partnership';
      case _i42.PasswordReset():
        return 'PasswordReset';
      case _i43.Project():
        return 'Project';
      case _i44.ReportTemplate():
        return 'ReportTemplate';
      case _i45.RoleNavPreference():
        return 'RoleNavPreference';
      case _i46.Space():
        return 'Space';
      case _i47.SyncCursor():
        return 'SyncCursor';
      case _i48.Task():
        return 'Task';
      case _i49.TaskDeltaPage():
        return 'TaskDeltaPage';
      case _i50.Team():
        return 'Team';
      case _i51.TeamMember():
        return 'TeamMember';
      case _i52.UserPreference():
        return 'UserPreference';
      case _i53.UserProfile():
        return 'UserProfile';
    }
    className = _i68.Protocol().getClassNameForObject(data);
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
    if (dataClassName == 'MakerflowAuthException') {
      return deserialize<_i24.MakerflowAuthException>(data['data']);
    }
    if (dataClassName == 'MakerflowConflictException') {
      return deserialize<_i25.MakerflowConflictException>(data['data']);
    }
    if (dataClassName == 'MakerflowForbiddenException') {
      return deserialize<_i26.MakerflowForbiddenException>(data['data']);
    }
    if (dataClassName == 'MakerflowNotFoundException') {
      return deserialize<_i27.MakerflowNotFoundException>(data['data']);
    }
    if (dataClassName == 'FieldConfig') {
      return deserialize<_i28.FieldConfig>(data['data']);
    }
    if (dataClassName == 'InsightSnapshot') {
      return deserialize<_i29.InsightSnapshot>(data['data']);
    }
    if (dataClassName == 'IntakeRequest') {
      return deserialize<_i30.IntakeRequest>(data['data']);
    }
    if (dataClassName == 'ItemComment') {
      return deserialize<_i31.ItemComment>(data['data']);
    }
    if (dataClassName == 'ItemWatcher') {
      return deserialize<_i32.ItemWatcher>(data['data']);
    }
    if (dataClassName == 'MeetingAgenda') {
      return deserialize<_i33.MeetingAgenda>(data['data']);
    }
    if (dataClassName == 'MeetingItem') {
      return deserialize<_i34.MeetingItem>(data['data']);
    }
    if (dataClassName == 'MeetingItemNote') {
      return deserialize<_i35.MeetingItemNote>(data['data']);
    }
    if (dataClassName == 'MeetingNoteSource') {
      return deserialize<_i36.MeetingNoteSource>(data['data']);
    }
    if (dataClassName == 'Membership') {
      return deserialize<_i37.Membership>(data['data']);
    }
    if (dataClassName == 'OnboardingAssignment') {
      return deserialize<_i38.OnboardingAssignment>(data['data']);
    }
    if (dataClassName == 'OnboardingTemplate') {
      return deserialize<_i39.OnboardingTemplate>(data['data']);
    }
    if (dataClassName == 'Organization') {
      return deserialize<_i40.Organization>(data['data']);
    }
    if (dataClassName == 'Partnership') {
      return deserialize<_i41.Partnership>(data['data']);
    }
    if (dataClassName == 'PasswordReset') {
      return deserialize<_i42.PasswordReset>(data['data']);
    }
    if (dataClassName == 'Project') {
      return deserialize<_i43.Project>(data['data']);
    }
    if (dataClassName == 'ReportTemplate') {
      return deserialize<_i44.ReportTemplate>(data['data']);
    }
    if (dataClassName == 'RoleNavPreference') {
      return deserialize<_i45.RoleNavPreference>(data['data']);
    }
    if (dataClassName == 'Space') {
      return deserialize<_i46.Space>(data['data']);
    }
    if (dataClassName == 'SyncCursor') {
      return deserialize<_i47.SyncCursor>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i48.Task>(data['data']);
    }
    if (dataClassName == 'TaskDeltaPage') {
      return deserialize<_i49.TaskDeltaPage>(data['data']);
    }
    if (dataClassName == 'Team') {
      return deserialize<_i50.Team>(data['data']);
    }
    if (dataClassName == 'TeamMember') {
      return deserialize<_i51.TeamMember>(data['data']);
    }
    if (dataClassName == 'UserPreference') {
      return deserialize<_i52.UserPreference>(data['data']);
    }
    if (dataClassName == 'UserProfile') {
      return deserialize<_i53.UserProfile>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i68.Protocol().deserializeByClassName(data);
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
      return _i68.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
