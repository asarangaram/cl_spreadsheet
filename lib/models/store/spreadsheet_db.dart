import 'package:sqlite_async/sqlite_async.dart';
import 'dart:developer'; // For logging errors

import 'package:cl_spreadsheet/models/store/cell_data.dart';
import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart'; // Import CheckboxGridId

import 'migration.dart';

class SpreadsheetDB {
  static const String dbName = 'spreadsheet.db';
  final SqliteDatabase db;
  SpreadsheetDB(this.db);

  static Future<SpreadsheetDB> openDB(String dbPath) async {
    final db = SqliteDatabase(path: dbPath);
    await migrations.migrate(db);
    return SpreadsheetDB(db);
  }

  Future<void> upsert(CheckboxGridId id, CellData cellData) async {
    await db.execute(
      '''
      INSERT OR REPLACE INTO cells 
      (row_index, col_index, cell_data)
      VALUES (?, ?, ?);
      ''',
      [id.row, id.column, cellData.toJson()],
    );
  }

  Future<CellData?> read(CheckboxGridId id) async {
    final result = await db.get(
      'SELECT cell_data FROM cells WHERE row_index = ? AND col_index = ?;',
      [id.row, id.column],
    );

    if (result['cell_data'] == null) {
      return null;
    }
    try {
      return CellData.fromJson(result['cell_data'] as String);
    } catch (e, st) {
      log(
        'Error deserializing CellData for R:${id.row}, C:${id.column}: $e\n$st',
      );
      return null; // Return null for corrupted data
    }
  }

  /// Deletes a cell record, effectively setting it to NULL.
  Future<void> delete(CheckboxGridId id) async {
    await db.execute(
      'DELETE FROM cells WHERE row_index = ? AND col_index = ?;',
      [id.row, id.column],
    );
  }

  /// Returns the entire dataset as a flattened Map for initial population.
  /// Format: Map\<CheckboxGridId, CellData>
  Future<Map<CheckboxGridId, CellData>> readAll() async {
    final allRows = await db.getAll(
      'SELECT row_index, col_index, cell_data FROM cells;',
    );

    final Map<CheckboxGridId, CellData> spreadsheet = {};

    for (final rowData in allRows) {
      final row = rowData['row_index'] as int;
      final col = rowData['col_index'] as int;
      final jsonString = rowData['cell_data'] as String;
      final id = CheckboxGridId(row: row, column: col);

      try {
        final cellData = CellData.fromJson(jsonString);
        spreadsheet[id] = cellData;
      } catch (e, st) {
        log('Error deserializing CellData for R:$row, C:$col: $e\n$st');
        // Skip this corrupted entry
      }
    }

    return spreadsheet;
  }
}
/* 
// =============================================================================
// 3. EXAMPLE USAGE (Demonstration)
// =============================================================================

void main() async {
  final dbManager = SpreadsheetDB();
  await dbManager.initialize();

  // --- 1. UPSERTING DATA (Testing all expected types) ---
  print('\n--- Upserting Data ---');
  await dbManager.upsert(1, 1, 'Project Status', {'format': 'bold', 'status': 'title'}); // Text
  await dbManager.upsert(1, 2, 42, {'format': 'general', 'source': 'API'}); // Int
  await dbManager.upsert(2, 1, 3.14159, {'format': 'currency', 'precision': 2}); // Float
  await dbManager.upsert(3, 1, DateTime.now().toIso8601String(), {'format': 'date', 'source': 'internal'}); // DateTime (as ISO String)
  await dbManager.upsert(100, 100, 'End Marker', {});

  // --- 2. READING A SINGLE CELL ---
  print('\n--- Reading Cell (3, 1) ---');
  final cell3_1 = await dbManager.read(3, 1);
  print('R3, C1: $cell3_1');

  // --- 3. READING A NULL CELL ---
  print('\n--- Reading Cell (5, 5) (NULL) ---');
  final cell5_5 = await dbManager.read(5, 5);
  print('R5, C5: $cell5_5');

  // --- 4. READ ALL ---
  print('\n--- Reading All Data ---');
  final allData = await dbManager.readAll();
  print('Total Rows with Data: ${allData.length}');
  
  final cell1_2 = allData[1]![2];
  print('R1, C2 from readAll: Value=${cell1_2.value} (Type: ${cell1_2.value.runtimeType})');
  
  final cell2_1 = allData[2]![1];
  print('R2, C1 from readAll: Value=${cell2_1.value} (Type: ${cell2_1.value.runtimeType})');

  // --- 5. DELETE OPERATION ---
  print('\n--- Deleting Cell (100, 100) ---');
  await dbManager.delete(100, 100);
  final cell100_100_after_delete = await dbManager.read(100, 100);
  print('R100, C100 after delete: $cell100_100_after_delete');
} */