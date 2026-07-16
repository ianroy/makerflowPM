import 'package:flutter/material.dart';
import 'package:makerflow_design/makerflow_design.dart';

import '../../data/field_models.dart';

/// Custom-field VALUE rendering + editing (fl-8-custom-fields). One place
/// defines how each tier-1 field type looks in a table cell and which editor
/// a tap opens — the Main Table and the task dialog both dispatch here.
///
/// Every cell is a labelled button (WCAG 4.1.2); `label` cells reuse the
/// status-label pattern (full-bleed color + AA ink via [MndLabelColors.textOn]).

/// Display text for a value (also powers column autofit + AT labels).
String customFieldText(FieldConfigVm config, Object? value) {
  // A checkbox is never "empty" — an absent value reads as unchecked.
  if (config.fieldType == 'checkbox') return value == true ? 'Yes' : 'No';
  if (value == null) return '—';
  switch (config.fieldType) {
    case 'date':
      final d = DateTime.tryParse(value.toString());
      if (d == null) return value.toString();
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[d.month - 1]} ${d.day}';
    case 'multiSelect':
      return value is List ? value.join(', ') : value.toString();
    case 'person':
      return 'User #$value';
    default:
      return value.toString();
  }
}

/// A 36px table cell for [config]'s value on a task row.
Widget customFieldCell(
  BuildContext context,
  FieldConfigVm config,
  Object? value, {
  required String taskTitle,
  required ValueChanged<Object?> onSet,
}) {
  final c = MakerflowTheme.of(context).colors;
  final text = customFieldText(config, value);
  final semanticsLabel =
      '${config.label}: $text, for $taskTitle. Edit ${config.label}';

  // Checkbox: tap toggles in place (no dialog).
  if (config.fieldType == 'checkbox') {
    final checked = value == true;
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onSet(checked ? null : true),
        child: Center(
          child: Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 18,
            color: checked ? c.brand : c.muted,
          ),
        ),
      ),
    );
  }

  // Label: full-bleed colored cell (the status-label pattern).
  if (config.fieldType == 'label' && value is String) {
    final option = config.options.where((o) => o.value == value).firstOrNull;
    final bg = option?.color ?? MndLabelColors.blank;
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: () => _openEditor(context, config, value, onSet),
        child: Container(
          color: bg,
          alignment: Alignment.center,
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: MndLabelColors.textOn(bg),
            ),
          ),
        ),
      ),
    );
  }

  return Semantics(
    button: true,
    label: semanticsLabel,
    excludeSemantics: true,
    child: InkWell(
      onTap: () => _openEditor(context, config, value, onSet),
      child: Center(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 13, color: value == null ? c.muted : c.text),
        ),
      ),
    ),
  );
}

/// Open the right editor for [config]'s type; calls [onSet] with the new
/// value (null = clear) when the user commits.
Future<void> _openEditor(BuildContext context, FieldConfigVm config,
    Object? current, ValueChanged<Object?> onSet) {
  return editCustomFieldValue(context, config, current).then((result) {
    if (result != null) onSet(result.value);
  });
}

/// A committed edit ([value] may be null = clear); a null RESULT = cancelled.
class CustomFieldEdit {
  const CustomFieldEdit(this.value);
  final Object? value;
}

/// Per-type value editors. Returns null when cancelled.
Future<CustomFieldEdit?> editCustomFieldValue(
    BuildContext context, FieldConfigVm config, Object? current) async {
  switch (config.fieldType) {
    case 'checkbox':
      return CustomFieldEdit(current == true ? null : true);
    case 'date':
      final now = DateTime.now();
      final initial =
          current is String ? DateTime.tryParse(current) ?? now : now;
      final picked = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(now.year - 5),
        lastDate: DateTime(now.year + 5),
        helpText: config.label,
      );
      // Store DATE-ONLY (no time, no zone): converting local midnight to UTC
      // shifts the date a day for half the world's timezones.
      return picked == null
          ? null
          : CustomFieldEdit(picked.toIso8601String().split('T').first);
    case 'select':
    case 'label':
      // Tolerant of mistyped stored values (schema drift): never hard-cast.
      return _pickOption(context, config, current is String ? current : null);
    case 'multiSelect':
      return _pickMulti(
          context,
          config,
          current is List
              ? current.whereType<String>().toList()
              : const <String>[]);
    case 'person':
      return _editScalar(context, config, current,
          hint: 'serverpod user id (number)',
          parse: (s) => int.tryParse(s),
          parseError: 'Enter a numeric user id');
    case 'number':
      return _editScalar(context, config, current,
          hint: 'e.g. 3.5',
          parse: (s) => num.tryParse(s),
          parseError: 'Enter a number');
    default: // text / longText
      return _editScalar(context, config, current,
          hint: null, parse: (s) => s, parseError: '');
  }
}

