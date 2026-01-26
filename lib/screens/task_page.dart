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
  final List<String> _filters = ['Today', 'Tomorrow', 'This Week', 'All'];
  bool _showCompleted = false;

  void _toggleTask(String id) {
    TimerService().toggleTask(id);
  }

  void _editTask(dynamic task) {
    showDialog(
      context: context,
      builder: (context) {
        String newTitle = task.title;
        DateTime? selectedDate = task.dueDate;
        TimeOfDay? selectedTime = task.reminderTime;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: const Text('Edit Task', style: TextStyle(color: Colors.white)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    controller: TextEditingController(text: newTitle),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter task name...',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
                    ),
                    onChanged: (value) => newTitle = value,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Date Picker (Optional)
                      TextButton.icon(
                        icon: Icon(
                          Icons.calendar_today, 
                          color: selectedDate != null ? Colors.redAccent : Colors.white70, 
                          size: 18
                        ),
                        label: Text(
                          selectedDate != null 
                            ? "${selectedDate!.day}/${selectedDate!.month}" 
                            : "No Date",
                          style: TextStyle(
                            color: selectedDate != null ? Colors.redAccent : Colors.white70
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.redAccent,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF2C2C2C),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: const Color(0xFF2C2C2C),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        onLongPress: () {
                          // Long press to clear date
                          setState(() => selectedDate = null);
                        },
                      ),
                      const Spacer(),
                      // Time Picker (Reminder)
                      TextButton.icon(
                        icon: Icon(
                          Icons.notifications, 
                          color: selectedTime != null ? Colors.redAccent : Colors.white70, 
                          size: 18
                        ),
                        label: Text(
                          selectedTime != null ? selectedTime!.format(context) : 'No Reminder',
                          style: TextStyle(
                            color: selectedTime != null ? Colors.redAccent : Colors.white70
                          ),
                        ),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.redAccent,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF2C2C2C),
                                    onSurface: Colors.white,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => selectedTime = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                ),
                TextButton(
                  onPressed: () {
                    // Confirm delete
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF2C2C2C),
                        title: const Text('Delete Task?', style: TextStyle(color: Colors.white)),
                        content: const Text('Are you sure you want to delete this task?', style: TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('No', style: TextStyle(color: Colors.white54)),
                          ),
                          TextButton(
                            onPressed: () {
                              TimerService().deleteTask(task.id);
                              Navigator.pop(context); // Close confirm dialog
                              Navigator.pop(context); // Close edit dialog
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                ),
                TextButton(
                  onPressed: () {
                    if (newTitle.isNotEmpty) {
                      TimerService().updateTask(
                        task.id,
                        newTitle,
                        selectedDate,
                        selectedTime,
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addNewTask() {

      showDialog(

        context: context,

        builder: (context) {

          String newTaskTitle = '';

          DateTime? selectedDate;

          TimeOfDay? selectedTime;

  

          return StatefulBuilder(

            builder: (context, setState) {

              return AlertDialog(

                backgroundColor: const Color(0xFF2C2C2C),

                title: const Text('New Task', style: TextStyle(color: Colors.white)),

                content: Column(

                  mainAxisSize: MainAxisSize.min,

                  children: [

                    TextField(

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

                    const SizedBox(height: 16),

                    Row(

                      children: [

                        // Date Picker (Optional)

                        TextButton.icon(

                          icon: Icon(

                            Icons.calendar_today, 

                            color: selectedDate != null ? Colors.redAccent : Colors.white70, 

                            size: 18

                          ),

                          label: Text(

                            selectedDate != null 

                              ? "${selectedDate!.day}/${selectedDate!.month}" 

                              : "No Date",

                            style: TextStyle(

                              color: selectedDate != null ? Colors.redAccent : Colors.white70

                            ),

                          ),

                          onPressed: () async {

                            final picked = await showDatePicker(

                              context: context,

                              initialDate: selectedDate ?? DateTime.now(),

                              firstDate: DateTime.now().subtract(const Duration(days: 365)),

                              lastDate: DateTime.now().add(const Duration(days: 365)),

                                                                                      builder: (context, child) {

                                                                                        return Theme(

                                                                                          data: ThemeData.dark().copyWith(

                                                                                            colorScheme: const ColorScheme.dark(

                                                                                              primary: Colors.redAccent,

                                                                                              onPrimary: Colors.white,

                                                                                              surface: Color(0xFF2C2C2C),

                                                                                              onSurface: Colors.white,

                                                                                            ),

                                                                                            dialogBackgroundColor: const Color(0xFF2C2C2C),

                                                                                          ),

                                                                                          child: child!,

                                                                                        );

                                                                                      },

                                                          

                              

                            );

                            if (picked != null) {

                              setState(() => selectedDate = picked);

                            }

                          },

                          onLongPress: () {

                            // Long press to clear date

                            setState(() => selectedDate = null);

                          },

                        ),

                        const Spacer(),

                        // Time Picker (Reminder)

                        TextButton.icon(

                          icon: Icon(

                            Icons.notifications, 

                            color: selectedTime != null ? Colors.redAccent : Colors.white70, 

                            size: 18

                          ),

                          label: Text(

                            selectedTime != null ? selectedTime!.format(context) : 'No Reminder',

                            style: TextStyle(

                              color: selectedTime != null ? Colors.redAccent : Colors.white70

                            ),

                          ),

                          onPressed: () async {

                            final picked = await showTimePicker(

                              context: context,

                              initialTime: TimeOfDay.now(),

                              builder: (context, child) {

                                return Theme(

                                  data: ThemeData.dark().copyWith(

                                    colorScheme: const ColorScheme.dark(

                                      primary: Colors.redAccent,

                                      onPrimary: Colors.white,

                                      surface: Color(0xFF2C2C2C),

                                      onSurface: Colors.white,

                                    ),

                                  ),

                                  child: child!,

                                );

                              },

                            );

                            if (picked != null) {

                              setState(() => selectedTime = picked);

                            }

                          },

                        ),

                      ],

                    ),

                  ],

                ),

                actions: [

                  TextButton(

                    onPressed: () => Navigator.pop(context),

                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),

                  ),

                  TextButton(

                    onPressed: () {

                      if (newTaskTitle.isNotEmpty) {

                        TimerService().addTask(

                          newTaskTitle, 

                          dueDate: selectedDate,

                          reminderTime: selectedTime,

                        );

                      }

                      Navigator.pop(context);

                    },

                    child: const Text('Add', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),

                  ),

                ],

              );

            },

          );

        },

      );

    }

  

        List<dynamic> _filterTasks(List<dynamic> tasks) {

  

          final now = DateTime.now();

  

          final todayStart = DateTime(now.year, now.month, now.day);

  

      

  

          return tasks.where((task) {

  

            // 1. Filter by Completion status

  

            if (task.isCompleted && !_showCompleted) {

  

              return false;

  

            }

  

      

  

            // 2. Filter by Date - "All" shows everything

  

            if (_selectedFilter == 'All') {

  

              return true;

  

            }

  

      

  

            // Tasks without date only show in "All" filter

  

            if (task.dueDate == null) {

  

              return false;

  

            }

  

      

  

            final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);

  

            final diffDays = taskDate.difference(todayStart).inDays;

  

      

  

            if (_selectedFilter == 'Today') {

  

              return diffDays == 0;

  

            } else if (_selectedFilter == 'Tomorrow') {

  

              return diffDays == 1;

  

            } else if (_selectedFilter == 'This Week') {

  

              return diffDays >= 0 && diffDays <= 7;

  

            }

  

            return true;

  

          }).toList();

  

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

  

                        PopupMenuButton<String>(

  

                          icon: const Icon(Icons.more_horiz, color: Colors.white),

  

                          color: const Color(0xFF2C2C2C),

  

                          onSelected: (value) {

  

                            if (value == 'toggle_completed') {

  

                              setState(() {

  

                                _showCompleted = !_showCompleted;

  

                              });

  

                            }

  

                          },

  

                          itemBuilder: (BuildContext context) {

  

                            return [

  

                              PopupMenuItem<String>(

  

                                value: 'toggle_completed',

  

                                child: Row(

  

                                  children: [

  

                                    Icon(

  

                                      _showCompleted ? Icons.check_box : Icons.check_box_outline_blank,

  

                                      color: Colors.redAccent,

  

                                    ),

  

                                    const SizedBox(width: 8),

  

                                    const Text('Show Completed', style: TextStyle(color: Colors.white)),

  

                                  ],

  

                                ),

  

                              ),

  

                            ];

  

                          },

  

                        ),

  

                      ],

  

                      ),

  

                      body: ListenableBuilder(

  

                        listenable: timerService,

  

                        builder: (context, child) {

  

                          final filteredTasks = _filterTasks(timerService.tasks);

  

                          return Padding(

  

                            padding: const EdgeInsets.all(16.0),

  

                            child: filteredTasks.isEmpty 

  

                              ? Center(child: Text("No tasks for $_selectedFilter", style: const TextStyle(color: Colors.white54)))

  

                              : ListView.builder(

  

                              itemCount: filteredTasks.length,

  

                              itemBuilder: (context, index) {

  

                                final task = filteredTasks[index];

  

                                return Row(

  

                                  children: [

  

                                    Expanded(

  

                                      child: TaskItem(

  

                                        task: task,

  

                                        onToggle: () => _toggleTask(task.id),

  

                                        onTap: () => _editTask(task),

  

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

  

    

  