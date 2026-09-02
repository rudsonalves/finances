import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../helpers/test_setup.dart';

void main() {
  test('opens an isolated in-memory SQLite database', () async {
    final factory = initializeFfiDatabase();
    final database = await factory.openDatabase(inMemoryDatabasePath);
    addTearDown(database.close);

    await database.execute(
      'CREATE TABLE fixture (id INTEGER PRIMARY KEY, value TEXT NOT NULL)',
    );
    await database.insert('fixture', {'value': 'ready'});

    final rows = await database.query('fixture');
    expect(rows, hasLength(1));
    expect(rows.single['value'], 'ready');
  });
}
