import 'package:cl_spreadsheet/common/async_value.dart';
import 'package:cl_spreadsheet/common/my_scaffold.dart';
import 'package:cl_spreadsheet/models/store/spread_sheet.dart';
import 'package:cl_spreadsheet/notifiers/store_notifier.dart';
import 'package:flutter/material.dart';

class SpreadSheetListener extends StatelessWidget {
  const SpreadSheetListener({super.key, required this.builder});
  final Widget Function(BuildContext context, SpreadSheet page) builder;

  @override
  Widget build(BuildContext context) {
    String dBPath = "mysheet.ss";
    final notifier = spreadSheetDBManager(dBPath).notifier;

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, final __) {
        return notifier.state.when(
          data: (data) => builder(context, data),

          error: (error, stackTrace) {
            return MyScaffold(
              child: Center(child: Text("Error: Failed to open $dBPath")),
            );
          },
          loading: () =>
              MyScaffold(child: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
