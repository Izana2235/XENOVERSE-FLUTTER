import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart' as app_state;
import '../theme/app_theme.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<app_state.AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(22),
            child: Text(
              'SETTINGS',
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Settings Content
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
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // System Preferences Section
                  Text(
                    'System Preferences',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Theme Setting
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THEME',
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _ThemeOptionWidget(
                                icon: Icons.brightness_auto,
                                label: 'System',
                                isSelected:
                                    appState.themeMode == app_state.AppThemeMode.system,
                                onTap: () =>
                                    appState.setThemeMode(app_state.AppThemeMode.system),
                                width:
                                    constraints.maxWidth > 500 ? null : double.infinity,
                              ),
                              _ThemeOptionWidget(
                                icon: Icons.light_mode,
                                label: 'Light',
                                isSelected:
                                    appState.themeMode == app_state.AppThemeMode.light,
                                onTap: () =>
                                    appState.setThemeMode(app_state.AppThemeMode.light),
                                width:
                                    constraints.maxWidth > 500 ? null : double.infinity,
                              ),
                              _ThemeOptionWidget(
                                icon: Icons.dark_mode,
                                label: 'Dark',
                                isSelected:
                                    appState.themeMode == app_state.AppThemeMode.dark,
                                onTap: () =>
                                    appState.setThemeMode(app_state.AppThemeMode.dark),
                                width:
                                    constraints.maxWidth > 500 ? null : double.infinity,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _ThemeOptionWidget extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double? width;

  const _ThemeOptionWidget({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.width,
  });

  @override
  State<_ThemeOptionWidget> createState() => _ThemeOptionWidgetState();
}

class _ThemeOptionWidgetState extends State<_ThemeOptionWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.accentDark : AppColors.accentLight;
    const hoverBgLight = Color(0x140000FF); // rgba(37, 99, 235, 0.08);
    final hoverBgDark = const Color(0x1F4F86FF); // rgba(79, 134, 255, 0.12);


    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: widget.width ?? 100,
          decoration: BoxDecoration(
            color: isDark
                ? (_isHovered
                    ? hoverBgDark
                    : Colors.white.withOpacity(0.06))
                : (_isHovered ? hoverBgLight : Colors.black.withOpacity(0.04)),
            border: Border.all(
              color: widget.isSelected
                  ? accentColor
                  : isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radio Button
              SizedBox(
                width: 18,
                height: 18,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: accentColor, width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: widget.isSelected
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              // Icon
              Icon(
                widget.icon,
                size: 24,
                color: widget.isSelected ? accentColor : null,
              ),
              const SizedBox(height: 6),
              // Label
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: widget.isSelected ? accentColor : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
