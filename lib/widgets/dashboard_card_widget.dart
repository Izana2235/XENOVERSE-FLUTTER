import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart' as app_state;

class DashboardCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
    this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Transform.translate(
          offset: _isHovered ? const Offset(0, -10) : Offset.zero,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    _isHovered ? 0.45 : 0.12,
                  ),
                  blurRadius: _isHovered ? 40 : 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 45,
                    ),
                  ],
                ),
                Text(
                  widget.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.read<app_state.AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Padding(
          padding: const EdgeInsets.all(22),
          child: Text(
            'DASHBOARD',
            style: TextStyle(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Cards Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int columns = constraints.maxWidth > 1024
                  ? 4
                  : constraints.maxWidth > 600
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: columns,
                childAspectRatio: 1.1,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  DashboardCard(
                    title: 'PRODUCTS',
                    value: '249',
                    icon: Icons.inventory_2_outlined,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.card1Start,
                        AppColors.card1End,
                      ],
                    ),
                    onTap: () => appState.switchTab('products'),
                  ),
                  DashboardCard(
                    title: 'CATEGORIES',
                    value: '25',
                    icon: Icons.category_outlined,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.card2Start,
                        AppColors.card2End,
                      ],
                    ),
                    onTap: () => appState.switchTab('categories'),
                  ),
                  DashboardCard(
                    title: 'CUSTOMERS',
                    value: '1500',
                    icon: Icons.groups_outlined,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.card3Start,
                        AppColors.card3End,
                      ],
                    ),
                    onTap: () => appState.switchTab('customers'),
                  ),
                  DashboardCard(
                    title: 'INVENTORY WARNING',
                    value: '56',
                    icon: Icons.notification_important_outlined,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.card4Start,
                        AppColors.card4End,
                      ],
                    ),
                    onTap: () => appState.switchTab('inventory'),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
