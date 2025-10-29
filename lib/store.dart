// To run this, you need to add these dependencies to your pubspec.yaml:
// dependencies:
//   sqlite_async: ^2.0.0
//   path: ^1.8.0

import 'dart:io';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

// =============================================================================
// 1. DATA MODEL
// =============================================================================

/// Represents a single cell's data in the spreadsheet.
/// It stores the main 'value' and an arbitrary 'properties' map.
class CellData {
  final dynamic value;
  final Map<String, dynamic> properties;

  CellData({required this.value, required this.properties});

  /// Converts the Dart object to a JSON map for serialization.
  Map<String, dynamic> toJson() => {'value': value, 'properties': properties};

  /// Creates a Dart object from a JSON map (after deserialization).
  factory CellData.fromJson(Map<String, dynamic> json) {
    return CellData(
      value: json['value'],
      properties: json['properties'] ?? {}, // Default to empty map if null
    );
  }

  @override
  String toString() {
    String valueType = (value != null) ? '(${value.runtimeType})' : '';
    return 'CellData(value: $value$valueType, properties: $properties)';
  }
}

// =============================================================================
// 2. DATABASE MANAGER (SpreadsheetDB)
// =============================================================================

class SpreadsheetDB {
  static const String dbName = 'spreadsheet.db';
  late final SqliteDatabase _db;

  /// Initializes the database connection and creates the table.
  Future<void> initialize() async {
    final dbPath = p.join(Directory.current.path, dbName);
    _db = SqliteDatabase(path: dbPath);

    // Using a single TEXT column to store the combined JSON object
    await _db.execute('''
      CREATE TABLE IF NOT EXISTS cells (
          row_index       INTEGER NOT NULL,
          col_index       INTEGER NOT NULL,
          cell_data       TEXT, -- Stores the entire cell structure as a JSON string
          PRIMARY KEY (row_index, col_index)
      );
      CREATE INDEX IF NOT EXISTS idx_row ON cells (row_index);
      CREATE INDEX IF NOT EXISTS idx_col ON cells (col_index);
    ''');
    //print('Database initialized at $dbPath');
  }

  /// Inserts or replaces a cell's data. Automatically handles serialization to JSON.
  Future<void> upsert(
    int row,
    int col,
    dynamic value,
    Map<String, dynamic> properties,
  ) async {
    if (value == null) {
      // Treat null value insertion as a DELETE operation in a sparse model
      return delete(row, col);
    }

    final cell = CellData(value: value, properties: properties);
    final cellJson = jsonEncode(cell.toJson());

    await _db.execute(
      '''
      INSERT OR REPLACE INTO cells 
      (row_index, col_index, cell_data)
      VALUES (?, ?, ?);
      ''',
      [row, col, cellJson],
    );
  }

  /// Reads a cell, deserializes the JSON, and returns the CellData object.
  Future<CellData?> read(int row, int col) async {
    final result = await _db.get(
      'SELECT cell_data FROM cells WHERE row_index = ? AND col_index = ?;',
      [row, col],
    );

    if (result['cell_data'] == null) {
      return null; // Cell is implicitly NULL
    }

    final jsonString = result['cell_data'] as String;
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    return CellData.fromJson(jsonMap);
  }

  /// Deletes a cell record, effectively setting it to NULL.
  Future<void> delete(int row, int col) async {
    await _db.execute(
      'DELETE FROM cells WHERE row_index = ? AND col_index = ?;',
      [row, col],
    );
  }

  /// Returns the entire dataset as a nested Map for initial population.
  /// Format: Map\<row_index, Map\<col_index, CellData>>
  Future<Map<int, Map<int, CellData>>> readAll() async {
    final allRows = await _db.getAll(
      'SELECT row_index, col_index, cell_data FROM cells;',
    );

    final Map<int, Map<int, CellData>> spreadsheet = {};

    for (final rowData in allRows) {
      final row = rowData['row_index'] as int;
      final col = rowData['col_index'] as int;
      final jsonString = rowData['cell_data'] as String;

      // Deserialize
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final cellData = CellData.fromJson(jsonMap);

      spreadsheet.putIfAbsent(row, () => {});
      spreadsheet[row]![col] = cellData;
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