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

  Future<SpreadSheet> upsert(int row, int col, CellData? cellData) async {
    // First update db
    await db.upsert(row, col, cellData);
    final celldataOnDb = await db.read(row, col);
    if (celldataOnDb == null) {
      return this;
    }
    final updated = Map<int, Map<int, CellData>>.from(data);
    updated.putIfAbsent(row, () => {});
    updated[row]![col] = celldataOnDb;
    return copyWith(data: updated);
  }

  Future<SpreadSheet> delete(int row, int col) async {
    await db.delete(row, col);
    final celldataOnDb = await db.read(row, col);
    if (celldataOnDb == null) {
      // delete from local if exists
      return this;
    }
    final updated = Map<int, Map<int, CellData>>.from(data);
    data.putIfAbsent(row, () => {});
    updated[row]![col] = celldataOnDb;
    return copyWith(data: updated);
  }

  CellData? read(int row, int col) {
    // Assume the data is in sync with db. Need to work if this is not the case!
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
