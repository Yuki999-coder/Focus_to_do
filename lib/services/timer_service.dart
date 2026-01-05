import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/clock_theme_model.dart';

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
  String _selectedSound = 'music/clock-tick.mp3';
  String _backgroundImage = 'assets/images/bg_universe.jpg';
  
  // Customization
  ClockStyle _clockStyle = const ClockStyle();

  // State
  TimerMode _currentMode = TimerMode.focus;
  int _remainingSeconds = 25 * 60;
  bool _isStopwatchMode = false;
  int _stopwatchSeconds = 0; // Tracks elapsed time in stopwatch mode
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
  String get backgroundImage => _backgroundImage;
  ClockStyle get clockStyle => _clockStyle;
  TimerMode get currentMode => _currentMode;
  int get remainingSeconds => _isStopwatchMode ? _stopwatchSeconds : _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isStopwatchMode => _isStopwatchMode;
  
  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;

  // Persistence Methods
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Settings
    _backgroundImage = prefs.getString('backgroundImage') ?? 'assets/images/bg_universe.jpg';
    
    final String? styleJson = prefs.getString('clockStyle');
    if (styleJson != null) {
      try {
        _clockStyle = ClockStyle.fromJson(jsonDecode(styleJson));
      } catch (e) {
        debugPrint("Error loading clock style: $e");
      }
    }

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
    await prefs.setString('backgroundImage', _backgroundImage);
    await prefs.setString('clockStyle', jsonEncode(_clockStyle.toJson()));
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

  void setBackgroundImage(String path) {
    _backgroundImage = path;
    _saveTasks(); // Save settings
    notifyListeners();
  }

  void updateClockStyle(ClockStyle newStyle) {
    _clockStyle = newStyle;
    _saveTasks();
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
    _isStopwatchMode = false; // Reset to Timer mode when duration is set
    if (_currentMode == TimerMode.focus && !_isRunning) {
      _remainingSeconds = _focusDuration * 60;
      notifyListeners();
    }
  }

  void setStopwatchMode() {
    _isStopwatchMode = true;
    _stopwatchSeconds = 0;
    _currentMode = TimerMode.focus; // Stopwatch is usually for focus
    if (!_isRunning) {
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

  void skipBreak() {
    if (_currentMode == TimerMode.breakMode) {
      _timer?.cancel();
      _timer = null;
      _isRunning = false;
      _currentMode = TimerMode.focus;
      _isStopwatchMode = false; // Reset to standard timer or keep preference? Reset safe.
      _remainingSeconds = _focusDuration * 60;
      notifyListeners();
    }
  }

  void startTimer() {
    if (_isRunning) return;
    
    _isRunning = true;
    _currentSessionStartTime ??= DateTime.now(); // Only set if not already set (resume)
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isStopwatchMode) {
        _stopwatchSeconds++;
        // Track time for current task if in Focus mode
        if (_currentMode == TimerMode.focus && _currentTask != null) {
          _currentTask!.secondsSpent++;
        }
        notifyListeners();
      } else {
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
      }
    });
  }

  void pauseTimer() {
    _logSession(); 
    // For Stopwatch, we might want to log the chunk, but keep the start time reference?
    // Actually _logSession uses difference from _currentSessionStartTime.
    // If we nullify it, we lose the start. But if we don't, duration increases during pause?
    // Better: _logSession calculates elapsed. We should reset start time on resume.
    // In startTimer: _currentSessionStartTime ??= DateTime.now(); handles resume if null.
    // If we pause, we log what we did. So next start is a "new" session chunk.
    // So current logic is fine for logging chunks.
    
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _currentSessionStartTime = null; // Prepare for next chunk
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
    final secondsToDisplay = _isStopwatchMode ? _stopwatchSeconds : _remainingSeconds;
    final minutes = secondsToDisplay ~/ 60;
    final seconds = secondsToDisplay % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
