import 'package:flutter/material.dart';
import '../services/timer_service.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Profile Header
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'My Stats',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(color: Colors.white38),
                    icon: Icon(Icons.search, color: Colors.white38),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Task List
              Expanded(
                child: ListenableBuilder(
                  listenable: timerService,
                  builder: (context, child) {
                    final tasks = timerService.tasks;
                    
                    if (tasks.isEmpty) {
                      return const Center(
                        child: Text("No tasks yet", style: TextStyle(color: Colors.white54)),
                      );
                    }

                    return ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return _buildMenuItem(
                          icon: task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                          iconColor: task.isCompleted ? Colors.greenAccent : Colors.orangeAccent,
                          title: task.title,
                          time: _formatDuration(task.secondsSpent),
                          isFocused: timerService.currentTask?.id == task.id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String time,
    required bool isFocused,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isFocused ? Colors.white10 : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: isFocused ? Border.all(color: Colors.white24) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              time,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}