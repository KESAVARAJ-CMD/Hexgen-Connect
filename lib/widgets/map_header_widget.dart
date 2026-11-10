import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class MapHeaderWidget extends StatelessWidget {
  const MapHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFE2F0FF),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Color(0x280057FF),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── 1. South India Vector Map Background ──────────────────────────
            Positioned.fill(
              child: CustomPaint(
                painter: _FuturisticSouthIndiaMapPainter(),
              ),
            ),

            // ── 2. Clear Hexgen Logo Canopy Badge (Top Center Un-obscured) ────
            Align(
              alignment: const Alignment(0, -0.90),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(245),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.skyBlue.withAlpha(160),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withAlpha(45),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'HEXGEN CONNECT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.navyBlue,
                    letterSpacing: 0.8,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ),

            // ── 3. Circular Photo Pin Badges (Shifted Down below Header) ──────
            // 📍 Bangalore Pin (Vidhana Soudha) - Positioned comfortably below header
            _buildPhotoMapPin(
              top: 85,
              left: 14,
              city: 'Bangalore',
              imageUrl:
                  'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=300&auto=format&fit=crop&q=80',
              fallbackIcon: Icons.apartment_rounded,
            ),

            // 📍 Chennai Pin (Chennai Central Station) - Positioned comfortably below header
            _buildPhotoMapPin(
              top: 85,
              right: 14,
              city: 'Chennai',
              imageUrl:
                  'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=300&auto=format&fit=crop&q=80',
              fallbackIcon: Icons.directions_subway_rounded,
            ),

            // 📍 Coimbatore Pin (Hills & Valley) - Center South
            _buildPhotoMapPin(
              top: 175,
              left: 110,
              city: 'Coimbatore',
              imageUrl:
                  'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=300&auto=format&fit=crop&q=80',
              fallbackIcon: Icons.terrain_rounded,
            ),

            // 📍 India Regional Pin - Bottom Left
            _buildPhotoMapPin(
              bottom: 35,
              left: 20,
              city: 'India',
              imageUrl:
                  'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=300&auto=format&fit=crop&q=80',
              fallbackIcon: Icons.flag_rounded,
            ),

            // ── 4. Cricket Batsman Action Photo Pin (Bottom Right) ─────────────
            Positioned(
              right: 20,
              bottom: 18,
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withAlpha(90),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=300&auto=format&fit=crop&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.electricBlue,
                      child: const Icon(Icons.sports_cricket_rounded,
                          color: Colors.white, size: 36),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoMapPin({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String city,
    required String imageUrl,
    required IconData fallbackIcon,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular Landmark Photo Pin
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppTheme.electricBlue, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricBlue.withAlpha(90),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppTheme.electricBlue,
                      child: Icon(fallbackIcon, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // White Pill Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AppTheme.skyBlue.withAlpha(140), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  city,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.navyBlue,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── South India Map Canvas Painter ────────────────────────────────────────────
class _FuturisticSouthIndiaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Land & Grid
    final landPaint = Paint()
      ..color = const Color(0xFFE5F1FF)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), landPaint);

    final gridPaint = Paint()
      ..color = const Color(0xFF93C5FD).withAlpha(45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Bay of Bengal Ocean
    final oceanPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7DD3FC), Color(0xFF38BDF8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(w * 0.68, 0, w * 0.32, h));

    final oceanPath = Path()
      ..moveTo(w * 0.70, 0)
      ..cubicTo(w * 0.66, h * 0.35, w * 0.74, h * 0.65, w * 0.82, h)
      ..lineTo(w, h)
      ..lineTo(w, 0)
      ..close();

    canvas.drawPath(oceanPath, oceanPaint);

    // Highway Vector Line
    final mainHighwayPaint = Paint()
      ..color = const Color(0xFF0057FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final innerStripePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final highwayPath = Path()
      ..moveTo(w * 0.22, h * 0.28)
      ..cubicTo(w * 0.45, h * 0.25, w * 0.65, h * 0.28, w * 0.78, h * 0.28);

    canvas.drawPath(highwayPath, mainHighwayPaint);
    canvas.drawPath(highwayPath, innerStripePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
