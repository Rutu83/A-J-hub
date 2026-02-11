// lib/utils/custom_icon_button.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

// --- STEP 1: Convert to StatefulWidget ---
// We need state to manage the AnimationController.
class CategoryAnimation extends StatefulWidget {
  /// The widget to display in the center (e.g., an Icon or a CircleAvatar).
  final Widget child;

  /// The color of the looping arrow.
  final Color arrowColor;

  /// The callback that is called when the button is tapped.
  final VoidCallback onPressed;

  const CategoryAnimation({
    super.key,
    required this.child,
    required this.arrowColor,
    required this.onPressed,
  });

  @override
  State<CategoryAnimation> createState() => _CategoryAnimationState();
}

// --- STEP 2: Add SingleTickerProviderStateMixin ---
// This mixin is essential for the AnimationController to work.
class _CategoryAnimationState extends State<CategoryAnimation>
    with SingleTickerProviderStateMixin {
  // --- STEP 3: Declare the AnimationController ---
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // --- STEP 4: Initialize and start the controller ---
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // How long one full rotation takes
      vsync: this,
    )..repeat(); // The .repeat() method is the key to making it loop forever.
  }

  @override
  void dispose() {
    // --- STEP 5: Always dispose of the controller to prevent memory leaks ---
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: SizedBox(
        width: 48, // Standard IconButton touch area
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- STEP 6: Use AnimatedBuilder to listen for changes ---
            // This is more efficient than TweenAnimationBuilder for continuous animations.
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) {
                // The builder rebuilds the Transform.rotate every frame.
                return Transform.rotate(
                  // _controller.value goes from 0.0 to 1.0 over the duration.
                  // We multiply by 2*pi to get a full 360-degree rotation.
                  angle: _controller.value * 2.0 * math.pi,
                  child: child,
                );
              },
              // The child is the part that doesn't need to be rebuilt,
              // making the animation more performant.
              child: CustomPaint(
                size: const Size(32, 32), // Size of the ring
                painter: _RingPainter(color: widget.arrowColor),
              ),
            ),
            // The central child widget (Icon or CircleAvatar)
            widget.child,
          ],
        ),
      ),
    );
  }
}

// The _RingPainter class remains exactly the same. No changes needed here.
class _RingPainter extends CustomPainter {
  final Color color;

  _RingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 1.8,
      false,
      paint,
    );

    final arrowPath = Path();
    final arrowAngle = math.pi * 1.8;
    arrowPath.moveTo(center.dx + radius * math.cos(arrowAngle),
        center.dy + radius * math.sin(arrowAngle));
    arrowPath.lineTo(center.dx + (radius - 4) * math.cos(arrowAngle + 0.2),
        center.dy + (radius - 4) * math.sin(arrowAngle + 0.2));
    arrowPath.moveTo(center.dx + radius * math.cos(arrowAngle),
        center.dy + radius * math.sin(arrowAngle));
    arrowPath.lineTo(center.dx + (radius + 4) * math.cos(arrowAngle + 0.2),
        center.dy + (radius + 4) * math.sin(arrowAngle + 0.2));
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
