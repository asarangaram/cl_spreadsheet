import 'package:flutter/material.dart';

import '../notifiers/navigate.dart';

class NavListener extends StatelessWidget {
  const NavListener({super.key, required this.builder});
  final Widget Function(BuildContext context, NavPage page) builder;

  @override
  Widget build(BuildContext context) {
    final notifier = navPagesManager.notifier;
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, final __) {
        return builder(context, notifier.state);
      },
    );
  }
}
