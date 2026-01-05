import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

enum TimerMode { focus, breakMode }

class TimerService extends ChangeNotifier {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  
  TimerService._internal() {
    _loadTasks();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Settings
  int _focusDuration = 25;
  int _shortBreakDuration = 5;
  String _selectedSound = 'clock-tick.mp3';

  // State
  TimerMode _currentMode = TimerMode.focus;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;

  // Task Management
  Task? _currentTask;
  DateTime? _currentSessionStartTime;

  List<Task> _tasks = [];

  // Getters
  int get focusDuration => _focusDuration;
  int get shortBreakDuration => _shortBreakDuration;
  String get selectedSound => _selectedSound;
  TimerMode get currentMode => _currentMode;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  
  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;

  // Persistence Methods
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((item) => Task.fromJson(item)).toList();
    } else {
      // Load default data if no data exists
      _tasks = [
        Task(
          id: '1', 
          title: 'Hoàn thành thiết kế UI', 
          dueDate: DateTime.now(),
          secondsSpent: 1500, // 25 min
          sessions: [
            FocusSession(startTime: DateTime.now().subtract(const Duration(hours: 2)), durationSeconds: 1500),
          ],
        ),
        Task(
          id: '2', 
          title: 'Viết báo cáo tuần', 
          dueDate: DateTime.now().add(const Duration(days: 1)),
          secondsSpent: 0,
        ),
        Task(
          id: '3', 
          title: 'Tập thể dục 30 phút', 
          isCompleted: true, 
          dueDate: DateTime.now(),
          secondsSpent: 1800,
          sessions: [
            FocusSession(startTime: DateTime.now().subtract(const Duration(days: 1, hours: 10)), durationSeconds: 1800), // Yesterday
          ],
        ),
        Task(
          id: '4',
          title: 'Họp team',
          dueDate: DateTime.now().add(const Duration(days: 3)),
        ),
      ];
      _saveTasks();
    }
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', encoded);
  }

  // Task Methods
  void selectTask(Task? task) {
    _currentTask = task;
    notifyListeners();
  }

  void setSound(String soundFile) {
    _selectedSound = soundFile;
    notifyListeners();
  }

  void addTask(String title, {DateTime? dueDate, TimeOfDay? reminderTime}) {
    _tasks.insert(0, Task(
      id: DateTime.now().toString(),
      title: title,
      dueDate: dueDate ?? DateTime.now(),
      reminderTime: reminderTime,
    ));
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  /// Sets the focus duration in minutes.
  /// If currently in Focus mode and not running, updates the remaining time immediately.
  void setDuration(int minutes) {
    _focusDuration = minutes;
    if (_currentMode == TimerMode.focus && !_isRunning) {
      _remainingSeconds = _focusDuration * 60;
      notifyListeners();
    }
  }

  /// Sets the short break duration in minutes.
  /// If currently in Break mode and not running, updates the remaining time immediately.
  void setShortBreakDuration(int minutes) {
    _shortBreakDuration = minutes;
    if (_currentMode == TimerMode.breakMode && !_isRunning) {
      _remainingSeconds = _shortBreakDuration * 60;
      notifyListeners();
    }
  }

  void startTimer() {
    if (_isRunning) return;
    
    _isRunning = true;
    _currentSessionStartTime = DateTime.now();
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        
        // Track time for current task if in Focus mode
        if (_currentMode == TimerMode.focus && _currentTask != null) {
          _currentTask!.secondsSpent++;
        }
        
        notifyListeners();
      } else {
        _handleTimerComplete();
      }
    });
  }

  void pauseTimer() {
    _logSession();
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    notifyListeners();
  }

  void stopTimer() {
    _logSession();
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _resetToCurrentModeStart();
    notifyListeners();
  }

  void _logSession() {
    if (_currentMode == TimerMode.focus && _currentTask != null && _currentSessionStartTime != null) {
      final now = DateTime.now();
      final duration = now.difference(_currentSessionStartTime!).inSeconds;
      if (duration > 0) {
         _currentTask!.sessions.add(FocusSession(
           startTime: _currentSessionStartTime!, 
           durationSeconds: duration
         ));
         _saveTasks();
      }
      _currentSessionStartTime = null;
    }
  }

  void _resetToCurrentModeStart() {
    if (_currentMode == TimerMode.focus) {
      _remainingSeconds = _focusDuration * 60;
    } else {
      _remainingSeconds = _shortBreakDuration * 60;
    }
  }

  void _handleTimerComplete() async {
    _logSession(); // Log the full session
    _timer?.cancel();
    _timer = null;
    _isRunning = false;

    // Task 2: Play a notification sound
    debugPrint("Timer finished. Playing notification sound...");
    try {
      await _audioPlayer.play(AssetSource(_selectedSound));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }

    // Task 2: Automatically switch UI to 'Break Mode'
    if (_currentMode == TimerMode.focus) {
      _currentMode = TimerMode.breakMode;
      _remainingSeconds = _shortBreakDuration * 60;
    } else {
      // Logic for when Break ends: Switch back to Focus (stopped)
      _currentMode = TimerMode.focus;
      _remainingSeconds = _focusDuration * 60;
    }
    notifyListeners();
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
