import 'package:cl_spreadsheet/grid_layout.dart';
import 'package:cl_spreadsheet/models/store/spread_sheet.dart';
import 'package:flutter/material.dart';

import 'models/store/checkbox_grid_id.dart';

class GridExampleScreen extends StatelessWidget {
  const GridExampleScreen({super.key, required this.sheet});
  final SpreadSheet sheet;

  @override
  Widget build(BuildContext context) {
    final initialGridContentMap = {
      for (var e in sheet.data.entries)
        e.key: switch (e.value.value) {
          _ => TextContent('${e.value}'),
        },
    };
    initialGridContentMap[CheckboxGridId(row: 0, column: 0)] =
        const TextContent('Padded Ints (Dec)');

    // We will use 10 rows and 4 columns here to test the vertical scrolling/spacer logic
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,

          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: CheckboxGridLayout(
            rows:
                10, // Increased rows to 10 to test scrolling when height > 400
            columns: 4,
            initialChildren: initialGridContentMap,
          ),
        );
      },
    );
  }
}
