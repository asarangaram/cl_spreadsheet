import 'package:cl_spreadsheet/common/my_scaffold.dart';
import 'package:flutter/material.dart';

import 'spread_sheet_viewer/spread_sheet_viewer.dart';

class SpreadSheetPage extends StatelessWidget {
  const SpreadSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(child: SpreadSheetViewer());
  }
}
