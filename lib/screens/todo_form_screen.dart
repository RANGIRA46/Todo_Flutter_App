import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../services/database_helper.dart';

class TodoFormScreen extends StatefulWidget {
  final Todo? todo; // Optional parameter for editing existing tasks

  const TodoFormScreen({Key? key, this.todo}) : super(key: key);

  @override
  _TodoFormScreenState createState() => _TodoFormScreenState();
}

class _TodoFormScreenState extends State<TodoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  String? _description;
  String _priority = 'Medium';
  String _category = 'Personal';
  DateTime? _dueDate; // Date for the task
  TimeOfDay? _actionTime; // Time for the task
  bool _isRecurring = false; // NEW: Toggle for everyday tasks

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      // Prefill fields if editing an existing task
      _title = widget.todo!.title;
      _description = widget.todo!.description;
      _priority = widget.todo!.priority;
      _category = widget.todo!.category;
      _dueDate = widget.todo!.dueDate;
      _actionTime = widget.todo!.actionTime != null
          ? TimeOfDay.fromDateTime(widget.todo!.actionTime!)
          : null;
      _isRecurring = widget.todo!.isRecurring; // Prefill isRecurring
    } else {
      _title = '';
      _description = null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _actionTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _actionTime) {
      setState(() {
        _actionTime = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      DateTime? actionTime = _actionTime != null && _dueDate != null
          ? DateTime(
              _dueDate!.year,
              _dueDate!.month,
              _dueDate!.day,
              _actionTime!.hour,
              _actionTime!.minute,
            )
          : null;

      final newTask = Todo(
        id: widget.todo?.id,
        title: _title,
        description: _description,
        dueDate: _dueDate,
        actionTime: actionTime,
        priority: _priority,
        category: _category,
        isRecurring: _isRecurring, // Save the recurring status
      );

      if (widget.todo == null) {
        await DatabaseHelper.instance.insertTodo(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task added successfully!')),
        );
      } else {
        await DatabaseHelper.instance.updateTodo(newTask);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!')),
        );
      }

      Navigator.pop(context, true);
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['Low', 'Medium', 'High']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Personal', 'Work', 'School']
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: Text(
                  _dueDate == null
                      ? 'Select Date'
                      : 'Date: ${DateFormat.yMMMd().format(_dueDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              ListTile(
                title: Text(
                  _actionTime == null
                      ? 'Select Time'
                      : 'Time: ${_actionTime!.format(context)}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16.0),
              SwitchListTile(
                title: const Text('Set as Everyday Task'),
                value: _isRecurring,
                onChanged: (value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(widget.todo == null ? 'Add Task' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}