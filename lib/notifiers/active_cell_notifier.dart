import 'package:minimal_mvn/minimal_mvn.dart';

import '../models/store/checkbox_grid_id.dart';

enum NavPage { home, spreadSheet }

class ActiveCellNotifier extends MMNotifier<CheckboxGridId?> {
  ActiveCellNotifier() : super(null);

  void setActiveCell(CheckboxGridId? activeCell) {
    notify(activeCell);
  }
}

final MMManager<ActiveCellNotifier> activeCellManager = MMManager(
  ActiveCellNotifier.new,
);
