import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/timer_service.dart';

class TimelinePage extends StatefulWidget {
  const TimelinePage({super.key});

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late TimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = TimerService();
    _timerService.addListener(_update);
  }

  @override
  void dispose() {
    _timerService.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 1. Flatten and Sort Data
    List<TimelineItem> items = [];
    for (var task in _timerService.tasks) {
      for (var session in task.sessions) {
        items.add(TimelineItem(session, task.title));
      }
    }
    items.sort((a, b) => b.session.startTime.compareTo(a.session.startTime));

    // 2. Group by Date
    Map<String, List<TimelineItem>> groupedItems = {};
    for (var item in items) {
      String dateKey = _getDateKey(item.session.startTime);
      if (!groupedItems.containsKey(dateKey)) {
        groupedItems[dateKey] = [];
      }
      groupedItems[dateKey]!.add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timeline'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text('No activity yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedItems.keys.length,
              itemBuilder: (context, index) {
                String dateKey = groupedItems.keys.elementAt(index);
                List<TimelineItem> dayItems = groupedItems[dateKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        dateKey,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Timeline Items
                    ...dayItems.map((item) => _buildTimelineItem(item)),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildTimelineItem(TimelineItem item) {
    final startTime = DateFormat('HH:mm').format(item.session.startTime);
    final endTime = DateFormat('HH:mm').format(
        item.session.startTime.add(Duration(seconds: item.session.durationSeconds)));
    final duration = _formatDuration(item.session.durationSeconds);

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 8),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey[800]!, width: 2),
        ),
      ),
      padding: const EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$startTime - $endTime',
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  duration,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.taskTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(date.year, date.month, date.day);

    if (checkDate == today) return 'Today';
    if (checkDate == yesterday) return 'Yesterday';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    return '${(seconds / 60).toStringAsFixed(0)}m';
  }
}

class TimelineItem {
  final FocusSession session;
  final String taskTitle;
  TimelineItem(this.session, this.taskTitle);
}
