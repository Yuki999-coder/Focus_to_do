import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../flip_digit.dart';
import '../services/timer_service.dart';

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
        final totalSeconds = timerService.remainingSeconds;
        final isRunning = timerService.isRunning;

        // Calculate digits
        final minutes = totalSeconds ~/ 60;
        final seconds = totalSeconds % 60;

        final minTens = minutes ~/ 10;
        final minOnes = minutes % 10;
        final secTens = seconds ~/ 10;
        final secOnes = seconds % 10;

        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Main Timer Display
              Center(
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.portrait) {
                      return _buildPortraitLayout(minTens, minOnes, secTens, secOnes);
                    } else {
                      return _buildLandscapeLayout(minTens, minOnes, secTens, secOnes);
                    }
                  },
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
                    // Pause/Resume Button
                    FloatingActionButton(
                      heroTag: 'pause_resume',
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        if (isRunning) {
                          timerService.pauseTimer();
                        } else {
                          timerService.startTimer();
                        }
                      },
                      child: Icon(isRunning ? Icons.pause : Icons.play_arrow),
                    ),
                    const SizedBox(width: 20),
                    // Stop/Exit Button
                    FloatingActionButton(
                      heroTag: 'stop_exit',
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        timerService.stopTimer();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.stop),
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

  // PORTRAIT: 2x2 Grid
  // Minutes on top row, Seconds on bottom row
  Widget _buildPortraitLayout(int mT, int mO, int sT, int sO) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minutes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlipDigit(value: mT, size: 120),
            const SizedBox(width: 10),
            FlipDigit(value: mO, size: 120),
          ],
        ),
        const SizedBox(height: 20),
        // Divider (optional, or just spacing)
        Container(
          height: 2,
          width: 200,
          color: Colors.white12,
        ),
        const SizedBox(height: 20),
        // Seconds
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlipDigit(value: sT, size: 120),
            const SizedBox(width: 10),
            FlipDigit(value: sO, size: 120),
          ],
        ),
      ],
    );
  }

  // LANDSCAPE: Single Row
  // MM : SS
  Widget _buildLandscapeLayout(int mT, int mO, int sT, int sO) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlipDigit(value: mT, size: 100),
        const SizedBox(width: 8),
        FlipDigit(value: mO, size: 100),
        
        // Separator dots
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dot(),
              const SizedBox(height: 20),
              _dot(),
            ],
          ),
        ),

        FlipDigit(value: sT, size: 100),
        const SizedBox(width: 8),
        FlipDigit(value: sO, size: 100),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}