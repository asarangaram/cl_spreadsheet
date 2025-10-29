import 'package:cl_spreadsheet/common/my_app_bar.dart';
import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  const MyScaffold({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: MyAppBar(), body: child);
  }
}
