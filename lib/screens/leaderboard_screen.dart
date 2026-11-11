import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/cyber_glass_backdrop.dart';
import '../core/widgets/hexgen_badge.dart';
import '../core/widgets/hexgen_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTimeframe = 0; // 0: Weekly, 1: Monthly, 2: All Time
  String _selectedSport = 'Cricket';

  final List<String> _sports = ['Cricket', 'Pickleball'];

  final List<Map<String, dynamic>> _topAthletes = [
    {
      'rank': 1,
      'name': 'Rohan V.',
      'handle': '@rohan.strike',
      'level': 'Master',
      'xp': 4890,
      'speed': '138 km/h',
      'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&auto=format&fit=crop&q=80',
      'trend': 'up',
      'trendDiff': '1',
    },
    {
      'rank': 2,
      'name': 'Arjun Mehta',
      'handle': '@arjun.crick',
      'level': 'Expert',
      'xp': 4320,
      'speed': '132 km/h',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=120&auto=format&fit=crop&q=80',
      'trend': 'same',
      'trendDiff': '0',
    },
    {
      'rank': 3,
      'name': 'Dev Patel',
      'handle': '@dev.pace',
      'level': 'Pro',
      'xp': 3980,
      'speed': '129 km/h',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=120&auto=format&fit=crop&q=80',
      'trend': 'up',
      'trendDiff': '3',
    },
    {
      'rank': 4,
      'name': 'Vikramaditya S.',
      'handle': '@vikram.ace',
      'level': 'Pro',
      'xp': 3450,
      'speed': '126 km/h',
      'avatar': 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=120&auto=format&fit=crop&q=80',
      'trend': 'down',
      'trendDiff': '1',
    },
    {
      'rank': 5,
      'name': 'Siddharth Rao',
      'handle': '@sid.seam',
      'level': 'Expert',
      'xp': 3120,
      'speed': '124 km/h',
      'avatar': 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=120&auto=format&fit=crop&q=80',
      'trend': 'up',
      'trendDiff': '2',
    },
    {
      'rank': 6,
      'name': 'Karan Singh',
      'handle': '@karan.power',
      'level': 'Trainer',
      'xp': 2890,
      'speed': '121 km/h',
      'avatar': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=120&auto=format&fit=crop&q=80',
      'trend': 'same',
      'trendDiff': '0',
    },
    {
      'rank': 7,
      'name': 'Aditya Sen',
      'handle': '@aditya.bat',
      'level': 'Pro',
      'xp': 2640,
      'speed': '118 km/h',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=120&auto=format&fit=crop&q=80',
      'trend': 'up',
      'trendDiff': '4',
    },
    {
      'rank': 8,
      'name': 'Manoj Krishnan',
      'handle': '@manoj.k',
      'level': 'Trainer',
      'xp': 2410,
      'speed': '115 km/h',
      'avatar': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=120&auto=format&fit=crop&q=80',
      'trend': 'down',
      'trendDiff': '2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final athlete1 = _topAthletes[0];
    final athlete2 = _topAthletes[1];
    final athlete3 = _topAthletes[2];
    final remainingAthletes = _topAthletes.sublist(3);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CyberGlassBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.cardBorderColor,
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: AppTheme.navyBlue,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'ARENA LEADERBOARD',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.navyBlue,
                        letterSpacing: 0.6,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.pureWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD6E4F8)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F2B5C).withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSport,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.navyBlue, size: 18),
                          isDense: true,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navyBlue,
                            fontFamily: 'Roboto',
                          ),
                          items: _sports.map((sport) {
                            return DropdownMenuItem(
                              value: sport,
                              child: Text(sport),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedSport = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // ── Scrollable Body ──────────────────────────────────────────────
                    ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              // 1. Timeframe Filter Selector
              Container(
                height: 44,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.cardBorderColor, width: 1.2),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTimeTab(0, 'WEEKLY')),
                    Expanded(child: _buildTimeTab(1, 'MONTHLY')),
                    Expanded(child: _buildTimeTab(2, 'ALL-TIME')),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Podium Section for Top 3 (2nd, 1st, 3rd)
              Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                decoration: BoxDecoration(
                  color: AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.cardBorderColor),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navyBlue.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_rounded, color: Color(0xFFF59E0B), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'ARENA CHAMPIONS PODIUM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.navyBlue,
                            letterSpacing: 0.8,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // #2 Silver (Left)
                        Expanded(child: _buildPodiumAthlete(athlete2, 2, 90, const Color(0xFF94A3B8))),
                        // #1 Gold (Center, Elevated)
                        Expanded(child: _buildPodiumAthlete(athlete1, 1, 120, const Color(0xFFF59E0B))),
                        // #3 Bronze (Right)
                        Expanded(child: _buildPodiumAthlete(athlete3, 3, 75, const Color(0xFFD97706))),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Leaderboard Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GLOBAL ATHLETES RANKING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      letterSpacing: 0.8,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    '${_topAthletes.length} Competitors',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.slateBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 4. Athletes List (Ranks 4+)
              ...remainingAthletes.map((athlete) => _buildAthleteRow(athlete)),
            ],
          ),

          // ── Sticky Bottom Athlete Card for Logged In User ─────────────────
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF034EA2),
                    Color(0xFF0866F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0866F5).withValues(alpha: 0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // User Rank Circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '#14',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Details
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Rahul Kumar (You)',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 1),
                        Text(
                          '1,420 XP • Top 8% in Arena',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFFBFDBFE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action / Share
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 14, color: AppTheme.electricBlue),
                        SizedBox(width: 3),
                        Text(
                          'PLAY NEXT',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildTimeTab(int index, String label) {
    final isSelected = _selectedTimeframe == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeframe = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryCtaGradient : null,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppTheme.slateBlue,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumAthlete(Map<String, dynamic> athlete, int rank, double pedestalHeight, Color accentColor) {
    final bool isFirst = rank == 1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) ...[
          const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 26),
          const SizedBox(height: 2),
        ],
        // Avatar with Ring
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: isFirst ? 60 : 48,
              height: isFirst ? 60 : 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: accentColor, width: isFirst ? 2.5 : 2),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(athlete['avatar'] as String),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          athlete['name'] as String,
          style: TextStyle(
            fontSize: isFirst ? 13 : 11.5,
            fontWeight: FontWeight.w900,
            color: AppTheme.navyBlue,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${athlete['xp']} XP',
          style: TextStyle(
            fontSize: isFirst ? 12 : 10.5,
            fontWeight: FontWeight.w800,
            color: AppTheme.electricBlue,
          ),
        ),
        const SizedBox(height: 8),

        // Pedestal Column
        Container(
          width: double.infinity,
          height: pedestalHeight,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isFirst ? AppTheme.iceBlue : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFirst ? AppTheme.lightBlue : AppTheme.cardBorderColor,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TOP SPEED',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.slateBlue.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                athlete['speed'] as String,
                style: TextStyle(
                  fontSize: isFirst ? 13 : 11,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.navyBlue,
                ),
              ),
              const SizedBox(height: 4),
              HexgenBadge(
                label: athlete['level'] as String,
                variant: isFirst ? HexgenBadgeVariant.primary : HexgenBadgeVariant.neutral,
                fontSize: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAthleteRow(Map<String, dynamic> athlete) {
    final rank = athlete['rank'] as int;
    final trend = athlete['trend'] as String;
    final trendDiff = athlete['trendDiff'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: HexgenCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank Number + Trend
            SizedBox(
              width: 38,
              child: Column(
                children: [
                  Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        trend == 'up'
                            ? Icons.arrow_drop_up_rounded
                            : (trend == 'down' ? Icons.arrow_drop_down_rounded : Icons.remove_rounded),
                        size: 14,
                        color: trend == 'up'
                            ? const Color(0xFF10B981)
                            : (trend == 'down' ? const Color(0xFFEF4444) : AppTheme.slateBlue),
                      ),
                      if (trend != 'same')
                        Text(
                          trendDiff,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: trend == 'up' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Avatar
            CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(athlete['avatar'] as String),
            ),

            const SizedBox(width: 12),

            // Name & Level
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athlete['name'] as String,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.navyBlue,
                      fontFamily: 'Roboto',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        athlete['handle'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.slateBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.iceBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          athlete['level'] as String,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.electricBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Right
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${athlete['xp']} XP',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.electricBlue,
                  ),
                ),
                Text(
                  athlete['speed'] as String,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.slateBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
