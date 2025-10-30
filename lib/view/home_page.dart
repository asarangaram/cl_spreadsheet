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
    );
  }
}

class CreditCardContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final double bannerHeight;
  final Widget? child;

  const CreditCardContainer({
    super.key,
    this.width = 340,
    this.height = 200,
    this.borderRadius = 18,
    this.bannerHeight = 40,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(width: 2, color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 2),
          child: Column(
            children: [
              // Top Banner — ✅ No radius here!
              Container(height: bannerHeight, color: Colors.grey.shade200),

              // Body
              Expanded(
                child: Container(color: Colors.white, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
