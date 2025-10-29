import 'package:cl_spreadsheet/common/my_scaffold.dart';
import 'package:cl_spreadsheet/listeners/spreadsheet_listener.dart';
import 'package:flutter/material.dart';

import '../grid_example_screen.dart';

class SpreadSheetPage extends StatelessWidget {
  const SpreadSheetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: SpreadSheetListener(
        builder: (context, sheet) {
          return GridExampleScreen(sheet: sheet);
        },
      ),
    );
  }
}
