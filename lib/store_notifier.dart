import 'package:minimal_mvn/minimal_mvn.dart';

import 'common/async_value.dart';
import 'store/cell_data.dart';
import 'store/spread_sheet.dart';
import 'store/spreadsheet_db.dart';

class SpreadSheetDBNotifier extends MMNotifier<AsyncValue<SpreadSheet>> {
  SpreadSheetDBNotifier(this.dbPath) : super(AsyncValue.loading()) {
    initialize();
  }
  String dbPath;
  final Map<int, Map<int, Object>> cellErrors = {};

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

  Future<bool> upsertOrDelete(int row, int col, CellData? cellData) async {
    try {
      return await state.when(
        data: (sheet) async {
          try {
            final data = await sheet.upsertOrDelete(row, col, cellData);
            notify(AsyncValue.data(data));
            if (cellErrors.containsKey(row) &&
                cellErrors[row]!.containsKey(col)) {
              cellErrors[row]!.remove(col);
              if (cellErrors[row]!.isEmpty) {
                cellErrors.remove(row);
              }
            }
            notify(state);
            return true;
          } catch (e) {
            cellErrors.putIfAbsent(row, () => {});
            cellErrors[row]![col] = e;
            notify(state);
            return false;
          }
        },
        error: (error, stackTrace) {
          cellErrors.putIfAbsent(row, () => {});
          cellErrors[row]![col] =
              'Cannot modify cell: Spreadsheet is in an error state.';
          notify(state);
          return false;
        },
        loading: () {
          cellErrors.putIfAbsent(row, () => {});
          cellErrors[row]![col] = 'Cannot modify while loading spreadsheet.';
          notify(state);
          return false;
        },
      );
    } catch (e) {
      cellErrors.putIfAbsent(row, () => {});
      cellErrors[row]![col] = e;
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
