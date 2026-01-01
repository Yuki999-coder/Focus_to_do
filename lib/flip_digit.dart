import 'dart:math';
import 'package:flutter/material.dart';

class FlipDigit extends StatelessWidget {
  /// The integer value to display (0-9).
  final int value;

  /// The size (width) of the digit card. Height will be calculated based on aspect ratio.
  final double size;

  const FlipDigit({
    Key? key,
    required this.value,
    this.size = 60.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return _FlipTransition(
          animation: animation,
          child: child,
        );
      },
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: _buildDigitCard(value),
    );
  }

  Widget _buildDigitCard(int digit) {
    return Container(
      key: ValueKey(digit),
      width: size,
      height: size * 1.5,
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C), // Dark grey
        borderRadius: BorderRadius.circular(size * 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Digit Text
          Text(
            digit.toString(),
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.0, // Tighter vertical alignment
            ),
          ),
          // Horizontal Split Line
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: size * 0.04, // Thin line proportional to size
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> animation;

  const _FlipTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final rotateAnim = Tween(begin: pi / 2, end: 0.0).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: rotateAnim,
      child: child,
      builder: (context, child) {
        // Simple rotation X effect for "flip"
        // Note: For a true 2-part split flap, we'd need complex clipping.
        // This provides a smooth whole-card vertical flip effect.
        
        final angle = rotateAnim.value;
        // If the animation is running in reverse (exit), we want it to flip 'down' (0 -> -pi/2)
        // However, AnimatedSwitcher handles the 'reverse' direction by running the animation 1.0 -> 0.0.
        // So for the exiting widget: 0.0 -> pi/2 (if we use the same Tween).
        // To make it look like a continuous flip:
        // Entering widget (forward): starts at pi/2 (tilted back) -> 0 (flat).
        // Exiting widget (reverse): starts at 0 (flat) -> pi/2 (tilted back).
        
        // To make the exit flip "down" instead of "up", we might need to invert for status.
        // But the simple effect requested is often just this oscillation.
        
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002) // Perspective
            ..rotateX(angle),
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }
}
