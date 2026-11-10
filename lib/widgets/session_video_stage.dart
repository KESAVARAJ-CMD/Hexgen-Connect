import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_controls.dart';
import '../models/pose_data.dart';
import 'skeleton_painter.dart';

/// Full session replay stage: real video + skeleton + speed + frame step.
class SessionVideoStage extends StatefulWidget {
  final String assetPath;
  final Map<String, Keypoint> keypoints;
  final String title;
  final String subtitle;
  final double height;
  final bool compact;

  const SessionVideoStage({
    super.key,
    required this.assetPath,
    required this.keypoints,
    this.title = '',
    this.subtitle = '',
    this.height = 320,
    this.compact = false,
  });

  @override
  State<SessionVideoStage> createState() => _SessionVideoStageState();
}

class _SessionVideoStageState extends State<SessionVideoStage> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _playing = false;
  bool _loading = true;
  String? _error;
  double _speed = 1.0;
  static const _speeds = [0.25, 0.5, 1.0, 1.5, 2.0];
  static const _assumedFps = 30;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<File> _materializeAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${assetPath.split('/').last}');
    if (!await file.exists() || await file.length() != bytes.lengthInBytes) {
      await file.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        flush: true,
      );
    }
    return file;
  }

  Future<void> _boot() async {
    setState(() {
      _loading = true;
      _error = null;
      _ready = false;
    });

    await _controller?.dispose();
    _controller = null;

    try {
      // File path avoids Android getLookupKeyForAsset pigeon channel failures.
      final file = await _materializeAsset(widget.assetPath);
      final controller = VideoPlayerController.file(file);
      _controller = controller;
      controller.addListener(_onTick);

      await controller.initialize();
      await controller.setLooping(true);
      await controller.setPlaybackSpeed(_speed);
      await controller.setVolume(1);
      await controller.play();

      if (!mounted) return;
      setState(() {
        _ready = true;
        _playing = true;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      // Fallback: try asset API once (some devices only work this way after cold start).
      try {
        final controller = VideoPlayerController.asset(widget.assetPath);
        _controller = controller;
        controller.addListener(_onTick);
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setPlaybackSpeed(_speed);
        await controller.play();
        if (!mounted) return;
        setState(() {
          _ready = true;
          _playing = true;
          _loading = false;
          _error = null;
        });
      } catch (e2) {
        if (!mounted) return;
        setState(() {
          _ready = false;
          _playing = false;
          _loading = false;
          _error = 'Video could not start. Stop the app and Run again (full restart).';
        });
      }
    }
  }

  void _onTick() {
    final c = _controller;
    if (!mounted || c == null) return;
    final playing = c.value.isPlaying;
    if (playing != _playing) {
      setState(() => _playing = playing);
    } else if (c.value.isInitialized) {
      setState(() {});
    }
  }

  Future<void> _togglePlay() async {
    final c = _controller;
    if (c == null || !_ready) return;
    if (c.value.isPlaying) {
      await c.pause();
    } else {
      await c.play();
    }
  }

  Future<void> _setSpeed(double speed) async {
    final c = _controller;
    setState(() => _speed = speed);
    if (c == null || !_ready) return;
    await c.setPlaybackSpeed(speed);
  }

  Future<void> _stepFrames(int frames) async {
    final c = _controller;
    if (c == null || !_ready) return;
    await c.pause();
    final frameMs = (1000 / _assumedFps).round();
    final next = c.value.position + Duration(milliseconds: frameMs * frames);
    final clamped = next < Duration.zero
        ? Duration.zero
        : (next > c.value.duration ? c.value.duration : next);
    await c.seekTo(clamped);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get _currentFrame {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return 0;
    return (c.value.position.inMilliseconds / (1000 / _assumedFps)).floor();
  }

  int get _totalFrames {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return 0;
    return (c.value.duration.inMilliseconds / (1000 / _assumedFps)).floor();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final progress = (c != null &&
            c.value.isInitialized &&
            c.value.duration.inMilliseconds > 0)
        ? (c.value.position.inMilliseconds / c.value.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navyBlue.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SizedBox(
              height: widget.height,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xFF0B1F3A)),
                  if (_ready && c != null)
                    _CoverVideo(controller: c)
                  else if (_loading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.cyanBlue,
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.videocam_off_rounded,
                                color: Colors.white54, size: 36),
                            const SizedBox(height: 10),
                            Text(
                              _error ?? 'Video unavailable',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Roboto',
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _boot,
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.cyanBlue,
                              ),
                              child: const Text(
                                'RETRY',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                          stops: const [0.5, 1],
                        ),
                      ),
                    ),
                  ),
                  if (_ready)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: SkeletonPainter(
                            keypoints: widget.keypoints,
                            color: AppTheme.cyanBlue,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: _chip('AI SKELETON', Icons.sensors_rounded),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: _chip('$_assumedFps FPS', Icons.speed_rounded),
                  ),
                  if (widget.title.isNotEmpty)
                    Positioned(
                      left: 14,
                      right: 70,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          if (widget.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Transport + speed + frame controls
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      c != null && c.value.isInitialized
                          ? _fmt(c.value.position)
                          : '00:00',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navyBlue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackShape: const GradientSliderTrackShape(),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7, elevation: 2),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                          inactiveTrackColor: AppTheme.lightBlue,
                          thumbColor: Colors.white,
                        ),
                        child: Slider(
                          value: progress.toDouble(),
                          onChanged: !_ready || c == null
                              ? null
                              : (v) {
                                  final d = c.value.duration;
                                  c.seekTo(Duration(
                                    milliseconds:
                                        (d.inMilliseconds * v).round(),
                                  ));
                                },
                        ),
                      ),
                    ),
                    Text(
                      c != null && c.value.isInitialized
                          ? _fmt(c.value.duration)
                          : '00:00',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.slateBlue,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _iconBtn(Icons.skip_previous_rounded, () => _stepFrames(-1)),
                    _iconBtn(Icons.replay_5_rounded, () async {
                      final c = _controller;
                      if (c == null || !_ready) return;
                      final t = c.value.position - const Duration(seconds: 5);
                      await c.seekTo(t < Duration.zero ? Duration.zero : t);
                    }),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryCtaGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.electricBlue.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                    _iconBtn(Icons.forward_5_rounded, () async {
                      final c = _controller;
                      if (c == null || !_ready) return;
                      final t = c.value.position + const Duration(seconds: 5);
                      await c.seekTo(
                        t > c.value.duration ? c.value.duration : t,
                      );
                    }),
                    _iconBtn(Icons.skip_next_rounded, () => _stepFrames(1)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'SPEED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.slateBlue,
                        letterSpacing: 0.6,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _speeds.map((s) {
                            final selected = _speed == s;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () => _setSpeed(s),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: selected
                                        ? AppTheme.primaryCtaGradient
                                        : null,
                                    color: selected ? null : AppTheme.iceBlue,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: selected
                                          ? Colors.transparent
                                          : AppTheme.cardBorderColor,
                                    ),
                                  ),
                                  child: Text(
                                    '${s}x',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: selected
                                          ? Colors.white
                                          : AppTheme.navyBlue,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!widget.compact) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _metaPill('FRAME $_currentFrame / $_totalFrames'),
                      const SizedBox(width: 8),
                      _metaPill('$_assumedFps FPS · ${_speed}x'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppTheme.iceBlue,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.cardBorderColor),
        ),
        child: Icon(icon, size: 20, color: AppTheme.navyBlue),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppTheme.cyanBlue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.iceBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.lightBlue),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppTheme.electricBlue,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}

class _CoverVideo extends StatelessWidget {
  final VideoPlayerController controller;

  const _CoverVideo({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final aspect = controller.value.aspectRatio <= 0
            ? 16 / 9
            : controller.value.aspectRatio;
        final stageW = constraints.maxWidth;
        final stageH = constraints.maxHeight;
        double w = stageW;
        double h = w / aspect;
        if (h < stageH) {
          h = stageH;
          w = h * aspect;
        }
        return ClipRect(
          child: OverflowBox(
            minWidth: w,
            maxWidth: w,
            minHeight: h,
            maxHeight: h,
            alignment: Alignment.center,
            child: SizedBox(
              width: w,
              height: h,
              child: VideoPlayer(controller),
            ),
          ),
        );
      },
    );
  }
}
