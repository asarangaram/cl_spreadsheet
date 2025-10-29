import 'package:flutter/foundation.dart' hide immutable;
import 'package:cl_spreadsheet/models/store/cell_data.dart';
import 'package:cl_spreadsheet/models/store/spreadsheet_db.dart';
import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart'; // Import CheckboxGridId
import 'package:meta/meta.dart';

@immutable
class SpreadSheet {
  const SpreadSheet({required this.db, required this.data});
  final Map<CheckboxGridId, CellData> data;
  final SpreadsheetDB db;

  SpreadSheet copyWith({
    Map<CheckboxGridId, CellData>? data,
    SpreadsheetDB? db,
  }) {
    return SpreadSheet(data: data ?? this.data, db: db ?? this.db);
  }

  @override
  String toString() => 'SpreadSheet(data: $data, db: $db)';

  @override
  bool operator ==(covariant SpreadSheet other) {
    if (identical(this, other)) return true;

    return mapEquals(other.data, data) && other.db == db;
  }

  @override
  int get hashCode => data.hashCode ^ db.hashCode;

  /// cellData == null deletes
  /// cellData != null upserts
  Future<SpreadSheet> upsertOrDelete(
    CheckboxGridId id,
    CellData? cellData,
  ) async {
    if (cellData == null) {
      if (data.containsKey(id)) {
        await db.delete(id);
        final updated = Map<CheckboxGridId, CellData>.from(data);
        updated.remove(id);
        return copyWith(data: updated);
      }
      return this;
    } else {
      // First update db
      await db.upsert(id, cellData);
      final updated = Map<CheckboxGridId, CellData>.from(data);
      updated[id] = cellData;
      return copyWith(data: updated);
    }
  }

  CellData? read(CheckboxGridId id) {
    return data[id];
  }

  static Future<SpreadSheet> load(SpreadsheetDB db) async {
    final data = await db.readAll();
    return SpreadSheet(db: db, data: data);
  }

  Future<SpreadSheet> reload() async {
    final data = await db.readAll();
    return SpreadSheet(db: db, data: data);
  }
}
