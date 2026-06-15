import 'package:serverpod/serverpod.dart';

/// Keyset/cursor pagination (Appendix D/H). Every `list` endpoint returns a
/// [Page] and orders by `(updatedAt, id)` — never `offset` (which drifts under
/// concurrent writes and scans). The sync engine reuses the same cursor shape.
class Cursor {
  Cursor(this.updatedAt, this.id);
  final DateTime updatedAt;
  final int id;

  /// Opaque wire form: "<millisSinceEpoch>:<id>".
  String encode() => '${updatedAt.toUtc().millisecondsSinceEpoch}:$id';

  static Cursor? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final ms = int.tryParse(parts[0]);
    final id = int.tryParse(parts[1]);
    if (ms == null || id == null) return null;
    return Cursor(DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true), id);
  }
}

/// A page of results plus the cursor to fetch the next page (null = end).
class Page<T> {
  Page({required this.items, this.nextCursor});
  final List<T> items;
  final String? nextCursor;
}

/// Clamp a caller-supplied limit to a sane range.
int normalizeLimit(int? limit, {int fallback = 50, int max = 200}) {
  if (limit == null || limit <= 0) return fallback;
  return limit > max ? max : limit;
}
