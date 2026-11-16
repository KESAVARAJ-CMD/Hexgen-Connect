import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ProfileImageService {
  static const String avatarPrefKey = 'player_avatar_path';
  static const String bannerPrefKey = 'player_banner_path';
  static const String bannerPresetPrefKey = 'player_banner_preset';

  static final ImagePicker _picker = ImagePicker();

  /// Pick avatar from camera or gallery
  static Future<String?> pickAvatar(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(avatarPrefKey, image.path);
        return image.path;
      }
    } catch (_) {}
    return null;
  }

  /// Pick banner from camera or gallery
  static Future<String?> pickBanner(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(bannerPrefKey, image.path);
        await prefs.remove(bannerPresetPrefKey);
        return image.path;
      }
    } catch (_) {}
    return null;
  }

  /// Save banner preset ID (e.g. 'stadium_night', 'stadium_sunset', 'cyber_turf')
  static Future<void> setBannerPreset(String presetId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(bannerPresetPrefKey, presetId);
    await prefs.remove(bannerPrefKey);
  }

  /// Clear custom avatar
  static Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(avatarPrefKey);
  }

  /// Clear custom banner
  static Future<void> clearBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(bannerPrefKey);
    await prefs.remove(bannerPresetPrefKey);
  }

  /// Shows the modern Instagram/WhatsApp style Image Picker Action Sheet
  static Future<void> showAvatarPickerSheet({
    required BuildContext context,
    required ValueChanged<String?> onAvatarUpdated,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose how you want to update your athlete profile photo',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: const Color(0xFF0052FF),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final path = await pickAvatar(ImageSource.camera);
                    if (path != null) onAvatarUpdated(path);
                  },
                ),
                _buildActionItem(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: const Color(0xFF16A34A),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final path = await pickAvatar(ImageSource.gallery);
                    if (path != null) onAvatarUpdated(path);
                  },
                ),
                _buildActionItem(
                  icon: Icons.sports_cricket_rounded,
                  label: 'Pro Avatar',
                  color: const Color(0xFF8B5CF6),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString(avatarPrefKey, 'preset:player');
                    onAvatarUpdated('preset:player');
                  },
                ),
                _buildActionItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove',
                  color: const Color(0xFFEF4444),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await clearAvatar();
                    onAvatarUpdated(null);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Shows the Banner Picker Sheet with Presets and Gallery
  static Future<void> showBannerPickerSheet({
    required BuildContext context,
    required ValueChanged<String?> onBannerUpdated,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Cover Banner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Choose a cricket stadium theme or upload your own',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Preset Stadium Themes',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.navyBlue,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildBannerPresetCard(
                    title: 'Night Lights',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF0052FF), Color(0xFF06B6D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await setBannerPreset('night_lights');
                      onBannerUpdated('preset:night_lights');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBannerPresetCard(
                    title: 'Sunset Turf',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFFDC2626), Color(0xFFF59E0B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await setBannerPreset('sunset_turf');
                      onBannerUpdated('preset:sunset_turf');
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBannerPresetCard(
                    title: 'Cyber Net',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF020617), Color(0xFF1E3A8A), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await setBannerPreset('cyber_net');
                      onBannerUpdated('preset:cyber_net');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: const Text('Gallery Image', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.navyBlue,
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final path = await pickBanner(ImageSource.gallery);
                      if (path != null) onBannerUpdated(path);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await clearBanner();
                      onBannerUpdated(null);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.navyBlue,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBannerPresetCard({
    required String title,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the Avatar Widget with fallback to asset or monogram
  static Widget buildAvatar({
    required String? avatarPath,
    required String displayName,
    double size = 80,
    double borderWidth = 3,
  }) {
    ImageProvider? imageProvider;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      if (avatarPath == 'preset:player') {
        imageProvider = const AssetImage('assets/player.png');
      } else if (File(avatarPath).existsSync()) {
        imageProvider = FileImage(File(avatarPath));
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: imageProvider == null ? AppTheme.primaryCtaGradient : null,
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageProvider == null
          ? Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M',
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }

  /// Builds the Stadium Cover Banner
  static Widget buildBanner({
    required String? bannerPath,
    required String? bannerPreset,
    double height = 140,
    Widget? overlayChild,
  }) {
    DecorationImage? decorationImage;
    Gradient gradient = const LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF0037B3), Color(0xFF0052FF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    if (bannerPath != null && File(bannerPath).existsSync()) {
      decorationImage = DecorationImage(
        image: FileImage(File(bannerPath)),
        fit: BoxFit.cover,
      );
    } else if (bannerPreset != null) {
      if (bannerPreset == 'sunset_turf') {
        gradient = const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFFDC2626), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      } else if (bannerPreset == 'cyber_net') {
        gradient = const LinearGradient(
          colors: [Color(0xFF020617), Color(0xFF1E3A8A), Color(0xFF10B981)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: decorationImage == null ? gradient : null,
        image: decorationImage,
      ),
      child: Stack(
        children: [
          // Subtle stadium floodlights & crease lines overlay
          CustomPaint(
            size: Size.infinite,
            painter: _StadiumAtmospherePainter(),
          ),
          ?overlayChild,
        ],
      ),
    );
  }
}

/// Custom painter for stadium atmosphere (floodlight rays and pitch crease lines)
class _StadiumAtmospherePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Floodlight glow from top-right and top-left
    final lightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.25),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.85, 20), radius: 100));
    canvas.drawCircle(Offset(size.width * 0.85, 20), 100, lightPaint);

    final leftLightPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(size.width * 0.15, 10), radius: 80));
    canvas.drawCircle(Offset(size.width * 0.15, 10), 80, leftLightPaint);

    // 2. Subtle pitch geometry / crease curves
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width, size.height * 0.6);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
