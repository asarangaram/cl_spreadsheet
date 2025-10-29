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

  Future<void> initialize() async {
    final db = await SpreadsheetDB.openDB(dbPath);
    final spreadSheet = await SpreadSheet.load(db);
    notify(AsyncValue.data(spreadSheet));
  }

  Future<void> reload() async {
    state.whenOrNull(
      data: (sheet) async {
        notify(AsyncValue.loading());
        notify(AsyncValue.data(await sheet.reload()));
      },
    );
  }

  Future<void> upsert(int row, int col, CellData? cellData) async {
    state.whenOrNull(
      data: (sheet) async {
        notify(AsyncValue.data(await sheet.upsertOrDelete(row, col, cellData)));
      },
    );
  }
}

Map<String, MMManager<SpreadSheetDBNotifier>> openedSheets = {};

MMManager<SpreadSheetDBNotifier> spreadSheetDBManager(String dbPath) {
  if (!openedSheets.containsKey(dbPath)) {
    openedSheets[dbPath] = MMManager(() => SpreadSheetDBNotifier(dbPath));
  }

  return openedSheets[dbPath]!;
}
