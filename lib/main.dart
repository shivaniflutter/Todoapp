import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
//import 'package:intl/intl.dart';
import 'package:todo_sqf/database_todo.dart';
import 'package:todo_sqf/todomodel.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}
class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> todos = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initDatabase().then((_) => fetchTodos());
  }

  Future<void> fetchTodos() async {
    todos = await getTodoData();
    setState(() {});
  }

  void showTodoForm({Todo? todo}) {
    if (todo != null) {
      titleController.text = todo.title;
      descriptionController.text = todo.description;
      dateController.text = todo.date;
    } else {
      clearForm();
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                    }
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        descriptionController.text.isNotEmpty &&
                        dateController.text.isNotEmpty) {
                      if (todo != null) {
                        Todo updatedTodo = Todo(
                          id: todo.id,
                          title: titleController.text,
                          description: descriptionController.text,
                          date: dateController.text,
                        );
                        await updateTodoData(updatedTodo);
                      } else {
                        Todo newTodo = Todo(
                          title: titleController.text,
                          description: descriptionController.text,
                          date: dateController.text,
                        );
                        await insertTodoData(newTodo);
                      }
                      fetchTodos();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(todo == null ? 'Add' : 'Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    dateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Card(
            child: ListTile(
              title: Text(todo.title),
              subtitle: Text('${todo.description}\n${todo.date}'),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => showTodoForm(todo: todo),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await deleteTodoData(todo.id!);
                      fetchTodos();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTodoForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
