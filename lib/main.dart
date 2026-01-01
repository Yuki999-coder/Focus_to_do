import 'dart:async';
import 'package:flutter/material.dart';
import 'flip_digit.dart'; // Đảm bảo import đúng file bạn vừa tạo

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Flip Clock',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Nền đen tuyền
      ),
      home: const FocusTimerScreen(),
    );
  }
}

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  // Cài đặt thời gian mặc định: 25 phút (Pomodoro)
  int totalSeconds = 25 * 60; 
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds > 0) {
        setState(() {
          totalSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán số phút và giây
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    // Tách các chữ số ra để hiển thị
    // Ví dụ: 25 phút -> chục=2, đơn vị=5
    final minTens = minutes ~/ 10;
    final minOnes = minutes % 10;
    final secTens = seconds ~/ 10;
    final secOnes = seconds % 10;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "FOCUS TIMER",
              style: TextStyle(color: Colors.white54, letterSpacing: 2),
            ),
            const SizedBox(height: 30),
            
            // Hàng hiển thị đồng hồ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === PHÚT ===
                FlipDigit(value: minTens, size: 80),
                const SizedBox(width: 8),
                FlipDigit(value: minOnes, size: 80),
                
                // Dấu hai chấm
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: [
                      _dot(),
                      const SizedBox(height: 15),
                      _dot(),
                    ],
                  ),
                ),

                // === GIÂY ===
                FlipDigit(value: secTens, size: 80),
                const SizedBox(width: 8),
                FlipDigit(value: secOnes, size: 80),
              ],
            ),
            
            const SizedBox(height: 50),
            // Nút điều khiển giả (chưa có chức năng, để trang trí thôi)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("DỪNG LẠI", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}