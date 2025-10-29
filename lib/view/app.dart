import 'package:cl_spreadsheet/listeners/nav_listener.dart';
import 'package:cl_spreadsheet/listeners/ui_preferences_listener.dart';
import 'package:cl_spreadsheet/notifiers/navigate.dart';
import 'package:cl_spreadsheet/view/home_page.dart';
import 'package:cl_spreadsheet/view/spread_sheet_page.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return UiPreferencesListener(
      builder: (context, uiPreferences) {
        return ShadApp(
          debugShowCheckedModeBanner: false,
          themeMode: uiPreferences.themeMode,

          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadZincColorScheme.light(),
            textTheme: ShadTextTheme(
              custom: {
                'myCustomStyle': const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                ),
              },
            ),
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadZincColorScheme.dark(),
            textTheme: ShadTextTheme(
              custom: {
                'myCustomStyle': const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.green,
                ),
              },
            ),
          ),
          home: NavListener(
            builder: (context, navPage) {
              return switch (navPage) {
                NavPage.home => HomePage(),
                NavPage.spreadSheet => SpreadSheetPage(),
              };
            },
          ),
          builder: (context, child) {
            return child!;
          },
        );
      },
    );
  }
}
