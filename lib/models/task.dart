import 'package:flutter/material.dart';

class FocusSession {
  final DateTime startTime;
  final int durationSeconds;

  FocusSession({required this.startTime, required this.durationSeconds});
}

class Task {
  final String id;
  String title;
  bool isCompleted;
  DateTime dueDate;
  TimeOfDay? reminderTime;
  int secondsSpent;
  List<FocusSession> sessions;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.dueDate,
    this.reminderTime,
    this.secondsSpent = 0,
    List<FocusSession>? sessions,
  }) : sessions = sessions ?? [];
}
