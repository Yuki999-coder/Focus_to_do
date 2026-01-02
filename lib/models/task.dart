class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime dueDate;
  int secondsSpent;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    this.secondsSpent = 0,
  });
}
