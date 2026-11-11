import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum AnimatedNavBarStyle { fluidPill, simple }

class AnimatedNavBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AnimatedNavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final AnimatedNavBarStyle style;
  final ValueChanged<int> onTap;
  final List<AnimatedNavBarItem> items;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    this.style = AnimatedNavBarStyle.fluidPill,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFD6E4F8), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F2B5C).withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: AppTheme.electricBlue.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.iceBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    border: isSelected
                        ? Border.all(color: AppTheme.lightBlue.withAlpha(120), width: 1)
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isSelected ? 5 : 0),
                        decoration: isSelected
                            ? BoxDecoration(
                                gradient: AppTheme.primaryCtaGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.electricBlue.withAlpha(80),
                                    blurRadius: 6,
                                  ),
                                ],
                              )
                            : null,
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          size: isSelected ? 16 : 22,
                          color: isSelected ? Colors.white : AppTheme.slateBlue,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.navyBlue,
                              letterSpacing: 0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
