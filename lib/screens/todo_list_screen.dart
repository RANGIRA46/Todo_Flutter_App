import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart'; // Updated import for Todo model
import '../services/database_helper.dart'; // Updated import for DatabaseHelper
import 'todo_form_screen.dart'; // Corrected import for the form screen

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

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTodo(id);
    _refreshTodos();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task deleted')),
    );
  }

  Future<void> _editTask(BuildContext context, Todo task) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoFormScreen(todo: task),
      ),
    );
    if (result == true) {
      _refreshTodos();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tasks found.'),
            );
          } else {
            final todos = snapshot.data!;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return _buildTaskTile(context, todo);
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

  Widget _buildTaskTile(BuildContext context, Todo todo) {
    return ListTile(
      title: Text(todo.title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${todo.priority} Priority - ${todo.category}'),
          if (todo.dueDate != null)
            Text('Due: ${DateFormat.yMMMd().format(todo.dueDate!)}'),
          if (todo.actionTime != null)
            Text('Time: ${DateFormat.Hm().format(todo.actionTime!)}'), // NEW: Display actionTime
          if (todo.isRecurring)
            const Text(
              'Recurring Task (Everyday)',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit Icon Button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _editTask(context, todo);
            },
          ),
          // Delete Icon Button
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Task'),
                  content: const Text('Are you sure you want to delete this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteTask(todo.id!);
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoFormScreen(todo: todo),
          ),
        );
        if (result == true) _refreshTodos();
      },
    );
  }
}