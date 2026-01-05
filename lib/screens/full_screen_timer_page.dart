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
                child: OrientationBuilder(
                  builder: (context, orientation) {
                    if (orientation == Orientation.portrait) {
                      return _buildPortraitLayout(minTens, minOnes, secTens, secOnes, timerService.clockStyle);
                    } else {
                      return _buildLandscapeLayout(minTens, minOnes, secTens, secOnes, timerService.clockStyle);
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
                    // Reset Button (formerly Stop)
                    FloatingActionButton(
                      heroTag: 'reset_timer',
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      onPressed: () {
                        timerService.stopTimer();
                      },
                      child: const Icon(Icons.replay),
                    ),
                    const SizedBox(width: 20),
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // PORTRAIT: 2x2 Grid or just Minutes if no seconds
  Widget _buildPortraitLayout(int mT, int mO, int sT, int sO, ClockStyle style) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Minutes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlipDigit(value: mT, size: 120, style: style),
            const SizedBox(width: 10),
            FlipDigit(value: mO, size: 120, style: style),
          ],
        ),
        
        if (style.showSeconds) ...[
          const SizedBox(height: 20),
          // Divider
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
              FlipDigit(value: sT, size: 120, style: style),
              const SizedBox(width: 10),
              FlipDigit(value: sO, size: 120, style: style),
            ],
          ),
        ],
      ],
    );
  }

    // LANDSCAPE: Single Row

    // MM : SS

    Widget _buildLandscapeLayout(int mT, int mO, int sT, int sO, ClockStyle style) {

      return Row(

        mainAxisAlignment: MainAxisAlignment.center,

        children: [

          FlipDigit(value: mT, size: 100, style: style),

          const SizedBox(width: 8),

          FlipDigit(value: mO, size: 100, style: style),

          

          if (style.showSeconds) ...[

            // Separator dots

            Padding(

              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: [

                  _dot(style.textColor),

                  const SizedBox(height: 20),

                  _dot(style.textColor),

                ],

              ),

            ),

  

            FlipDigit(value: sT, size: 100, style: style),

            const SizedBox(width: 8),

            FlipDigit(value: sO, size: 100, style: style),

          ],

        ],

      );

    }

  

    Widget _dot(Color color) {

      return Container(

        width: 12,

        height: 12,

        decoration: BoxDecoration(

          color: color,

          shape: BoxShape.circle,

        ),

      );

    }

  }

  