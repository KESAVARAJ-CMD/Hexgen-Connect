import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/services/profile_image_service.dart';
import '../core/theme/app_theme.dart';

class AthleteHighlightItem {
  final String id;
  final String title;
  final String speed;
  final String? lane;
  final String? date;
  final String? thumbnailUrl;
  final IconData icon;
  final List<Color> gradientColors;
  final String? videoAsset;

  const AthleteHighlightItem({
    required this.id,
    required this.title,
    required this.speed,
    this.lane = 'Hexgen Turf • Lane 1',
    this.date = 'Today • 05:30 PM',
    this.thumbnailUrl,
    required this.icon,
    required this.gradientColors,
    this.videoAsset = 'assets/U15S125O3B1.mp4',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'speed': speed,
    'lane': lane,
    'date': date,
    'thumbnailUrl': thumbnailUrl,
    'iconCode': icon.codePoint,
    'gradientColor1': gradientColors[0].toARGB32(),
    'gradientColor2': gradientColors[1].toARGB32(),
    'videoAsset': videoAsset,
  };

  factory AthleteHighlightItem.fromJson(Map<String, dynamic> json) => AthleteHighlightItem(
    id: json['id'] as String? ?? UniqueKey().toString(),
    title: json['title'] as String? ?? 'Practice Drill',
    speed: json['speed'] as String? ?? '140 km/h',
    lane: json['lane'] as String? ?? 'Hexgen Turf • Lane 1',
    date: json['date'] as String? ?? 'Recent Drill',
    thumbnailUrl: json['thumbnailUrl'] as String?,
    icon: _iconFromCode(json['iconCode'] as int?),
    gradientColors: [
      Color(json['gradientColor1'] as int? ?? 0xFF0052FF),
      Color(json['gradientColor2'] as int? ?? 0xFF00D2FF),
    ],
    videoAsset: json['videoAsset'] as String? ?? 'assets/U15S125O3B1.mp4',
  );

  static IconData _iconFromCode(int? code) {
    if (code == Icons.air_rounded.codePoint) return Icons.air_rounded;
    if (code == Icons.sync_rounded.codePoint) return Icons.sync_rounded;
    if (code == Icons.bolt_rounded.codePoint) return Icons.bolt_rounded;
    if (code == Icons.sports_cricket_rounded.codePoint) return Icons.sports_cricket_rounded;
    return Icons.sports_cricket_rounded;
  }
}

class AthleteStoryViewer extends StatefulWidget {
  final AthleteHighlightItem highlight;
  final String? athleteName;
  final String? avatarPath;
  final VoidCallback? onRemoveRequested;

  const AthleteStoryViewer({
    super.key,
    required this.highlight,
    this.athleteName,
    this.avatarPath,
    this.onRemoveRequested,
  });

  static Future<bool?> open(
    BuildContext context, {
    required AthleteHighlightItem highlight,
    String? athleteName,
    String? avatarPath,
    VoidCallback? onRemoveRequested,
  }) {
    return Navigator.push<bool>(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (context, animation, secondaryAnimation) => AthleteStoryViewer(
          highlight: highlight,
          athleteName: athleteName,
          avatarPath: avatarPath,
          onRemoveRequested: onRemoveRequested,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  State<AthleteStoryViewer> createState() => _AthleteStoryViewerState();
}

class _AthleteStoryViewerState extends State<AthleteStoryViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    // 5-second Instagram Story Duration
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) Navigator.pop(context);
      }
    });

    _initVideo();
  }

  Future<void> _initVideo() async {
    final asset = widget.highlight.videoAsset ?? 'assets/U15S125O3B1.mp4';
    try {
      final controller = VideoPlayerController.asset(asset);
      _videoController = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0.0); // Mute for story reel preview
      await controller.play();
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        _progressController.forward();
      }
    } catch (_) {
      // If video asset is missing or error, still run the 5s telemetry story preview
      if (mounted) {
        _progressController.forward();
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _pauseStory() {
    setState(() => _isPaused = true);
    _progressController.stop();
    _videoController?.pause();
  }

  void _resumeStory() {
    setState(() => _isPaused = false);
    _progressController.forward();
    _videoController?.play();
  }

  void _confirmRemoveHighlight() {
    _pauseStory();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 8),
            Text(
              'Remove Highlight',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
          ],
        ),
        content: Text(
          'Remove "${widget.highlight.title}" from your profile highlights?',
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resumeStory();
            },
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Close dialog
              widget.onRemoveRequested?.call();
              Navigator.pop(context, true); // Close story viewer with true
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.highlight.title;
    final speed = widget.highlight.speed;
    final lane = widget.highlight.lane ?? 'Hexgen Turf • Lane 1';
    final name = widget.athleteName ?? 'Athlete';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTapDown: (_) => _pauseStory(),
          onTapUp: (_) => _resumeStory(),
          onTapCancel: () => _resumeStory(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Video Player or Animated Telemetry Canvas
              if (_isVideoInitialized && _videoController != null)
                Center(
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
              else
                _buildTelemetryFallbackVisual(),

              // Gradient Vignette for clear readability of HUD and top controls
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.22, 0.70, 1.0],
                    ),
                  ),
                ),
              ),

              // 2. Top Progress Bar (5s Story Indicator)
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 2.8,
                      ),
                    );
                  },
                ),
              ),

              // 3. Top Header Bar (Avatar, Drill Title, Delete & Close)
              Positioned(
                top: 20,
                left: 14,
                right: 10,
                child: Row(
                  children: [
                    // Athlete mini Avatar
                    ProfileImageService.buildAvatar(
                      avatarPath: widget.avatarPath,
                      displayName: name,
                      size: 36,
                      borderWidth: 1.5,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0052FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  speed,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            lane,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Remove/Delete Highlight Menu
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                      tooltip: 'Options',
                      onPressed: () {
                        _confirmRemoveHighlight();
                      },
                    ),

                    // Close Story Icon (✕)
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                      tooltip: 'Close Story',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // 4. Pause Indicator if Held Down
              if (_isPaused)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pause_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Paused',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

              // 5. Bottom Telemetry HUD Overlay
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Telemetry Quick Stats Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildHudMetric('142.4', 'BALL SPEED', unit: 'km/h', color: const Color(0xFF00E5FF)),
                          _buildHudDivider(),
                          _buildHudMetric('94%', 'SWEET SPOT', color: const Color(0xFF10B981)),
                          _buildHudDivider(),
                          _buildHudMetric('42°', 'BAT ANGLE', color: const Color(0xFFF59E0B)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Hold screen to pause replay',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHudMetric(String value, String label, {String? unit, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: 2),
              Text(
                unit,
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildHudDivider() {
    return Container(
      width: 1,
      height: 22,
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildTelemetryFallbackVisual() {
    final thumb = widget.highlight.thumbnailUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumb != null && thumb.startsWith('http'))
          Image.network(
            thumb,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          )
        else
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              ),
            ),
          ),
        Container(
          color: Colors.black.withValues(alpha: 0.65),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.highlight.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${widget.highlight.speed} • Practice Drill Telemetry',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
