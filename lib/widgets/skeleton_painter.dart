import 'package:flutter/material.dart';
import '../models/pose_data.dart';

class SkeletonPainter extends CustomPainter {
  final Map<String, Keypoint> keypoints;
  final Color color;
  final double confidenceThreshold;

  const SkeletonPainter({
    required this.keypoints,
    this.color = Colors.greenAccent,
    this.confidenceThreshold = 0.2,
  });

  static const _connections = <(String, String)>[
    ('l_ear', 'nose'), ('nose', 'r_ear'),
    ('l_shoulder', 'r_shoulder'),
    ('l_shoulder', 'l_elbow'), ('l_elbow', 'l_wrist'),
    ('r_shoulder', 'r_elbow'), ('r_elbow', 'r_wrist'),
    ('l_shoulder', 'l_hip'), ('r_shoulder', 'r_hip'),
    ('l_hip', 'r_hip'),
    ('l_hip', 'l_knee'), ('l_knee', 'l_ankle'),
    ('r_hip', 'r_knee'), ('r_knee', 'r_ankle'),
    ('l_ankle', 'l_heel'), ('l_heel', 'l_foot'),
    ('r_ankle', 'r_heel'), ('r_heel', 'r_foot'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (keypoints.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final jointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final jointHaloPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    for (final (from, to) in _connections) {
      final a = keypoints[from];
      final b = keypoints[to];
      if (a == null || b == null ||
          a.score < confidenceThreshold || b.score < confidenceThreshold) {
        continue;
      }
      canvas.drawLine(
        Offset(a.x * size.width, a.y * size.height),
        Offset(b.x * size.width, b.y * size.height),
        linePaint,
      );
    }

    for (final point in keypoints.values) {
      if (point.score < confidenceThreshold) continue;
      final center = Offset(point.x * size.width, point.y * size.height);
      canvas.drawCircle(center, 5, jointHaloPaint);
      canvas.drawCircle(center, 2.4, jointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonPainter oldDelegate) =>
      oldDelegate.keypoints != keypoints ||
      oldDelegate.color != color ||
      oldDelegate.confidenceThreshold != confidenceThreshold;
}