/// Text-style editor for text/longText/number/person.
Future<CustomFieldEdit?> _editScalar(
  BuildContext context,
  FieldConfigVm config,
  Object? current, {
  required String? hint,
  required Object? Function(String) parse,
  required String parseError,
}) {
  final controller = TextEditingController(text: current?.toString() ?? '');
  final formKey = GlobalKey<FormState>();
  final isLong = config.fieldType == 'longText';
  return showDialog<CustomFieldEdit>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(config.label),
      content: Form(
        key: formKey,
        child: SizedBox(
          width: 320,
          child: TextFormField(
            key: const ValueKey('cf-editor'),
            controller: controller,
            autofocus: true,
            maxLines: isLong ? 4 : 1,
            decoration: InputDecoration(labelText: config.label, hintText: hint),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null; // empty clears
              return parse(v.trim()) == null ? parseError : null;
            },
            onFieldSubmitted: isLong
                ? null
                : (_) {
                    if (formKey.currentState!.validate()) {
                      final t = controller.text.trim();
                      Navigator.pop(
                          ctx, CustomFieldEdit(t.isEmpty ? null : parse(t)));
                    }
                  },
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;
            final t = controller.text.trim();
            Navigator.pop(ctx, CustomFieldEdit(t.isEmpty ? null : parse(t)));
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

/// Option picker for select/label — label options render as colored pills
/// with AA ink; includes a Clear row.
Future<CustomFieldEdit?> _pickOption(
    BuildContext context, FieldConfigVm config, String? current) {
  return showDialog<CustomFieldEdit>(
    context: context,
    builder: (ctx) {
      final c = MakerflowTheme.of(ctx).colors;
      return SimpleDialog(
        title: Text(config.label),
        children: [
          for (final o in config.options)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, CustomFieldEdit(o.value)),
              child: Semantics(
                button: true,
                selected: o.value == current,
                label: o.value,
                excludeSemantics: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: MndSpace.s12, vertical: MndSpace.s8),
                  decoration: BoxDecoration(
                    color: o.color ??
                        (config.fieldType == 'label'
                            ? MndLabelColors.blank
                            : Colors.transparent),
                    borderRadius:
                        BorderRadius.circular(MakerflowShape.radiusSmall),
                  ),
                  child: Text(
                    o.value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: config.fieldType == 'label'
                          ? MndLabelColors.textOn(o.color ?? MndLabelColors.blank)
                          : c.text,
                    ),
                  ),
                ),
              ),
            ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, const CustomFieldEdit(null)),
            child: Text('Clear', style: TextStyle(color: c.muted)),
          ),
        ],
      );
    },
  );
}

/// Checkbox-list picker for multiSelect.
Future<CustomFieldEdit?> _pickMulti(
    BuildContext context, FieldConfigVm config, List<String> current) {
  final selected = current.toSet();
  return showDialog<CustomFieldEdit>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx2, setState) => AlertDialog(
        title: Text(config.label),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final o in config.options)
                CheckboxListTile(
                  dense: true,
                  title: Text(o.value),
                  value: selected.contains(o.value),
                  onChanged: (v) => setState(() =>
                      v == true ? selected.add(o.value) : selected.remove(o.value)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx2), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(
                ctx2,
                CustomFieldEdit(selected.isEmpty
                    ? null
                    : config.options
                        .map((o) => o.value)
                        .where(selected.contains)
                        .toList())),
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
