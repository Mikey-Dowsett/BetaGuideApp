import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

/// Shared live stats written by the camera page, read by analytics.
class PoseStats {
  final double fps;
  final int personCount;
  final List<YOLOResult> results;
  final int totalFrames;
  const PoseStats({
    required this.fps,
    required this.personCount,
    required this.results,
    required this.totalFrames,
  });
  factory PoseStats.empty() =>
      const PoseStats(fps: 0, personCount: 0, results: [], totalFrames: 0);
}

final globalStats = ValueNotifier<PoseStats>(PoseStats.empty());

/// Lightweight "yolo-analytics" style page: FPS, detection state, keypoints.
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key, required this.stats});
  final ValueNotifier<PoseStats> stats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YOLO Analytics')),
      body: ValueListenableBuilder<PoseStats>(
        valueListenable: stats,
        builder: (context, s, child) {
          final first = s.results.isEmpty ? null : s.results.first;
          final kps = first?.keypoints ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  _Card(title: 'FPS', value: s.fps.toStringAsFixed(1)),
                  const SizedBox(width: 12),
                  _Card(title: 'Persons', value: '${s.personCount}'),
                  const SizedBox(width: 12),
                  _Card(title: 'Frames', value: '${s.totalFrames}'),
                ],
              ),
              const SizedBox(height: 16),
              Text('Detections (${s.results.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              for (final r in s.results)
                ListTile(
                  dense: true,
                  title: Text(r.className),
                  trailing: Text(
                    'conf:${r.confidence.toStringAsFixed(2)} '
                    'kp:${r.keypoints?.length ?? 0}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Keypoints first person (${kps.length})',
                  style: Theme.of(context).textTheme.titleMedium),
              for (var i = 0; i < kps.length; i++)
                ListTile(
                  dense: true,
                  title: Text('kp $i'),
                  trailing: Text(
                    'x:${kps[i].x.toStringAsFixed(1)} y:${kps[i].y.toStringAsFixed(1)}',
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              if (s.results.isEmpty)
                const Text(
                    'No person detected yet — point camera at a subject.'),
            ],
          );
        },
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: Theme.of(context).textTheme.labelMedium),
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
