class Todo {
  final int? id;
  String title;
  String? description;
  bool isCompleted;
  DateTime? dueDate;
  String priority; // New: "Low", "Medium", or "High"
  String category; // New: "Work", "Personal", or "School"
  bool isRecurring; // New: Is the task recurring?

  Todo({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority = "Medium", // Default priority
    this.category = "Personal", // Default category
    this.isRecurring = false, // Default is not recurring
  });

  // Convert a Todo into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'priority': priority,
      'category': category,
      'isRecurring': isRecurring ? 1 : 0,
    };
  }

  // Create a Todo from a Map
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      dueDate: map['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['dueDate'])
          : null,
      priority: map['priority'] ?? "Medium",
      category: map['category'] ?? "Personal",
      isRecurring: map['isRecurring'] == 1,
    );
  }

  // Clone method for creating copies when updating
  Todo copy({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
    String? category,
    bool? isRecurring,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isRecurring: isRecurring ?? this.isRecurring,
    );
  }
}