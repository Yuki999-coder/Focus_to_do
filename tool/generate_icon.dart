import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Simple icon generator for Focus To Do app
/// Creates a green background with white clock icon

Future<void> main() async {
  // Create the icon using canvas
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = const Size(1024, 1024);
  
  // Green background
  final bgPaint = Paint()..color = const Color(0xFF22C55E);
  canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
  
  // White clock
  final clockPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 40;
  
  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width * 0.35;
  
  // Clock circle
  canvas.drawCircle(center, radius, clockPaint);
  
  // Clock hands
  final handPaint = Paint()
    ..color = Colors.white
    ..style = PaintingStyle.stroke
    ..strokeWidth = 30
    ..strokeCap = StrokeCap.round;
  
  // Hour hand (pointing to 10)
  canvas.drawLine(
    center,
    Offset(center.dx - radius * 0.4, center.dy - radius * 0.5),
    handPaint,
  );
  
  // Minute hand (pointing to 2)  
  handPaint.strokeWidth = 20;
  canvas.drawLine(
    center,
    Offset(center.dx + radius * 0.5, center.dy - radius * 0.4),
    handPaint,
  );
  
  // Center dot
  final dotPaint = Paint()..color = Colors.white;
  canvas.drawCircle(center, 25, dotPaint);
  
  print('Icon design completed!');
  print('');
  print('Since Flutter cannot generate PNG files directly in a script,');
  print('please use one of these methods to create the icon:');
  print('');
  print('Option 1: Use an online tool like https://icon.kitchen/');
  print('  - Choose a clock icon');
  print('  - Set background color to #22C55E (green)');
  print('  - Set icon color to white');
  print('');
  print('Option 2: Use Android Studio Image Asset Studio');
  print('  - Right-click on res folder > New > Image Asset');
  print('  - Choose clock icon, green background');
  print('');
  print('For now, the adaptive icon XML files will work on Android 8+');
}
