import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

/// Draws YOLO pose boxes + keypoints. Coordinates in [YOLOResult.normalizedBox]
/// are 0..1, so we scale to widget size. Keypoints are in pixel space of the
/// camera frame — normalized here against the max keypoint extent.
class PosePainter extends CustomPainter {
  PosePainter(this.results);
  final List<YOLOResult> results;

  // COCO-17 skeleton edges (indices into keypoints list).
  static const _edges = [
    [5, 6], [5, 7], [7, 9], [6, 8], [8, 10], // arms
    [5, 11], [6, 12], [11, 12], // torso
    [11, 13], [13, 15], [12, 14], [14, 16], // legs
    [0, 1], [0, 2], [1, 3], [2, 4], // face
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3;
    final boxPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = Colors.redAccent;

    for (final r in results) {
      final b = r.normalizedBox;
      canvas.drawRect(
        Rect.fromLTRB(
          b.left * size.width,
          b.top * size.height,
          b.right * size.width,
          b.bottom * size.height,
        ),
        boxPaint,
      );
      final kps = r.keypoints;
      if (kps == null || kps.isEmpty) continue;
      double maxX = 1, maxY = 1;
      for (final k in kps) {
        if (k.x > maxX) maxX = k.x;
        if (k.y > maxY) maxY = k.y;
      }
      Offset map(Keypoint k) =>
          Offset(k.x / maxX * size.width, k.y / maxY * size.height);
      for (final e in _edges) {
        if (e[0] < kps.length && e[1] < kps.length) {
          canvas.drawLine(map(kps[e[0]]), map(kps[e[1]]), line);
        }
      }
      for (final k in kps) {
        canvas.drawCircle(map(k), 4, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter old) => true;
}
