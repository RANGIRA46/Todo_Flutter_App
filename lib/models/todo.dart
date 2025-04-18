class Todo {
  final int? id;
  String title;
  String? description;
  bool isCompleted;
  DateTime? dueDate;
  DateTime? actionTime; // Time for the action to take place
  String priority;
  String category;
  bool isRecurring;

  Todo({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.actionTime,
    this.priority = "Medium",
    this.category = "Personal",
    this.isRecurring = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'actionTime': actionTime?.millisecondsSinceEpoch,
      'priority': priority,
      'category': category,
      'isRecurring': isRecurring ? 1 : 0,
    };
  }

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
          : null,
      priority: map['priority'] ?? "Medium",
      category: map['category'] ?? "Personal",
      isRecurring: map['isRecurring'] == 1,
    );
  }
}