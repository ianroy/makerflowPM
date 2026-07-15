import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import '../business/audit.dart';
import '../business/custom_fields.dart';
import '../business/rbac.dart';

/// Custom-field DEFINITIONS (fl-8-view-field-endpoints). Members read them to
/// render columns; only workspaceAdmin+ mutates the schema. Values land with
/// fl-8-custom-fields (D6: JSON property bag on the entity).
class FieldConfigEndpoint extends Endpoint {
  /// Field types the platform accepts today (tier-1 set; extends with
  /// fl-8-custom-fields). Kept server-side so clients can't invent types.
  static const allowedFieldTypes = {
    'text', 'longText', 'number', 'date', 'select', 'multiSelect',
    'person', 'checkbox', 'label',
  };

  Future<List<FieldConfig>> list(Session session, int organizationId,
      {String? entityType}) async {
    await RbacGuard.requireRole(session, organizationId, MembershipRole.viewer);
    return FieldConfig.db.find(
      session,
      where: (f) {
        var w = f.organizationId.equals(organizationId);
        if (entityType != null) w &= f.entityType.equals(entityType);
        return w;
      },
      orderBy: (f) => f.sortOrder,
    );
  }

  /// Create or update a definition (workspaceAdmin+). Validates the field type
  /// and guards the (org, entityType, key) uniqueness with a typed conflict.
  ///
  /// Changing an existing field's TYPE while tasks hold values for it is a
  /// two-step confirm (the Airtable pattern): the first save throws a typed
  /// Conflict stating how many values are affected; retrying with
  /// [coerceValues] converts them (safe conversions per
  /// [CustomFields.coerceValue]; unconvertible values are cleared).
  Future<FieldConfig> save(Session session, FieldConfig draft,
      {bool coerceValues = false}) async {
    final ctx = await RbacGuard.requireRole(
        session, draft.organizationId, MembershipRole.workspaceAdmin);
    if (!allowedFieldTypes.contains(draft.fieldType)) {
      throw MakerflowConflictException(
          message: 'Unknown field type "${draft.fieldType}". '
              'Allowed: ${allowedFieldTypes.join(', ')}.');
    }
    final now = DateTime.now().toUtc();

    final draftId = draft.id;
    final FieldConfig saved;
    var coercedCount = 0;
    if (draftId == null) {
      final dup = await FieldConfig.db.findFirstRow(
        session,
        where: (f) =>
            f.organizationId.equals(draft.organizationId) &
            f.entityType.equals(draft.entityType) &
            f.key.equals(draft.key),
      );
      if (dup != null) {
        throw MakerflowConflictException(
            message: 'A field with key "${draft.key}" already exists for '
                '${draft.entityType}.');
      }
      saved = await FieldConfig.db.insertRow(
          session, draft.copyWith(createdAt: now, updatedAt: now));
    } else {
      final existing = await FieldConfig.db.findById(session, draftId);
      if (existing == null || existing.organizationId != draft.organizationId) {
        throw MakerflowNotFoundException(message: 'Field not found.');
      }
      // Warn-before-write: the affected-values check must precede the row
      // update, or an unconfirmed type change would already be persisted.
      final typeChanged = existing.fieldType != draft.fieldType;
      if (typeChanged && existing.entityType == 'task' && !coerceValues) {
        final affected = await CustomFields.countTaskValues(session, existing);
        if (affected > 0) {
          throw MakerflowConflictException(
              message: 'Changing "${existing.key}" from ${existing.fieldType} '
                  'to ${draft.fieldType} affects $affected existing value'
                  '${affected == 1 ? '' : 's'}. Retry with coerceValues to '
                  'convert them (unconvertible values are cleared).');
        }
      }
      saved = await FieldConfig.db.updateRow(
        session,
        draft.copyWith(
          organizationId: existing.organizationId, // tenancy pinned
          entityType: existing.entityType, // identity pinned
          key: existing.key, // key is immutable once created (values key on it)
          createdAt: existing.createdAt,
          updatedAt: now,
        ),
      );
      if (typeChanged && existing.entityType == 'task') {
        coercedCount = await CustomFields.coerceTaskValues(session, saved);
      }
    }
    await Audit.record(session,
        ctx: ctx,
        entityType: 'fieldConfig',
        entityId: saved.id,
        action: draftId == null ? 'create' : 'update',
        summary: '${saved.entityType}.${saved.key} (${saved.fieldType})'
            '${coercedCount > 0 ? ' — coerced $coercedCount values' : ''}');
    return saved;
  }

  /// Remove a definition (workspaceAdmin+). Hard delete is acceptable while no
  /// value storage exists; fl-8-custom-fields upgrades this to retire.
  Future<void> delete(Session session, int id) async {
    final existing = await FieldConfig.db.findById(session, id);
    if (existing == null) {
      throw MakerflowNotFoundException(message: 'Field not found.');
    }
    final ctx = await RbacGuard.requireRole(
        session, existing.organizationId, MembershipRole.workspaceAdmin);
    await FieldConfig.db.deleteRow(session, existing);
    await Audit.record(session,
        ctx: ctx,
        entityType: 'fieldConfig',
        entityId: id,
        action: 'delete',
        summary: '${existing.entityType}.${existing.key}');
  }
}
