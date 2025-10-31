import 'package:cl_spreadsheet/common/async_value.dart';
import 'package:cl_spreadsheet/common/my_scaffold.dart';
import 'package:cl_spreadsheet/models/sheet_properties.dart';
import 'package:cl_spreadsheet/models/store/spread_sheet.dart';
import 'package:cl_spreadsheet/notifiers/store_notifier.dart';
import 'package:flutter/material.dart';

class SpreadSheetListener extends StatelessWidget {
  const SpreadSheetListener({
    super.key,
    required this.builder,
    required this.sheetProperties,
  });
  final Widget Function(BuildContext context, SpreadSheet page) builder;
  final SheetProperties sheetProperties;

  @override
  Widget build(BuildContext context) {
    final notifier = spreadSheetDBManager(sheetProperties).notifier;

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, final __) {
        return notifier.state.when(
          data: (data) => builder(context, data),

          error: (error, stackTrace) {
            return MyScaffold(
              child: Center(
                child: Text("Error: Failed to open ${sheetProperties.name}"),
              ),
            );
          },
          loading: () =>
              MyScaffold(child: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
