import 'package:cl_spreadsheet/models/sheets_manager.dart';
import 'package:minimal_mvn/minimal_mvn.dart';

class CurrentSheetsNotifier extends MMNotifier<CurrentSheets> {
  CurrentSheetsNotifier() : super(CurrentSheets());
}

MMManager<CurrentSheetsNotifier> sheetManager = MMManager(
  () => CurrentSheetsNotifier(),
);
