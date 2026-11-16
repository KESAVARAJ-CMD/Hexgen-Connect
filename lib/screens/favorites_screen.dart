import 'package:flutter/material.dart';
import '../core/services/favorites_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../features/session/simple_over_video_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selectedFilter = 'All'; // 'All', 'Session', 'Over'
  final FavoritesService _favoritesService = FavoritesService();

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  void _openFavoriteVideo(FavoriteItem item) {
    String sessionTitle = item.title;
    String overName = 'Over 01';
    String overType = item.subtitle;
    int initialBallIndex = 0;

    if (item.extraData != null) {
      sessionTitle = item.extraData!['sessionTitle'] as String? ?? sessionTitle;
      overName = item.extraData!['overName'] as String? ?? overName;
      overType = item.extraData!['summary'] as String? ?? overType;
      initialBallIndex = item.extraData!['ballIndex'] as int? ?? 0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SimpleOverVideoScreen(
          sessionTitle: sessionTitle,
          overName: overName,
          overType: overType,
          lane: item.lane,
          speed: item.speed,
          ballsSummary: '6 Balls • Peak ${item.speed}',
          initialBallIndex: initialBallIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _favoritesService.items;
    final filteredItems = _selectedFilter == 'All'
        ? allItems
        : allItems.where((i) => i.type == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        showOrbs: false,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.navyBlue,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Favorite Highlights',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${allItems.length}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Filter Chips ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'All (${allItems.length})'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Shot', 'Shots'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Over', 'Best Overs'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Session', 'Sessions'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── List of Favorites ────────────────────────────────────────
              Expanded(
                child: filteredItems.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFFECACA),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.favorite_border_rounded,
                                    size: 38,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No Favorites Saved',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.navyBlue,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap the heart icon (❤️) on any session or over you played well to save it here for instant review.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 40),
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isOver = item.type == 'Over';
                          final isShot = item.type == 'Shot';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Tag Badge + Date + Unfavorite Icon
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                      decoration: BoxDecoration(
                                        color: isShot
                                            ? const Color(0xFFFDF4FF)
                                            : (isOver ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF)),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isShot
                                              ? const Color(0xFFF0ABFC)
                                              : (isOver ? const Color(0xFFA7F3D0) : const Color(0xFFDBEAFE)),
                                        ),
                                      ),
                                      child: Text(
                                        isShot ? 'FAVORITE SHOT' : (isOver ? 'BEST OVER' : 'SAVED SESSION'),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: isShot
                                              ? const Color(0xFFA855F7)
                                              : (isOver ? const Color(0xFF059669) : AppTheme.electricBlue),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          item.date,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            _favoritesService.removeFavorite(item.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Removed from Favorites'),
                                                behavior: SnackBarBehavior.floating,
                                                duration: Duration(seconds: 1),
                                                backgroundColor: AppTheme.navyBlue,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFFEF2F2),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.favorite_rounded,
                                              color: Color(0xFFEF4444),
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Title
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.navyBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Subtitle
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Watch Video Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openFavoriteVideo(item),
                                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                                    label: const Text(
                                      'Watch Highlight Video',
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.electricBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6.5),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.navyBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.navyBlue : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.navyBlue,
          ),
        ),
      ),
    );
  }
}
