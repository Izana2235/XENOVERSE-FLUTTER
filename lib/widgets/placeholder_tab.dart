import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlaceholderTab extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PlaceholderTab({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final mutedColor = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Container(
              decoration: BoxDecoration(
                color: surface.withOpacity(0.5),
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                children: [
                  Text(
                    description,
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Icon(
                    icon,
                    size: 80,
                    color: mutedColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${title.toLowerCase()} list will be displayed here',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
