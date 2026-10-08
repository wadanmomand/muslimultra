import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';

class TasbihProgressRing extends StatelessWidget {
  final double progress;
  final int count;
  final int target;
  final bool isCompleted;
  final VoidCallback onTap;
  final bool isDark;

  const TasbihProgressRing({
    super.key,
    required this.progress,
    required this.count,
    required this.target,
    required this.isCompleted,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = math.min(MediaQuery.of(context).size.width * 0.72, 260.0);

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isDark
                ? (isCompleted ? AppColors.goldGradient : AppColors.cardGradientDark)
                : (isCompleted ? AppColors.goldGradient : AppColors.sandCardGradientLight),
            boxShadow: [
              BoxShadow(
                color: isCompleted
                    ? AppColors.gold.withValues(alpha: 0.4)
                    : (isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : AppColors.midnightNavy.withValues(alpha: 0.08)),
                blurRadius: isCompleted ? 28 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: CustomPaint(
            painter: _RingPainter(
              progress: progress,
              isCompleted: isCompleted,
              isDark: isDark,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                      color: isCompleted
                          ? (isDark ? AppColors.midnightNavyDark : AppColors.midnightNavy)
                          : (isDark ? AppColors.goldBright : AppColors.midnightNavy),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Colors.black.withValues(alpha: 0.15)
                          : AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '/ $target',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCompleted
                            ? (isDark ? AppColors.midnightNavyDark : AppColors.midnightNavy)
                            : (isDark ? AppColors.goldLight : AppColors.goldDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;
  final bool isDark;

  _RingPainter({
    required this.progress,
    required this.isCompleted,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;
    const strokeWidth = 8.0;

    // Track Paint
    final trackPaint = Paint()
      ..color = isDark
          ? AppColors.midnightNavyBorder.withValues(alpha: 0.6)
          : AppColors.sandBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress Paint
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = isCompleted
            ? (isDark ? AppColors.midnightNavyDark : Colors.white)
            : AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth + 1.5;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isCompleted != isCompleted ||
        oldDelegate.isDark != isDark;
  }
}
