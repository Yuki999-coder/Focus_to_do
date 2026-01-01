import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted ? Colors.redAccent : Colors.grey,
                width: 2,
              ),
              color: task.isCompleted ? Colors.redAccent : Colors.transparent,
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted ? Colors.grey : Colors.white,
            fontSize: 16,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
