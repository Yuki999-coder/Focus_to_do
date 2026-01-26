import 'package:flutter/material.dart';

class ClockStyle {
  final Color cardColor;
  final Color textColor;
  final double borderRadius;
  final bool showSeconds;
  final double digitSize;      // Size of digits (1.0 = 100%)
  final double digitSpacing;   // Spacing between digit groups

  const ClockStyle({
    this.cardColor = const Color(0xFF2C2C2C), // Default Dark Grey
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.showSeconds = true,
    this.digitSize = 1.0,      // Default 100%
    this.digitSpacing = 10.0,  // Default spacing
  });

  ClockStyle copyWith({
    Color? cardColor,
    Color? textColor,
    double? borderRadius,
    bool? showSeconds,
    double? digitSize,
    double? digitSpacing,
  }) {
    return ClockStyle(
      cardColor: cardColor ?? this.cardColor,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      showSeconds: showSeconds ?? this.showSeconds,
      digitSize: digitSize ?? this.digitSize,
      digitSpacing: digitSpacing ?? this.digitSpacing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardColor': cardColor.value,
      'textColor': textColor.value,
      'borderRadius': borderRadius,
      'showSeconds': showSeconds,
      'digitSize': digitSize,
      'digitSpacing': digitSpacing,
    };
  }

  factory ClockStyle.fromJson(Map<String, dynamic> json) {
    return ClockStyle(
      cardColor: Color(json['cardColor'] ?? 0xFF2C2C2C),
      textColor: Color(json['textColor'] ?? 0xFFFFFFFF),
      borderRadius: (json['borderRadius'] ?? 8.0).toDouble(),
      showSeconds: json['showSeconds'] ?? true,
      digitSize: (json['digitSize'] ?? 1.0).toDouble(),
      digitSpacing: (json['digitSpacing'] ?? 10.0).toDouble(),
    );
  }
}
