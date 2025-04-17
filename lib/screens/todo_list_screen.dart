import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';
import 'todo_form_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  void _refreshTodos() {
    setState(() {
      _todosFuture = DatabaseHelper.instance.getTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: FutureBuilder<List<Todo>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          } else {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${todo.priority} Priority - ${todo.category}'),
                      if (todo.isRecurring)
                        const Text('Recurring Task (Everyday)',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) async {
                      todo.isCompleted = value!;
                      await DatabaseHelper.instance.updateTodo(todo);
                      _refreshTodos();
                    },
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TodoFormScreen(todo: todo),
                      ),
                    );
                    if (result == true) _refreshTodos();
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TodoFormScreen(),
            ),
          );
          if (result == true) _refreshTodos();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}