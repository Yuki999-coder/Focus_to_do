import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String _selectedFilter = 'Today';
  final List<String> _filters = ['Today', 'Tomorrow', 'This Week'];

  final List<Task> _tasks = [
    Task(id: '1', title: 'Hoàn thành thiết kế UI', dueDate: DateTime.now()),
    Task(id: '2', title: 'Viết báo cáo tuần', dueDate: DateTime.now()),
    Task(id: '3', title: 'Tập thể dục 30 phút', isCompleted: true, dueDate: DateTime.now()),
  ];

  void _toggleTask(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
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
                  setState(() {
                    _tasks.insert(0, Task(
                      id: DateTime.now().toString(),
                      title: newTaskTitle,
                      dueDate: DateTime.now(),
                    ));
                  });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: TaskItem(
                    task: _tasks[index],
                    onToggle: () => _toggleTask(index),
                    onTap: () {
                      // Logic to set as current focus task can be implemented here
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Focused on: ${_tasks[index].title}'),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.grey[800],
                        ),
                      );
                    },
                  ),
                ),
                // Optional side action button if needed, 
                // but requirement said floating or right side.
                // We'll use a floating action button for adding tasks generally.
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTask,
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}