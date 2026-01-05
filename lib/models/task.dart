import 'package:flutter/material.dart';

class FocusSession {
  final DateTime startTime;
  final int durationSeconds;

  FocusSession({required this.startTime, required this.durationSeconds});

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'durationSeconds': durationSeconds,
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      startTime: DateTime.parse(json['startTime']),
      durationSeconds: json['durationSeconds'],
    );
  }
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'dueDate': dueDate.toIso8601String(),
    'reminderTime': reminderTime != null
        ? '${reminderTime!.hour}:${reminderTime!.minute}'
        : null,
    'secondsSpent': secondsSpent,
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory Task.fromJson(Map<String, dynamic> json) {
    TimeOfDay? reminder;
    if (json['reminderTime'] != null) {
      final parts = (json['reminderTime'] as String).split(':');
      if (parts.length == 2) {
        reminder = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      reminderTime: reminder,
      secondsSpent: json['secondsSpent'] ?? 0,
      sessions: json['sessions'] != null
          ? (json['sessions'] as List)
              .map((s) => FocusSession.fromJson(s))
              .toList()
          : [],
    );
  }
}
