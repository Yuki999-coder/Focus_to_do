import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/timer_service.dart';
import 'full_screen_timer_page.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();

    return ListenableBuilder(
      listenable: timerService,
      builder: (context, child) {
        final isBreak = timerService.currentMode == TimerMode.breakMode;
        
        return Scaffold(
          body: Stack(
            children: [
              // Background Image or Color
              Positioned.fill(
                child: Builder(
                  builder: (context) {
                    if (timerService.backgroundImage == 'color_black') {
                      return Container(color: Colors.black);
                    }
                    if (timerService.backgroundImage == 'color_white') {
                      return Container(color: Colors.white);
                    }
                    
                    if (timerService.backgroundImage.startsWith('assets/')) {
                       return Image.asset(
                        timerService.backgroundImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: Colors.black);
                        },
                      );
                    } else {
                      // Assume local file
                      return Image.file(
                        File(timerService.backgroundImage),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return Container(color: Colors.black);
                        },
                      );
                    }
                  },
                ),
              ),
              // Dark Overlay (changes color in Break Mode)
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  color: isBreak 
                      ? Colors.blueGrey.withOpacity(0.6) 
                      : Colors.black.withOpacity(0.4),
                ),
              ),
              
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with Full Screen Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.fullscreen, color: Colors.white, size: 32),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FullScreenTimerPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Task Selector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PopupMenuButton<String>(
                        onSelected: (taskId) {
                           if (taskId == 'none') {
                             timerService.selectTask(null);
                           } else {
                             final task = timerService.tasks.firstWhere((t) => t.id == taskId);
                             timerService.selectTask(task);
                           }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'none',
                              child: Text('No Task'),
                            ),
                            ...timerService.tasks.where((t) => !t.isCompleted).map((task) => PopupMenuItem(
                                  value: task.id,
                                  child: Text(
                                    task.title, 
                                    style: TextStyle(
                                      fontWeight: task.id == timerService.currentTask?.id 
                                          ? FontWeight.bold 
                                          : FontWeight.normal
                                    )
                                  ),
                                )),
                          ];
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline, 
                                color: timerService.currentTask != null ? Colors.greenAccent : Colors.white70, 
                                size: 18
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  timerService.currentTask?.title ?? 'Select a Task to Focus',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_drop_down, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 2),
                    
                    // Center Timer (Clickable)
                    GestureDetector(
                      onTap: () => _showDurationPicker(context, timerService),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 250,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 2,
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          SizedBox(
                            width: 220, // Constrain width inside the circle
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                timerService.formattedTime,
                                style: const TextStyle(
                                  fontSize: 64,
                                  fontWeight: FontWeight.w100,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          if (timerService.isRunning) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      timerService.stopTimer();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white24,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Icon(Icons.stop),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      timerService.pauseTimer();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.pause),
                                        SizedBox(width: 8),
                                        Text(
                                          'Pause',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (isBreak)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: TextButton.icon(
                                  onPressed: () {
                                    timerService.skipBreak();
                                  },
                                  icon: const Icon(Icons.skip_next, color: Colors.white70),
                                  label: const Text(
                                    'Skip Break',
                                    style: TextStyle(color: Colors.white70, fontSize: 16),
                                  ),
                                ),
                              ),
                          ] else if ((timerService.isStopwatchMode && timerService.remainingSeconds > 0) ||
                              (!timerService.isStopwatchMode &&
                                  timerService.currentMode == TimerMode.focus &&
                                  timerService.remainingSeconds < timerService.focusDuration * 60))
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      timerService.stopTimer();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white24,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Text('Finish', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      timerService.startTimer();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_arrow),
                                        SizedBox(width: 8),
                                        Text(
                                          'Resume',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    timerService.startTimer();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isBreak ? Colors.tealAccent : Colors.white,
                                    foregroundColor: Colors.black,
                                    minimumSize: const Size(double.infinity, 60),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.play_arrow),
                                      const SizedBox(width: 8),
                                      Text(
                                        timerService.isStopwatchMode 
                                          ? 'Start Stopwatch' 
                                          : (isBreak ? 'Start Break' : 'Start Focus'),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Skip Break Button (when paused/stopped)
                                if (isBreak && !timerService.isRunning)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: TextButton.icon(
                                      onPressed: () {
                                        timerService.skipBreak();
                                      },
                                      icon: const Icon(Icons.skip_next, color: Colors.white70),
                                      label: const Text(
                                        'Skip Break',
                                        style: TextStyle(color: Colors.white70, fontSize: 16),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom Text / Hints
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBottomHint(Icons.lock_outline, 'Strict Mode', null),
                          const SizedBox(width: 40),
                          _buildBottomHint(Icons.volume_up_outlined, 'Sound', () => _showSoundPicker(context, timerService)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSoundPicker(BuildContext context, TimerService timerService) {
    // Default sounds
    final List<Map<String, String>> sounds = [
      {'name': 'Clock Tick', 'path': 'music/clock-tick.mp3'},
      {'name': 'Vine Boom', 'path': 'music/vine-boom.mp3'},
    ];
    
    // Add custom sounds
    sounds.addAll(timerService.customSounds);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Completion Sound',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...sounds.map((soundItem) {
                final isSelected = timerService.selectedSound == soundItem['path'];
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.tealAccent : Colors.grey,
                  ),
                  title: Text(
                    soundItem['name']!,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    timerService.setSound(soundItem['path']!);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showDurationPicker(BuildContext context, TimerService timerService) {
    if (timerService.isRunning) return;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Timer Settings'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showTimePickerFor(context, timerService, true);
            },
            child: const Text('Set Focus Duration'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              if (timerService.isStopwatchMode) {
                 // Switch back to Timer (default 25 min or current setting)
                 timerService.setDuration(timerService.focusDuration); 
              } else {
                 timerService.setStopwatchMode();
              }
            },
            child: Text(timerService.isStopwatchMode ? 'Switch to Timer Mode' : 'Switch to Stopwatch Mode'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showTimePickerFor(context, timerService, false);
            },
            child: const Text('Set Break Duration'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  void _showTimePickerFor(BuildContext context, TimerService timerService, bool isFocus) {
    // Default duration to show
    final initialDuration = isFocus 
        ? Duration(minutes: timerService.focusDuration) 
        : Duration(minutes: timerService.shortBreakDuration);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.grey[900], // Dark background for visibility
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  isFocus ? 'Focus Duration' : 'Break Duration',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                CupertinoButton(
                  child: const Text('Done', style: TextStyle(color: Colors.blueAccent)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.hm,
                  initialTimerDuration: initialDuration,
                  onTimerDurationChanged: (Duration newDuration) {
                    if (newDuration.inMinutes > 0) {
                      if (isFocus) {
                        timerService.setDuration(newDuration.inMinutes);
                      } else {
                        timerService.setShortBreakDuration(newDuration.inMinutes);
                      }
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomHint(IconData icon, String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
