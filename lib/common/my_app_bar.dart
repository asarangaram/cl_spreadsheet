import 'package:cl_spreadsheet/listeners/nav_listener.dart';
import 'package:cl_spreadsheet/listeners/ui_preferences_listener.dart';
import 'package:cl_spreadsheet/notifiers/navigate.dart';
import 'package:cl_spreadsheet/notifiers/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return NavListener(
      builder: (context, page) {
        return AppBar(
          title: Text("Word Walls"),
          centerTitle: true,
          actionsPadding: EdgeInsetsDirectional.only(start: 8),
          leading: page != NavPage.home
              ? ShadButton.ghost(
                  leading: Icon(Icons.home),
                  onPressed: () {
                    navPagesManager.notifier.goto(NavPage.home);
                  },
                )
              : null,
          actions: [
            UiPreferencesListener(
              builder: (context, uiPreferences) {
                final themeMode = uiPreferences.themeMode;
                return Tooltip(
                  message: switch (themeMode) {
                    ThemeMode.system => 'Uses System Dark/Light',
                    ThemeMode.light => 'Light mode',
                    ThemeMode.dark => 'Dart Mode',
                  },
                  child: ShadButton.ghost(
                    onPressed: uiPreferencesManager.notifier.nextThemeMode,
                    leading: Icon(
                      switch (themeMode) {
                        ThemeMode.system => LucideIcons.sunMoon,
                        ThemeMode.light => LucideIcons.sun,
                        ThemeMode.dark => LucideIcons.moon,
                      },

                      semanticLabel: switch (themeMode) {
                        ThemeMode.system => 'Switch to light mode',
                        ThemeMode.light => 'Switch to dark mode',
                        ThemeMode.dark => 'Switch to system defaut',
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
