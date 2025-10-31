import 'package:cl_spreadsheet/common/async_value.dart';
import 'package:cl_spreadsheet/listeners/sheets_listener.dart';
import 'package:cl_spreadsheet/listeners/ui_preferences_listener.dart';
import 'package:cl_spreadsheet/notifiers/navigate.dart';
import 'package:cl_spreadsheet/notifiers/sheets_notifier.dart';
import 'package:cl_spreadsheet/notifiers/ui_preferences.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../listeners/nav_listener.dart';

class SSMenuBar extends StatelessWidget {
  const SSMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final square = SizedBox.square(
      dimension: 16,
      child: Center(
        child: SizedBox.square(
          dimension: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.foreground,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
    final divider = ShadSeparator.horizontal(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: theme.colorScheme.muted,
    );
    return NavListener(
      builder: (context, page) {
        return SheetsListener(
          builder: (context, sheetsAsync) {
            return sheetsAsync.when(
              data: (sheets) {
                return DecoratedBox(
                  decoration: BoxDecoration(color: theme.colorScheme.muted),
                  child: ShadMenubar(
                    selectOnHover: false,
                    items: [
                      /* SizedBox(
                    width: 64,
                    height: 64,
                    child: (page != NavPage.home)
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: ShadButton.ghost(
                                leading: Icon(Icons.home),
                                onPressed: () {
                                  navPagesManager.notifier.goto(NavPage.home);
                                },
                              ),
                            ),
                          )
                        : null,
                  ), */
                      ShadMenubarItem(
                        items: [
                          ShadContextMenuItem(
                            child: Text('New Sheet'),
                            onPressed: () async {
                              final sheet = await sheetManager.notifier
                                  .newSheet(context);
                              if (sheet != null) {
                                navPagesManager.notifier.goto(
                                  NavPage.spreadSheet,
                                );
                              }
                            },
                          ),

                          ShadContextMenuItem(
                            trailing: Icon(LucideIcons.chevronRight),
                            items: [
                              if (sheets.sheets.isEmpty)
                                ShadContextMenuItem(
                                  enabled: false,
                                  leading: SizedBox.square(dimension: 16),
                                  child: Text('Empty'),
                                )
                              else
                                for (final sheet in sheets.sheets)
                                  Tooltip(
                                    message: (sheet != sheets.activeSheet)
                                        ? "Open ${sheet.name}"
                                        : "Open ${sheet.name}, ${page != NavPage.spreadSheet ? "Last Opened" : "Current Sheet"}",
                                    child: ShadContextMenuItem(
                                      enabled:
                                          (sheet != sheets.activeSheet) ||
                                          page != NavPage.spreadSheet,
                                      leading: (sheet == sheets.activeSheet)
                                          ? square
                                          : SizedBox.square(dimension: 16),
                                      child: Text(sheet.name),
                                      onPressed: () {
                                        sheetManager.notifier.openSheet(sheet);
                                        navPagesManager.notifier.goto(
                                          NavPage.spreadSheet,
                                        );
                                      },
                                    ),
                                  ),
                            ],
                            child: Text('Open Sheet'),
                          ),
                          divider,
                          ShadContextMenuItem(
                            onPressed: () =>
                                navPagesManager.notifier.goto(NavPage.home),
                            child: Text('Close'),
                          ),
                        ],
                        child: const Text('Sheets'),
                      ),
                      if ((page == NavPage.spreadSheet) &&
                          sheets.activeSheet != null)
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                sheets.activeSheet!.name,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: theme.textTheme.h4,
                              ),
                            ),
                          ),
                        )
                      else
                        Spacer(),
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
                              onPressed:
                                  uiPreferencesManager.notifier.nextThemeMode,
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
                  ),
                );
              },
              error: (e, st) => Text("Error Listing files"),
              loading: () => CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }
}
