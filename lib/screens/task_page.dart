import 'package:flutter/material.dart';
import '../widgets/task_item.dart';
import '../services/timer_service.dart';
import 'focus_page.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String _selectedFilter = 'Today';
  final List<String> _filters = ['Today', 'Tomorrow', 'This Week'];

  void _toggleTask(String id) {
    TimerService().toggleTask(id);
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        String newTaskTitle = '';
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          title: const Text('New Task', style: TextStyle(color: Colors.white)),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter task name...',
              hintStyle: TextStyle(color: Colors.white54),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
            ),
            onChanged: (value) => newTaskTitle = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                if (newTaskTitle.isNotEmpty) {
                  TimerService().addTask(newTaskTitle);
                }
                Navigator.pop(context);
              },
              child: const Text('Add', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedFilter,
            dropdownColor: const Color(0xFF2C2C2C),
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            onChanged: (String? newValue) {
              setState(() {
                _selectedFilter = newValue!;
              });
            },
            items: _filters.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: timerService,
        builder: (context, child) {
          final tasks = timerService.tasks;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Row(
                  children: [
                    Expanded(
                      child: TaskItem(
                        task: task,
                        onToggle: () => _toggleTask(task.id),
                        onTap: () {
                          // Just select, don't navigate
                          timerService.selectTask(task);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected: ${task.title}'),
                              duration: const Duration(milliseconds: 500),
                              backgroundColor: Colors.grey[800],
                            ),
                          );
                        },
                      ),
                    ),
                    // Play Button to start focus on this task
                    IconButton(
                      icon: Icon(
                        Icons.play_circle_fill, 
                        color: timerService.currentTask?.id == task.id 
                            ? Colors.redAccent 
                            : Colors.white70,
                        size: 32,
                      ),
                      onPressed: () {
                        timerService.selectTask(task);
                        // Navigate to Focus Page (Pushing on top to ensure user sees it)
                        // Note: Ideally we switch tabs, but pushing is safer without context of MainScreen
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const FocusPage()),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}