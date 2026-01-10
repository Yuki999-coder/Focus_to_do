import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path_utils;
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
  List<String> _customBackgrounds = [];
  List<Map<String, String>> _customSounds = [];

  // State
  TimerMode _currentMode = TimerMode.focus;
  int _remainingSeconds = 25 * 60;
  bool _isStopwatchMode = false;
  int _stopwatchSeconds = 0; // Tracks elapsed time in stopwatch mode
  Timer? _timer;
  bool _isRunning = false;
  DateTime? _timerStartTime; // For Stopwatch: When did we start counting?
  DateTime? _timerTargetTime; // For Countdown: When will it finish?

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
  List<String> get customBackgrounds => _customBackgrounds;
  List<Map<String, String>> get customSounds => _customSounds;

  // Persistence Methods
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Settings
    _backgroundImage = prefs.getString('backgroundImage') ?? 'assets/images/bg_universe.jpg';
    _selectedSound = prefs.getString('selectedSound') ?? 'music/clock-tick.mp3';
    
    final String? styleJson = prefs.getString('clockStyle');
    if (styleJson != null) {
      try {
        _clockStyle = ClockStyle.fromJson(jsonDecode(styleJson));
      } catch (e) {
        debugPrint("Error loading clock style: $e");
      }
    }

    // Load Custom Assets
    _customBackgrounds = prefs.getStringList('customBackgrounds') ?? [];
    
    final String? soundsJson = prefs.getString('customSounds');
    if (soundsJson != null) {
      final List<dynamic> decoded = jsonDecode(soundsJson);
      _customSounds = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    final String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      _tasks = decoded.map((item) => Task.fromJson(item)).toList();
    } else {
      // Default data logic...
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

    // --- RESTORE TIMER STATE ---
    await _restoreTimerState(prefs);

    notifyListeners();
  }

  Future<void> _restoreTimerState(SharedPreferences prefs) async {
    _isRunning = prefs.getBool('timer_isRunning') ?? false;
    _isStopwatchMode = prefs.getBool('timer_isStopwatch') ?? false;
    _currentMode = TimerMode.values[prefs.getInt('timer_mode') ?? 0];
    
    final taskId = prefs.getString('timer_taskId');
    if (taskId != null && taskId != 'none') {
      try {
        _currentTask = _tasks.firstWhere((t) => t.id == taskId);
      } catch (_) {
        _currentTask = null;
      }
    }

    // Load saved durations
    _focusDuration = prefs.getInt('timer_focusDuration') ?? 25;
    _shortBreakDuration = prefs.getInt('timer_breakDuration') ?? 5;
    _remainingSeconds = prefs.getInt('timer_remainingSeconds') ?? (_focusDuration * 60);
    _stopwatchSeconds = prefs.getInt('timer_stopwatchSeconds') ?? 0;

    // If it was running, calculate the diff
    if (_isRunning) {
      final String? targetTimeStr = prefs.getString('timer_targetTime');
      final String? startTimeStr = prefs.getString('timer_startTime');
      final String? sessionStartStr = prefs.getString('timer_sessionStartTime');

      if (sessionStartStr != null) {
        _currentSessionStartTime = DateTime.parse(sessionStartStr);
      }

      final now = DateTime.now();

      if (_isStopwatchMode) {
        if (startTimeStr != null) {
          final startTime = DateTime.parse(startTimeStr);
          final diff = now.difference(startTime).inSeconds;
          _stopwatchSeconds = diff > 0 ? diff : 0;
          startTimer(restore: true);
        }
      } else {
        // Countdown
        if (targetTimeStr != null) {
          final targetTime = DateTime.parse(targetTimeStr);
          final diff = targetTime.difference(now).inSeconds;
          
          if (diff <= 0) {
            // Timer finished while app was closed
            _remainingSeconds = 0;
            _isRunning = false;
            _handleTimerComplete();
          } else {
            _remainingSeconds = diff;
            startTimer(restore: true);
          }
        }
      }
    }
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('timer_isRunning', _isRunning);
    await prefs.setBool('timer_isStopwatch', _isStopwatchMode);
    await prefs.setInt('timer_mode', _currentMode.index);
    await prefs.setString('timer_taskId', _currentTask?.id ?? 'none');
    await prefs.setInt('timer_focusDuration', _focusDuration);
    await prefs.setInt('timer_breakDuration', _shortBreakDuration);
    await prefs.setInt('timer_remainingSeconds', _remainingSeconds);
    await prefs.setInt('timer_stopwatchSeconds', _stopwatchSeconds);

    if (_timerTargetTime != null) {
      await prefs.setString('timer_targetTime', _timerTargetTime!.toIso8601String());
    } else {
      await prefs.remove('timer_targetTime');
    }

    if (_timerStartTime != null) {
      await prefs.setString('timer_startTime', _timerStartTime!.toIso8601String());
    } else {
      await prefs.remove('timer_startTime');
    }
    
    if (_currentSessionStartTime != null) {
      await prefs.setString('timer_sessionStartTime', _currentSessionStartTime!.toIso8601String());
    } else {
      await prefs.remove('timer_sessionStartTime');
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('backgroundImage', _backgroundImage);
    await prefs.setString('selectedSound', _selectedSound);
    await prefs.setString('clockStyle', jsonEncode(_clockStyle.toJson()));
    final String encoded = jsonEncode(_tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', encoded);
    
    // Save Custom Assets
    await prefs.setStringList('customBackgrounds', _customBackgrounds);
    await prefs.setString('customSounds', jsonEncode(_customSounds));
  }

  Future<void> addCustomBackground(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path_utils.basename(sourcePath);
    final savedPath = path_utils.join(appDir.path, 'backgrounds', fileName);
    
    final savedFile = File(savedPath);
    if (!await savedFile.parent.exists()) {
      await savedFile.parent.create(recursive: true);
    }
    
    await File(sourcePath).copy(savedPath);
    
    _customBackgrounds.add(savedPath);
    _saveTasks();
    notifyListeners();
  }

  Future<void> addCustomSound(String name, String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = path_utils.basename(sourcePath);
    final savedPath = path_utils.join(appDir.path, 'sounds', fileName);
    
    final savedFile = File(savedPath);
    if (!await savedFile.parent.exists()) {
      await savedFile.parent.create(recursive: true);
    }
    
    await File(sourcePath).copy(savedPath);
    
    _customSounds.add({'name': name, 'path': savedPath});
    _saveTasks();
    notifyListeners();
  }

  // Task Methods
  void selectTask(Task? task) {
    _currentTask = task;
    _saveTimerState(); // Save selection
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

  void updateTask(String id, String newTitle, DateTime newDate, TimeOfDay? newReminder) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index].title = newTitle;
      _tasks[index].dueDate = newDate;
      _tasks[index].reminderTime = newReminder;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    if (_currentTask?.id == id) {
      _currentTask = null;
    }
    _saveTasks();
    notifyListeners();
  }

  /// Sets the focus duration in minutes.
  /// If currently in Focus mode and not running, updates the remaining time immediately.
  void setDuration(int minutes) {
    _focusDuration = minutes;
    _isStopwatchMode = false; // Reset to Timer mode when duration is set
    if (_currentMode == TimerMode.focus && !_isRunning) {
      _remainingSeconds = _focusDuration * 60;
      _saveTimerState();
      notifyListeners();
    }
  }

  void setStopwatchMode() {
    _isStopwatchMode = true;
    _stopwatchSeconds = 0;
    _currentMode = TimerMode.focus; // Stopwatch is usually for focus
    if (!_isRunning) {
      _saveTimerState();
      notifyListeners();
    }
  }

  /// Sets the short break duration in minutes.
  /// If currently in Break mode and not running, updates the remaining time immediately.
  void setShortBreakDuration(int minutes) {
    _shortBreakDuration = minutes;
    if (_currentMode == TimerMode.breakMode && !_isRunning) {
      _remainingSeconds = _shortBreakDuration * 60;
      _saveTimerState();
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
      _saveTimerState();
      notifyListeners();
    }
  }

  void startTimer({bool restore = false}) {
    if (_isRunning && !restore) return;
    
    _isRunning = true;
    
    if (!restore) {
      _currentSessionStartTime ??= DateTime.now();
      
      if (_isStopwatchMode) {
        // For stopwatch, "StartTime" is Now minus what we already have.
        // e.g. We have 10s. Now is 12:00:10. StartTime was 12:00:00.
        _timerStartTime = DateTime.now().subtract(Duration(seconds: _stopwatchSeconds));
        _timerTargetTime = null;
      } else {
        // For Countdown, "TargetTime" is Now + Remaining.
        _timerTargetTime = DateTime.now().add(Duration(seconds: _remainingSeconds));
        _timerStartTime = null;
      }
      _saveTimerState();
    }
    
    notifyListeners();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Re-sync with real time to prevent drift and handle simple backgrounding
      final now = DateTime.now();

      if (_isStopwatchMode) {
        if (_timerStartTime != null) {
          final diff = now.difference(_timerStartTime!).inSeconds;
          _stopwatchSeconds = diff;
        } else {
           _stopwatchSeconds++; // Fallback
        }
        
        // Track time for current task if in Focus mode
        if (_currentMode == TimerMode.focus && _currentTask != null) {
          _currentTask!.secondsSpent++; // This logic needs to be smarter for persistence, but ok for now
        }
        notifyListeners();
      } else {
        // Countdown
        if (_timerTargetTime != null) {
             final diffMs = _timerTargetTime!.difference(now).inMilliseconds;
             final diff = (diffMs / 1000).ceil();
             if (diff > 0) {
               _remainingSeconds = diff;
             } else {
               _remainingSeconds = 0;
               _handleTimerComplete();
               return;
             }
        } else {
           if (_remainingSeconds > 0) {
            _remainingSeconds--;
           } else {
            _handleTimerComplete();
            return;
           }
        }

        // Track time for current task if in Focus mode
        if (_currentMode == TimerMode.focus && _currentTask != null) {
            _currentTask!.secondsSpent++;
        }
        
        notifyListeners();
      }
    });
  }

  void pauseTimer() {
    _logSession(); 
    
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _currentSessionStartTime = null; // Prepare for next chunk
    _timerStartTime = null;
    _timerTargetTime = null;
    _saveTimerState();
    notifyListeners();
  }

  void stopTimer() {
    _logSession();
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _resetToCurrentModeStart();
    _timerStartTime = null;
    _timerTargetTime = null;
    _saveTimerState();
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
    if (_isStopwatchMode) {
      _stopwatchSeconds = 0;
    }
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
    debugPrint("Timer finished. Playing notification sound: $_selectedSound");
    try {
      if (_selectedSound.startsWith('music/')) {
        await _audioPlayer.play(AssetSource(_selectedSound));
      } else {
        await _audioPlayer.play(DeviceFileSource(_selectedSound));
      }
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
    
    final hours = secondsToDisplay ~/ 3600;
    final minutes = (secondsToDisplay % 3600) ~/ 60;
    final seconds = secondsToDisplay % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
