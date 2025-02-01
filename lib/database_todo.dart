import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'todomodel.dart';

late Database database;

Future<void> initDatabase() async {
  final dbPath = await getDatabasesPath(); // Get the database directory path
  final path = join(dbPath, "TodoDB.db"); // Join path with database name

  print("Database path: $path"); // Print the path for reference

  database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE Todo (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          date TEXT
        )
      ''');
      print("Table 'Todo' created successfully.");
    },
  );
}

Future<void> insertTodoData(Todo todo) async {
  int id = await database.insert("Todo", todo.toMap(), 
  conflictAlgorithm: ConflictAlgorithm.replace);
  print("Inserted Todo: ${todo.toMap()} with id: $id");
}

Future<List<Todo>> getTodoData() async {
  List<Map<String, dynamic>> todoMap = await database.query("Todo");
  print("Fetched Todos: $todoMap");
  return todoMap.map((map) => Todo.fromMap(map)).toList();
}

Future<void> deleteTodoData(int id) async {
  int count = await database.delete("Todo", where: 'id = ?', whereArgs: [id]);
  print("Deleted Todo with id: $id (Affected rows: $count)");
}

Future<void> updateTodoData(Todo todo) async {
  int count = await database.update("Todo", todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  print("Updated Todo: ${todo.toMap()} (Affected rows: $count)");
}
