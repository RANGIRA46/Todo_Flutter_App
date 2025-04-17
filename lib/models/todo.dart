class Todo {
  final int? id;
  String title;
  String? description;
  bool isCompleted;
  DateTime? dueDate;
  DateTime? actionTime; // NEW: Time for the action to take place
  String priority; // For task priority (e.g., Low, Medium, High)
  String category; // For task category (e.g., Work, Personal, School)
  bool isRecurring; // For recurring tasks (e.g., Everyday)

  Todo({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.actionTime, // NEW: Initialize actionTime
    this.priority = "Medium",
    this.category = "Personal",
    this.isRecurring = false,
  });

  // Convert a Todo to a Map (for database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'actionTime': actionTime?.millisecondsSinceEpoch, // NEW: Add actionTime to the map
      'priority': priority,
      'category': category,
      'isRecurring': isRecurring ? 1 : 0,
    };
  }

  // Create a Todo from a Map (for database retrieval)
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      actionTime: map['actionTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['actionTime'])
          : null, // NEW: Parse actionTime
      priority: map['priority'] ?? "Medium",
      category: map['category'] ?? "Personal",
      isRecurring: map['isRecurring'] == 1,
    );
  }
}