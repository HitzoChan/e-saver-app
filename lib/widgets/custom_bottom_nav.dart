import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_utils.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.responsiveBorderRadius(20)),
          topRight: Radius.circular(context.responsiveBorderRadius(20)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: context.responsiveElevation(10),
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.responsiveBorderRadius(20)),
          topRight: Radius.circular(context.responsiveBorderRadius(20)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: AppColors.textWhite,
          unselectedItemColor: AppColors.textGray,
          elevation: 0,
          selectedFontSize: context.responsiveFontSize(12),
          unselectedFontSize: context.responsiveFontSize(12),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: context.responsiveIconSize(24)),
              activeIcon: Icon(Icons.home, size: context.responsiveIconSize(24)),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined, size: context.responsiveIconSize(24)),
              activeIcon: Icon(Icons.bar_chart, size: context.responsiveIconSize(24)),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline, size: context.responsiveIconSize(24)),
              activeIcon: Icon(Icons.add_circle, size: context.responsiveIconSize(24)),
              label: 'Add',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: context.responsiveIconSize(24)),
              activeIcon: Icon(Icons.calendar_today, size: context.responsiveIconSize(24)),
              label: 'Planner',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: context.responsiveIconSize(24)),
              activeIcon: Icon(Icons.person, size: context.responsiveIconSize(24)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
