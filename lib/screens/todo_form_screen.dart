import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo;

  const TodoFormScreen({Key? key, this.todo}) : super(key: key);

  @override
  _TodoFormScreenState createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  late String _priority;
  late String _category;
  DateTime? _dueDate;
  late bool _isRecurring;

  @override
  void initState() {
    super.initState();
    _title = widget.todo?.title ?? '';
    _description = widget.todo?.description;
    _priority = widget.todo?.priority ?? "Medium";
    _category = widget.todo?.category ?? "Personal";
    _dueDate = widget.todo?.dueDate;
    _isRecurring = widget.todo?.isRecurring ?? false;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newTodo = Todo(
        id: widget.todo?.id,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        priority: _priority,
        category: _category,
        isCompleted: widget.todo?.isCompleted ?? false,
        isRecurring: _isRecurring,
      );

      if (widget.todo == null) {
        await DatabaseHelper.instance.insertTodo(newTodo);
      } else {
        await DatabaseHelper.instance.updateTodo(newTodo);
      }
      if (mounted) Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                items: ['Low', 'Medium', 'High']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value!),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['Work', 'Personal', 'School']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(_dueDate != null
                    ? DateFormat('MMM d, yyyy').format(_dueDate!)
                    : 'No date selected'),
                onTap: () => _pickDate(context),
              ),
              SwitchListTile(
                title: const Text('Recurring Task (Everyday)'),
                value: _isRecurring,
                onChanged: (value) => setState(() => _isRecurring = value),
              ),
              ElevatedButton(
                onPressed: _saveTask,
                child:
                    Text(widget.todo == null ? 'Add Task' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}