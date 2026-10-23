import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';

import 'analytics_page.dart';
import 'pose_painter.dart';

const String poseModel = "yolo26n-pose";
const String segModel = "yolo26n-seg";
const String depthModel = "yolo26n-depth";
const String csegModel = "assets/models/best.tflite";

/// Basic real-time pose test using an official Ultralytics pose model.
/// Uses the official model ID so the plugin downloads + caches it on first
/// run — no .tflite asset bundling needed. Swap to a bundled asset path
/// (e.g. 'assets/yolo26n-pose.tflite' + task: YOLOTask.pose) if offline.
class CameraTestPage extends StatefulWidget {
  const CameraTestPage({super.key});

  @override
  State<CameraTestPage> createState() => _CameraTestPageState();
}

class _CameraTestPageState extends State<CameraTestPage> {
  List<YOLOResult> _results = [];
  double _fps = 0;
  int _frames = 0;
  Object? _modelError;
  YOLOTask? _task = YOLOTask.pose;
  String _modelPath = poseModel;
  String _selected = "pose";

  void _onModelChanged(String? value) {
    if (value == null || value == _selected) return;
    setState(() {
      _selected = value;
      _results = [];
      _modelError = null;
      if (value == "pose") {
        _task = YOLOTask.pose;
        _modelPath = poseModel;
      } else if (value == "seg") {
        _task = YOLOTask.segment;
        _modelPath = segModel;
      } else if (value == "depth") {
        _task = YOLOTask.depth;
        _modelPath = depthModel;
      } else {
        // Custom finetuned yolo26n-pose: pin pose task explicitly.
        _task = YOLOTask.segment;
        _modelPath = csegModel;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selected,
            onChanged: _onModelChanged,
            items: const [
              DropdownMenuItem<String>(value: "pose", child: Text("Pose")),
              DropdownMenuItem<String>(value: "seg", child: Text("Seg")),
              DropdownMenuItem<String>(value: "depth", child: Text("Depth")),
              DropdownMenuItem<String>(
                value: "custom",
                child: Text("Custom (best)"),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          YOLOView(
            key: ValueKey(_modelPath),
            modelPath: _modelPath,
            task: _task,
            onResult: (results) {
              _frames++;
              if (!mounted) return;
              setState(() => _results = results);
              globalStats.value = PoseStats(
                fps: _fps,
                personCount: results.length,
                results: results,
                totalFrames: _frames,
              );
            },
            onPerformanceMetrics: (m) {
              _fps = m.fps;
            },
            onModelError: (error, modelPath, task) {
              if (mounted) setState(() => _modelError = error);
            },
          ),
          // Custom skeleton overlay on top of the native preview.
          IgnorePointer(child: CustomPaint(painter: PosePainter(_results))),
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: _Hud(fps: _fps, count: _results.length),
          ),
          if (_modelError != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Model error: $_modelError',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  const _Hud({required this.fps, required this.count});
  final double fps;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'FPS: ${fps.toStringAsFixed(1)}  |  Persons: $count',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
