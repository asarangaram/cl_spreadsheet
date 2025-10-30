import 'package:cl_spreadsheet/common/menu_bar.dart';
import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SSMenuBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
