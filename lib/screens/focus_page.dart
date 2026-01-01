import 'package:flutter/material.dart';
import 'full_screen_timer_page.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
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
          // Dark Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Center Timer
                Stack(
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
                    const Text(
                      '25:00',
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w100,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const Spacer(),
                
                // Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FullScreenTimerPage(),
                        ),
                      );
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
                          'Bắt đầu Tập trung',
                          style: TextStyle(
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
