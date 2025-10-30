import 'package:cl_spreadsheet/models/store/cell_data.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/text_content.dart';
import 'package:flutter/material.dart';

import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart';

typedef OnCellValueSubmitted =
    void Function(CheckboxGridId id, String newValue);

/// A stateful widget to wrap content and handle the edit/display toggle.
class GridCell extends StatefulWidget {
  final CheckboxGridId id;
  final CellData? cellData;

  const GridCell({super.key, required this.cellData, required this.id});

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CellContentViewer(id: widget.id, cellData: widget.cellData);
  }
}

class CellContentViewer extends StatelessWidget {
  const CellContentViewer({
    super.key,
    required this.id,
    required this.cellData,
  });
  final CheckboxGridId id;
  final CellData? cellData;

  @override
  Widget build(BuildContext context) {
    if (cellData == null) {
      return SizedBox.shrink();
    }
    final content = switch (cellData!.value) {
      _ => TextContent('${cellData!.value}'),
    };

    return Tooltip(
      message: content.tooltipMessage,
      waitDuration: const Duration(milliseconds: 500),
      child: content.buildWidget(cellData!.value),
    );
  }
}

class CellContentEditor extends StatelessWidget {
  const CellContentEditor({
    super.key,
    required this.id,
    required this.cellData,
  });
  final CheckboxGridId id;
  final CellData cellData;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
