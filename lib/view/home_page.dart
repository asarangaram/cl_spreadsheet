import 'package:cl_spreadsheet/common/my_scaffold.dart';
import 'package:cl_spreadsheet/notifiers/navigate.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: Center(
        child: ShadButton.secondary(
          child: Text("New Sheet"),
          onPressed: () {
            navPagesManager.notifier.goto(NavPage.spreadSheet);
          },
        ),
      ),
    );
  }
}
