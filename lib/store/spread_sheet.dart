import 'package:flutter/foundation.dart' hide immutable;
import 'package:cl_spreadsheet/store/cell_data.dart';
import 'package:cl_spreadsheet/store/spreadsheet_db.dart';
import 'package:meta/meta.dart';

@immutable
class SpreadSheet {
  const SpreadSheet({required this.db, required this.data});
  final Map<int, Map<int, CellData>> data;
  final SpreadsheetDB db;

  SpreadSheet copyWith({
    Map<int, Map<int, CellData>>? data,
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
    int row,
    int col,
    CellData? cellData,
  ) async {
    if (cellData == null) {
      if (data[row]![col] != null) {
        await db.delete(row, col);
        final updated = Map<int, Map<int, CellData>>.from(data);
        updated[row]!.remove(col);
        if (updated[row]!.isEmpty) {
          updated.remove(row);
        }
        return copyWith(data: updated);
      }
      return this;
    } else {
      // First update db
      await db.upsert(row, col, cellData);
      final updated = Map<int, Map<int, CellData>>.from(data);
      updated.putIfAbsent(row, () => {});
      updated[row]![col] = cellData;
      return copyWith(data: updated);
    }
  }

  CellData? read(int row, int col) {
    return data[row]?[col];
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
