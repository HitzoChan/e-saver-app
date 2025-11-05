import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/responsive_utils.dart';

class ApplianceCard extends StatelessWidget {
  final String name;
  final String icon;
  final int count;
  final VoidCallback? onTap;

  const ApplianceCard({
    super.key,
    required this.name,
    required this.icon,
    this.count = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: context.responsivePadding(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.responsiveElevation(10),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              icon,
              style: TextStyle(fontSize: context.responsiveIconSize(32)),
            ),
            SizedBox(height: context.responsiveSize(8)),
            Text(
              name,
              style: TextStyle(
                fontSize: context.responsiveFontSize(12),
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            if (count > 0) ...[
              SizedBox(height: context.responsiveSize(4)),
              Container(
                padding: context.responsivePadding(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.responsiveBorderRadius(12)),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(10),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ApplianceListCard extends StatelessWidget {
  final String name;
  final String category;
  final String estimate;
  final String usage;
  final VoidCallback? onTap;

  const ApplianceListCard({
    super.key,
    required this.name,
    required this.category,
    required this.estimate,
    required this.usage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.responsiveSize(12)),
        padding: context.responsivePadding(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: context.responsiveElevation(10),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: context.responsiveSize(50),
              height: context.responsiveSize(50),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(context.responsiveBorderRadius(12)),
              ),
              child: Icon(
                Icons.electrical_services,
                color: AppColors.primaryBlue,
                size: context.responsiveIconSize(24),
              ),
            ),
            SizedBox(width: context.responsiveSize(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(16),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: context.responsiveSize(4)),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(12),
                      color: AppColors.textGray.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  estimate,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: context.responsiveSize(4)),
                Text(
                  usage,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(10),
                    color: AppColors.textGray.withValues(alpha: 0.8),
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
