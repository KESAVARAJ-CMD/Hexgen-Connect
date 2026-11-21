import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../core/network/matrix_api_service.dart';
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
  final String? videoPath;
  final String? streamUrl;

  const AthleteHighlightItem({
    required this.id,
    required this.title,
    required this.speed,
    this.lane = 'Hexgen Turf • Lane 1',
    this.date = 'Today • 05:30 PM',
    this.thumbnailUrl,
    required this.icon,
    required this.gradientColors,
    this.videoAsset,
    this.videoPath,
    this.streamUrl,
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
    'videoPath': videoPath,
    'streamUrl': streamUrl,
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
    videoAsset: json['videoAsset'] as String?,
    videoPath: json['videoPath'] as String?,
    streamUrl: json['streamUrl'] as String?,
  );

  static IconData _iconFromCode(int? code) {
    if (code == Icons.air_rounded.codePoint) return Icons.air_rounded;
    if (code == Icons.sync_rounded.codePoint) return Icons.sync_rounded;
    if (code == Icons.bolt_rounded.codePoint) return Icons.bolt_rounded;
    if (code == Icons.sports_cricket_rounded.codePoint) return Icons.sports_cricket_rounded;
    return Icons.sports_cricket_rounded;
  }
}

/// ── Dynamic Freeze-Frame Thumbnail Bubble for Profile Highlights ─────────────
class HighlightVideoFreezeBubble extends StatefulWidget {
  final AthleteHighlightItem highlight;
  final double size;

  const HighlightVideoFreezeBubble({
    super.key,
    required this.highlight,
    this.size = 54,
  });

  @override
  State<HighlightVideoFreezeBubble> createState() => _HighlightVideoFreezeBubbleState();
}

class _HighlightVideoFreezeBubbleState extends State<HighlightVideoFreezeBubble> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initThumbnail();
  }

  @override
  void didUpdateWidget(HighlightVideoFreezeBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlight.videoPath != widget.highlight.videoPath ||
        oldWidget.highlight.streamUrl != widget.highlight.streamUrl ||
        oldWidget.highlight.videoAsset != widget.highlight.videoAsset) {
      _disposeController();
      _initThumbnail();
    }
  }

  Future<void> _initThumbnail() async {
    final videoPath = widget.highlight.videoPath;
    var streamUrl = widget.highlight.streamUrl;
    final asset = widget.highlight.videoAsset;

    final hasVideo = (videoPath != null && videoPath.isNotEmpty) ||
        (streamUrl != null && streamUrl.isNotEmpty) ||
        (asset != null && asset.isNotEmpty);

    if (!hasVideo) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if ((streamUrl == null || streamUrl.isEmpty) && videoPath != null && videoPath.isNotEmpty) {
        streamUrl = await MatrixApiService().getPlaybackUrl(videoPath);
      }

      VideoPlayerController controller;
      if (streamUrl != null && streamUrl.isNotEmpty) {
        controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
      } else if (asset != null && asset.isNotEmpty) {
        controller = VideoPlayerController.asset(asset);
      } else {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      await controller.initialize();
      await controller.setVolume(0);
      await controller.pause();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _videoController = controller;
        _isInitialized = true;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[HighlightVideoFreezeBubble] Thumbnail error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _disposeController() {
    _videoController?.dispose();
    _videoController = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. If video controller is ready, show frozen frame directly from the actual video!
    if (_isInitialized && _videoController != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: ClipOval(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      );
    }

    // 2. If loading
    if (_isLoading) {
      return Container(
        width: widget.size,
        height: widget.size,
        color: const Color(0xFFF1F5F9),
        child: const Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0057FF),
            ),
          ),
        ),
      );
    }

    // 3. Fallback when no video is attached: Bowler icon
    return Container(
      width: widget.size,
      height: widget.size,
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(9),
      child: Image.asset(
        'assets/Bowler_icon.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.sports_cricket_rounded,
          color: Color(0xFF64748B),
          size: 22,
        ),
      ),
    );
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
    VideoPlayerController? controller;

    // 1. Resolve Cloud Video Playback URL if videoPath or streamUrl is available
    String? streamUrl = widget.highlight.streamUrl;
    final videoPath = widget.highlight.videoPath;

    if ((streamUrl == null || streamUrl.isEmpty) && videoPath != null && videoPath.isNotEmpty) {
      try {
        streamUrl = await MatrixApiService().getPlaybackUrl(videoPath);
      } catch (e) {
        debugPrint('[AthleteStoryViewer] Error resolving cloud video: $e');
      }
    }

    // 2. Try network streaming from Cloudflare R2
    if (streamUrl != null && streamUrl.isNotEmpty) {
      try {
        controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
        _videoController = controller;
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setVolume(1.0);
        await controller.play();
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _progressController.forward();
        }
        return;
      } catch (e) {
        debugPrint('[AthleteStoryViewer] Cloud stream error: $e');
      }
    }

    // 3. Fallback to asset if specified and not empty
    final asset = widget.highlight.videoAsset;
    if (asset != null && asset.isNotEmpty) {
      try {
        controller = VideoPlayerController.asset(asset);
        _videoController = controller;
        await controller.initialize();
        await controller.setLooping(true);
        await controller.setVolume(1.0);
        await controller.play();
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
          _progressController.forward();
        }
        return;
      } catch (_) {}
    }

    // 4. If no video is found or video failed to load, proceed with 5s telemetry preview
    if (mounted) {
      _progressController.forward();
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
                          _buildHudMetric(speed.replaceAll(' km/h', ''), 'BALL SPEED', unit: 'km/h', color: const Color(0xFF00E5FF)),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/Bowler_icon.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.sports_cricket_rounded,
                    color: Colors.white70,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
