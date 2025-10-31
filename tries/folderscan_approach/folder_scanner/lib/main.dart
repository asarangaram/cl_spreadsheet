import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class SheetProperties {
  final String name;
  final int columns;
  final int rows;

  SheetProperties({required this.name, required this.columns, required this.rows});

  factory SheetProperties.fromFileName(String fileName) {
    final sheetPattern = RegExp(r'^(.+)\.(\d+)\.(\d+)\.sheet$');
    final match = sheetPattern.firstMatch(fileName);

    if (match != null) {
      final name = match.group(1)!;
      final rows = int.parse(match.group(2)!);
      final columns = int.parse(match.group(3)!);
      return SheetProperties(name: name, rows: rows, columns: columns);
    }
    throw const FormatException('Invalid filename format');
  }

  String toFileName() {
    return '$name.$rows.$columns.sheet';
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sheet Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SheetProperties> _sheets = [];

  Future<void> _scanFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final scanDir = Directory('${directory.path}/scan');

      if (await scanDir.exists()) {
        await scanDir.delete(recursive: true);
      }
      await scanDir.create();

      // Create some dummy files for demonstration
      final sheet1 = SheetProperties(name: 'mySheet', rows: 10, columns: 20);
      final sheet2 = SheetProperties(name: 'another-sheet', rows: 5, columns: 15);
      final sheet3 = SheetProperties(name: 'yet-another', rows: 1, columns: 1);

      File('${scanDir.path}/${sheet1.toFileName()}').writeAsStringSync('');
      File('${scanDir.path}/${sheet2.toFileName()}').writeAsStringSync('');
      File('${scanDir.path}/${sheet3.toFileName()}').writeAsStringSync('');
      File('${scanDir.path}/invalid-file.txt').writeAsStringSync('');

      final files = await scanDir.list().toList();
      final List<SheetProperties> sheets = [];

      for (var file in files) {
        final fileName = file.path.split('/').last;
        try {
          final sheet = SheetProperties.fromFileName(fileName);
          sheets.add(sheet);
        } on FormatException {
          // Ignore files that don't match the format
        }
      }

      setState(() {
        _sheets = sheets;
      });
    } catch (e) {
      print('Error scanning folder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sheet Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _scanFolder,
              child: const Text('Scan Folder'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Detected Sheets:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _sheets.isEmpty
                  ? const Text('No sheets found. Press "Scan Folder" to start.')
                  : ListView.builder(
                      itemCount: _sheets.length,
                      itemBuilder: (context, index) {
                        final sheet = _sheets[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.grid_on),
                            title: Text(sheet.name),
                            subtitle: Text('Rows: ${sheet.rows}, Columns: ${sheet.columns}'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}