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
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/bg_universe.jpg',
                  fit: BoxFit.cover,
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
                          Text(
                            timerService.formattedTime,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w100,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          if (timerService.isRunning) {
                            timerService.pauseTimer();
                          } else {
                            timerService.startTimer();
                          }
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
                            Icon(timerService.isRunning ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(
                              timerService.isRunning 
                                  ? 'Pause' 
                                  : (isBreak ? 'Start Break' : 'Start Focus'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Bottom Text / Hints
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBottomHint(Icons.lock_outline, 'Strict Mode'),
                          const SizedBox(width: 40),
                          _buildBottomHint(Icons.volume_up_outlined, 'Sound'),
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

  Widget _buildBottomHint(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
