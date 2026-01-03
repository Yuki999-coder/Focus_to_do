import 'package:flutter/material.dart';

class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime dueDate;
  TimeOfDay? reminderTime;
  int secondsSpent;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    this.reminderTime,
    this.secondsSpent = 0,
  });
}
