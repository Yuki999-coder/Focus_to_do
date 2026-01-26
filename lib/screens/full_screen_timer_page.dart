import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flip_digit.dart';
import '../services/timer_service.dart';
import '../widgets/clock_customizer_sheet.dart';
import '../models/clock_theme_model.dart';

class FullScreenTimerPage extends StatefulWidget {
  const FullScreenTimerPage({super.key});

  @override
  State<FullScreenTimerPage> createState() => _FullScreenTimerPageState();
}

class _FullScreenTimerPageState extends State<FullScreenTimerPage> {
  @override
  void initState() {
    super.initState();
    // Hide status bar and navigation bar for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI overlays when leaving the page
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerService = TimerService();

    return ListenableBuilder(
      listenable: timerService,
      builder: (context, child) {
        final totalSeconds = timerService.isStopwatchMode 
            ? timerService.remainingSeconds // Actually stopwatchSeconds via getter logic in service
            : timerService.remainingSeconds;
            
        final isRunning = timerService.isRunning;

        // Calculate digits including Hours
        final hours = totalSeconds ~/ 3600;
        final minutes = (totalSeconds % 3600) ~/ 60;
        final seconds = totalSeconds % 60;

        final hourTens = hours ~/ 10;
        final hourOnes = hours % 10;
        final minTens = minutes ~/ 10;
        final minOnes = minutes % 10;
        final secTens = seconds ~/ 10;
        final secOnes = seconds % 10;
        
        final hasHours = hours > 0;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Top Controls (Exit Full Screen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fullscreen_exit, color: Colors.white70, size: 32),
                          onPressed: () => Navigator.pop(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.palette_outlined, color: Colors.white70, size: 32),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true, // Allow full height if needed
                              backgroundColor: Colors.transparent,
                              builder: (context) => const ClockCustomizerSheet(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main Timer Display
              Center(
                child: FittedBox(
                   fit: BoxFit.scaleDown,
                   child: _buildTimerLayout(hasHours, hourTens, hourOnes, minTens, minOnes, secTens, secOnes, timerService.clockStyle),
                ),
              ),

              // Controls (Bottom Center)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Restart Button (doesn't save to timeline)
                    FloatingActionButton(
                      heroTag: 'restart_timer',
                      backgroundColor: Colors.white12,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        timerService.restartTimer();
                      },
                      child: const Icon(Icons.replay),
                    ),
                    const SizedBox(width: 16),
                    // Finish Button (saves to timeline)
                    FloatingActionButton(
                      heroTag: 'finish_timer',
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        timerService.stopTimer();
                      },
                      child: const Icon(Icons.stop),
                    ),
                    const SizedBox(width: 16),
                    // Pause/Resume Button
                    FloatingActionButton(
                      heroTag: 'pause_resume',
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      onPressed: () {
                        if (isRunning) {
                          timerService.pauseTimer();
                        } else {
                          timerService.startTimer();
                        }
                      },
                      child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
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

  // Unified Layout: HH : MM : SS (Horizontal Row)
  Widget _buildTimerLayout(bool hasHours, int hT, int hO, int mT, int mO, int sT, int sO, ClockStyle style) {
    // Base size adjusted by style.digitSize
    final double baseSize = hasHours ? 80 : 100;
    final double digitSize = baseSize * style.digitSize;
    final double spacing = style.digitSpacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (hasHours) ...[
          FlipDigit(value: hT, size: digitSize, style: style),
          SizedBox(width: spacing * 0.6),
          FlipDigit(value: hO, size: digitSize, style: style),
          
          _buildSeparator(digitSize, style.textColor, spacing),
        ],

        FlipDigit(value: mT, size: digitSize, style: style),
        SizedBox(width: spacing * 0.6),
        FlipDigit(value: mO, size: digitSize, style: style),

        if (style.showSeconds) ...[
          _buildSeparator(digitSize, style.textColor, spacing),

          FlipDigit(value: sT, size: digitSize, style: style),
          SizedBox(width: spacing * 0.6),
          FlipDigit(value: sO, size: digitSize, style: style),
        ],
      ],
    );
  }

  Widget _buildSeparator(double height, Color color, double spacing) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(color),
          SizedBox(height: spacing * 1.6),
          _dot(color),
        ],
      ),
    );
  }

  Widget _dot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

  