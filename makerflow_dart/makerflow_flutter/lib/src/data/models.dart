/// Plain client-side view models. These MIRROR the Serverpod model YAML on the
/// server (task.spy.yaml, project.spy.yaml). Once `serverpod generate` runs,
/// the repository layer can swap these for the generated `makerflow_client`
/// types directly — they are intentionally field-compatible.
class TaskVm {
  TaskVm({
    required this.id,
    required this.organizationId,
    required this.title,
    required this.status,
    required this.priority,
    this.projectId,
    this.assigneeName,
    this.dueAt,
    this.sortOrder = 0,
    this.customFields = const {},
    this.version = 1,
  });

  final int id;
  final int organizationId;
  final String title;
  String status; // matches TaskStatus enum names: backlog/todo/inProgress/...
  String priority;
  final int? projectId;
  final String? assigneeName;
  final DateTime? dueAt;
  double sortOrder;

  /// D6 custom-field values, keyed by FieldConfig.key (decoded from the
  /// server's `customFieldsJson`). Value shapes per field type are documented
  /// on the server's CustomFields validator.
  final Map<String, dynamic> customFields;
  int version;

  TaskVm copyWith(
          {String? status,
          double? sortOrder,
          Map<String, dynamic>? customFields,
          int? version}) =>
      TaskVm(
        id: id,
        organizationId: organizationId,
        title: title,
        status: status ?? this.status,
        priority: priority,
        projectId: projectId,
        assigneeName: assigneeName,
        dueAt: dueAt,
        sortOrder: sortOrder ?? this.sortOrder,
        customFields: customFields ?? this.customFields,
        version: version ?? this.version,
      );
}

// ProjectVm moved to feature_models.dart (richer: adds `lane`).

/// Ordered kanban columns. Single source for both drag and keyboard moves.
const kanbanColumns = <String>[
  'backlog',
  'todo',
  'inProgress',
  'inReview',
  'blocked',
  'done',
];
