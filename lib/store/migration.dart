import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
        CREATE TABLE IF NOT EXISTS cells (
                row_index       INTEGER NOT NULL,
                col_index       INTEGER NOT NULL,
                cell_data       TEXT, -- Stores the entire cell structure as a JSON string
                PRIMARY KEY (row_index, col_index)
            );
            CREATE INDEX IF NOT EXISTS idx_row ON cells (row_index);
            CREATE INDEX IF NOT EXISTS idx_col ON cells (col_index);
    ''');
    }),
  );
