class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime dueDate;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
  });
}
