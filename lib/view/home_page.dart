import 'package:cl_spreadsheet/common/my_scaffold.dart';
import 'package:cl_spreadsheet/models/sheet_properties.dart';
import 'package:cl_spreadsheet/view/forms/new_sheet_form.dart';

import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final profile = [
  (title: 'Name', value: 'Alexandru'),
  (title: 'Username', value: 'nank1ro'),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ShadButton.outline(
                child: const Text('New'),
                onPressed: () async {
                  final sheet = await showShadDialog<SheetProperties?>(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (context) => ShadDialog.alert(
                      gap: 0,
                      backgroundColor: Colors.transparent,

                      shadows: [],
                      border: BoxBorder.all(color: Colors.transparent),
                      child: SizedBox(
                        width: 375,
                        child: NewSheetForm(
                          onClose: () => Navigator.of(context).pop(null),
                          onSubmit: ({required sheetProperties}) =>
                              Navigator.of(context).pop(sheetProperties),
                        ),
                      ),
                    ),
                  );
                  if (sheet != null) {
                    print("Sheet : $sheet");
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
