import 'package:flutter/material.dart';

class ClockStyle {
  final Color cardColor;
  final Color textColor;
  final double borderRadius;
  final bool showSeconds;

  const ClockStyle({
    this.cardColor = const Color(0xFF2C2C2C), // Default Dark Grey
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.showSeconds = true,
  });

  ClockStyle copyWith({
    Color? cardColor,
    Color? textColor,
    double? borderRadius,
    bool? showSeconds,
  }) {
    return ClockStyle(
      cardColor: cardColor ?? this.cardColor,
      textColor: textColor ?? this.textColor,
      borderRadius: borderRadius ?? this.borderRadius,
      showSeconds: showSeconds ?? this.showSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardColor': cardColor.value,
      'textColor': textColor.value,
      'borderRadius': borderRadius,
      'showSeconds': showSeconds,
    };
  }

  factory ClockStyle.fromJson(Map<String, dynamic> json) {
    return ClockStyle(
      cardColor: Color(json['cardColor'] ?? 0xFF2C2C2C),
      textColor: Color(json['textColor'] ?? 0xFFFFFFFF),
      borderRadius: (json['borderRadius'] ?? 8.0).toDouble(),
      showSeconds: json['showSeconds'] ?? true,
    );
  }
}
