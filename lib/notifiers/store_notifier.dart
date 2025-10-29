import 'package:minimal_mvn/minimal_mvn.dart';

import '../common/async_value.dart';
import '../models/store/cell_data.dart';
import '../models/store/spread_sheet.dart';
import '../models/store/spreadsheet_db.dart';
import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart'; // Import CheckboxGridId

class SpreadSheetDBNotifier extends MMNotifier<AsyncValue<SpreadSheet>> {
  SpreadSheetDBNotifier(this.dbPath) : super(AsyncValue.loading()) {
    initialize();
  }
  String dbPath;
  final Map<CheckboxGridId, Object> cellErrors = {};

  Future<void> initialize() async {
    try {
      final db = await SpreadsheetDB.openDB(dbPath);
      final spreadSheet = await SpreadSheet.load(db);
      notify(AsyncValue.data(spreadSheet));
    } catch (e, st) {
      notify(AsyncValue.error(e, st));
    }
  }

  Future<void> reload() async {
    state.whenOrNull(
      data: (sheet) async {
        notify(AsyncValue.loading());
        try {
          notify(AsyncValue.data(await sheet.reload()));
        } catch (e, st) {
          notify(AsyncValue.error(e, st));
        }
      },
    );
  }

  Future<bool> upsertOrDelete(CheckboxGridId id, CellData? cellData) async {
    try {
      return await state.when(
        data: (sheet) async {
          try {
            final updatedSheet = await sheet.upsertOrDelete(id, cellData);
            notify(AsyncValue.data(updatedSheet));
            cellErrors.remove(id); // Clear error on success
            notify(
              state,
            ); // Notify listeners that cellErrors might have changed
            return true;
          } catch (e) {
            cellErrors[id] = e; // Store cell-specific error
            notify(
              state,
            ); // Notify listeners that cellErrors might have changed
            return false;
          }
        },
        error: (error, stackTrace) {
          cellErrors[id] =
              'Cannot modify cell: Spreadsheet is in an error state.';
          notify(state);
          return false;
        },
        loading: () {
          cellErrors[id] = 'Cannot modify while loading spreadsheet.';
          notify(state);
          return false;
        },
      );
    } catch (e) {
      cellErrors[id] = e; // Store cell-specific error
      notify(state);
      return false;
    }
  }
}

Map<String, MMManager<SpreadSheetDBNotifier>> openedSheets = {};

MMManager<SpreadSheetDBNotifier> spreadSheetDBManager(String dbPath) {
  if (!openedSheets.containsKey(dbPath)) {
    openedSheets[dbPath] = MMManager(() => SpreadSheetDBNotifier(dbPath));
  }

  return openedSheets[dbPath]!;
}
